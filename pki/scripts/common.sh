#!/bin/bash
# Common functions

function generate_key {
    if [ -f "$1" ]; then
        echo "WARNING using existing key $1"
        echo "To re-generate the key please remove this file"
        return
    fi

    if [ $KEY_TYPE == "ec" ]; then
        openssl ecparam -genkey -name $KEY_SIZE -noout -out $1
    elif [ $KEY_TYPE == "rsa" ]; then
        openssl genrsa -out $1 $KEY_SIZE
    else
        echo "ERROR unsupported key type: $KEY_TYPE"
        return
    fi

}

function configure_file {
    if [ ! -f "$2" ]; then
        sed \
        -e "s|COUNTRY|$COUNTRY|g" \
        -e "s|STATE|$STATE|g" \
        -e "s|ORG_UNIT|$ORG_UNIT|g" \
        -e "s|ORG|$ORG|g" \
        -e "s|DOMAIN|$DOMAIN|g" \
        -e "s|EMAIL|$EMAIL|g" \
        -e "s|ROOT_NAME|$ROOT_NAME|g" \
        -e "s|INT_NAME|$INT_NAME|g" \
        -e "s|COMMON_NAME|$3|g" \
        -e "s|SERVER_FQDN|$SERVER_FQDN|g" \
        -e "s|EXPIRY_DAYS|$EXPIRY_DAYS|g" \
        -e "s|DIR|$DIR|g" \
        $1 > $2
    else
        echo "WARNING using existing configuration $2"
        echo "To re-generate the configuration please remove this file"
    fi
}

