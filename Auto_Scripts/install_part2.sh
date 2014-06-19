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
read -p "Enter the swift partition " SWIFT_PART
read -p "Enter the OS password " OPENSTACK_PW
   
. functions
   
#Neutron: server& pluggins
function neutron {
   apt-get install -y neutron-server neutron-plugin-openvswitch neutron-plugin-openvswitch-agent dnsmasq neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent
   service neutron-server stop
   modify_neutron_conf
   rm /var/lib/neutron/neutron.sqlite
   for i in $( ls /etc/init.d/neutron-* ); do service `basename $i` restart; done
   service dnsmasq restart
}

#Nova
function nova {
   apt-get install -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor nova-compute-kvm
   modify_nova_conf 
   for i in $( ls /etc/init.d/nova-* ); do service `basename $i` restart; done
   rm /var/lib/nova/nova.sqlite
   nova-manage db sync
   for i in $( ls /etc/init.d/nova-* ); do service `basename $i` restart; done
}

#Cinder
function cinder {
   apt-get install -y cinder-api cinder-scheduler cinder-volume
}

#Swift
function swift {
   apt-get -y install swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   modify_swift_conf
}

#Horizon
function horizon  {
   apt-get -y install openstack-dashboard memcached && dpkg --purge openstack-dashboard-ubuntu-theme
   modify_horizon_conf
   service apache2 restart; service memcached restart
}

#Execution begins here
function all {
   neutron
   nova
   cinder
   swift
   horizon
}

function help {
  echo Usage
  echo "./install_part1.sh <option> where option can be one of the below"
  echo update
  echo mysql
  echo keystone
  echo glance
  echo ovs 
  echo all
}

$1
rc=`echo $?`
if [ $rc == 127 ]; then
   help
fi
