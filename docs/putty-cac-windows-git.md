# Using PuTTY-CAC with Git on Windows

This guide explains how to use **PuTTY-CAC / Plink** as the SSH client for **Git for Windows**, including PIV-backed authentication.

The working architecture is:

```text
Git for Windows
    |
    v
plink.exe
    |
    v
PuTTY-CAC saved session
    |
    v
Windows CAPI / PIV middleware
    |
    v
PIV card
    |
    v
Git server over SSH
```

This setup works well when the SSH private key is stored on a PIV card and cannot be exported as a normal private-key file.

---

## Prerequisites

You need:

- Git for Windows
- PuTTY-CAC
- A working PIV card and smart-card reader
- Windows PIV middleware or minidriver
- An SSH public key registered with the Git server
- Permission to use the PIV certificate for SSH authentication

Verify that Windows can see the PIV:

```powershell
certutil -scinfo
```

---

# 1. Configure PuTTY-CAC

Open the PuTTY-CAC version of `putty.exe`.

For each Git server, create a saved PuTTY session.

For example:

```text
Saved session name: git.example.com
Host Name:          git.example.com
Port:               22
Connection type:    SSH
```

Use the hostname itself as the saved session name.

Do **not** use:

```text
git@git.example.com
```

as the saved-session name.

Using only the hostname allows Git to pass the normal SSH destination to Plink and lets Plink automatically load the corresponding saved session.

## Configure the SSH username

Under:

```text
Connection -> Data
```

set:

```text
Auto-login username: git
```

GitLab and many other Git servers use the SSH username:

```text
git
```

The actual user account is determined from the SSH public key.

## Configure the PIV certificate

In PuTTY-CAC, select the appropriate PIV certificate under the CAPI/certificate configuration.

The exact menu varies by PuTTY-CAC version, but it is usually under something similar to:

```text
Connection -> SSH -> Certificate
```

or:

```text
Connection -> SSH -> CAPI
```

Select the PIV certificate containing the key you intend to use for SSH authentication.

After selecting the certificate:

1. Return to **Session**.
2. Select the saved session.
3. Click **Save** again.

If you do not save the session after selecting the certificate, the PIV configuration may not persist.

---

# 2. Register the SSH Public Key

The Git server must know the SSH public key corresponding to the PIV private key.

For GitLab, add the SSH-format public key to:

```text
User Settings -> SSH Keys
```

The key should look similar to:

```text
ssh-rsa AAAAB3...
```

or:

```text
ecdsa-sha2-nistp256 AAAA...
```

If GitLab supports key usage types, select:

```text
Authentication
```

or:

```text
Authentication & Signing
```

if the same key will also be used for commit signing.

Browser PIV authentication and SSH authentication are separate. Logging into GitLab with the PIV in a browser does not automatically register the PIV-derived SSH key.

---

# 3. Test PuTTY-CAC Directly

Before configuring Git, verify that Plink can authenticate.

Run:

```powershell
plink.exe -v git.example.com
```

A successful connection should include output similar to:

```text
Reading key file "CAPI:..."
Using username "git".
Offered public key
Offer of public key accepted
Authenticating with public key "CAPI:..."
Sent public key signature
Access granted
Welcome to GitLab, @username!
```

This message is normal for GitLab:

```text
Server refused to allocate pty
```

GitLab's SSH endpoint is intended for Git operations, not interactive shell access.

---

# 4. Configure Git to Use Plink

Configure Git globally:

```powershell
git config --global core.sshCommand "plink.exe -batch"
git config --global ssh.variant plink
```

Verify:

```powershell
git config --global --get core.sshCommand
git config --global --get ssh.variant
```

Expected output:

```text
plink.exe -batch
plink
```

The `-batch` option tells Plink not to stop Git operations for interactive SSH questions.

This is desirable once the server's SSH host key has already been verified and cached.

---

# 5. Test Git Access

Before cloning, test repository access with:

```powershell
git ls-remote git@git.example.com:GROUP/PROJECT.git
```

For example:

```powershell
git ls-remote git@git.example.com:jwernick/continue.git
```

Successful output looks similar to:

```text
46e488f4c9449e8cb1e72ca9c1383e229b0a8bf2    HEAD
46e488f4c9449e8cb1e72ca9c1383e229b0a8bf2    refs/heads/main
```

Once this works, normal Git commands can be used:

```powershell
git clone git@git.example.com:GROUP/PROJECT.git
git fetch
git pull
git push
git push origin --tags
```

---

# 6. Servers Using a Nonstandard SSH Port

Some Git servers use a port other than 22.

For example:

```text
git.example.com:10022
```

Create a separate PuTTY-CAC saved session:

```text
Saved session name: git.example.com
Host Name:          git.example.com
Port:               10022
Auto-login username: git
PIV certificate:     selected PIV/CAPI certificate
```

Test it directly:

```powershell
plink.exe -v git.example.com
```

Then Git can use a normal SSH URL containing the port:

```powershell
git clone ssh://git@git.example.com:10022/GROUP/PROJECT.git
```

## First Connection to a New Host or Port

Because Git uses:

```text
plink.exe -batch
```

Plink cannot ask whether a new SSH host key should be trusted.

If Git reports:

```text
The host key is not cached for this server
...
FATAL ERROR: Cannot confirm a host key in batch mode
```

connect once manually without `-batch`:

```powershell
plink.exe -P 10022 git@git.example.com
```

Verify the server fingerprint against an authoritative source.

If it is correct, answer:

```text
y
```

to store the host key.

After that, retry the Git command.

PuTTY caches SSH host keys by **hostname and port**, so:

```text
git.example.com:22
```

and:

```text
git.example.com:10022
```

are separate trust entries.

---

# 7. Why You Should Not Use `-load` in Git Configuration

It is useful to test a saved PuTTY session manually with:

```powershell
plink.exe -load "git.example.com"
```

However, avoid configuring Git like this:

```powershell
git config --global core.sshCommand 'plink.exe -load "git.example.com" -batch'
```

Git also supplies the SSH hostname and remote Git command to Plink.

Combining those extra arguments with `-load` can cause Plink to interpret the hostname as part of the remote command.

A GitLab server may then return:

```text
Disallowed command
```

The cleaner configuration is:

```powershell
git config --global core.sshCommand "plink.exe -batch"
git config --global ssh.variant plink
```

and a PuTTY saved session named exactly after the hostname:

```text
git.example.com
```

---

# 8. Pageant

Pageant is optional for normal Git repository access if Git is already using:

```text
Git -> Plink -> PuTTY-CAC -> CAPI -> PIV
```

You do not need Pageant simply to clone, fetch, pull, or push.

Pageant can still be useful when:

- Multiple applications need access to the same SSH identity
- An OpenSSH-compatible bridge is being used
- The PIV key is also being used for SSH-based Git commit signing

## Certificate and Key Prompting

Pageant may display a confirmation prompt whenever an application requests use of a certificate or key.

This can become disruptive when applications such as VS Code periodically perform:

```text
git fetch
```

If permitted by organizational policy, Pageant has an option to disable per-use **certificate/key prompting**.

This does **not** necessarily disable the PIV PIN requirement. PIN prompting and PIN caching are controlled separately by the smart-card middleware and policy.

Disabling key confirmation also means that applications in the Windows session that can access Pageant may request signatures without an additional Pageant approval dialog.

---

# 9. VS Code Auto-Fetch

VS Code may periodically run Git fetch operations in the background.

Its setting is:

```json
"git.autofetch": true
```

If repeated PIV or Pageant prompts become disruptive, determine whether the prompt comes from:

- Pageant key confirmation
- PuTTY-CAC
- Windows CAPI
- The PIV middleware
- Another Git-related extension

If Pageant's certificate/key prompting is the cause, disabling that prompt can preserve auto-fetch while avoiding repeated approval dialogs.

---

# 10. Troubleshooting

## Git Prompts for a Password

Symptom:

```text
git@git.example.com's password:
```

The PIV-backed SSH key was not successfully used.

Test directly:

```powershell
plink.exe -v git.example.com
```

Look for:

```text
Offered public key
Offer of public key accepted
```

If there is no `Offered public key` line, check:

- You are running PuTTY-CAC rather than standard PuTTY
- The correct saved session is loading
- The PIV certificate is selected
- The session was saved after selecting the certificate

If you see:

```text
Offered public key
Server refused our key
```

check:

- The corresponding public key is registered with GitLab
- The correct PIV certificate was selected
- The SSH key belongs to the correct GitLab account
- The server accepts the key algorithm

## Confirm Which Plink Is Running

Run:

```powershell
Get-Command plink.exe | Format-List Source,Version
where.exe plink.exe
```

Verify that the executable is the intended PuTTY-CAC version.

## `Disallowed command`

If Git returns:

```text
Disallowed command
fatal: Could not read from remote repository.
```

check whether `core.sshCommand` contains `-load`.

Inspect it:

```powershell
git config --global --get core.sshCommand
```

The recommended value is:

```text
plink.exe -batch
```

not:

```text
plink.exe -load "some-session" -batch
```

## `Cannot confirm a host key in batch mode`

This means the SSH host key has not been cached yet.

Connect manually once without `-batch`:

```powershell
plink.exe -P PORT git@HOSTNAME
```

Verify and accept the host key, then retry Git.

## Close Existing PuTTY Processes

To terminate active PuTTY and Plink processes:

```powershell
Get-Process plink, putty -ErrorAction SilentlyContinue |
    Stop-Process -Force
```

To include Pageant:

```powershell
Get-Process plink, putty, pageant -ErrorAction SilentlyContinue |
    Stop-Process -Force
```

---

# 11. Recommended Final Configuration

For a normal GitLab server on port 22:

```text
PuTTY saved session: git.example.com
Host Name:           git.example.com
Port:                22
Auto-login username: git
Authentication:      PIV certificate through PuTTY-CAC/CAPI
```

Git configuration:

```powershell
git config --global core.sshCommand "plink.exe -batch"
git config --global ssh.variant plink
```

Repository URL:

```text
git@git.example.com:GROUP/PROJECT.git
```

Validation:

```powershell
plink.exe -v git.example.com
git ls-remote git@git.example.com:GROUP/PROJECT.git
```

For a server using port 10022:

```text
PuTTY saved session: git.example.com
Host Name:           git.example.com
Port:                10022
Auto-login username: git
Authentication:      PIV certificate through PuTTY-CAC/CAPI
```

Repository URL:

```text
ssh://git@git.example.com:10022/GROUP/PROJECT.git
```

---

# Security Considerations

- The PIV private key remains on the card.
- The public key must be separately registered with the Git server.
- Verify SSH host-key fingerprints before caching them.
- `-batch` should be used only after host keys are trusted.
- PIV PIN behavior is controlled separately from PuTTY/Pageant confirmation behavior.
- Disabling Pageant per-use confirmation allows unattended applications in the current Windows session to request signatures from loaded keys.
- Use only organization-approved PuTTY-CAC builds, middleware, and PIV configurations.
