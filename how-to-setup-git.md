# How to set up Git

## Add user identity
Add name and email.
``` sh
GIT_NAME="Hiro Protagonist"
GIT_EMAIL="me@users.noreply.github.com"
git config user.name $GIT_NAME
git config user.email $GIT_EMAIL
```
## Add GPG signing

Configure Git to use GPG signing.
``` sh
git config --global commit.gpgsign true
```
Change to the Git repository path.
```
GIT_REPO_PATH=$HOME/projects/myproject
cd $GIT_REPO_PATH
```
Get the signing key fingerprint and configure the repository.
``` sh
GIT_SIGNING_KEY=$(gpg --list-keys --with-colons $GIT_EMAIL | awk -F: '/^pub:/ { print $5 }')
git config user.signingkey $SIGNING_KEY
```
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTg0MDI4NDI5OV19
-->