#[
sortplz: sort files into subdirectories, based on given criteria.
Michael Adams, unquietwiki.com, 2022-10-03
]#

# Libraries
import
  std/os,
  std/parseopt,
  std/sequtils

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

  echo "Processing extension: ", ext

  # Does the source directory exist?
  if not os.dirExists(fromdir):
    quit(1)

  # Does the destination directory exist?
  var newdir: string = os.joinPath(todir, ext)
  echo "Creating directory: ", newdir
  os.createDir(newdir)

  # Process the list of files in the source directory
  var searchpath = os.joinPath(fromdir,"*." & ext)
  echo "Moving files: ", searchpath, " to ", newdir
  for f in toSeq(os.walkFiles(searchpath)):
    echo "Moving file: ", os.lastPathPart(f)
    os.moveFile(f, newdir & os.DirSep & os.lastPathPart(f))

# Functions to display command line information
proc writeVersion() =
  echo name, " ", version
  echo description
  echo "Maintainer(s): ", author

proc writeHelp() =
  writeVersion()
  echo "Usage: sortplz -f [fromdir] -t [todir] -e [ext]"

# Parse command line
for kind, key, val in getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "ext", "e":
      echo "Loading extension: ", val
      exts.add(val)
    of "fromdir", "f":
      if val.len > 0: fromdir = val
      echo "Source directory: ", fromdir
    of "todir", "t":
      if val.len > 0: todir = val
      echo "Destination directory: ", todir
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
  echo "No extensions provided!"
  writeHelp()
  quit(0)
else:
  for e in exts:
   processDir(e)
