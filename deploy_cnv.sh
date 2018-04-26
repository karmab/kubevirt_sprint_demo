#!/bin/bash
URL="https://download.fedoraproject.org/pub/fedora/linux/releases/27/CloudImages/x86_64/images/Fedora-Cloud-Base-27-1.6.x86_64.qcow2"
PUBKEY=`cat ~/.ssh/id_rsa.pub`
ansible-playbook -i /root/hosts -e "name=fedora type=linux url=$URL public_key=\"$PUBKEY\" namespace=default sync=false" deploy.yml
