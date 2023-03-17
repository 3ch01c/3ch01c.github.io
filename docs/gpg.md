# GPG

## Generate a key

Follow the prompts after running the following command.

```sh
gpg --full-gen-key
```

## Export a key

Useful if you want to copy a key to another server.

```sh
gpg --export-secret-key -a -o example.pgp me@example.com
```

## Import a key

```sh
gpg -i example.pgp
```

## Revoke a key

Find the ID of the key you want to revoke (e.g., `21D5D74C`) and create a revocation certificate.

```sh
KEY_ID="21D5D74C"
REVOCATION_CERTIFICATE="$KEY_ID.asc"
gpg --output $REVOCATION_CERTIFICATE --gen-revoke $KEY_ID
```

Import the revocation certificate into your GPG client.

```sh
gpg --import $REVOCATION_CERTIFICATE
```

View the revocation was applied.

```sh
gpg -k $KEY_ID
```

Push revocation to key servers.

```sh
gpg --send-keys KEY_ID
```

## Create a GPG container

```sh
docker run -it --rm -v ${PWD}/example.pgp:/example.pgp alpine
apk add gnupg
gpg
```
