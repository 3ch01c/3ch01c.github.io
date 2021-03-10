#!/bin/bash
# from http://spawn.link/chromeos-openvpn-using-ovpn-files-to-setup-openvpn-on-chromeos/

OVPN_FILE="${1}"
OUTPUT_PREFIX="${2}"

if [ ! -e "${OVPN_FILE}" ]; then
	    echo "File not found: ${OVPN_FILE}"
	        exit 1
	fi

	if [ "${OUTPUT_PREFIX}" == "" ]; then
		  OUTPUT_PREFIX=$(date '+%s')
	  fi

	  awk '/<ca>/{flag=1;next}/<\/ca>/{flag=0}flag' "${OVPN_FILE}" > "${OUTPUT_PREFIX}-ca.crt"
	  awk '/<cert>/{flag=1;next}/<\/cert>/{flag=0}flag' "${OVPN_FILE}" > "${OUTPUT_PREFIX}-client.crt"
	  awk '/<key>/{flag=1;next}/<\/key>/{flag=0}flag' "${OVPN_FILE}" > "${OUTPUT_PREFIX}-client.key"

	  openssl pkcs12 -export \
		      -in "${OUTPUT_PREFIX}-client.crt" \
		          -inkey "${OUTPUT_PREFIX}-client.key" \
			      -out "${OUTPUT_PREFIX}-client.p12"
