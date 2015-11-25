# Deploy Openshift v3.1 on OpenStack

#### The purpose of this project is to minimize as much manual setup as possible

#### A complete howto for a manual setup of openshift on openstack can be found here https://blog.openshift.com/setting-openshift-3-openstack/ by Veer Muchandi


### Steps
- We make use of the nova client for access to openstack
- If not installed please install it
- A comprehensive guide can be found here http://docs.openstack.org/user-guide/common/cli_install_openstack_command_line_clients.html

- A quick guide to install novaclient on your local machine (assuming you have python installed)

  - pip install python-novaclient
  - pip install python-barbicanclient
  - pip install python-ceilometerclient
  - pip install python-cinderclient
  - pip install python-glanceclient
  - pip install python-gnocchiclient
  - pip install python-heatclient
  - pip install python-magnumclient
  - pip install python-manilaclient
  - pip install python-mistralclient
  - pip install python-muranoclient
  - pip install python-neutronclient
  - pip install python-novaclient
  - pip install python-saharaclient
  - pip install python-swiftclient
  - pip install python-troveclient
  - pip install python-tuskarclient
  - pip install python-openstackclient

- Ensure you have access to openstack and the RHMAP tenant (if not create a service request to allow you access to public openstack RHMAP tenant)
- Login and go to the Access&Security tab then navigate to the API Access sub tab
- Click on the 'Download OpenStack RC File'
- This file will be used in the nova-create.sh script
- The nova-create script will do the following :-
  - Initialise the nova client access (it will ask you for a password)
  - Create a key-pair pem file for access into each instance that is created
  - Create a security group
  - Add rules to this group
  - Launch 4 instances using m1.large flavor and Rhel7.1 guest image (master and 3 nodes)
  - The command nova-list can be used to obtain ip addresses which should be used to update the host file
  - TBD - create floating ip
  - TBD - associate floating ip to instance
  - TBD - create volume (size 15G)
  - TBD - associate volume to instance (use /dev/vdb as device)
  - TBD - check subscription manager (might have to add nameserver 8.8.8.8 nameserver 8.8.4.4 to /etc/resolv.conf)
  - TBD - docker setup (cat <<EOF > /etc/sysconfig/docker-storage-setup
          DEVS=/dev/vdb
          VG=docker-vg
          EOF
  - TBD - execute docker-storage-setup and verify cat /etc/sysconfig/docker-storage
  - TBD - systemctl restart docker
  - TBD - sudo lvextend -r -l +100%FREE /dev/docker-vg/docker-pool


- Once this is completed the xpaas script will execute doing :-
  - Subscription registration
  - Update repositories
  - Install the relevant software
  - Update hostnames
  - Remove NetworkManagr
  - Install and start docker
  - Generate ssh keys
  - Install ansible
  - Clone the openshift ansible git repo
  - Install openshift
  - Configure openshift

  - TBD - sudo su
          yum -y install httpd-tools
          touch /etc/origin/htpasswd
          htpasswd -c /etc/origin/htpasswd test  # enter test as the password

