#!/bin/sh

url=$1
# Format 'MON DAY YEAR' space delimited
startday=$2
repo_install_path="/bin/filter-repo"

export PATH="$PATH:${repo_install_path}"

now=$(date | cut -d" " -f2,3,4 | tr -d '[:space:]' | tr -d ',')
name=$(echo "$url" | md5sum | cut -d" " -f1)

# Naive Approach
name_snapshot="${name}${now}"
git clone "$url" "$name_snapshot"

# Unpack objects if packed
cd "$name_snapshot"/.git
mv objects/pack pack
pack=$(ls pack | grep '.pack')
git unpack-objects < pack/"$pack"
cd ../../

# Get stats
size=$(du -sb | cut -f 1)
now=$(date | cut -d" " -f2,3,4 | tr -d ',')
commits=$(git rev-list --count HEAD --since="${startday}")
echo "${url},${commits},${size}" >> naive.csv

# Our Approach
if [ "$startday" = "$now" ]
then
    git clone "$url" "$name"
    cd "$name"
else
    echo "false"
    cd "$name"
    git pull -X theirs --allow-unrelated-histories
fi

# Unpack objects if packed
cd .git
mv objects/pack pack
pack=$(ls pack | grep '.pack')
git unpack-objects < pack/"$pack"
cd ../

# Compare with Naive for Dangling Objects
force_pushes=$(diff -r .git/objects ../$name_snapshot/.git/objects)

# Filter project
remote=$(git remote) && url=$(git remote get-url --push $remote)
git filter-repo --path-regex '^.*/*.java$' --force
git remote add origin "$url"

# Get stats
size=$(du -sb | cut -f 1)
commits=$(git rev-list --count HEAD --since="${startday}")
cd ../

# Determine boolean value for force pushes
if [ "$force_pushes" = "" ]; then
    force_pushes=0
else
    force_pushes=1
fi

echo "${url},${commits},${size},${force_pushes}" >> efficient.csv

