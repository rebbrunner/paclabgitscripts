#!/bin/sh

# Collects data every snapshot - might be overkill.  Justfication - naive approach is a collection of folders for each snapshot, our approach is one file.  If we wait until the end, in order to detect force pushes we will have to test every snapshot against every different folder in the naive approach, which means matching dates with snapshot names.

url=$1
# Format 'MON DAY YEAR' space delimited
startday=$2
startfolder=$3
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

# Unpack objects if packed
cd "${now}/.git"
mv objects/pack pack
pack=$(ls pack | grep '.pack')
git unpack-objects < pack/"$pack"
cd ../

# Get stats
size=$(du -sb | cut -f 1)
commits=$(git rev-list --count HEAD --since="${startday}")
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
dangling=$(git fsck --full)

# Filter project
remote=$(git remote) && url=$(git remote get-url --push $remote)
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
# start location
cd "$startfolder"

# Determine boolean value for force pushes
if [ "$dangling" = "" ]; then
    force_pushes=0
else
    force_pushes=1
fi

echo "${url},${commits},${size},${force_pushes}" >> efficient.csv

