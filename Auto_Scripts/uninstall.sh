#!/bin/bash

function stop_remove_horizon {
   service apache2 stop; service memcached stop
   apt-get -y remove openstack-dashboard memcached 
   apt-get -y autoremove openstack-dashboard memcached
   apt-get -y purge openstack-dashboard memcached 
}

function stop_remove_swift {
   swift-init main stop && service rsyslog sop && service memcached stop
   apt-get -y remove swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   apt-get -y autoremove swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
   apt-get -y purge swift swift-account swift-container swift-object swift-proxy openssh-server memcached python-pip python-netifaces python-xattr python-memcache xfsprogs python-keystoneclient python-swiftclient python-webob git
}   

function stop_remove_cinder {
   service tgt stop
   for i in $( ls /etc/init.d/cinder-* ); do service `basename $i` stop; done
   apt-get remove -y --purge cinder*
   apt-get autoremove -y cinder-api cinder-scheduler cinder-volume
}   

function stop_remove_nova {
   for i in $( ls /etc/init.d/nova-* ); do service `basename $i` stop; done
   apt-get remove -y --purge nova*
   apt-get autoremove -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor nova-compute-kvm
}

function stop_remove_neutron {
   for i in $( ls /etc/init.d/neutron-* ); do service `basename $i` stop; done
   service dnsmasq stop
   apt-get remove -y --purge neutron* dnsmasq
   apt-get autoremove -y neutron-server neutron-plugin-openvswitch neutron-plugin-openvswitch-agent dnsmasq neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent
}

function stop_remove_glance {
   service glance-registry stop; service glance-api stop
   apt-get remove -y --purge glance*
   apt-get -y autoremove glance
}

function stop_remove_keystone {
   service keystone stop
   apt-get remove -y --purge keystone*
   apt-get autoremove -y keystone
}

function stop_remove_mysql {
   service mysql stop
   apt-get remove -y --purge mysql* python-mysql* rabbitmq-server ntp
   apt-get autoremove -y mysql-server python-mysqldb rabbitmq-server ntp
}

function stop_remove_ovs {
   apt-get remove -y openvswitch-controller openvswitch-switch openvswitch-datapath-dkms
   apt-get autoremove -y openvswitch-controller openvswitch-switch openvswitch-datapath-dkms
   apt-get purge -y openvswitch-controller openvswitch-switch openvswitch-datapath-dkms
}

stop_remove_horizon
stop_remove_swift
stop_remove_cinder
stop_remove_nova
stop_remove_neutron
stop_remove_glance
stop_remove_keystone
stop_remove_mysql
#stop_remove_ovs
