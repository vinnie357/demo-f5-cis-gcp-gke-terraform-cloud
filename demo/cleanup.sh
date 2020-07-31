#!/bin/bash
# expects sed/gcloud/jq best run in google cloud shell
# assumes setup has been run
# cluster name
#gcloud container clusters list --filter name:cis-demo-gke --format json | jq .[].name
clusterName=$(gcloud container clusters list --filter name:cis-demo-gke --format json | jq -r .[].name)
# zone
#gcloud container clusters list --filter name:cis-demo-gke --format json | jq .[].zone
zone=$(gcloud container clusters list --filter name:cis-demo-gke --format json | jq -r .[].zone)
# project
project=$(gcloud info --format json | jq -r .config.project)
# cluster creds
gcloud container clusters \
    get-credentials  $clusterName	 \
    --zone $zone
# delete cis
kubectl delete node big-ip-cis-1
kubectl delete deployment k8s-bigip-ctlr-deployment -n kube-system
kubectl delete clusterrolebinding k8s-bigip-ctlr-clusteradmin
kubectl delete serviceaccount k8s-bigip-ctlr -n kube-system
kubectl delete secret bigip-login -n kube-system
# delete app deployments
kubectl delete svc owasp-juiceshop
kubectl delete deployment owasp-juiceshop
kubectl delete configmaps f5-as3-declaration-juiceshop
# delete fw rule
#gcloud compute --project=$project firewall-rules delete cis-ingress

echo "====Done===="