# Create and Update Scripts

Author: Rebecca Brunner
<br>
Date: 12 March 2020

## Description

Create script for cloning and filtering a list of git projects.<br>
Update script for looping through a directory pulling updates

## Requirements

- Git
- Filter-Repo installed to path
- Python
- OpenZFS for snapshots

## Usage

- Run create script: `./create.sh GIT_URL ZPOOL_NAME PROJECT_NAME`
- Run update script: `./update.sh ZPOOL_NAME PROJECT_NAME`
- Run failsafe script: `./failsafe.sh ZPOOL_NAME PROJECT_NAME`
