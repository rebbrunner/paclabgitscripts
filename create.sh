# This script takes a series of arguements including a git url, folder path, and folder name.  The URL is used to clone to the folder 
# path and folder directory and then the resulting repository is filtered using filter-repo.

while test $# -gt 0
do
    URL="$1"
    CLONE_PATH="$2"
    FOLDER_NAME="$3"
    echo "$FOLDER_NAME"
    cd "$CLONE_PATH"
    git clone "$URL" "$FOLDER_NAME"
    cd "$FOLDER_NAME"
    remote=$(git remote) && url=$(git remote get-url --push $remote)
    git filter-repo --invert-paths --path-match data/
    git filter-repo --invert-paths --path-match output/
    git remote add origin "$url"
    shift
    shift
    shift
done
