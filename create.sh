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
