#!/bin/bash
# Extracts certificate and private key from PFX using openssl

set -e

printHelp () {
	echo "Usage: $0 PFX_FILE"
	echo "  PFX_FILE    path of file containing certificate configuration (e.g., example.com.pfx)"
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
        -v|--verbose) VERBOSE=1 ;;
		*) PFX_FILE=$1
	esac
	shift
done

if [ -z ${PFX_FILE+x} ]; then printHelp; fi

if [ ! -z ${VERBOSE+x} ]; then echo "Extracting private key and certificate..."; fi

CN="${PFX_FILE%.*}"
openssl pkcs12 -in ${PFX_FILE} -nocerts -out "${CN}.key" -nodes
openssl pkcs12 -in ${PFX_FILE} -nokeys -out "${CN}.crt"

if [ ! -z ${VERBOSE+x} ]; then
	echo ""
	echo "Private key: $CN.key"
	echo "Certificate request: $CN.csr"
fi
