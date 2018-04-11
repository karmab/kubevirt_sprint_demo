This repo holds details for the demo of the current sprint work in kubevirt

## scope of the demo

- deploy downstream openshift 3.9 on 3 masters + 3 nodes with metrics and cns
- deploy latest kubevirt
- show v2v apb
- import windows vm disk with v2v apb
- show vm entities in the console, start vm from console
- launch a windows vm using windows vm template
- access windows vm using exposed rdp fron the outside
- deploy an sqlserver apb
- switch the sqlserver of windows to this external one

## current issues

- need to find the best HA name for master config... defaulting to first node is wrong
- same template fails to be deployed through template service broker. should leave in default project if old templating system will be used
- seeding script to additional sqlserver is missing
- need to find out proper sqlserver connection string for remote access
- load balancer ips can't be reached through openvpn
- cloning disabled

## infra used

- 3  BM physical machines with two additional SSD disks ( for docker and glusterfs)
- openshift-ansible-roles-3.9.14-1.git.3.c62bc34.el7.noarch

## requisites

- kernel recent enough (3.10.0-693.21.1.el7.x86_64) as it needs to be able to modprobe *target_core_user* module

## deployment

### basic openshift installation

- nodes provisioned with rhel7.4 and subscribed to 
  - rhel-7-server-rpms
  - rhel-7-server-extras-rpms
  - rhel-7-server-ose-3.9-rpms
  - rhel-7-fast-datapath-rpms
  - rhel-7-server-ansible-2.4-rpms

- we deploy openshift with this [inventory file](hosts) and with the following commands on first master
  we also use the following playbook [post.yml](post.yml) to disable selinux and install virtctl on all the nodes

```
yum -y install openshift-ansible screen
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```

### post install 

we disable selinux and install virtctl on all the nodes with this template

```
ansible-playbook -i /root/hosts /root/post.yml
```

- we fix broker-config configmap so we get apbs from docker hub

```
NAMESPACE="openshift-ansible-service-broker"
oc project $NAMESPACE
oc get cm broker-config -o yaml > broker-config-full.yml.old
oc get cm broker-config -o jsonpath={'.data.broker-config'} > broker-config.yml.old
oc delete cm broker-config
oc create cm broker-config --from-file=broker-config=broker-config.yml
oc delete pod --all
```

### kubevirt

we use the existing kubevirt APB with storage-cns flavor. the following file [kubevirt-apb.yml](kubevirt-apb.yml) is used

```
oc create -f kubevirt-apb.yml
```

### deploy custom webconsole with vm entities

- update webconsole deployment to use the custom image

```
IMAGE="jniederm/origin-web-console:demo-v4"
oc set image deploy/webconsole webconsole=$IMAGE  -n openshift-web-console
```

- TODO: document how to build a custom image with the required patches available [here](https://happylynx.github.io/2018/04/06/custom-compilation-of-origin-web-console.html)

### Import windows image as a pvc

- we import windows image twice with the dedicated import-disk apb to the pvcs [windows](import-disk-apb.yml) and [windows2](import-disk-apb2.yml)

```
oc create -f import-disk-apb.yml
oc create -f import-disk-apb2.yml
```

### Install templates

- [windows runonce template](windows-template-runonce.yml) using the windows pvc, and intended to be launched once and not destroyed
- [windows template2](windows-template2.yml) using the windows2 pvc, and intended to be used for creation/deletion test

```
oc create -f windows-template-runonce.yml -n default
oc create -f windows-template2.yml -n openshift
```

## Workflow


- deploy a windows vm using template from the openshift UI. this will:
  - create the offline vm (stopped) based on the existing windows pvc
  - create a service for rdp (using node port, as load balancer is failing because of vpn routing issues)
  - create a service and a route for http
- access windows vm rdp locating on which node the vm is running and getting the nodeport used from the services tab
- TODO: seed sqlserver linux database 
- TODO: switch sql server DB in the windows vm

## Additional tricks

- handle cache issues in ansible service broker

  use the provided script [clean_service_catalog.sh](clean_service_catalog.sh)


- downloading a big image from a google drive with command line

```
# get image at https://github.com/prasmussen/gdrive#downloads
sudo cp gdrive-linux-x64 /usr/bin/gdrive
sudo chmod a+x /usr/bin/gdrive
gdrive download 1hG9otdB7Vs2J1nqwyUPpdVKP3QdvAqoC
qemu-img convert -O raw SummitVM.vdi SummitVM.img
```

- we cover gluster cloning in a separate [doc](glustercloning/README.md)

## Lessons learnt

- needs links for everything that needs testing!

## Problems?

Send me a mail at [karimboumedhel@gmail.com](mailto:karimboumedhel@gmail.com) !

Mac Fly!!!

karmab
