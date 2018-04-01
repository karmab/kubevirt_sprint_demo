This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy openshift 3.9 on 3 masters + 3 nodes with metrics and cns, centos as base OS
- ansible service broker backed up by NFS storage provided on the first master
- deploy kubevirt
- launch a vm with selinux enabled on the nodes
- access windows vm using exposed rdp
- switch the sqlserver of the vm to an external one

## infra used

- one 64GB physical machine. All nodes are VM with 8Gb of RAM and an extra 100GB disk for the master

## requisites

- extras channels if using rhel
- make sure to use a kernel recent enough (3.10.0-693.21.1.el7.x86_64) as it needs to be able to modprobe *target_core_user* module
- install python-passlib and java-1.8.0-openjdk-headless on node running ansible ( for metrics install to work)

## deployment

### openshift

- nodes were provisioned with rhel7.4 cloud image

- to deploy openshift with cns, we run the playbook with this [inventory file](hosts)

```
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /root/openshift-ansible/playbooks/deploy_cluster.yml
```

for asb pods to launch, openshift-ansible-service-broker project needs to be patched

```
oc patch namespace openshift-ansible-service-broker  -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'
```

### post install 

- to deploy kubevirt, we use provided kubevirt APB and select storage-cns flavor

- we also disable selinux on all the nodes in order to be able to launch vms and install virtctl. For this task, the playbook [post.yml](post.yml) can be used, against the same inventory

## Testing

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

- access windows vm rdp
 
for this, we used an ssh tunnel on the master to reach port 3389 on the private ip of the vm
 
- expose web service of the vm 

```
NAME="vm1"
oc expose `oc get pod -l kubevirt.io/domain=$NAME -o name` --port=80 --name=$NAME-web
oc expose svc --hostname=wingtiptoys.10.19.139.31.xip.io $NAME-web
```

- switch sql server

 TODO


## Additional information

- expose svc with a loadbalancer

```
oc expose pod virt-launcher-vm1-ephemeral-bbpbp --port=80 --name=mytest --type=LoadBalancer
```

## Lessons learnt

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
