#! /bin/bash

# Create an encryption key suitable for using with ssh or other PKI tools. Two
# files are generated: a private key (e.g., id_rsa.key) and a public key (e.g.,
# id_rsa.key.pub).

TYPE="ed25519"
ROUNDS=100
BITLENGTH=2048
CN="id_rsa"

printHelp () {
	echo "Usage: $0 [-t TYPE] [-a ROUNDS] [-b BITLENGTH] [-N PASSPHRASE] CN"
	echo "       CN: common name to identify the key owner (default id_rsa)"
	echo "       TYPE: type of key to generate (default ed25519)"
	echo "       ROUNDS: number of KDF rounds used (default 100)"
	echo "       BITLENGTH: bit length of key (default 2048)"
	echo "       PASSPHRASE: passphrase used to encrypt/decrypt key"
    echo ""
	exit 1
}

if [[ $# -eq 0 ]]; then
	printHelp
fi
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-h|--help)
		printHelp
		;;
        -t)
        TYPE=$2
        shift
        ;;
        -a)
        ROUNDS=$2
        shift
        ;;
        -b)
        BITLENGTH=$2
        shift
        ;;
        -N)
        PASSPHRASE=$2
        shift
        ;;
        *)
		CN=$1
	esac
	shift
done

if [ -z ${PASSPHRASE+x} ]; then yes | ssh-keygen -f $CN.key -t $TYPE -a $ROUNDS -b $BITLENGTH -C $(basename $CN)
elif [ -z "$PASSPHRASE" ]; then ssh-keygen -f $CN.key -t $TYPE -a $ROUNDS -b $BITLENGTH -C $(basename $CN)
else yes | ssh-keygen -f $CN.key -t $TYPE -a $ROUNDS -b $BITLENGTH -C $(basename $CN) -N $PASSPHRASE
fi