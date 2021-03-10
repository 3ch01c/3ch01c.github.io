#!/bin/bash
PLATFORM=$(uname -s) # e.g., Linux, Darwin, etc.
echo "* Get the kompose for $PLATFORM"
curl -L https://github.com/kubernetes/kompose/releases/download/v1.19.0/kompose-$PLATFORM-amd64 -o kompose
echo "* Make kompose executable"
chmod +x kompose
echo "* Move kompose to PATH"
sudo mv kompose /usr/local/bin/kompose