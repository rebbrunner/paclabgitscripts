#!/bin/sh

url=$1
# Format 'Mon DD YYYY' space delimited %b %d %Y
startday="Jun 15 2020"
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
git filter-repo --path-regex '^.*.java$' --force
git remote add origin "$url"

# Get stats
size=$(du -sb | cut -f 1)
commits=$(git rev-list --count HEAD --since="${startday}")
if [ "$commits" = "" ] 
then
	commits=0
fi
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
    git pull -X theirs --allow-unrelated-histories
fi

# Look for dangling objects
branch=$(git branch | grep '*' | cut -d" " -f2)
dangling=$(git fsck --full "origin/${branch}")

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

# Get stats
size=$(du -sb | cut -f 1)
commits=$(git rev-list --count HEAD --since="${startday}")
if [ "$commits" = "" ]
then
	commits=0
fi
# start location
cd "$startfolder"

# Determine boolean value for force pushes
if [ "$dangling" = "" ]; then
    force_pushes=0
else
    force_pushes=1
fi

echo "${url},${commits},${size},${force_pushes}" >> efficient.csv

