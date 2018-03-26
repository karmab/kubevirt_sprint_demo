#!/bin/bash
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm screen
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel  install ansible git
cd /root
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
git checkout [[ openshift_version ]]
[% for master in range(0, masters) %]
ssh-keyscan -H master0[[ node + 1 ]].[[ domain ]] >> ~/.ssh/known_hosts
[% endfor %]
[% for node in range(0, nodes) %]
ssh-keyscan -H node0[[ node + 1 ]].[[ domain ]] >> ~/.ssh/known_hosts
[% endfor %]
export IP=`dig +short master01.[[ domain ]]`
sed -i "s/#log_path/log_path/" /etc/ansible/ansible.cfg
sed -i "s/openshift_master_default_subdomain=.*/openshift_master_default_subdomain=$IP.xip.io/" /root/hosts
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/deploy_cluster.yml
[% for master in range(0, masters) %]
ssh root@master0[[ node + 1 ]].[[ domain ]] htpasswd -b /etc/origin/master/htpasswd [[ user ]] [[ password ]]
[% endfor %]
oc adm policy add-cluster-role-to-user cluster-admin developer
