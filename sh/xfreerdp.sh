HOST="rdp.example.com"
SMARTCARD="OMNIKEY AG 3121 USB"
USER="me"
DOMAIN="example.com"
xfreerdp -v:"$HOST" /smartcard:"$SMARTCARD" /w:1600 /h:1200 /u:"$USER" /d:"$DOMAIN" /dynamic-resolution
