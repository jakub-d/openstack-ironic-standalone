#!/bin/bash
set -eu

LOCKDIR=/etc/keystone/fernet-keys/poors-man-lock

release_lock() {
	rm -rf ${LOCKDIR}
}

trap release_lock EXIT

acquire_lock() {
	for i in $(seq 120); do
		set +e
		mkdir ${LOCKDIR}
		rval="$?"
		set -e
		if [ "$rval" -eq "0" ]; then
			return 0
		fi
		sleep 1
	done
	trap - EXIT
	echo "Error: Failed to acquire lock" 2>&1
	exit 1
}

create_database() {
	mysql -u "${DB_ADMIN_USER}" --password="${DB_ADMIN_PASS}" -h "${DB_NAME}" -e 'CREATE DATABASE IF NOT EXISTS keystone;'
	mysql -u "${DB_ADMIN_USER}" --password="${DB_ADMIN_PASS}" -h "${DB_NAME}" -e "GRANT ALL PRIVILEGES ON keystone.* TO 'ironic'@'%';"
}

set_fernet_repository_permissions() {
	chown keystone /etc/keystone/fernet-keys /etc/keystone/credential-keys
	chmod 0700 /etc/keystone/fernet-keys /etc/keystone/credential-keys
}

populate_identity_service_db() {
	su -s /bin/sh -c "keystone-manage db_sync" keystone
}

initialize_fernet_repository() {
	keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
	keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
}

bootstrap_identity_service() {
	keystone-manage bootstrap --bootstrap-password "${OS_PASSWORD}" \
	  --bootstrap-admin-url "${OS_URL}" \
	  --bootstrap-internal-url "${OS_URL}" \
	  --bootstrap-public-url "${OS_URL}" \
	  --bootstrap-region-id "${KEYSTONE_REGION}"
}

acquire_lock
create_database
populate_identity_service_db
set_fernet_repository_permissions
initialize_fernet_repository
bootstrap_identity_service
