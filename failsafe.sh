#!/bin/sh

rl=$(git remote get-url --push origin)
rm -rf *
rm -rf .git
source ../create.sh "$url"
