This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy downstream openshift 3.9 on 3 masters + 3 nodes with metrics and cns
- deploy latest kubevirt
- import windows vm with v2v apb
- launch a windows vm using windows vm apb and using a cloned pvc
- access windows vm using exposed rdp fron the outside
- switch the sqlserver of the vm to an external one
- show vm entities in the console

## infra used

- 3  BM physical machines with two additional SSD disks ( for docker and glusterfs)

## requisites

- kernel recent enough (3.10.0-693.21.1.el7.x86_64) as it needs to be able to modprobe *target_core_user* module

## deployment

### basic openshift installation

- nodes provisioned with rhel7.4

- nodes prepared with [this script](installation/runcmd_master)

- we launch [this script](installation/install.sh) on the first master
  among other things, it deploys openshift with this [inventory file](installation/hosts)

### post install 

- to deploy kubevirt, we use provided kubevirt APB and select storage-cns flavor. we use `oc create` with the following file [kubevirt-apb.yml](kubevirt-apb.yml)

- we used the following playbook [post.yml](post.yml) to disable selinux and install virtctl on all the nodes, using the same inventory

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


- fix broker-config configmap so we get apbs from docker hub

```
NAMESPACE="openshift-ansible-service-broker"
oc project $NAMESPACE
oc get cm broker-config -o yaml > broker-config-full.yml.old
oc get cm broker-config -o jsonpath={'.data.broker-config'} > broker-config.yml.old
oc delete cm broker-config
oc create cm broker-config --from-file=broker-config=broker-config.yml
oc delete pod --all
```

- download a big image from a google drive  ( using gdrive command line)

```
# get image at https://github.com/prasmussen/gdrive#downloads
sudo cp gdrive-linux-x64 /usr/local/bin/gdrive;
sudo chmod a+x /usr/local/bin/gdrive;
gdrive download 0B7_OwkDsUIgFWXA1B2FPQfV5S8H
```

- expose svc with a loadbalancer

```
oc expose pod virt-launcher-vm1-ephemeral-bbpbp --port=80 --name=mytest --type=LoadBalancer
```

## Lessons learnt

- needs links for everything that needs testing!

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
