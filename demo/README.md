# Demo Resources Role

Deploy Demo resources onto a cluster.

### Role Variables
| variable       | default           |choices           | comments  |
|:-------------|:-------------|:----------|:----------|
|user|   | _optional_ |User with cluster-admin permissions.|
|password| |_optional_|Password for **admin_user**.|
|namespace|default | |Namespace to create resources.|
|vm_name|windows | |Ovm name to create.|
|action|provision| <ul><li>provision</li><li>deprovision</li></ul>|Action to perform.|
|plan | gluster | <ul><li>storage-none</li><li>storage-demo</li><li>storage-glusterfs</li></ul> | Storage role to install with KubeVirt.|
|version |0.4.1|<ul><li>0.4.1</li><li>0.4.0</li><li>0.3.0</li><li>0.2.0</li><li>0.1.0</li></ul>|KubeVirt release version.|

### How to run

```
ansible-playbook -i hosts deploy.yml
```
