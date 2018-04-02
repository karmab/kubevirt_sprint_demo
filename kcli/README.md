
briefly documents how to leverage kcli for the deployment 

### deploying on a kvm host, from a box with kcli installed. run the following, from root directory

```
kcli plan sprint7
```

### manual process

we will grab the rendered files (in the results directory) so they can be used on baremetal or other virtualization platforms

- put a subscription script in ~/register.sh

```
sleep 30
subscription-manager register --force --activationkey=MYKEY --org=XXX
subscription-manager repos --enable=rhel-7-server-rpms
```

- have a look at parameters that can be overriden with -P

```
docker run -it --rm karmab/kcli plan -g github.com/karmab/kubevirt_sprint_demo --info
```

- generate the rendered files, scripts and commands in the ~/results directory

```
docker run -it --rm -v ~/register.sh:/root/register.sh -v ~/results:/tmp karmab/kcli plan -g github.com/karmab/kubevirt_sprint_demo
```

- a variant using parameters,

```
docker run -it --rm -v ~/register.sh:/root/register.sh -v ~/results:/tmp karmab/kcli plan -g github.com/karmab/kubevirt_sprint_demo -P domain=cloud.lab.eng.bos.redhat.com -P docker_disk_device=sdn -P cns_disk_device=sdo
```
