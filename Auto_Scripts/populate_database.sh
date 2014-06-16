#!/bin/sh

mysql -uroot -p$OPENSTACK_PW << EOF
CREATE DATABASE keystone;
GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$OPENSTACK_PW';
GRANT ALL ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$OPENSTACK_PW';

CREATE DATABASE glance;
GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY '$OPENSTACK_PW';
GRANT ALL ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$OPENSTACK_PW';

CREATE DATABASE neutron;
GRANT ALL ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$OPENSTACK_PW';
GRANT ALL ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$OPENSTACK_PW';

CREATE DATABASE nova;
GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY '$OPENSTACK_PW';
GRANT ALL ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$OPENSTACK_PW';

CREATE DATABASE cinder;
GRANT ALL ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$OPENSTACK_PW';
GRANT ALL ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$OPENSTACK_PW';

CREATE DATABASE heat;
GRANT ALL ON heat.* TO 'heat'@'%' IDENTIFIED BY '$OPENSTACK_PW';
GRANT ALL ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$OPENSTACK_PW';
EOF
