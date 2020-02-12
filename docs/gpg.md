# GPG

## Generate a key

Follow the prompts after running the following command.

```sh
gpg --full-gen-key
```

## Revoking a key

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