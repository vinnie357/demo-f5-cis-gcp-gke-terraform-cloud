# https://github.com/mdditt2000/kubernetes-1-18/blob/master/cis%201.14/QuickStartGuideCluster.md
# https://github.com/mdditt2000/kubernetes-1-18/blob/master/cis%201.14/QuickStartGuideNode.md

1. setup flannel if desired

2. get cluster credentials
    gcloud container clusters \
        get-credentials cis-demo-gke-cluster-splendid-llama	 \
        --zone us-east1-b
2. configure cis deployment
    kubectl create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password='mypassword'
    kubectl create serviceaccount k8s-bigip-ctlr -n kube-system
    kubectl create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr
    kubectl create -f demo/container-controller/f5-cluster-deployment.yaml
3. configure bigip node
    kubectl create -f demo/big-ip/f5-bigip-node.yaml
4. deploy a service/app
    kubectl create -f demo/app/f5-hello-world-deployment.yaml
    kubectl create -f demo/app/f5-hello-world-service.yaml
4. deploy a config map
    kubectl create -f demo/config-maps/f5-as3-configmap.yaml