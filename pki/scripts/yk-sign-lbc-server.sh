#!/bin/bash
# Sign an client/server CSR using a yubikey

# Setup openssl path and use opensc-pkcs11 to interact with yubikey
OPENSSL_BIN=`which openssl`
#OPENSSL_ENGINE="engine dynamic -pre SO_PATH:/usr/local/lib/engines/engine_pkcs11.so -pre ID:pkcs11 \
#    -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:/usr/local/lib/opensc-pkcs11.so"

if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 END_NAME"
    exit
fi

# Setup variables
export DIR=lbcloud-pki-root-1
export INT_NAME=lbcloud-int-1
export END_NAME=$1

set -e

# Load config
. $DIR/config

export EXPIRY_DAYS=90

# Load helpers
. ./scripts/common.sh

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    CONFIG="scripts/engine-nix.conf"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG="scripts/engine-osx.conf"
fi

echo "Signing end certificate: $DIR/$END_NAME/$END_NAME.crt"

set -e

# Run sign command
sudo --preserve-env OPENSSL_CONF=$CONFIG openssl x509 -engine pkcs11 -CAkeyform engine -CAkey slot_0-id_3 \
    -sha512 -CA $DIR/$INT_NAME.crt -req -extensions v3_req -extfile $DIR/$END_NAME/$END_NAME.conf \
    -in $DIR/$END_NAME/$END_NAME.csr -days=$EXPIRY_DAYS -out $DIR/$END_NAME/$END_NAME.crt

echo "Signed end certificate: $DIR/$END_NAME/$END_NAME.crt"
sudo --preserve-env chown $USER:$USER $DIR/$END_NAME/$END_NAME.crt
echo "Appended $DIR/$INT_NAME.crt to $DIR/$END_NAME/$END_NAME.crt"
sudo cat $DIR/$INT_NAME.crt >> $DIR/$END_NAME/$END_NAME.crt



