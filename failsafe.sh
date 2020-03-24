#!/usr/bin/env bash

remote=$(git remote) && url=$(git remote get-url --push $remote)
rm -rf *
rm -rf .git
source ../create.sh "$url"
