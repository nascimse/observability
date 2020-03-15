#!/bin/bash -x
TOPICS="TCP-RAW-FILEBEAT TCP-RAW-PROMETHEUS"

error()
{
if [ ${1} -ne 0 ] ; then
    echo "ERRO"
    exit ${1}
fi
}

if [[ ${1} = "delete" ]] ; then
  for NEWTOPIC in ${TOPICS} ; do
    kubectl -n monitoring exec -ti kafka-cli -- /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.monitoring:2181 --delete --topic ${NEWTOPIC}
    error $? && echo -e "\n Successfully deleted Kafka topics ${NEWTOPIC} \n"
  done
else
  for NEWTOPIC in ${TOPICS} ; do
    kubectl -n monitoring exec -ti kafka-cli -- /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper.monitoring:2181 --topic ${NEWTOPIC} --create --partitions 10 --replication-factor 3
    error $? && echo -e "\n Successfully created Kafka topics ${NEWTOPIC} \n"
  done
fi
