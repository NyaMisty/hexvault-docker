#!/bin/bash

CRT_PATH="/workdir/hexvault.crt"
KEY_PATH="/workdir/hexvault.key"
CA_CRT="/opt/fake_hexrays_ca/hexrays_fake.crt"
CA_KEY="/opt/fake_hexrays_ca/hexrays_fake_key.pem"

if [ -z $VAULT_HOSTNAME ]; then
    echo 'No $VAULT_HOSTNAME specified!'
    exit 1
fi

if [ ! -f "$CRT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    echo "Cert not found, Generating new cert for $VAULT_HOSTNAME..."
    rm -f "$CRT_PATH" "$KEY_PATH"
    set -e -x
#    openssl genpkey -algorithm RSA -out "$KEY_PATH"
#    openssl req -new -key "$KEY_PATH" -out /tmp/request.csr \
#            -subj "/CN=$VAULT_HOSTNAME" \
#            -reqexts SAN -config <(cat <<EOF
#[req]
#distinguished_name = req_distinguished_name
#[req_distinguished_name]
#[SAN]
#subjectAltName=DNS:$VAULT_HOSTNAME
#EOF
#)
#    openssl x509 -req -in /tmp/request.csr -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial -out "$CRT_PATH" -days 36500 -sha256 \
#            -extfile <(echo "subjectAltName=DNS:$VAULT_HOSTNAME")

    openssl genpkey -algorithm RSA -out "$KEY_PATH" -pkeyopt rsa_keygen_bits:2048
    openssl req -new -key "$KEY_PATH" -out /tmp/request.csr -subj "/C=UN/ST=UnitedNations/L=Unk/O=Unk/OU=Unk/CN=$VAULT_HOSTNAME"
    openssl x509 -req -in /tmp/request.csr -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial -out "$CRT_PATH" -days 36500 -sha256    
    echo "============== Cert Generated! =============="
    openssl x509 -in "$CRT_PATH" -text -subject -noout
else
    echo "Cert already exists, skipping cert creation!"
fi

chmod 0600 $CRT_PATH $CRT_KEY

exec bash /start.sh
