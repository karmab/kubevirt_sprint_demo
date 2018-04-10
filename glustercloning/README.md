### deploy clone enabled gluster provisioner

- we need to substitute *rhgs3/rhgs-volmanager-rhel7:latest* for *gluster/heketiclone* in the heketi-storage dc

```
oc set image deploy/webconsole heketi=gluster/heketiclone:latest  -n app-storage
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
