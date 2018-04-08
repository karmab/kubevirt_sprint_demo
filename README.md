This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy downstream openshift 3.9 on 3 masters + 3 nodes with metrics and cns
- deploy latest kubevirt
- import windows vm with v2v apb
- launch a windows vm using windows vm apb and using a cloned pvc
- access windows vm using exposed rdp fron the outside
- switch the sqlserver of the vm to an external one
- show vm entities in the console

## current issues


- need to find the best HA name for master config... defaulting to first node is wrong
- heketi admin secret type has to be changed to gluster.org/glusterfile, making default gluster storage class useless
- custom build of the custom webconsole image  crashloops
- same template fails to be deployed through template service broker. should leave in default project if old templating system will be used
- seeding script to additional sqlserver is missing
- need to find out proper sqlserver connection string for remote access
- fedora vms lack default route
- load balancer ips can't be reached through openvpn

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


### deploy clone enabled gluster provisioner

- we need to substitute *rhgs3/rhgs-volmanager-rhel7:latest* for *gluster/heketiclone* in the heketi-storage dc

```
oc patch dc/heketi-storage  -n app-storage -p '{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"heketi"}],"containers":[{"image":"gluster/heketiclone:latest","name":"heketi"}]}}}}'
oc patch dc/heketi-storage  -n app-storage -p '{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"heketi"}],"containers":[{"image":"gluster/heketiclone:latest","name":"heketi"}]}}}}'
```

Note that this could also be done during initial deployment using this additional  inventory variable
*openshift_storage_glusterfs_heketi_image: gluster/heketiclone*

- deploy the external provisioner using [glusterfile-provisioner.yml](glusterfile-provisioner.yml)

```
oc project app-storage
oc create -f  glusterfile-provisioner.yml
```

- add the proper provisioner and smartclone to the kubevirt storage class ( Note it needs to be recreated, as updating the provisioner is forbidden)

```
oc get sc kubevirt -o yaml | sed "s@provisioner:.*@  smartclone: \"true\"\nprovisioner: gluster.org/glusterfile@" > kubevirt-sc.yml
oc delete -f kubevirt-sc.yml
oc create -f kubevirt-sc.yml
```

- switch kubevirt sc so it's the default one!!!
- change the type of the secret type: heketi-storage-admin-secret to *gluster.org/glusterfile*

```
oc get secret heketi-storage-admin-secret -o yaml -n app-storage > secret.yaml.old
oc get secret heketi-storage-admin-secret -o yaml -n app-storage > secret.yaml
oc delete -f secret.yml
oc create -f secret.yml
```

### deploy custom webconsole with vm entities

- build a custom image with the required patches using procedure described in [console.sh](console.sh)
- push the image in docker hub
- update webconsole deployment to use the custom image

```
oc get deploy webconsole -n openshift-web-console  -o yaml > webconsole.yml.old
oc patch deploy/webconsole  -n openshift-web-console -p '{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"webconsole"}],"containers":[{"image":"jniederm/origin-web-console:demo-v2-ebd3660c-47b77c45","name":"webconsole"}]}}}}'
```

### seed sqlserver linux database 
TODO

## Testing

- import windows image with the dedicated import-disk apb

```
oc create -f import-disk-apb.yml
```

- install [windows template](windows-template.yml)

```
oc create -f windows-template.yml -n default
```

- deploy a windows vm using template from the openshift UI ( and specifying an existing PVC_NAME). this will:
  - create the offline vm and start it
  - create a service for rdp (using node port, as load balancer is failing because of vpn routing issues)
  - create a service and a route for http

- access windows vm rdp locating on which node the vm is running and getting the nodeport used from the services tab
 
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
sudo cp gdrive-linux-x64 /usr/bin/gdrive
sudo chmod a+x /usr/bin/gdrive
gdrive download 1hG9otdB7Vs2J1nqwyUPpdVKP3QdvAqoC
qemu-img convert -O raw SummitVM.vdi SummitVM.img
```

- [gluster troubleshooting](gluster.md]

## Lessons learnt

- needs links for everything that needs testing!

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
