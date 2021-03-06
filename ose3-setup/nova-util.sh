#!/bin/bash
#
# @(#)$Id$
#
# Utility to create/delete instances on OpenStack
# 
# The following are set as default 
# - flavor m1.large 
# - image  OS1_rhel-guest-image-7.1-20150224.0.x86_64.qcow2
# 
# Depending on the RC file vars use :
# - tenant RHMAP (public) 
# - user   mobileqe 
# - pwd    3b73947641f1

# for reference - list of flavors
# m1.miq
# m1.small
# m1.large
# c3.2xlarge
# c3.large
# c3.mxlarge
# c3.xlarge
# m1.tiny
# m1.medium
# m3.large
# m3.medium
# m3.xlarge
# r3.large
# t2.medium
# t2.micro
# t2.small

# 209.132.183.44 xmlrpc.rhn.redhat.com
# 23.204.148.218 content-xmlrpc.rhn.redhat.com
# 209.132.183.49 subscription.rhn.redhat.com
# 209.132.182.33 repository.jboss.org
# 209.132.182.63 registry.access.redhat.com

# for a list of images use 
# nova image-list

clear

cmds=( create createServer remove removeKey removeSecGroup useRc )

# define convenience functions 
function updateTime() {
  TIME=$(date +%T)
  NOW="\033[0;96m[ $(date +%Y-%m-%d) ${TIME} ]\033[0m"
  DEBUG="${NOW} \033[0;95mDEBUG\033[0m :"
  INFO="${NOW} \033[0;94mINFO\033[0m  :"
  ERROR="${NOW} \033[0;91mERROR\033[0m :"
}

KEYPAIR=ose31pb
SECGROUP=ose31sec
#INSTANCES=(master-osev31 node1-osev31 node2-osev31 node3-osev31)
INSTANCES=(master-osev31 node1-osev31)
#RHEL_IMAGE=_OS1_rhel-guest-image-7.1
RHEL_IMAGE=rhel-guest-image-7.1-20150224.0.x86_64

function usage() {
  echo -e "${INFO} Usage \n"
  echo -e "        \033[0;93m./nova-util.sh create\033[0m"       
  echo -e "        \033[0;93m./nova-util.sh remove\033[0m"
  echo -e "        \033[0;93m./nova-util.sh removeKey\033[0m"
  echo -e "        \033[0;93m./nova-util.sh removeSecGroup\033[0m"
  echo -e "        \033[0;93m./nova-util.sh useRc <downloaded rc file>\033[0m"
  echo " " 
} 

function create() {

  # used for testing 
  # overides the previous set values
  if [ "$1" = "test" ]
  then
    KEYPAIR=abckp
    SECGROUP=abc
    INSTANCES=(abc-test1 abc-test2)
    echo -e "${INFO} Using test parameters"
  else
    echo -e "${INFO} No params"
  fi

  echo -e "${INFO} Creating ssh key pair on openstack saved in the ~/.ssh directory"

  # generate a key-pair
  nova keypair-add ${KEYPAIR} > ~/.ssh/${KEYPAIR}.pem
  chmod 600  ~/.ssh/${KEYPAIR}.pem

  nova keypair-list

  sleep 5;


  echo -e "${INFO} Creating new security group ${SECGROUP}"

  #create security group
  nova secgroup-create ${SECGROUP} 'Openshift v3.1 on OpenStack'


  image=$(nova image-list | grep ${RHEL_IMAGE} | awk '{print $2}')
  flavor=$(nova flavor-list | grep m1.large | awk '{print $2}')

  if [ -z "$image" ] 
  then
    echo -e "${ERROR} Image not found '_OS1_rhel-guest-image-7.1 '"
    exit 1
  fi

  if [ -z "$flavor" ] 
  then
    echo -e "${ERROR} Flavor not found 'm1.large'"
    exit 1
  fi


  echo -e "${DEBUG} Image found ${image}"
  echo -e "${DEBUG} flavor found ${flavor}"

  echo -e "${INFO} Adding rules to ${SECGROUP}"
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


  for i in ${INSTANCES[@]}; do
    echo -e "${INFO} Launching instance ${i}"
    nova boot --flavor ${flavor} --image ${image} --security-groups ${SECGROUP},default --key-name ${KEYPAIR} ${i}
    sleep 10;
  done

  nova list
}

function createServer() {
  updateTime
  image=$(nova image-list | grep ${RHEL_IMAGE} | awk '{print $2}')
  flavor=$(nova flavor-list | grep m1.large | awk '{print $2}')
  echo -e "${DEBUG} --image ${image} "
  
  for i in ${INSTANCES[@]}; do
    echo -e "${INFO} Launching instance ${i}"
    nova boot --flavor ${flavor} --image ${image} --security-groups ${SECGROUP},default --key-name ${KEYPAIR} ${i}
    sleep 10;
  done

  nova list
}

function remove() {
  # used for testing 
  # overides the previous set values
  if [  "$1" = "test" ]
  then
    KEYPAIR=abckp
    SECGROUP=abc
    INSTANCES=(abc-test1 abc-test2)
    echo -e "${INFO} Using test parameters"
  fi

  for i in ${INSTANCES[@]}; do
    echo -e "${INFO} Deleting instance ${i}"
    nova delete ${i}
  done
}

function removeKey() {
  # used for testing 
  # overides the previous set values
  if [  "$1" = "test" ]
  then
    KEYPAIR=abckp
    SECGROUP=abc
    INSTANCES=(abc-test1 abc-test2)
    echo -e "${INFO} Using test parameters"
  fi

  echo -e "${INFO} Deleting keypair ${KEYPAIR}"
  nova keypair-delete ${KEYPAIR}
}

function removeSecGroup() {
  # used for testing 
  # overides the previous set values
  if [  "$1" = "test" ]
  then
    KEYPAIR=abckp
    SECGROUP=abc
    INSTANCES=(abc-test1 abc-test2)
    echo -e "${INFO} Using test parameters"
  fi

  echo -e "${INFO} Deleting security group  ${SECGROUP}"
  nova secgroup-delete ${SECGROUP}
}

updateTime
flag=false

if [ "$#" -eq 0 ]
then
  usage
  exit 1
else

  for var in "${cmds[@]}"
  do
    if [ "${var}" = "${1}" ]
    then
      flag=true
    fi
  done

  if [ "${flag}" = "false" ]
  then
    usage
    exit 1
  fi

  case ${1} in
      create)
        create ${2}
    ;;
    createServer)
        createServer ${2}
    ;;
      remove)
        remove ${2}
    ;;
      removeKey)
        removeKey ${2}
    ;;
      removeSecGroup)
        removeSecGroup ${2}
    ;;
      useRc)
        source ${2}
        exit 0
    ;;
  
  esac


fi

