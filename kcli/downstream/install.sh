#!/bin/bash
yum -y install openshift-ansible screen
[% for master in range(0, masters) %]
ssh-keyscan -H master0[[ master + 1 ]].[[ domain ]] >> ~/.ssh/known_hosts
[% endfor %]
export IP=`dig +short master01.[[ domain ]]`
sed -i "s/#log_path/log_path/" /etc/ansible/ansible.cfg
sed -i "s/openshift_master_default_subdomain=.*/openshift_master_default_subdomain=$IP.xip.io/" /root/hosts
sed -i "s/openshift_master_cluster_hostname=.*/openshift_master_cluster_hostname=$IP.xip.io/" /root/hosts
sed -i "s/openshift_master_cluster_public_hostname=.*/openshift_master_cluster_public_hostname=$IP.xip.io/" /root/hosts
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
[% for master in range(0, masters) %]
ssh root@master0[[ master + 1 ]].[[ domain ]] htpasswd -b /etc/origin/master/htpasswd [[ user ]] [[ password ]]
[% endfor %]
oc adm policy add-cluster-role-to-user cluster-admin developer
oc patch namespace openshift-ansible-service-broker  -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'
