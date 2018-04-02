## deploying on a kvm host, from a box with kcli installed

```
kcli plan sprint7
```

# grabbing the rendered files (in the results directory) so they can be used on baremetal or other virtualization platforms

```
mkdir results
docker run -it --rm -v results:/tmp --entrypoint=/bin/bash karmab/plan -g github.com/karmab/kubevirt_sprint_demo/kcli/downstream
```
