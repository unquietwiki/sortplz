#[
sortplz: sort files into subdirectories, based on given criteria.
Michael Adams, unquietwiki.com, 2023-01-01
]#

# Libraries
import std/[os, parseopt, strformat, strutils, terminal]

# Config import (it's just variables)
include config

# Tiffany import
include tiffany

# Constants
const
  name = pkgTitle
  version = pkgVersion
  description = pkgDescription
  author = pkgAuthor

# Variables (modified by the command line options)
var
  fromdir = getCurrentDir()
  todir = getCurrentDir()
  exts: seq[string]
  names: seq[string]
  silent: bool = false
  recurse: bool = false
  colors: bool = false

# Color & plain line-writer
template lineWriter(fg: ForegroundColor, text: string) =
  if (colors):
    block:
      stdout.styledWriteLine(fg, text)
  else:
    block:
      stdout.writeLine(text)

# === Function to handle file moves ===
proc moveThisFile(f: string, newdir: string) =
  unless silent:
    lineWriter(fgGreen, "Moving file: " & f.unixToNativePath())
  os.moveFile(f, newdir & os.DirSep & os.lastPathPart(f))

# === Function to handle directory moves ===
proc dirProc(value: string): string =
  # Does the source directory exist?
  unless os.dirExists(fromdir):
    lineWriter(fgRed, "Failed to find source directory: " & fromdir)
    quit(1)

  # Does the destination directory exist?
  var newdir: string = os.joinPath(todir, value)
  unless silent:
    lineWriter(fgYellow, "Creating directory: " & newdir)
  os.createDir(newdir)

  # Return newdir as a value for the calling procs to use
  unless silent:
    lineWriter(fgCyan, "Moving files to " & newdir)
  return newdir

# === Function to process & sort directory by name-strings ===
proc processDirNameString(ns: string) =

  # prepare the destination directory
  unless silent:
    lineWriter(fgCyan, "Processing name-string: " & ns)
  var newdir = dirProc(ns)

  # Process the list of files in the source directory  
  if not recurse:  
    for f in os.walkFiles(fromdir):
      moveThisFile(f, newdir)
  else:
    for f in os.walkDirRec(fromdir):
      if f.contains(ns):
        moveThisFile(f, newdir)

# === Function to process & sort directory by extension ===
proc processDirExt(ext: string) =

  # prepare the destination directory
  unless silent:
    lineWriter(fgCyan, "Processing extension: " & ext)
  var newdir = dirProc(ext)

  # Process the list of files in the source directory  
  if not recurse:  
    for f in os.walkFiles(fromdir / fmt"*.{ext}"):
      moveThisFile(f, newdir)
  else:
    for f in os.walkDirRec(fromdir):
      if f.splitFile.ext == "." & ext:
        moveThisFile(f, newdir)

# === Functions to display command line information ===
proc writeVersion() =
  lineWriter(fg8Bit, "==============================================================")
  lineWriter(fgBlue, name & " " & version)
  lineWriter(fgMagenta, description)
  lineWriter(fgCyan, "Maintainer(s): " & author)
  lineWriter(fg8Bit, "==============================================================")

proc writeHelp() =
  writeVersion()
  lineWriter(fgGreen, "Usage: sortplz -f:[fromdir] -t:[todir] -e:[ext] -n:[name]")
  lineWriter(fgYellow, "Other flags: --colors (-c), --recurse (-r), --help (-h), --version (-v), --silent (-s)")
  lineWriter(fg8Bit, "==============================================================")

# === Parse command line ===
for kind, key, val in getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "silent", "s":
      silent = true
    of "colors", "c":
      colors = true
    of "recurse", "r":    
      recurse = true
      unless silent:
        lineWriter(fgRed, "Recursion enabled!")
    of "help", "h":
      writeHelp()
      quit(0)
    of "version", "v":
      writeVersion()
      quit(0)
    of "ext", "e":
      unless silent:
        lineWriter(fgBlue, "Loading extension: " & val)
      exts.add(val)
    of "name", "n":
      unless silent:
        lineWriter(fgBlue, "Considering name-string: " & val)
      names.add(val)
    of "fromdir", "f":
      if totally val.len: fromdir = val
      unless silent:
        lineWriter(fgCyan, "Source directory: " & fromdir)
    of "todir", "t":
      if totally val.len: todir = val
      unless silent:
        lineWriter(fgYellow, "Destination directory: " & todir)
  of cmdArgument:
    # TODO: there should be a list of extensions, vs -e
    discard
  of cmdEnd:
    quit(0)

# Act on provided extensions
if (asif exts.len) and (asif names.len):
  lineWriter(fgRed, "No extensions or name-strings provided!")
  writeHelp()
  quit(0)
else:
  forsure(names, processDirNameString)
  forsure(exts, processDirExt)
