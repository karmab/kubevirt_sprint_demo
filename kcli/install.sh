#!/bin/bash
yum -y install openshift-ansible screen
[% for master in range(0, masters) %]
ssh-keyscan -H master0[[ master + 1 ]].[[ domain ]] >> ~/.ssh/known_hosts
[% endfor %]
ssh-keyscan -H master.[[ domain ]] >> ~/.ssh/known_hosts
sed -i "s/#log_path/log_path/" /etc/ansible/ansible.cfg
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
[% for master in range(0, masters) %]
ssh root@master0[[ master + 1 ]].[[ domain ]] htpasswd -b /etc/origin/master/htpasswd [[ user ]] [[ password ]]
[% endfor %]
oc adm policy add-cluster-role-to-user cluster-admin developer
