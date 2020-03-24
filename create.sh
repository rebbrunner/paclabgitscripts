#!/usr/bin/env bash

# This script takes a git url.  The URL is used to clone to the current directory.

url="$1"

# Enable sparse checkout
git init
git config --local core.sparseCheckout true
echo "**/*.java" > .git/info/sparse-checkout

# Get objects
git remote add origin "$url"
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
