This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy openshift3.9 on 3 nodes with metrics and cns
- deploy kubevirt using an unified apb (pulling from kubevirt-ansible repo) and deploying an extra storage class
- install a window template
- launch a kubevirt windows vm instanciating the template
- access a web service exposed on the vm

## infra used

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


### openshift

- nodes were provisioned with rhel7.4 using a dedicated satellite and subscribed to the extras channel.

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

## Testing

- import cirros image with a dedicated [disk-importer pod](import-windows.yml)

```
oc create -f import-cirros.yml
```

- import windows image with a [disk-importer pod](import-windows.yml)

```
oc create -f import-windows.yml
```

alternatively we can install [disk import template](import-windows-template.yml)

```
oc create -f import-windows-template.yml -n openshift
```

- install [windows template](windows-template.yml)

```
oc create -f windows-template.yml -n openshift
```

- deploy a windows vm using template from the openshift UI ( and specifying an existing PVC_NAME), which also indicates that the underlying vm should be started

- check offlinevirtualmachine is there 

```
oc get ovm -n default
```

- access windows vm rdp
 
 for this, we used an ssh tunnel on the master to reach port 3389 on the private ip of the vm
 

- expose web service of the vm 

```
NAME="vm1"
oc expose `oc get pod -l kubevirt.io/domain=$NAME -o name` --port=80 --name=$NAME-web
oc expose svc --hostname=wingtiptoys.10.19.139.31.xip.io $NAME-web
```

## Additional information

- Serve windows image from a given node

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

- Delete completed pods

```
oc get pods --field-selector=status.phase!=Running -o name | xargs oc delete
```

- expose svc with a loadbalancer

```
oc expose pod virt-launcher-vm1-ephemeral-bbpbp --port=80 --name=mytest --type=LoadBalancer
```

## Lessons learnt

- better to run the main playbook for openshift and then dedicated one for gluster and metrics
- make sure you have all the relevant links for testing of all components

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
