#!/bin/sh

mysql -uroot -popenstackcs << EOF
CREATE DATABASE keystone;
GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'openstackcs';
GRANT ALL ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'openstackcs';

CREATE DATABASE glance;
GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY 'openstackcs';
GRANT ALL ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'openstackcs';

CREATE DATABASE neutron;
GRANT ALL ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'openstackcs';
GRANT ALL ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'openstackcs';

CREATE DATABASE nova;
GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY 'openstackcs';
GRANT ALL ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'openstackcs';

CREATE DATABASE cinder;
GRANT ALL ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'openstackcs';
GRANT ALL ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'openstackcs';

CREATE DATABASE heat;
GRANT ALL ON heat.* TO 'heat'@'%' IDENTIFIED BY 'openstackcs';
GRANT ALL ON heat.* TO 'heat'@'localhost' IDENTIFIED BY 'openstackcs';
EOF
