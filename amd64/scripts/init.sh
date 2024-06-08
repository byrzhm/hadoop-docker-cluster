#! /bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <num>"
  exit 1
fi

num=$1

# 向 myid 文件写入id
echo "$num" > /root/zookeeper/tmp/myid

# 向 kafka/config/server.properties写入broker.id
sed -i "s/^broker.id.*/broker.id=$num/" /root/kafka/config/server.properties
echo "host.name=$(hostname)" >> /root/kafka/config/server.properties
echo "listeners=PLAINTEXT://$(hostname):9092" >> /root/kafka/config/server.properties
