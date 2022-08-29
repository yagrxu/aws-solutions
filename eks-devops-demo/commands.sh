# /bin/bash

# local setup
aws eks update-kubeconfig --name event_0714 --kubeconfig ~/.kube/config-event-0714 --region ap-southeast-1 --alias config-event-0714

# balance cross zone
kubectl apply -f ./nginx-topology.yaml.yaml
kubectl apply -f ./nginx-pod-affinity.yaml

# demo


# metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# cluster autoscaler
kubectl apply -f ./cluster-provisioner.yaml

# hpa
kubectl apply -f ./nginx-demo.yaml
kubectl apply -f ./hpa.yaml

k top nodes

kubectl delete -f ./nginx-demo.yaml
kubectl delete -f ./hpa.yaml
kubectl delete -f ./cluster-provisioner.yaml
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# vpa
sh  ~/me/apps/autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

# fargate demo
kubectl create namespace fargate


# load generator
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache-service; done"
kubectl run -i --tty load-generator1 --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache-service; done"
kubectl run -i --tty load-generator2 --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache-service; done"
