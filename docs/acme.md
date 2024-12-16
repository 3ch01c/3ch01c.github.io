# acme.sh

[Acme.sh](https://github.com/acmesh-official/acme.sh) is a script to issue, renew, and install SSL certificates.

## Quick Start

1. Install Acme.sh.
   ```sh
   curl https://get.acme.sh | sh
   source ~/.bashrc
   ```

2. Register your email address to get notified of renewal.
   ```sh
   acme.sh --register-account --accountemail myemail@mydomain.com
   ```

3. Make sure there's a cron job automating renewal of certificates.
   ```sh
   crontab -l | grep acme.sh
   # The above command should output something like the below:
   10 0 * * * “/home/_CPANEL_USERNAME_/.acme.sh”/acme.sh -- cron -- home “/home/_CPANEL_USERNAME_/.acme.sh” > /dev/null
   ```

4. Check the webroot of your domain.
   ```sh
   uapi DomainInfo single_domain_data domain=_MYDOMAIN.COM_ | grep documentroot
   ```

5. Issue a certificate.
   ```sh
   acme.sh --issue --webroot ~/public_html -d mydomain.com -d www.mydomain.com --force
   ```

6. Install the certificate on Namecheap
   ```sh
   acme.sh —-deploy —-deploy-hook cpanel_uapi —-domain mydomain.com --domain www.mydomain.com
   ```
