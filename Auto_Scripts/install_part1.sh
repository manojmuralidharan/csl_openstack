#!/bin/bash

########################################################################################################
# Reference                                                                                            #
# https://github.com/Ch00k/openstack-install-aio/blob/master/openstack-all-in-one.rst#operating-system #
# Use this script to install openstack components one by one or all in one shot.                       #
# Requirements & assumptions 									       #
#   Ubuntu 12.04 Server 64-bit                                                                         #
#   Two NICs with one having access to internet.                                                       #
#   At least 4 GB RAM                                                                                  #
########################################################################################################

readonly user=`whoami`
if [ "X$user" != "Xroot" ]; then
   echo "You should be a root user to run this script"
   exit
fi

ROOT_DIR=`pwd`
read -p "Enter the External IP " EXT_IP
read -p "Enter the Internal IP " MGMT_IP 
read -p "Enter the OS password " OPENSTACK_PW 

. functions

function update_repo {
   apt-get -y install ubuntu-cloud-keyring python-software-properties software-properties-common python-keyring   
   echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-proposed/havana main >> /etc/apt/sources.list.d/havana.list
   apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
}

#MySql & messaging frameworks
function install_mysql {
   apt-get install -y mysql-server python-mysqldb rabbitmq-server ntp
   #Modify conf, restart and poputele db
   sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
   service mysql restart
   chmod +x populate_database.sh
   ./populate_database.sh
}

#Check if IP forwarding enabled
function check_ip_forwarding {
   sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
   sysctl net.ipv4.ip_forward=1
}

#Keystone
function install_keystone {
   apt-get install -y keystone
   #Modify conf, restart and poputele db
   chmod +x populate_keystone.sh 
   modify_keystone_conf
   rm /var/lib/keystone/keystone.db 
   service keystone restart
   keystone-manage db_sync
   ./populate_keystone.sh 
   echo -e 'export OS_TENANT_NAME=admin\nexport OS_USERNAME=admin\nexport OS_PASSWORD=$OPENSTACK_PW\nexport OS_AUTH_URL="http://'$EXT_IP':5000/v2.0/"' > ~/.keystonerc
   source ~/.keystonerc 
   echo "source ~/.keystonerc" >> ~/.bashrc
}

#Glance
function install_glance {
   apt-get -y install glance
   #Modify conf, restart and poputele db
   modify_glance_conf
   rm /var/lib/glance/glance.sqlite 
   service glance-api restart; service glance-registry restart
   glance-manage db_sync
   service glance-registry restart; service glance-api restart
}

#Neutron: OVS
function install_neutron_vs {
   apt-get install -y openvswitch-controller openvswitch-switch openvswitch-datapath-dkms
   ovs-vsctl add-br br-int
   ovs-vsctl add-br br-ex
}

#After ovs bridges are created the network interfaces are to be re-alligned. For this refer install_manual.txt.
function install_manual {
   echo "****************************************************************************************"
   echo "* Installation part 1 is completed........                                             *"
   echo "* Before part 2 you should re-configure the network interfaces to suit openstack needs *"
   echo "* With the help of install_manual.txt set up the interfaces and netwroking of the host *"
   echo "****************************************************************************************"
}

#main function where the real execution begins
function main {
   update_repo
   install_mysql
   check_ip_forwarding   
   install_keystone
   install_glance
   install_neutron_vs
   install_manual
}

main 2>&1
