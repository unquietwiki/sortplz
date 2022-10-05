#[
sortplz: sort files into subdirectories, based on given criteria.
Michael Adams, unquietwiki.com, 2022-10-03
]#

# Libraries
import std/[os, parseopt, sequtils, terminal]

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
  silent: bool = false

# Function to process & sort directory
proc processDir(ext: string) =

  if not silent:
    stdout.styledWriteLine(fgCyan, "Processing extension: ", ext)

  # Does the source directory exist?
  if not os.dirExists(fromdir):
    stdout.styledWriteLine(fgRed, "Failed to find source directory: ", ext)
    quit(1)

  # Does the destination directory exist?
  var newdir: string = os.joinPath(todir, ext)
  if not silent:
    stdout.styledWriteLine(fgYellow, "Creating directory: ", newdir)
  os.createDir(newdir)

  # Process the list of files in the source directory
  var searchpath = os.joinPath(fromdir,"*." & ext)
  if not silent:
    stdout.styledWriteLine(fgCyan, "Moving files: ", searchpath, " to ", newdir)
  for f in toSeq(os.walkFiles(searchpath)):
    if not silent:
      stdout.styledWriteLine(fgGreen, "Moving file: ", os.lastPathPart(f))    
    os.moveFile(f, newdir & os.DirSep & os.lastPathPart(f))

# Functions to display command line information
proc writeVersion() =
  stdout.styledWriteLine(fg8Bit, "==============================================================")
  stdout.styledWriteLine(fgBlue, name, " ", version)
  stdout.styledWriteLine(fgMagenta, description)
  stdout.styledWriteLine(fgCyan, "Maintainer(s): ", author)
  stdout.styledWriteLine(fg8Bit, "==============================================================")

proc writeHelp() =
  writeVersion()
  stdout.styledWriteLine(fgGreen, "Usage: sortplz -f:[fromdir] -t:[todir] -e:[ext]")
  stdout.styledWriteLine(fgYellow, "Other flags: --help (-h), --version (-v), --silent (-s)")
  stdout.styledWriteLine(fg8Bit, "==============================================================")

#stdout.styledWriteLine(fgYellow, )

# Parse command line
for kind, key, val in getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "ext", "e":
      if not silent:
        stdout.styledWriteLine(fgBlue, "Loading extension: ", val)
        exts.add(val)
    of "fromdir", "f":
      if val.len > 0: fromdir = val
      if not silent:
        stdout.styledWriteLine(fgCyan, "Source directory: ", fromdir)
    of "todir", "t":
      if val.len > 0: todir = val
      if not silent:
        stdout.styledWriteLine(fgYellow, "Destination directory: ", todir)
    of "silent", "s":
      silent = true
    of "help", "h":
      writeHelp()
      quit(0)
    of "version", "v":
      writeVersion()
      quit(0)
  of cmdArgument:
    # TODO: there should be a list of extensions, vs -e
    discard
  of cmdEnd:
    quit(0)

# Act on provided extensions
if exts.len < 1:  
  stdout.styledWriteLine(fgRed, "No extensions provided!")
  writeHelp()
  quit(0)
else:
  for e in exts:
    processDir(e)
