#!/bin/bash

# Variables
DIRYAML=${PWD}
MEMORY=11264
CPU=4
DISKSIZE=150000mb
KUBEVERSION=v1.17.0

# Functions
error()
{
 if [ ${1} -ne 0 ] ; then
   echo "ERRO"
   exit ${1}
 fi
}

kube-proccess()
{
 echo http:`grep http ${HOME}/.kube/config | cut -d: -f3`:`kubectl get svc -n monitoring | grep $1 | cut -d: -f2 | cut -d/ -f1`
}

# Main
echo -e "\n Cleaning minikube environment \n"
minikube delete -p devops
rm -rf ${HOME}/.kube
rm -rf ${HOME}/.minikube

echo -e "\n Creating minikube environment \n"
minikube start --memory ${MEMORY} --cpus ${CPU} --disk-size=${DISKSIZE} --kubernetes-version ${KUBEVERSION} -p devops
error $? && echo -e "\n Successfully created minikube environment \n"
sleep 180
kubectl get pods -n kube-system
echo -e "------------------------------- \n"

echo -e "Creating docker image prometheus-kafka-adapter \n"
cd ${DIRYAML}/kube-prometheus-kafka-adapter/
eval $(minikube docker-env -p devops)
docker build -t prometheus-kafka-adapter:v1 .
error $? && echo "Successfully created docker image prometheus-kafka-adapter"
echo -e "------------------------------- \n"

YAMLLIST="kube-kafka/01-namespace/;0 \
     	  kube-kafka/02-rbac-namespace-default/;0 \
          kube-kafka/03-zookeeper/;120 \
          kube-kafka/05-kafka/;120 \
          kube-kafka/06-kafka-manager/;120 \
          kube-kafka/07-kafka-cli/;120 \
          kube-elasticsearch/;120 \
          kube-kibana/;120 \
          kube-prometheus-kafka-adapter/;120 \
          kube-prometheus/;120 \
          kube-filebeat/;120 \
          kube-logstash/;0"

for YAML in ${YAMLLIST} ; do
  SLEEP=`echo ${YAML} | cut -d";" -f2`
  YAML=`echo ${YAML} | cut -d";" -f1`
  kubectl create -f ${DIRYAML}/${YAML}
  error $? && sleep ${SLEEP}
  echo -e "Successfully created - ${YAML}"
  echo -e "------------------------------- \n"
done

kubectl get pods -n monitoring
error $?

echo -e "------------------------------- \n"
echo -e "Creating Kafka topics \n"
${DIRYAML}/create-topics.sh
error $?

echo -e "------------------------------- \n"
echo -e "Finished created Observability Stak \n\n"
echo "To access Kibana use URL:"
echo `kube-proccess kibana`
echo -e "\n"
echo "To access Kafka Manager use URL:"
echo `kube-proccess kafka-manager`
echo -e "\n"
echo "To access Prometheus use URL:"
echo `kube-proccess prometheus-service`
echo -e "\n"
echo "To access kubernetes Dashboard type the command below on terminal:"
echo "minikube dashboard -p devops"
echo "-------------------------------"
