## troubleshooting gluster issues


# heketi storage getting crazy

```
oc rsh HEKETI_POD
mount to see if the db 
try to mount it manually
reboot otherwise
```

# list heketi volumes from heketi

```
oc rsh HEKETI_POD
heketi-cli --user admin --secret $HEKETI_ADMIN_KEY volume list
```

## checks on gluster pods

```
gluster volume status vol_59dd901bf3ef0f4f284428270f7c5c7f
gluster volume start vol_59dd901bf3ef0f4f284428270f7c5c7f
```

the bricks need to be all online ( they are mounts on the gluster pod)

deleting the pvc does delete the corresponding gluster volume ( but pv is still visible, although released )
