#!/bin/bash -x
topics="TCP-RAW-FILEBEAT TCP-RAW-PROMETHEUS"

if [[ ${1} = "cria" ]] ; then
  for topic in ${topics} ; do
  kubectl -n monitoring exec -ti kafka-cli -- /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.monitoring:2181 --topic ${topic} --create --partitions 10 --replication-factor 3
  done
else
  for topic in ${topics} ; do
  kubectl -n monitoring exec -ti kafka-cli -- /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.monitoring:2181 --delete --topic ${topic}
  done
fi
