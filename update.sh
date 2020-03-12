dir="$1"

cd "$dir"
git pull -X theirs --allow-unrelated-histories --depth=1
remote=$(git remote) && url=$(git remote get-url --push $remote)
git filter-repo --invert-paths --path-match data/
git filter-repo --invert-paths --path-match output/
git remote add origin "$url"
