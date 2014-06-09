#!/bin/bash
#Network testing starts here : Reference : https://wiki.debian.org/OpenStackHowto/Quantum
 neutron net-create testnetwork
 neutron subnet-create testnetwork 10.0.0.0/24
 neutron subnet-update 126b75ac-4bb7-475d-ba2e-b8b85a710d4b --dns_nameservers list=true 8.8.8.8
 neutron router-create testrouter
 neutron router-interface-add 1e69f5c4-2e2c-4399-97d0-64c822eb4e7a 126b75ac-4bb7-475d-ba2e-b8b85a710d4b
 neutron net-create ext_net --router:external=True
 neutron subnet-create --allocation-pool start=10.2.56.240,end=10.2.56.250 ext_net 10.2.56.0/24 --enable_dhcp=False
 neutron net list
 neutron subnet-list
 neutron router-list
 neutron router-gateway-set 1e69f5c4-2e2c-4399-97d0-64c822eb4e7a 08180148-93ca-410f-a64c-00339862010c
 nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
 nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0
 nova secgroup-add-rule default udp 1 65535 0.0.0.0/0
 #Try to launch an instance from horizon or CLI : "nova boot --flavor m1_512_20 --image "CirrOS 0.3.1" --nic net-id=9fdb051a-0f50-4972-8305-3bc2569a3241 cirros"
