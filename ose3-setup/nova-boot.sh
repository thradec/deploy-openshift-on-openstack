# m1.large and _OS1_rhel-guest-image-7.1-20150224.0.x86_64.qcow2 image
# RHMAP tenenat using mobileqe pwd 3b73947641f1

KEYPAIR=ose31
SECGROUP=osev31
INSTANCE_NAME=myTest

source RHM-mobileqe.sh

# generate a key-pair
nova keypair-add ${KEYPAIR} > ~/.ssh/${KEYPAIR}.pem
chmod 600  ~/.ssh/${KEYPAIR}.pem

nova keypair-list

sleep 5;

#create security group
nova secgroup-create ${SECGROUP} 'Openshift v3.1 on openstack'


image=$(nova image-list | grep _OS1_rhel-guest-image-7.1 | awk '{print $2}')
flavor=$(nova flavor-list | grep m1.large | awk '{print $2}')

nova secgroup-add-rule ${SECGROUP} icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 22 22 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 53 53 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 80 80 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 443 443 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 1936 1936 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 4001 4001 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 7001 7001 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 8443  8444 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 10250 10250 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} tcp 24224 24224 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} udp 53 53 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} udp 4789 4789 0.0.0.0/0
nova secgroup-add-rule ${SECGROUP} udp 24224 24224 0.0.0.0/0


nova boot --flavor ${flavor} --image ${image} --security-groups ${SECGROUP},default --key-name ${KEYPAIR} ${INSTANCE_NAME}

sleep 10;

nova list
