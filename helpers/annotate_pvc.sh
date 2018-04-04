#/bin/bash
NAMESPACE=${2:-default}
PV=`oc get pvc $1 -n $NAMESPACE -o jsonpath={'.spec.volumeName'}`
ID=`oc get pv $PV -o jsonpath='{.metadata.annotations.gluster\.org/heketi-volume-id}'`
echo Running oc annotate pvc $1 -n $NAMESPACE gluster.org/heketi-volume-id=$ID
oc annotate pvc $1 -n $NAMESPACE gluster.org/heketi-volume-id=$ID
