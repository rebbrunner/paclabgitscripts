#!/bin/bash

zfs_fs="zfs/comp"
repo_install_path="/bin/filter-repo"
export PATH="$PATH:${repo_install_path}"

url=$1
name=$(echo "$url" | md5sum | cut -d" " -f1)

git clone "$url" "$name"
cd "$name"
size=$(du -sb | cut -f 1)
cd ../
echo "${url},${size}" >> control.csv

git clone --depth=1 "$url" "${name}_shallow"
cd "${name}_shallow"
size=$(du -sb | cut -f 1)
cd ../
echo "${url},${size}" >> shallow.csv

cd "${name}_shallow"
git filter-repo --path-regex '^.*/*.java$'
git remote add origin "$url"
size=$(du -sb | cut -f 1)
cd ../
echo "${url},${size}" >> filtered.csv

zfs create "${zfs_fs}/${name}"
mv "${name}_shallow" "/${zfs_fs}/${name}/"

