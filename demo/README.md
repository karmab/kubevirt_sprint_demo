# Demo Resources Role

Deploy Demo resources onto a cluster.

- kubevirt with a given storage flavor
- an openshift template for deploying an ovm with additional services (http and either ssh/rdp)
- import two disks
- launch a sample vm using pretty much the same

### Requirements

a Running *openshift+gluster* cluster with ansible service broker enabled


### Role Variables
| variable       | default           |choices           | comments  |
|:-------------|:-------------|:----------|:----------|
|user|developer||User with cluster-admin permissions.|
|password|developer||Password for **admin_user**.|
|namespace|default | |Namespace where to create resources.|
|vm_type|windows |<ul><li>linux</li><li>windows</li></ul>|Ovm name to create.|
|action|provision| <ul><li>provision</li><li>deprovision</li></ul>|Action to perform.|
|plan | gluster | <ul><li>storage-none</li><li>storage-demo</li><li>storage-glusterfs</li></ul> | Storage role to install|
|registry|docker.io||registry where to grab apbs|
|repository|mutism||repository where to grab apbs|
|preload|true||Whether to preload apbs to openshift registry|
|image_url|http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img||Url where to download base OS|
|apb_list|import-vm-disk-apb, kubevirt-apb, mssql-apb||List of apbs to push|

### How to run

```
ansible-playbook -i hosts deploy.yml
```
