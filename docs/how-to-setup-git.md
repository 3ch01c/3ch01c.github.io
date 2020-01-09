# How to set up Git

## Clone it

Clone with HTTPS.

```sh
GIT_USER="3ch01c"
GIT_REPO_NAME="3ch01c.github.io"
GIT_REPO_https://github.com/$GIT_USEGIT_REPO_NAME.git"  # https://github.com/3ch01c/3ch01c.github.io.git
git clone $GIT_REPO_URL
```

Or clone with SSH.

```sh
GIT_USER="3ch01c"
GIT_REPO_NAME="3ch01c.github.io"
SSH_USER="git@github.com"
GIT_REPO_URL="$SSH_USER:$GIT_USER/$GIT_REPO_NAME.git"  # git@github.com:3ch01c/3ch01c.github.io.git
git clone $GIT_REPO_URL
```

## Identify yourself

Add user name/email to the current project.

```sh
GIT_USER_NAME="Jack Miner"
GIT_USER_EMAIL="5547581+3ch01c@users.noreply.github.com"
git config user.name $GIT_USER_NAME
git config user.email $GIT_USER_EMAIL
```

## Sign your commits <a name="#gpg"></a>

Use GPG signing globally.

```sh
git config --global commit.gpgsign true
export
```

Assign a GPG key for signing commits.

```sh
GIT_SIGNING_KEY=$($GPG_PROGRAM --list-keys --with-colons $GIT_USER_EMAIL  | awk -F: '/^pub:/ { print $5 }')
git config user.signingkey $GIT_SIGNING_KEY
```

## Save your Git credentials

_[Thanks Jay Patel!](https://stackoverflow.com/a/28562712/4068278)_
Enable [credential caching](https://help.github.com/articles/caching-your-github-password-in-git/#platform-linux).

```sh
git config --global credential.helper store
```

Specify cache expiration.

```sh
git config --global credential.helper 'cache --timeout 7200'
```

## Troubleshooting

### `error: gpg failed to sign the data`

Ensure the signing key was configured correctly.

```sh
git config --get user.signingkey
```

If the key looks bad, refer to [how to sign your commits](#gpg). If the key looks good, set `GPG_TTY`.

```sh
export GPG_TTY=$(tty)
```

If that osn or coiguignour it se the correct GPG program. Maybe it's `gpg` or maybe it's `gpg2` or maybe it's something else.

```sh
GPG_PROGRAM="gpg"
git config --global gpg.program $GPG_PROGRAM
```
