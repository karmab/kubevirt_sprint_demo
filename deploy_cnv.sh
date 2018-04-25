#!/bin/bash
URL="http://zzz.yy.es/f.img"
ansible-playbook -i /root/hosts -e "name=galaxtux type=linux url=$URL namespace=default preload=true" deploy.yaml
