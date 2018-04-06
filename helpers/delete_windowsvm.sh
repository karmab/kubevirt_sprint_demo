NAMESPACE=`oc project -q`
oc delete ovm $1 -n $NAMESPACE
oc delete route http-$1 -n $NAMESPACE
oc delete svc http-$1 -n $NAMESPACE
oc delete svc rdp-$1 -n $NAMESPACE
oc delete pvc $1 -n $NAMESPACE
