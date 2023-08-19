#!/bin/bash

# Tool to generate QR codes

# Download QRCodeGen-1.14.3.jar if it doesn't exist in the current working directory.
if [[ ! -f QRCodeGen-1.14.3.jar ]]; then
    wget https://github.com/Zwixx/QRCodeGen/releases/download/1.14.3/QRCodeGen-1.14.3.jar
fi
# Scale UI up if running on ChromeOS
if [[ -d /mnt/chromeos ]]; then
    java -Dsun.java2d.uiScale=2.0 -jar QRCodeGen-1.14.3.jar
else
    java QRCodeGen-1.14.3.jar
fi
