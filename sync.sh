#!/bin/bash

# this script sync images to docker repo

HUB="docker.io"
ORG="mutism"
TAG="demo
image="$1"
echo "Processing $image"
  id=`docker images $image -q`
  name=`echo $image | cut -d'/' -f2 | cut -d':' -f1`
  docker tag $id $HUB/$ORG/$name:$TAG
  docker push $HUB/$ORG/$name:$TAG
  echo "------------------------------"
