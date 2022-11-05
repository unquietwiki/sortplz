#[
sortplz: sort files into subdirectories, based on given criteria.
Michael Adams, unquietwiki.com, 2022-11-04
]#

# Libraries
import std/[os, parseopt, sequtils, strutils, terminal]

# Config import (it's just variables)
include config

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

# === Function to handle file moves ===
proc moveThisFile(f: string, newdir: string) =
  if not silent:
    stdout.styledWriteLine(fgGreen, "Moving file: ", f.unixToNativePath())
  os.moveFile(f, newdir & os.DirSep & os.lastPathPart(f))

# === Function to handle directory moves ===
proc dirProc(value: string): string =
  # Does the source directory exist?
  if not os.dirExists(fromdir):
    stdout.styledWriteLine(fgRed, "Failed to find source directory: ", fromdir)
    quit(1)

  # Does the destination directory exist?
  var newdir: string = os.joinPath(todir, value)
  if not silent:
    stdout.styledWriteLine(fgYellow, "Creating directory: ", newdir)
  os.createDir(newdir)

  # Return newdir as a value for the calling procs to use
  if not silent:
    stdout.styledWriteLine(fgCyan, "Moving files to ", newdir)
  return newdir

# === Function to process & sort directory by name-strings ===
proc processDirNameString(ns: string) =

  # prepare the destination directory
  if not silent:
    stdout.styledWriteLine(fgCyan, "Processing name-string: ", ns)
  var newdir = dirProc(ns)

  # Process the list of files in the source directory  
  if not recurse:  
    for f in toSeq(os.walkFiles(os.joinPath(fromdir))):
      moveThisFile(f, newdir)
  else:
    for f in toSeq(os.walkDirRec(os.joinPath(fromdir))):
      if f.contains(ns):
        moveThisFile(f, newdir)

# === Function to process & sort directory by extension ===
proc processDirExt(ext: string) =

  # prepare the destination directory
  if not silent:
    stdout.styledWriteLine(fgCyan, "Processing extension: ", ext)
  var newdir = dirProc(ext)

  # Process the list of files in the source directory  
  if not recurse:  
    for f in toSeq(os.walkFiles(os.joinPath(fromdir,"*." & ext))):
      moveThisFile(f, newdir)
  else:
    for f in toSeq(os.walkDirRec(os.joinPath(fromdir))):
      if f.splitFile.ext == "." & ext:
        moveThisFile(f, newdir)

# === Functions to display command line information ===
proc writeVersion() =
  stdout.styledWriteLine(fg8Bit, "==============================================================")
  stdout.styledWriteLine(fgBlue, name, " ", version)
  stdout.styledWriteLine(fgMagenta, description)
  stdout.styledWriteLine(fgCyan, "Maintainer(s): ", author)
  stdout.styledWriteLine(fg8Bit, "==============================================================")

proc writeHelp() =
  writeVersion()
  stdout.styledWriteLine(fgGreen, "Usage: sortplz -f:[fromdir] -t:[todir] -e:[ext] -n:[name]")
  stdout.styledWriteLine(fgYellow, "Other flags: --recurse (-r) --help (-h), --version (-v), --silent (-s)")
  stdout.styledWriteLine(fg8Bit, "==============================================================")

# === Parse command line ===
for kind, key, val in getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "silent", "s":
      silent = true
    of "recurse", "r":    
      recurse = true
      stdout.styledWriteLine(fgRed, "Recursion enabled!")
    of "help", "h":
      writeHelp()
      quit(0)
    of "version", "v":
      writeVersion()
      quit(0)
    of "ext", "e":
      if not silent:
        stdout.styledWriteLine(fgBlue, "Loading extension: ", val)
        exts.add(val)
    of "name", "n":
      if not silent:
        stdout.styledWriteLine(fgBlue, "Considering name-string: ", val)
        names.add(val)
    of "fromdir", "f":
      if val.len > 0: fromdir = val
      if not silent:
        stdout.styledWriteLine(fgCyan, "Source directory: ", fromdir)
    of "todir", "t":
      if val.len > 0: todir = val
      if not silent:
        stdout.styledWriteLine(fgYellow, "Destination directory: ", todir)
  of cmdArgument:
    # TODO: there should be a list of extensions, vs -e
    discard
  of cmdEnd:
    quit(0)

# Act on provided extensions
if exts.len < 1 and names.len < 1:
  stdout.styledWriteLine(fgRed, "No extensions or name-strings provided!")
  writeHelp()
  quit(0)
else:
  for n in names:
    processDirNameString(n)
  for e in exts:
    processDirExt(e)
