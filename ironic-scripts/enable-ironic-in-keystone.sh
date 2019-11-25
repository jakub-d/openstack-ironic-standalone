#!/bin/bash
set -eux

wait_for_keystone() {
	while [ "1" ]; do
		openstack user list >/dev/null 2>&1 && return || sleep 1
	done
}

create_service_project() {
	openstack project show ${KEYSTONE_IRONIC_PROJECT} -f shell 2>/dev/null | grep -q name || \
		openstack project create --domain default \
			--description "Service Project"  ${KEYSTONE_IRONIC_PROJECT}
}

create_service_user() {
	openstack user show ${KEYSTONE_IRONIC_USER} -f shell 2>/dev/null | grep -q name || \
		openstack user create --password ${KEYSTONE_IRONIC_PASSWORD} ${KEYSTONE_IRONIC_USER}
	openstack role add --project ${KEYSTONE_IRONIC_PROJECT} --user ${KEYSTONE_IRONIC_USER} admin
}

register_service() {
	openstack service show ${KEYSTONE_IRONIC_SERVICE} -f shell 2>/dev/null | grep -q name || \
		openstack service create --name ${KEYSTONE_IRONIC_SERVICE} --description \
			"Ironic baremetal provisioning service" baremetal
}

create_endpoints() {
	for interface in $(echo "admin public internal"); do
		openstack endpoint list | grep baremetal | grep -q "${interface}" || \
			openstack endpoint create --region "${KEYSTONE_REGION}" baremetal "${interface}" "${IRONIC_API_URL}"
	done
}

wait_for_keystone
create_service_project
create_service_user
register_service
create_endpoints
