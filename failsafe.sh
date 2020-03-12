# This script is a WIP that accepts a directory as input and resets the working tree back to head.  It is meant as a failsafe in case 
# the working tree becomes corrupted.  This will not resolve issues if something happens to the .git folder itself, it will only 
# resolve issues with the working tree.  Further development is needed to determine the best strategy for recovering from a corrupted 
# .git folder.  Two possible solutions include recloning a project, or recovering from a previous snapshot and attempting to fetch objects 
# again.

DIR="$1"

cd "$DIR"
git reset --hard HEAD
