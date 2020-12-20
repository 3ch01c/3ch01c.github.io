#!/bin/bash
# This script creates an OpenSSL private key, certificate signing request, and self-signed certificate.
# You must supply a at least a Common Name argument (e.g., example.com) or else include it in your config file.

set -e

printHelp () {
	echo "Usage: $0 CN [-c CONFPATH]"
	echo "  CN          common name to identify the host (e.g., example.com)"
	echo "  -c CONFPATH path of file containing certificate configuration (e.g., example.com.ssl.conf)"
	echo "  -v          increase output verbosity"
	exit 1
}

if [[ $# -eq 0 ]]; then
	printHelp
fi
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-h|--help) printHelp ;;
		-c|--config) CONFIG=$2; shift ;;
    -v|--verbose) VERBOSE=1 ;;
		*) CN=$1
	esac
	shift
done

if [ ! -z ${VERBOSE+x} ]; then echo "Generating private key and certificate signing request..."; fi
if [ -z ${CONFIG+x} ]; then
	# Use default config
	echo openssl req -noout -newkey rsa:2048 -nodes -sha256 -keyout $CN.key -out $CN.csr -subj /CN=$CN
	openssl req -newkey rsa:2048 -nodes -sha256 -keyout $CN.key -out $CN.csr -subj /CN=$CN
else
	# Use custom config file
	openssl req -noout -newkey rsa:2048 -nodes -sha256 -keyout $CN.key -out $CN.csr -config $CONFIG
fi
if [ ! -z ${VERBOSE+x} ]; then echo "Securing private key permissions..."; fi
chmod 600 $CN.key
if [ ! -z ${VERBOSE+x} ]; then echo "Verifying private key..."; fi
openssl rsa -check -noout -in $CN.key
if [ ! -z ${VERBOSE+x} ]; then echo "Verifying certificate signing request..."; fi
openssl req -text -noout -verify -in $CN.csr
if [ ! -z ${VERBOSE+x} ]; then echo "Generating self-signed certificate..."; fi
if [ -z ${CONFIG+x} ]; then
	openssl x509 -req -days 365 -in $CN.csr -signkey $CN.key -out $CN.crt
else
	openssl x509 -req -days 365 -in $CN.csr -signkey $CN.key -out $CN.crt -extensions v3_req -extfile $CONFIG
fi
if [ ! -z ${VERBOSE+x} ]; then echo "Verifying self-signed certificate..."; fi
openssl x509 -in $CN.crt -text -noout

if [ ! -z ${VERBOSE+x} ]; then
	echo ""
	echo "Private key: $CN.key"
	echo "Certificate request: $CN.csr"
	echo "Self-signed certificate: $CN.crt"
fi
