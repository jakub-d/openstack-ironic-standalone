Helm Chart - Openstack Ironic Standalone
========================================

Breaking change in 2.0.0
------------------------
The chart switches from MySQL to Mariadb DB engine.
Create a SQL dump on existing database before upgrade and load it to the newly created Mariadb.
Note that configuration parameters for databases change.

[![Build Status](https://travis-ci.org/jakub-d/openstack-ironic-standalone.svg?branch=master)](https://travis-ci.org/jakub-d/openstack-ironic-standalone)

[Openstack Ironic](https://docs.openstack.org/ironic/latest/index.html), Ironic is an OpenStack project which provisions bare metal (as opposed to virtual) machines. It may be used independently or as part of an OpenStack Cloud, and integrates with the OpenStack Identity (keystone), Compute (nova), Network (neutron), Image (glance), and Object (swift) services.

This Helm chart installs Openstack Ironic in [standalone mode](https://docs.openstack.org/ironic/latest/install/standalone.html).

TL;DR;

Create a config file (`my-site.yaml`) with following variables defined:
```
---
ironicServerName: example.example.io
persistentVolumeClaimName: existing-claim-name
api:
  externalIPs:
    - 10.10.10.10
httpboot:
  externalIPs:
    - 10.10.10.10
tftp:
  externalIPs:
    - 10.10.10.10
mariadb:
  db:
    password: secret1
  rootUser:
    password: secret1
  master:
    persistence:
      existingClaim: existing-claim-name
rabbitmq:
  rabbitmq:
    password: secret3
```
(you don't have to define secrets, but this step is required for production, as random-generated secrets will change each helm roll-over and will not match persistent storage db)

Another example of the config file, using ingress and dynamic pv provisioners (make sure the tftp storageClass used allows cross-pod mounting):
```
---
ironicServerName: ironic.example.io
api:
  ingress:
    enabled: true
    hosts:
      - ironic.example.io
httpboot:
  ingress:
    enabled: true
    hosts:
      - ironicwww.example.io
tftp:
  externalIPs:
    - 10.10.10.10
  nodeSelector:
    hostname: 10.10.10.10.xip.io
  persistence:
    storageClass: sharefs
mysql:
  mysqlPassword: secret1
  mysqlRootPassword: secret2
rabbitmq:
  rabbitmq:
    password: secret3
```

Then install a chart using command:
```
helm repo add ironic https://ironic.storage.googleapis.com
helm install ironic/openstack-ironic-standalone -f my-site.yaml
```

Configuration
=============

All configuration parameters are documented in the `values.yaml` file.

Comparison to [Kolla](https://docs.openstack.org/ironic/latest/install/standalone.html)
=======================================================================================

Kolla provides a method to deploy a full Openstack suite. This chart installs only Openstack Ironic.
The chart has a *minimalistic* approach.

Why minimalistic?
-----------------
* Uses simple Docker images with no sophisticated entrypoints. Docker images are from Openstack rpms packaged by CentOS.
* Depending services like MySQL, Rabbitmq are installed from production Helm charts

Storage
=======

The chart can use an existing volume claim. It will create a claim, if there is no claim name provided.
It uses `subPath` functionality to create sub directories on the existing claim.
The existing claim name must be defined in two places: `persistentVolumeClaimName` and `mysql.persistence.existingClaim`.

One can upload disk images using HTTP PUT request:

```
curl -T diskimage.qcow2 http://<httpboot_externalIP>
```

Note on tftpd
=============

Tftp protocol does not fit to Kubernetes network model.
Here is how it works:
```
Client:x → Srv:69 - client requests
Client:x ← Srv:y - server replies from a random port, not 69
Client:x → Srv:y - client acknowledges on dedicated port
```

Some charts use ptftp instead, but we were not able to enable it:
* it had too many bugs and we were not able to transfer large files using it

That's why we start in.tftpd DaemonSet with hostNetwork enabled.
It means that we have a pool of servers running in.tftpd.
Only the one that has the external IP address attached will be serving files.
It does not use a Kubernetes network model (POD network, service network).

The tftpd service can be exposed using keepalived floating IP, simple DNS
round-robin record or simply by aiming directly at k8s node address.
