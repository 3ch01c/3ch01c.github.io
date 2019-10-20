# How to set up Git
## Clone a repository
Clone a repository.
``` sh
GIT_REPO_URL=https://github.com/3ch01c/3ch01c.github.io
git clone $GIT_REPO_URL
```
Change to the repository directory
```
GIT_REPO_PATH=
```
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
GPG_PROGRAM=gpg
GIT_SIGNING_KEY=$($GPG_PROGRAM --list-keys --with-colons $GIT_EMAIL | awk -F: '/^pub:/ { print $5 }')
git config user.signingkey $GIT_SIGNING_KEY
```
## Troubleshooting
### `error: gpg failed to sign the data`
Ensure the signing key was configured correctly.
```
git config --get user.signingkey
```
If that doesn't work, configure TTY.
```
export GPG_TTY=$(tty)
```
If that doesn't work, configure Git to use the correct GPG program.
```
git config gpg.program $GPG_PROGRAM
```
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEyNTg5ODQ4MzQsLTE1OTM0ODc1OCwtMT
g0Mzk4ODY5MCwxMzc2NzYxNjAxXX0=
-->