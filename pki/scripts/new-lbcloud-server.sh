#!/bin/bash 
# Create a new server certificate
# if [ "$#" -ne 4 ]; then 
#     echo "Usage: $0 ROOT_NAME SERVER_NAME SERVER_CN SERVER_FQDN"
#     echo "Example: $0 root server1 server.example.com server.example.com"
#     exit
# fi

# scripts/new-server.sh lbcloud-pki-root-1 lbcloud-pki pki.lootbot.cloud pki.lootbot.cloud

# First, Set the CA Name and SERVER Common Name and FQDN
export ROOT_NAME=lbcloud-pki-root-1
export DIR=lbcloud-pki-root-1


# Prompt the user for SERVER_NAME if not provided
if [ -z "$SERVER_NAME" ]; then
    read -p "Enter the server name (SERVER_NAME): " SERVER_NAME
fi

# Prompt the user for SERVER_CN if not provided
if [ -z "$SERVER_CN" ]; then
    read -p "Enter the server common name (SERVER_CN): " SERVER_CN
fi

# Prompt the user for SERVER_FQDN if not provided
if [ -z "$SERVER_FQDN" ]; then
    read -p "Enter the server fully qualified domain name (SERVER_FQDN): " SERVER_FQDN
fi

# Display the information and ask for confirmation
echo "You have entered the following information:"
echo "ROOT_NAME: $ROOT_NAME"
echo "SERVER_NAME: $SERVER_NAME"
echo "SERVER_CN: $SERVER_CN"
echo "SERVER_FQDN: $SERVER_FQDN"
read -p "Is this information correct? (yes/no): " CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
    echo "Aborting."
    exit
fi

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