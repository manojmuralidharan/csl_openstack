#!/bin/bash

#Reference Wiki : https://github.com/Ch00k/openstack-install-aio/blob/master/openstack-all-in-one.rst#operating-system
   
. functions
   
#BEGIN
 sudo -i

#Neutron: server& pluggins
 apt-get install -y neutron-server neutron-plugin-openvswitch neutron-plugin-openvswitch-agent dnsmasq neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent
 service neutron-server stop
 modify_neutron_conf
 rm /var/lib/neutron/neutron.sqlite
 for i in $( ls /etc/init.d/neutron-* ); do service `basename $i` restart; done

#Nova
 apt-get install -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor nova-compute-kvm
 vi /etc/nova/nova-compute.conf 
 cp /etc/nova/nova-compute.conf /etc/nova/nova-compute.conf.lfc 
 vi /etc/nova/nova-compute.conf
 vi /etc/nova/api-paste.ini 
 vi /etc/nova/nova.conf 
 cp /etc/nova/nova.conf /etc/nova/nova.conf.lfv
 cp /etc/nova/nova.conf.lfv /etc/nova/nova.conf.lfc
 vi /etc/nova/nova.conf
 for i in $( ls /etc/init.d/nova-* ); do service `basename $i` restart; done
 rm /var/lib/nova/nova.sqlite
 nova-manage db sync
 nova-manage service list

#Cinder
 apt-get install -y cinder-api cinder-scheduler cinder-volume
 df -kh

#Swift
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
 
#Horizon
 apt-fast -y install openstack-dashboard memcached && dpkg --purge openstack-dashboard-ubuntu-theme
#This might fail---you need to add an entry "ServerName 127.0.1.1" in the file /etc/apache2/apache2.conf. I put 127.0.1.1 here which appears in my /etc/hosts representing my hostname
 service apache2 restart; service memcached restart
END
