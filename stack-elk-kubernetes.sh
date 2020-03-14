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

cd /home/${dir_user}/work/git/kube-prometheus-kafka-adapter/
eval $(minikube docker-env -p devops)
docker build -t prometheus-kafka-adapter:v1 .

kubectl create -f ${dir_yaml}/kube-kafka/01-namespace/ && \
kubectl create -f ${dir_yaml}/kube-kafka/02-rbac-namespace-default && \
kubectl create -f ${dir_yaml}/kube-kafka/03-zookeeper ; sleep 120 && \
kubectl create -f ${dir_yaml}/kube-kafka/05-kafka ; sleep 120 && \
kubectl create -f ${dir_yaml}/kube-kafka/06-kafka-manager ; sleep 60 && \
kubectl create -f ${dir_yaml}/kube-kafka/07-kafka-cli ; sleep 120 && \ 
kubectl get pods -n monitoring && \ 
${dir_yaml}/create-topics.sh cria && \
kubectl create -f ${dir_yaml}/kube-elasticsearch/ ; sleep 120 && \
kubectl create -f ${dir_yaml}/kube-kibana/ ; sleep 120 && \
kubectl create -f ${dir_yaml}/kube-logstash/ ; sleep 120 && \
kubectl create -f ${dir_yaml}/kube-prometheus-kafka-adapter/ ; sleep 30 && \
kubectl get pods -n inmetrics && \
kubectl create -f ${dir_yaml}/kube-prometheus/ ; sleep 60 && \
kubectl create -f ${dir_yaml}/kube-filebeat/  ; sleep 60 && \
kubectl get pods -n monitoring
