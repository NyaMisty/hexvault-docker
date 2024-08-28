#!/bin/bash

# don't copy conf because vault only supports sqlite3 currently
# and we decided to hardcode the sqlite3 db path
#if ! [ -f /workdir/hexvault.conf ]; then
#	cp /opt/hexvault/hexvault.conf.example /workdir/hexvault.conf
#fi

set -x

CONF=/opt/hexvault/hexvault.conf
FILES=/opt/hexvault/files/store
mkdir -p /workdir/files/store

# hardcoded in hexvault.conf
DBPATH=/opt/hexvault/files/hexvault.sqlite3

if ! [ -f $DBPATH ]; then
	echo 'hexvault.sqlite3 not exists, initializing database...'
	rm -f ${DBPATH}* # remove all shm / wal
	/opt/hexvault/vault_server -f $CONF -d $FILES --recreate-schema
else
	echo 'hexvault.sqlite3 already exists, skip database initialization :)'
fi

/opt/hexvault/vault_server -f $CONF -d $FILES -v -e 100 -c /workdir/hexvault.crt -k /workdir/hexvault.key 
