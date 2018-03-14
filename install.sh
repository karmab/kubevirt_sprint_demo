#!/bin/bash
sleep 360
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm screen
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel  install ansible git
cd /root
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
git checkout [[ openshift_version ]]
ssh-keyscan -H master01.[[ domain ]] >> ~/.ssh/known_hosts
[% for node in range(0, nodes) %]
ssh-keyscan -H node0[[ node + 1 ]].[[ domain ]] >> ~/.ssh/known_hosts
[% endfor %]
export IP=`dig +short node01.[[ domain ]]`
sed -i "s/#log_path/log_path/" /etc/ansible/ansible.cfg
sed -i "s/openshift_master_default_subdomain=.*/openshift_master_default_subdomain=$IP.xip.io/" /root/hosts
[% if deploy %]
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/deploy_cluster.yml
htpasswd -b /etc/origin/master/htpasswd [[ user ]] [[ password ]]
[% else %]
echo ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/deploy_cluster.yml >> /root/install2.sh
echo htpasswd -b /etc/origin/master/htpasswd [[ user ]] [[ password ]] >> /root/install2.sh
[% endif %]
[% for node in range(0, nodes) %]
ssh root@node0[[ node + 1 ]].[[ domain ]] reboot
[% endfor %]
reboot
