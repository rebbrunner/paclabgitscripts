# Create and Update Scripts

Author: Rebecca Brunner
<br>
Date: 12 March 2020

## Description

    create.sh   -> Clone a repository, enable sparse checkouts, filter unwanted files, unpack objects, snapshot folder
    update.sh   -> Perform a shallow pull and resolve possible conflicts
    failsafe.sh -> Recover from corrupted repository state

## Requirements

- Git
- Filter-Repo installed to path
- Python
- OpenZFS for snapshots

## Usage

- Run create script: `./create.sh GIT_URL ZPOOL_NAME PROJECT_NAME`
- Run update script: `./update.sh ZPOOL_NAME PROJECT_NAME`
- Run failsafe script: `./failsafe.sh ZPOOL_NAME PROJECT_NAME`
