#!/bin/bash

# Script for generating credentials for example Auths and entities
# Author: Hokeun Kim

AUTH_CREDS_DIR=auth/credentials/
ENTITY_CREDS_DIR=entity/credentials/
AUTH_DATABASES_DIR=auth/databases/

if [ $# != 2 ]
then
	echo "Please provide required arguments (number of networks, Auth DB protection method)"
	echo 'Usage: ./generateCredentialsAndConfigs.sh NUM_NETS AUTH_DB_PROTECTION_METHOD'
	exit
fi

# number of networks (Auths)
NUM_NETS=$1
# Protection method for Auth DB, see AuthDBProtectionMethod.java for supported methods
AUTH_DB_PROTECTION_METHOD=$2

read -s -p "Enter new password for Auth: " MASTER_PASSWORD

CA_PASSWORD=$MASTER_PASSWORD
AUTH_PASSWORD=$MASTER_PASSWORD

# Move to Auth credentials
cd ../
cd $AUTH_CREDS_DIR

# Generate CA credentials
./generateCACredentials.sh $CA_PASSWORD

net_id=1
while [ "$net_id" -le $NUM_NETS ]
do
	# Generate Auth credentials
	./generateExampleAuthCredentials.sh "10"$net_id localhost $CA_PASSWORD $AUTH_PASSWORD
	# Make directories for Entity certificates and keys for Auth databases
	MY_CERTS_DIR="../../"$AUTH_DATABASES_DIR"auth10"$net_id"/my_certs/"
	mkdir -p $MY_CERTS_DIR
	mv "certs/Auth10"$net_id*"Cert.pem" $MY_CERTS_DIR
	MY_KEYSTORES_DIR="../../"$AUTH_DATABASES_DIR"auth10"$net_id"/my_keystores/"
	mkdir -p $MY_KEYSTORES_DIR
	mv "keystores/Auth10"$net_id*".pfx" $MY_KEYSTORES_DIR
	CURRENT_AUTH_DB_DIR=../../$AUTH_DATABASES_DIR"/auth10"$net_id
	mkdir -p $CURRENT_AUTH_DB_DIR"/entity_certs/"
	mkdir -p $CURRENT_AUTH_DB_DIR"/entity_keys/"
	mkdir -p $CURRENT_AUTH_DB_DIR"/trusted_auth_certs/"
	let "net_id+=1"
done

# Move to repository root
cd ../../
# Move to Auth databases
cd $AUTH_DATABASES_DIR
# Exchange certs among trusted Auths
my_net_id=1
while [ "$my_net_id" -le $NUM_NETS ]
do
	trusted_net_id=1
	while [ "$trusted_net_id" -le $NUM_NETS ]
	do
		if [ "$my_net_id" == "$trusted_net_id" ]; then
			let "trusted_net_id+=1"
			continue
		fi
		cp "auth10"$my_net_id"/my_certs/Auth10"$my_net_id"InternetCert.pem" "auth10"$trusted_net_id"/trusted_auth_certs"
		let "trusted_net_id+=1"
	done
	let "my_net_id+=1"
done

# Move to repository root
cd ../../

# Move to Entity credentials
cd $ENTITY_CREDS_DIR

# Generate Entity credentials
./generateExampleEntityCredentials.sh $NUM_NETS $CA_PASSWORD

# Move to repository root
cd ../../

# Copy Auth certificates to Entity local directories
mkdir -p entity/auth_certs
cp $AUTH_DATABASES_DIR/auth10*/my_certs/*EntityCert.pem entity/auth_certs

# Initialize Node.js example entities (npm installation)
cd entity/node
./initNodeEntities.sh
cd ../..

# generate configuration files for example Node.js entities
cd examples/configs
./initConfigs.sh $NUM_NETS $AUTH_DB_PROTECTION_METHOD
cd ../..
