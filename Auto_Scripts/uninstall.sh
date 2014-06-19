#!/bin/bash

function horizon {
   service apache2 stop; service memcached stop
   apt-get -y --purge remove openstack-dashboard memcached 
   apt-get -y autoremove openstack-dashboard memcached
}

function swift {
   swift-init main stop && service rsyslog sop && service memcached stop
   rm -rf /home/swift/keystone-signing
   rm -rf /etc/swift/
   rm -rf /srv/node/
   apt-get -y remove swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   apt-get -y autoremove swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   apt-get -y purge swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
}   

function cinder {
   service tgt stop
   for i in $( ls /etc/init.d/cinder-* ); do service `basename $i` stop; done
   apt-get remove -y --purge "^.*cinder.*"
   apt-get autoremove -y cinder-api cinder-scheduler cinder-volume
}   

function nova {
   for i in $( ls /etc/init.d/nova-* ); do service `basename $i` stop; done
   apt-get remove -y --purge "^.*nova*"
   apt-get autoremove -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor nova-compute-kvm
}

function neutron {
   for i in $( ls /etc/init.d/neutron-* ); do service `basename $i` stop; done
   service dnsmasq stop
   apt-get remove -y --purge "^.*neutron*" dnsmasq
   apt-get autoremove -y neutron-server neutron-plugin-openvswitch neutron-plugin-openvswitch-agent dnsmasq neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent
}

function glance {
   service glance-registry stop; service glance-api stop
   apt-get remove -y --purge "^.*glance*"
   apt-get -y autoremove glance
}

function keystone {
   service keystone stop
   apt-get remove -y --purge "^.*keystone*"
   apt-get autoremove -y keystone
}

function mysql {
   mysql -uroot -popenstackcs  -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema| grep -v test | grep -v OLD |gawk '{print "drop database " $1 ";select sleep(0.1);"}' | mysql -uroot -popenstackcs
   service mysql stop
   apt-get remove -y --purge mysql* python-mysql* rabbitmq-server ntp
   apt-get autoremove -y mysql-server python-mysqldb rabbitmq-server ntp
}

function ovs {
   ovs-vsctl del-port br-ex eth0
   ovs-vsctl del-br br-ex
   ovs-vsctl del-br br-int
   apt-get remove -y --purge "^.*openvswitch*"
   apt-get autoremove -y openvswitch-controller openvswitch-switch openvswitch-datapath-dkms
}

function all {
   horizon
   swift
   cinder
   nova
   neutron
   glance
   keystone
   mysql
   ovs
}

function help {
   echo Usage
   echo "./install_part1.sh <option> where option can be one of the below"
   echo horizon
   echo swift
   echo cinder
   echo nova
   echo neutron
   echo glance
   echo keystone
   echo mysql
   echo ovs
}

$1
rc=`echo $?`
if [ $rc == 127 ]; then
   help
fi
