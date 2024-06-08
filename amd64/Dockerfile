# @Author: Chen Mingshuo & Hongming Zhu
# @Date: 2024/06/07

FROM ubuntu:22.04

WORKDIR /root/

# apt换清华源
# 使用 http, 因为 https 需要 certificates
RUN sed -i "s@http://.*.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

# 安装JDK等
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget vim openssh-server net-tools

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 

# 配置SSH免密码登录
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# 下载并解压 Hadoop
RUN wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
RUN tar -xzvf hadoop-3.3.6.tar.gz && \
    rm hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 hadoop && \
    chmod -R 777 hadoop

# 下载并解压 Zookeeper
RUN wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz
RUN tar -xzvf apache-zookeeper-3.9.2-bin.tar.gz && \
    rm apache-zookeeper-3.9.2-bin.tar.gz && \
    mv apache-zookeeper-3.9.2-bin zookeeper && \
    chmod -R 777 zookeeper

# 下载并解压 Flink
# RUN wget https://archive.apache.org/dist/flink/flink-1.14.6/flink-1.14.6-bin-scala_2.12.tgz
COPY flink-1.14.6-bin-scala_2.12.tgz /root/
RUN tar -xzvf flink-1.14.6-bin-scala_2.12.tgz && \
    rm flink-1.14.6-bin-scala_2.12.tgz && \
    mv flink-1.14.6 flink && \
    chmod -R 777 flink


# flink-shaded-hadoop-3-uber-3.1.1.7.2.9.0-173-9.0.jar
# flink-shaded-zookeeper-3-3.8.3-18.0.jar
RUN wget https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/flink/flink-shaded-hadoop-3-uber/3.1.1.7.2.9.0-173-9.0/flink-shaded-hadoop-3-uber-3.1.1.7.2.9.0-173-9.0.jar
RUN wget https://repo1.maven.org/maven2/org/apache/flink/flink-shaded-zookeeper-3/3.8.3-18.0/flink-shaded-zookeeper-3-3.8.3-18.0.jar
RUN mv flink-shaded-*.jar /root/flink/lib/
# commons-cli-1.4.jar
RUN wget https://repo1.maven.org/maven2/commons-cli/commons-cli/1.4/commons-cli-1.4.jar
RUN mv commons-cli*.jar /root/flink/lib/
COPY flink_config/ /root/tmpdir/

# 下载并解压 Kafka
# RUN wget https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/3.7.0/kafka_2.12-3.7.0.tgz
# RUN wget https://mirrors.aliyun.com/apache/kafka/3.7.0/kafka_2.12-3.7.0.tgz
COPY kafka_2.12-3.7.0.tgz /root/
RUN tar -xzvf kafka_2.12-3.7.0.tgz && \
    rm kafka_2.12-3.7.0.tgz && \
    mv kafka_2.12-3.7.0 kafka && \
    chmod -R 777 kafka


# Hadoop
RUN echo "slave1" > /root/hadoop/etc/hadoop/workers
RUN echo "slave2" >> /root/hadoop/etc/hadoop/workers
RUN echo "slave3" >> /root/hadoop/etc/hadoop/workers

ENV HADOOP_HOME=/root/hadoop

RUN mkdir $HADOOP_HOME/tmp
ENV HADOOP_TMP_DIR=$HADOOP_HOME/tmp

RUN mkdir $HADOOP_HOME/namenode
RUN mkdir $HADOOP_HOME/datanode

ENV HADOOP_CONFIG_HOME=$HADOOP_HOME/etc/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

ENV PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

ENV HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/tools/lib/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_CLASSPATH

ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"

# Zookeeper
ENV ZOOKEEPER_HOME=/root/zookeeper
ENV PATH=$ZOOKEEPER_HOME/bin:$PATH

# flink
ENV FLINK_HOME=/root/flink
ENV PATH=$FLINK_HOME/bin:$PATH

# kafka
ENV KAFKA_HOME=/root/kafka
ENV PATH=$KAFKA_HOME/bin:$PATH

# 配置Hadoop
COPY hadoop_config/* /root/hadoop/etc/hadoop/
RUN sed -i '1i export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' /root/hadoop/etc/hadoop/hadoop-env.sh

# 配置Zookeeper
RUN mkdir /root/zookeeper/tmp
RUN cp /root/zookeeper/conf/zoo_sample.cfg /root/zookeeper/conf/zoo.cfg
COPY zookeeper_config/* /root/zookeeper/conf/

# 配置Kafka
COPY kafka_config/* /root/kafka/config/

# 配置SSH
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config


RUN echo "export HADOOP_CLASSPATH=`hadoop classpath`" >> /root/.bashrc

# scripts
COPY scripts/* /root/scripts/
RUN chmod -R 777 /root/scripts
ENV PATH=/root/scripts:$PATH

# 启动SSH服务
CMD ["bash", "-c", "bash"]