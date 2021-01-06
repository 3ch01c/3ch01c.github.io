#!/bin/bash

echo -n "5.1 Enforce Multifactor Authentication for Login... "
RESULT=$(/usr/bin/grep -Ec '^(auth\s+sufficient\s+pam_smartcard.so|auth\s+required\s+pam_deny.so)' /etc/pam.d/login)
if [[ $RESULT != 2 ]]; then
echo "FAIL ($RESULT)"
cat << EOF

To remediate, run the following commands:

/bin/cat > /etc/pam.d/login << LOGIN_END
# login: auth account password session
auth sufficient pam_smartcard.so
auth optional pam_krb5.so use_kcminit
auth optional pam_ntlm.so try_first_pass
auth optional pam_mount.so try_first_pass
auth required pam_opendirectory.so try_first_pass
auth required pam_deny.so
account required pam_nologin.so
account required pam_opendirectory.so
password required pam_opendirectory.so
session required pam_launchd.so
session required pam_uwtmp.so
session optional pam_mount.so
LOGIN_END
/bin/chmod 644 /etc/pam.d/login
/usr/sbin/chown root:wheel /etc/pam.d/login

EOF
else
echo "OK"
fi

echo -n "5.2 Allow Smartcard Authentication... "
RESULT=$(/usr/bin/profiles -P -o stdout | /usr/bin/grep -c 'allowSmartCard = 1')
if [[ $RESULT != 1 ]]; then
echo "FAIL ($RESULT)"
cat << EOF

To remediate, run the following commands:

cat << EOP | /usr/bin/profiles -I -F -
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>PayloadContent</key>
    <array>
      <dict>
        <key>PayloadDisplayName</key>
        <string>SmartCard</string>
        <key>PayloadIdentifier</key>
        <string>com.apple.security.smartcard</string>
        <key>PayloadType</key>
        <string>com.apple.security.smartcard</string>
        <key>PayloadUUID</key>
        <string>$(uuidgen)</string>
        <key>allowSmartCard</key>
        <true/>
      </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>auth_smartcard_allow</string>
    <key>PayloadIdentifier</key>
    <string>$(hostname).$(uuidgen)</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>$(uuidgen)</string>
  </dict>
</plist>
EOP

EOF
# profiles -P -o stdout | grep -A 10 -B 10 allowSmartCard
else
echo "OK"
fi