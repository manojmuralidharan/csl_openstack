#!/bin/bash 

#Reference Wiki : https://github.com/Ch00k/openstack-install-aio/blob/master/openstack-all-in-one.rst#operating-system

readonly user=`whoami`
if [ "X$user" != "Xroot" ]; then
   echo "You should be a root user to run this script"
   exit
fi

ROOT_DIR=`pwd`
read -p "Enter the External IP " EXT_IP
read -p "Enter the Internal IP " MGMT_IP
   
. functions
   
#Neutron: server& pluggins
function install_neutron {
   apt-get install -y neutron-server neutron-plugin-openvswitch neutron-plugin-openvswitch-agent dnsmasq neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent
   service neutron-server stop
   modify_neutron_conf
   rm /var/lib/neutron/neutron.sqlite
   for i in $( ls /etc/init.d/neutron-* ); do service `basename $i` restart; done
}

#Nova
function install_nova {
   apt-get install -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor nova-compute-kvm
   modify_nova_conf 
   for i in $( ls /etc/init.d/nova-* ); do service `basename $i` restart; done
   rm /var/lib/nova/nova.sqlite
   nova-manage db sync
}

#Cinder
function install_cinder {
   apt-get install -y cinder-api cinder-scheduler cinder-volume
}

#Swift
function install_swift {
   apt-get -y install swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   apt-get install -f --fix-missing
   apt-get update
   apt-get -y install swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   mkdir -p /etc/swift && chown -R swift:swift /etc/swift/
   mkdir -p /srv/node
   vi /etc/swift/swift.conf
   chown -R swift:swift /srv/node
   openssl req -new -x509 -nodes -out /etc/swift/cert.crt -keyout /etc/swift/cert.key
   cd /opt/openstack/install_scripts/
   git clone https://github.com/openstack/swift.git && cd swift && python setup.py install
   vi /etc/swift/proxy-se
   vi /etc/swift/proxy-server.conf
   mkdir -p /home/swift/keystone-signing && chown -R swift:swift /home/swift/keystone-signing
   cd /etc/swift/
   swift-ring-builder account.builder create 18 3 1
   swift-ring-builder container.builder create 18 3 1
   swift-ring-builder object.builder create 18 3 1
   swift-ring-builder account.builder add z1-192.168.8.70:6002/sda4 100
   swift-ring-builder container.builder add z1-192.168.8.70:6001/sda4 100
   swift-ring-builder object.builder add z1-192.168.8.70:6000/sda4 100
   swift-ring-builder account.builder rebalance
   swift-ring-builder container.builder rebalance
   swift-ring-builder object.builder rebalance
}

#Horizon
function install_horizon  {
   apt-get -y install openstack-dashboard memcached && dpkg --purge openstack-dashboard-ubuntu-theme
   modify_horizon_conf
   service apache2 restart; service memcached restart
}

#Execution begins here
function main {

   install_neutron
   install_nova
   #install_cinder
   #install_swift
   install_horizon

}

main 2>&1
