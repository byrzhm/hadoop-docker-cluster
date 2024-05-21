# @Author: Chen Mingshuo & Hongming Zhu
# @Date: 2024/05/20

FROM ubuntu:22.04

WORKDIR /root/

# apt换清华源
# 使用 http, 因为 https 需要 certificates
RUN sed -i "s@http://.*.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

# 安装JDK等
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget vim openssh-server net-tools mysql-server

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

# 下载并解压 HBase
RUN wget https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/2.5.8/hbase-2.5.8-bin.tar.gz
RUN tar -xzvf hbase-2.5.8-bin.tar.gz && \
    rm hbase-2.5.8-bin.tar.gz && \
    mv hbase-2.5.8 hbase && \
    chmod -R 777 hbase

# 下载并解压 Spark
RUN wget https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3-scala2.13.tgz
RUN tar -xzvf spark-3.5.1-bin-hadoop3-scala2.13.tgz && \
    rm spark-3.5.1-bin-hadoop3-scala2.13.tgz && \
    mv spark-3.5.1-bin-hadoop3-scala2.13 spark && \
    chmod -R 777 spark
    
RUN echo "slave1" > /root/hadoop/etc/hadoop/workers
RUN echo "slave2" >> /root/hadoop/etc/hadoop/workers
RUN echo "slave3" >> /root/hadoop/etc/hadoop/workers

# 配置环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/root/hadoop

RUN mkdir $HADOOP_HOME/tmp
ENV HADOOP_TMP_DIR=$HADOOP_HOME/tmp

RUN mkdir $HADOOP_HOME/namenode
RUN mkdir $HADOOP_HOME/datanode

ENV HADOOP_CONFIG_HOME=$HADOOP_HOME/etc/hadoop

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

# HBase
ENV HBASE_HOME=/root/hbase
ENV PATH=$HBASE_HOME/bin:$HBASE_HOME/sbin:$PATH

# Spark
ENV SPARK_HOME=/root/spark 
ENV PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH 
ENV HADOOP_CONF_DIR=/root/hadoop/etc/hadoop 
ENV YARN_CONF_DIR=/root/hadoop/etc/hadoop 

# 配置Hadoop
COPY hadoop_config/* /root/hadoop/etc/hadoop/
RUN sed -i '1i export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' /root/hadoop/etc/hadoop/hadoop-env.sh

# 配置Zookeeper
RUN mkdir /root/zookeeper/tmp
RUN cp /root/zookeeper/conf/zoo_sample.cfg /root/zookeeper/conf/zoo.cfg
COPY zookeeper_config/* /root/zookeeper/conf/

# 配置HBase
COPY hbase_config/* /root/hbase/conf/
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /root/hbase/conf/hbase-env.sh
RUN echo "export HBASE_MANAGES_ZK=false" >> /root/hbase/conf/hbase-env.sh
RUN echo "export HBASE_LIBRARY_PATH=/root/hadoop/lib/native" >> /root/hbase/conf/hbase-env.sh
RUN echo 'export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP="true"' >> /root/hbase/conf/hbase-env.sh

# 配置Spark
RUN mv /root/spark/conf/spark-env.sh.template /root/spark/conf/spark-env.sh
RUN echo "export SPARK_DIST_CLASSPATH=$(/root/hadoop/bin/hadoop classpath)" >> /root/spark/conf/spark-env.sh
RUN mv /root/spark/conf/workers.template /root/spark/conf/workers
RUN echo "master" > /root/spark/conf/workers
RUN echo "slave1" >> /root/spark/conf/workers
RUN echo "slave2" >> /root/spark/conf/workers
RUN echo "slave3" >> /root/spark/conf/workers

# 配置SSH
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# 下载并解压 MySQL JDBC
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.24.tar.gz
RUN tar -xzvf mysql-connector-java-8.0.24.tar.gz && \
    rm mysql-connector-java-8.0.24.tar.gz && \
    mv mysql-connector-java-8.0.24/mysql-connector-java-8.0.24.jar /root/spark/jars/

# 启动SSH服务
CMD ["bash", "-c", "service ssh restart; bash"]