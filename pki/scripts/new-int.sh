#!/bin/bash 
# Create a new intermediate
if [ "$#" -ne 3 ]; then 
    echo "Usage: $0 ROOT_NAME INT_NAME \"Human Name\""
    exit
fi


# First, set the certificate base name and human names
export ROOT_NAME=$1
export INT_NAME=$2
export HUMAN_NAME=$3
export DIR=$ROOT_NAME

set -e

# Load configuration
. $DIR/config

# Load helpers
. scripts/common.sh

# Generate new key
echo "Generating key: $DIR/$INT_NAME.key"
generate_key $DIR/$INT_NAME.key

# Copy (and edit!) the intermediate certificate configuration template
echo "Generating configuration: $DIR/$INT_NAME.conf"
configure_file templates/int.cfg.tmpl $DIR/$INT_NAME.conf "$HUMAN_NAME"

# Generate new CSR
openssl req -new -config $DIR/$INT_NAME.conf -extensions v3_ca -key $DIR/$INT_NAME.key -out $DIR/$INT_NAME.csr 

# Create serial file
if [ ! -f "$DIR/$INT_NAME.srl" ]; then
    echo "01" > $DIR/$INT_NAME.srl
fi

echo "Generated CSR: $DIR/$INT_NAME.csr, this must now be signed"

