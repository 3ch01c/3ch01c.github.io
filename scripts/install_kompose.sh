#!/bin/bash
PLATFORM=$(uname -s) # e.g., Linux, Darwin, etc.
curl -L https://github.com/kubernetes/kompose/releases/download/v1.19.0/kompose-$PLATFORM-amd64 -o kompose
chmod +x kompose
sudo mv kompose /usr/local/bin/kompose