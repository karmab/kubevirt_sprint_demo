#!/bin/bash
yum -y install openshift-ansible screen
ssh-keyscan -H cnvdemo1.cloud.lab.eng.bos.redhat.com >> ~/.ssh/known_hosts
ssh-keyscan -H cnvdemo2.cloud.lab.eng.bos.redhat.com >> ~/.ssh/known_hosts
ssh-keyscan -H cnvdemo3.cloud.lab.eng.bos.redhat.com >> ~/.ssh/known_hosts
export IP=`dig +short cnvdemo1.cloud.lab.eng.bos.redhat.com`
sed -i "s/#log_path/log_path/" /etc/ansible/ansible.cfg
sed -i "s/openshift_master_default_subdomain=.*/openshift_master_default_subdomain=$IP.xip.io/" /root/hosts
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
ssh root@cnvdemo1.cloud.lab.eng.bos.redhat.com htpasswd -b /etc/origin/master/htpasswd developer developer
ssh root@cnvdemo2.cloud.lab.eng.bos.redhat.com htpasswd -b /etc/origin/master/htpasswd developer developer
ssh root@cnvdemo3.cloud.lab.eng.bos.redhat.com htpasswd -b /etc/origin/master/htpasswd developer developer
oc adm policy add-cluster-role-to-user cluster-admin developer
