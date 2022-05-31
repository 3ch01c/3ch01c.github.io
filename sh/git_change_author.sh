#!/bin/sh
# Renames an author across history
# From https://stackoverflow.com/a/30737248

git filter-branch --env-filter '

OLD_EMAIL=$1 # "your-old-email@example.com"
CORRECT_NAME=$2 # "Your Correct Name"
CORRECT_EMAIL=$3 # "your-correct-email@example.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
