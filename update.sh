# This script accepts a directory containing a git project and updates it.  It creates a shallow update and assumes in 
# the case of merge conflicts to simply accept all incoming changes.  We also allow unrelated histories since using shallow clones 
# and pulls creates divergent histories.  Filter repo is used to filter out unwanted files.  These lines can be altered for production 
# the commands here were for testing.  The lines above and below work to conserve the remote which is stripped from the repository's 
# references during cleaning.

dir="$1"

cd "$dir"
git pull -X theirs --allow-unrelated-histories --depth=1
remote=$(git remote) && url=$(git remote get-url --push $remote)
git filter-repo --invert-paths --path-match data/
git filter-repo --invert-paths --path-match output/
git remote add origin "$url"
