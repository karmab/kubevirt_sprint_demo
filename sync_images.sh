#!/bin/bash

# this script sync images to docker repo

HUB="docker.io"
ORG="mutism"
TAG="demo"
IMAGES="ansibleplaybookbundle/kubevirt-apb jniederm/origin-web-console:demo-v9 ansibleplaybookbundle/mssql-apb:latest docker.io/ansibleplaybookbundle/kubevirt-apb:latest kubevirt/virt-api:v0.4.1 kubevirt/virt-controller:v0.4.1 kubevirt/virt-handler:v0.4.1 kubevirt/virt-launcher:v0.4.1 gluster/heketiclone:latest jcoperh/importer:latest ansibleplaybookbundle/import-vm-disk-apb:latest ansibleplaybookbundle/import-vm-apb:latest ansibleplaybookbundle/windows-vm-apb:latest"
for image in $IMAGES ; do
  echo "Processing $image"
  id=`docker images $image -q`
  name=`echo $image | cut -d'/' -f2 | cut -d':' -f1`
  docker tag $id $HUB/$ORG/$name:$TAG
  docker push $HUB/$ORG/$name:$TAG
  echo "------------------------------"
done
