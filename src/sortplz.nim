#[
sortplz: sort files into subdirectories, based on given criteria.
Michael Adams, unquietwiki.com, 2022-10-03
]#

# Libraries
import
  std/os,
  std/parseopt,
  std/strutils

# Config import
include
  config

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

# Function to process & sort directory
proc processDir(ext: string) =

  # Temporary variables
  var newdir: string = ""

  # Does the source directory exist?
  if os.dirExists(fromdir) == false:
    quit(1)

  # Does the destination directory exist?
  if os.dirExists(todir) == false:
    newdir = os.joinPath(todir, ext)
    os.createDir(newdir)

  # Process the list of files in the source directory
  for kind, path in walkDir(fromdir, relative = false, checkDir = false):
    if kind == pcFile:
      if path.endsWith(ext):
        os.moveFile(path, newdir)

# Functions to display command line information
proc writeVersion() =
  echo name, " ", version
  echo description

proc writeHelp() =
  writeVersion()
  echo "Usage: sortplz -f [fromdir] -t [todir] [ext] ..."

# Parse command line
var p = initOptParser(@["--fromdir:string","-f:string","--todir:string","-t:string","--help","-h","--version","-v"],
  shortNoVal = {'h','v'}, longNoVal = @["help","version"])

for kind, key, val in p.getopt():
  case kind
  of cmdArgument:
    echo "Loading extension: ", val
    exts.add(val)
  of cmdLongOption, cmdShortOption:
    case key
    of "fromdir", "f":
      if val != "": fromdir = val
      break
    of "todir", "t":
      if val != "": todir = val
      break
    of "help", "h":
      writeHelp()
      quit(0)
    of "version", "v":
      writeVersion()
      quit(0)
  of cmdEnd: quit(0)
  
# debug
echo "DEBUG:", p.remainingArgs()
echo "DEBUG:", exts

# Act on provided extensions
if exts.len < 1:
  echo "No extensions provided!"
  writeHelp()
  quit(0)
else:
  for e in exts:
   processDir(e)
