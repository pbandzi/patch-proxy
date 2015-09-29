#!/bin/bash
# Must be running from foreman/ci directory in genesis cloned repo

# must use escape char '\' in proxy address before'/' 
# e.g. http:\/\/proxy.example.com:123
PROXY='http:\/\/proxy.example.com:80'
# IP addrress of DNS server
CUSTOM_DNS='8.8.8.8'
# e.g. example.com
CUSTOM_DOMAIN='example.com'

#GENESIS_DIR=${PWD%/foreman/ci}

## environment.txt
sed -i "s/REPLACE/$PROXY/g" environment.txt

## deploy.sh
# replace git clone for cp
# delete 3 lines after pattern excluding pattern
# -> not neeeded anymore - cp is used also in original script now
#sed -i -e '/GIT_SSL_NO_VERIFY=true/{n;N;N;d}' deploy.sh
# change patern
#sed -i 's|^.*GIT_SSL_NO_VERIFY=true.*|cp -rf '$GENESIS_DIR' \/tmp\/|g' deploy.sh

## bootstrap.sh
# a -> append
# i -> prepend
# linux env proxy
sed -i "/##END VARS/a sed -i \'s|elif errcode in (42, 55, 56):|elif errcode == 42:|\' \/usr\/lib\/python2.7\/site-packages\/urlgrabber\/grabber.py" bootstrap.sh

# When https_proxy enabled we are not able to check if installation finnished successfully
# Getting: requests.exceptions.ConnectionError
#sed -i "/##END VARS/a echo \"export https_proxy=$PROXY\" >> \/etc\/bashrc" bootstrap.sh

sed -i "/##END VARS/a export https_proxy=$PROXY" bootstrap.sh
# yum proxy
sed -i "/##END VARS/a echo \"proxy=$PROXY\" >> \/etc\/yum.conf" bootstrap.sh
# proxy for ansible
sed -i "/run.sh.*/i cp \/vagrant\/environment.txt \/opt\/khaleesi\/" bootstrap.sh
sed -i "/run.sh.*/i sed -i \'\/\^- name: Install Foreman\/r environment.txt\' playbooks\/opnfv-vm.yml" bootstrap.sh
# cannot do following because deploy script will overwrite it (opnfv.yml -> opnfv-vm.yml). But I don't need it anyway now for VM
#sed -i "/run.sh.*/i sed -i \'\/\^- name: Install Foreman\/r environment.txt\' playbooks\/opnfv.yml" bootstrap.sh

sed -i "/run.sh.*/i sed -i \'\/git:\/i INSERTION_MARKER\' \/opt\/khaleesi\/roles\/foreman\/opnfv-install\/tasks\/main.yml" bootstrap.sh
sed -i "/run.sh.*/i sed -i \'\/INSERTION_MARKER\/r environment.txt\' \/opt\/khaleesi\/roles\/foreman\/opnfv-install\/tasks\/main.yml" bootstrap.sh
sed -i "/run.sh.*/i sed -i \'\/INSERTION_MARKER\/d\' \/opt\/khaleesi\/roles\/foreman\/opnfv-install\/tasks\/main.yml" bootstrap.sh

## vm_nodes_provision.sh
# linux env proxy
sed -i "/##END VARS/a echo \"export https_proxy=$PROXY\" >> \/etc\/bashrc" vm_nodes_provision.sh
# yum proxy
sed -i "/##END VARS/a echo \"proxy=$PROXY\" >> \/etc\/yum.conf" vm_nodes_provision.sh
# resolv.conf
sed -i "s/^nameserver 8.8.8.8/nameserver $CUSTOM_DNS/g" vm_nodes_provision.sh
sed -i "s/^search ci.com opnfv.com/search ci.com opnfv.com $CUSTOM_DOMAIN/g" vm_nodes_provision.sh
