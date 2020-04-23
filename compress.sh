#!/bin/bash

zfs_fs="zfs/comp"
url="$1"
name=$(echo "$url" | md5sum | cut -f1 -d" ")
ratio=$(zfs get compressratio "${zfs_fs}/${name}" | grep "${zfs_fs}/${name}" | cut -f1,5 -d" ")
zfs destroy "${zfs_fs}/${name}"
echo "${url},${ratio}" >> compression.csv

