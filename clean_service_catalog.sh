#!/bin/bash
oc get clusterserviceclass --no-headers | awk '{ print $1 }' | xargs oc delete clusterserviceclass
oc get clusterserviceplan --no-headers | awk '{ print $1 }' | xargs oc delete clusterserviceplan
oc get bundles --no-headers | xargs oc delete bundles
apb bootstrap
apb relist
oc delete pod --all -n openshift-template-service-broker
