This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy openshift3.9 on 3 nodes with metrics and cns
- deploy kubevirt using an unified apb (pulling from kubevirt-ansible repo) and deploying an extra storage class
- launch a kubevirt windows vm from windows vm apb 
- access a web service it exposes

### Infra

- 3 Bare metal servers running rhel
- 1 Single centos server used with kvm

We deploy on the 3 nodes:
- openshift ( 1 master and 2 nodes)
- gluster.-kubernetes
- ansible service broker backed up by NFS storage provided on the master
- metrics using the same scheme
- kubevirt using an APB

## requisites

- extras channels if using rhel
- make sure to use a kernel recent enough (3.10.0-693.21.1.el7.x86_64) as it needs to be able to modprobe *target_core_user* module
- install python-passlib and java-1.8.0-openjdk-headless on node running ansible ( for metrics install to work)

## vm deployment

### Using kcli

we use kcli to deploy the vms on a kvm host, Note we cant to the full deployment from kcli, since the node needs to be rebooted to pick a more recent kernel version, so the final commands need to be launched manually

```
kcli plan kubecns
```

### openshift deployment

- to deploy openshift with cns, we run the playbook with this [inventory file](hosts)

```
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/deploy_cluster.yml
```

- to launch metrics afterward

```
ansible-playbook -i /root/hosts playbooks/openshift-metrics/config.yml
```

for metric pod to launch, patch the storageclass so that it is the default one

```
oc patch storageclass glusterfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

# Testing

# Additional information

## Serve windows image from a given node

```
yum -y install httpd
cd /var/www/html
cp /var/lib/libvirt/images/win-test.qcow2 win-test.qcow2
chown apache.apache *
systemct enable httpd
systemctl start httpd
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
```

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
