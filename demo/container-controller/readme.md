#https://github.com/mdditt2000/kubernetes-1-18/tree/master/cis%201.14/big-ip-92-cluster


#create kubernetes bigip container connecter, authentication and RBAC
kubectl create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password='myPassword@'
kubectl create serviceaccount k8s-bigip-ctlr -n kube-system
kubectl create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr
kubectl create -f f5-cluster-deployment.yaml
kubectl create -f f5-bigip-node.yaml


kubectl create -f f5-as3-configmap.yaml
kubectl create -f ../config-maps/f5-as3-configmap.yaml

kubectl create -f f5-k8s-ingress.yaml

kubectl get pod -n kube-system
kubectl log -f f5-server-### -n kube-system | grep -i 'as3'
kubectl logs -n kube-system k8s-bigip-ctlr-deployment-6cdb4bbb96-xs9x4 --follow

#delete kubernetes bigip container connecter, authentication and RBAC 
kubectl delete node bigip1
kubectl delete deployment k8s-bigip-ctlr-deployment -n kube-system
kubectl delete clusterrolebinding k8s-bigip-ctlr-clusteradmin
kubectl delete serviceaccount k8s-bigip-ctlr -n kube-system
kubectl delete secret bigip-login -n kube-system

