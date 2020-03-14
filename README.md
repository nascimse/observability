# observability
Stack observability [elk, filebeat, prometheus, kafka]

01 - Change variables dir_user and dir_yaml on script stack-elk-kubernetes.sh

02 - Execute script: ./stack-elk-kubernetes.sh <user_name>


#!/bin/bash -x
dir_user=$1
dir_yaml=/home/${dir_user}/work
kube_version=v1.17.0

minikube delete -p devops
rm -rf /home/${dir_user}/.kube
rm -rf /home/${dir_user}/.minikube

minikube start --memory 11264 --cpus 4 --disk-size='150000mb' --kubernetes-version ${kube_version} -p devops
sleep 180

kubectl get pods -n kube-system

cd /home/${dir_user}/work/git/kubernetes-prometheus-kafka-adapter/
eval $(minikube docker-env -p devops)
docker build -t prometheus-kafka-adapter:v1 .

kubectl create -f ${dir_yaml}/kubernetes-kafka/01-namespace/ && \
kubectl create -f ${dir_yaml}/kubernetes-kafka/02-rbac-namespace-default && \
kubectl create -f ${dir_yaml}/kubernetes-kafka/03-zookeeper ; sleep 120 && \
kubectl create -f ${dir_yaml}/kubernetes-kafka/05-kafka ; sleep 120 && \
kubectl create -f ${dir_yaml}/kubernetes-kafka/06-kasfka-manager ; sleep 60 && \
kubectl create -f ${dir_yaml}/kubernetes-kafka/07-kafka-cli ; sleep 120 && \ 
kubectl get pods -n monitoring && \ 
/home/${dir_user}/work/scripts/create-topics.sh cria && \
kubectl create -f ${dir_yaml}/kubernetes-elasticsearch/ ; sleep 120 && \
kubectl create -f ${dir_yaml}/kubernetes-kibana/ ; sleep 120 && \
kubectl create -f ${dir_yaml}/kubernetes-logstash/ ; sleep 120 && \
kubectl create -f ${dir_yaml}/kubernetes-prometheus-kafka-adapter/ ; sleep 60 && \
kubectl get pods -n inmetrics && \
kubectl create -f ${dir_yaml}/kubernetes-prometheus/ ; sleep 60 && \
kubectl create -f ${dir_yaml}/kubernetes-filebeat/  ; sleep 60 && \
kubectl get pods -n monitoring 
