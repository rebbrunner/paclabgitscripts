# This script is a WIP that accepts a directory as input and resets the working tree back to head.  It is meant as a failsafe in case 
# the working tree becomes corrupted.  This will not resolve issues if something happens to the .git folder itself, it will only 
# resolve issues with the working tree.  Further development is needed to determine the best strategy for recovering from a corrupted 
# .git folder.  Two possible solutions include recloning a project, or recovering from a previous snapshot and attempting to fetch objects 
# again.
# This script takes a git url, zpool name, and project name.  The URL is used to clone to the current directory.

zpool="$2"
project_name="$3"

# Recover to HEAD
git reset --hard HEAD

# Get objects
git fetch --depth=1

# Filter out unwanted objects
remote=$(git remote) && url=$(git remote get-url --push $remote)
git filter-repo --path-regex '^.*/*.java$'
git remote add origin "$url"

# Unpack objects
cd .git
mv objects/pack pack
pack=$(ls pack | grep '.pack')
git unpack-objects < pack/"$pack"
rm -rf pack
cd ../

# Checkout working tree
git checkout master

# Snapshot
#timestamp=$(date +"%T")
#zfs snapshot "$zpool"/"$project_name"@"$timestamp"
