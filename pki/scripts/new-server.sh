#!/bin/bash 
# Create a new server certificate
if [ "$#" -ne 4 ]; then 
    echo "Usage: $0 ROOT_NAME SERVER_NAME SERVER_CN SERVER_FQDN"
    echo "Example: $0 root server1 server.example.com server.example.com"
    exit
fi

# scripts/new-server.sh lbcloud-pki-root-1 lbcloud-pki pki.lootbot.cloud pki.lootbot.cloud

# First, Set the CA Name and SERVER Common Name and FQDN
export ROOT_NAME=$1
export SERVER_NAME=$2
export SERVER_CN=$3
export SERVER_FQDN=$4
export DIR=$1

set -e

# Load server config
. $DIR/server-config

# Load helpers
. ./scripts/common.sh

# Make directory for the server cert
mkdir -p $DIR/$SERVER_NAME/

# Check if the server already exists
if [ -f $DIR/$SERVER_NAME/$SERVER_NAME.key ]; then
    echo "Server $SERVER_NAME already exists"
    exit
fi

# Generate a new server key
echo "Generating key: $DIR/$SERVER_NAME/$SERVER_NAME.key"
generate_key $DIR/$SERVER_NAME/$SERVER_NAME.key

# Copy (and edit!) the intermediate certificate configuration template
echo "Generating config: $DIR/$SERVER_NAME/$SERVER_NAME.conf"
configure_file templates/server.cfg.tmpl $DIR/$SERVER_NAME/$SERVER_NAME.conf "$SERVER_CN"
	
# Generate new CSR
echo "Generating csr: $DIR/$SERVER_NAME/$SERVER_NAME.csr"
openssl req -new -config $DIR/$SERVER_NAME/$SERVER_NAME.conf -key $DIR/$SERVER_NAME/$SERVER_NAME.key -out $DIR/$SERVER_NAME/$SERVER_NAME.csr 

# All done!
echo "Generated CSR: $DIR/$SERVER_NAME/$SERVER_NAME.csr, this must now be signed"