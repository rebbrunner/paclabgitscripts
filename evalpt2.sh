#!/bin/sh

url=$1
# Format 'Mon DD YYYY' space delimited %b %d %Y
startday="Jun 14 2020"
startfolder=$(pwd)
repo_install_path="/bin/filter-repo"
zpool="zfs"

export PATH="$PATH:${repo_install_path}"

now=$(date +"%b %d %Y")
name=$(echo "$url" | md5sum | cut -d" " -f1)

# Naive Approach
if [ "$startday" = "$now" ]; then
    mkdir "${name}"
fi
cd "$name"
git clone "$url" "$now"

# Filter clone
cd "$now"

# Count number of commits
commits=$(git rev-list --count HEAD --since="${startday}")
if [ "$commits" = "" ] 
then
	commits=0
fi

git filter-repo --path-regex '^.*.java$' --force
git remote add origin "$url"

# Get stats
size=$(du -sb | cut -f 1)
cd ../../
echo "${url},${commits},${size}" >> naive.csv

# Our Approach
if [ "$startday" = "$now" ]
then
    zfs create "${zpool}/${name}"
    cd "/${zpool}/${name}"
    git clone "$url" .
else
    cd "/${zpool}/${name}"
    branch=$(git branch | grep '*' | cut -d" " -f2)
    git pull -X theirs --allow-unrelated-histories origin "$branch"
fi

# Look for dangling objects
branch=$(git branch | grep '*' | cut -d" " -f2)
dangling=$(git fsck --full "origin/${branch}")

commits=$(git rev-list --count HEAD --since="${startday}")
if [ "$commits" = "" ]
then
	commits=0
fi

# Filter project
git filter-repo --path-regex '^.*/*.java$' --force
git remote add origin "$url"

# Unpack objects
cd .git
mv objects/pack pack
pack=$(ls pack | grep '.pack')
git unpack-objects < pack/"$pack"
cd ../

# Snapshot
zfs snapshot -r "${zpool}/${name}@${now}"

# Get size
size=$(du -sb | cut -f 1)

# start location
cd "$startfolder"

# Determine boolean value for force pushes
if [ "$dangling" = "" ]; then
    force_pushes=0
else
    force_pushes=1
fi

echo "${url},${commits},${size},${force_pushes}" >> efficient.csv

