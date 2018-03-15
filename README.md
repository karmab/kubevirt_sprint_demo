This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy openshift3.9 on 3 nodes with metrics and cns
- deploy kubevirt using an unified apb (pulling from kubevirt-ansible repo) and deploying an extra storage class
- launch a kubevirt windows vm from windows vm apb (using an underlying template)
- access a web service exposed on the vm

### Infra

- 3 Bare metal servers running rhel

additionally a single centos server was used with kvm to deploy the same setup

We will deploy the following on the 3 nodes:

- openshift ( 1 master and 2 nodes)
- gluster.-kubernetes
- ansible service broker backed up by NFS storage provided on the master
- metrics using the same scheme
- kubevirt using an APB

## requisites

- extras channels if using rhel
- make sure to use a kernel recent enough (3.10.0-693.21.1.el7.x86_64) as it needs to be able to modprobe *target_core_user* module
- install python-passlib and java-1.8.0-openjdk-headless on node running ansible ( for metrics install to work)

## deployment

### On the physical nodes

nodes were provisioned with rhel7.4 using a dedicated satellite and subscribed to the extras channel.

### On vms

we use [*kcli*](https://github.com/karmab/kcli) to deploy the vms on a kvm host, Note we can't do the full deployment from kcli, since the node needs to be rebooted to pick a more recent kernel version, so the final commands need to be launched manually once the nodes are ready.

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

this is needed for the pod hawkular-cassandra and the metrics-cassandra-1 pvc

### post install 

- to deploy kubevirt, we use provided kubevirt APB and select storage-cns flavor

- we also disable selinux on all the nodes in order to be able to launch vms and install virtctl. For this task, the playbook [post.yml](post.yml) can be used, against the same inventory

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

## Lessons learnt

- better to run the main playbook for openshift and then dedicated one for gluster and metrics

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
