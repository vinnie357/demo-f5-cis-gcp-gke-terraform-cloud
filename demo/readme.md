# CIS GKE Demo setup
https://github.com/mdditt2000/kubernetes-1-18/blob/master/cis%201.14/QuickStartGuideCluster.md 
https://github.com/mdditt2000/kubernetes-1-18/blob/master/cis%201.14/QuickStartGuideNode.md


TLDR:
        connect to cloud shell

            cd demo
            . setup.sh


1. ~~setup flannel if desired~~

2. get cluster credentials

        clusterName=$(gcloud container clusters list --filter name:cis-demo-gke --format json | jq -r .[].name)
        zone=$(gcloud container clusters list --filter name:cis-demo-gke --format json | jq -r .[].zone)
        gcloud container clusters \
        get-credentials  $clusterName	 \
        --zone $zone
        or:    
        gcloud container clusters \
            get-credentials  cis-demo-gke-cluster-living-mullet	 \
            --zone us-east1-b
2. configure cis deployment

        kubectl create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password='mypassword'
        kubectl create serviceaccount k8s-bigip-ctlr -n kube-system
        kubectl create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr
        kubectl create -f demo/container-controller/f5-cluster-deployment.yaml
3. ~~configure bigip node~~

    ~~kubectl create -f demo/big-ip/f5-bigip-node.yaml~~
4. deploy a service/app

        kubectl create -f demo/app/f5-hello-world-deployment.yaml
        kubectl create -f demo/app/f5-hello-world-service.yaml
4. deploy a config map

        kubectl create -f demo/config-maps/f5-as3-configmap.yaml



## to automate ##

add public ips of k8s nodes to mgmt acl ??
switch to "external network add routes and acls"
define config map
- template selfip for virtual address
- ?? irule for the sni/routing?
- as3 