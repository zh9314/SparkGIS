#!/bin/bash
add-apt-repository ppa:openjdk-r/ppa -y
apt-get update
apt-get install openjdk-8-jdk -y --force-yes
apt-get install wget -y

wget https://archive.apache.org/dist/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz -P /root/
tar -xzf /root/hadoop-2.9.2.tar.gz -C /root/
mv /root/hadoop-2.9.2/ /root/hadoop/

#wget https://downloads.lightbend.com/scala/2.13.0-M5/scala-2.13.0-M5.tgz -P /root/
wget https://downloads.lightbend.com/scala/2.10.7/scala-2.10.7.tgz -P /root/
wget https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-without-hadoop.tgz -P /root/
#tar -xzf /root/scala-2.13.0-M5.tgz -C /root/
tar -xzf scala-2.10.7.tgz 
tar -xzf /root/spark-2.4.0-bin-without-hadoop.tgz -C /root/

wget http://download.geofabrik.de/asia/china-latest-free.shp.zip -P /root/
wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -P /root/
tar -xzf /root/apache-maven-3.3.9-bin.tar.gz -C /root/


#mv scala-2.13.0-M5 scala
mv scala-2.10.7 scala
mv spark-2.4.0-bin-without-hadoop spark
mv apache-maven-3.3.9 maven

###configure hadoop related configurations
cat > /root/hadoop/etc/hadoop/core-site.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>  
    <property>  
        <name>hadoop.tmp.dir</name>  
        <value>/root/hadoop/tmp</value>  
        <description>Abase for other temporary directories.</description>  
    </property>  
    <property>  
        <name>fs.default.name</name>  
        <value>hdfs://192.168.10.10:9000</value>  
    </property>  
    <property>  
        <name>io.file.buffer.size</name>  
        <value>4096</value>  
    </property>  
</configuration>  
EOF

cat > /root/hadoop/etc/hadoop/hdfs-site.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>  
    <property>  
        <name>dfs.nameservices</name>  
        <value>hadoop-cluster1</value>  
    </property>  
    <property>  
        <name>dfs.namenode.secondary.http-address</name>  
        <value>192.168.10.10:50090</value>  
    </property>  
    <property>  
        <name>dfs.namenode.name.dir</name>  
        <value>file:///root/hadoop/dfs/name</value>  
    </property>  
    <property>  
        <name>dfs.datanode.data.dir</name>  
        <value>file:///root/hadoop/dfs/data</value>  
    </property>  
    <property>  
        <name>dfs.replication</name>  
        <value>2</value>  
    </property>  
    <property>  
        <name>dfs.webhdfs.enabled</name>  
        <value>true</value>  
    </property> 
</configuration> 

EOF

cat > /root/hadoop/etc/hadoop/mapred-site.xml <<'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>  
    <property>  
        <name>mapreduce.framework.name</name>  
        <value>yarn</value>  
    </property>  
    <property>  
        <name>mapreduce.jobtracker.http.address</name>  
        <value>192.168.10.10:50030</value>  
    </property>  
    <property>  
        <name>mapreduce.jobhistory.address</name>  
        <value>192.168.10.10:10020</value>  
    </property>  
    <property>  
        <name>mapreduce.jobhistory.webapp.address</name>  
        <value>192.168.10.10:19888</value>  
    </property>
    <property>
	<name>yarn.app.mapreduce.am.staging-dir</name>
	<value>/tmp/hadoop-yarn/staging</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.done-dir</name>
        <value>${yarn.app.mapreduce.am.staging-dir}/history/done</value>
    </property>
    <property>
	<name>mapreduce.jobhistory.intermediate-done-dir</name>
	<value>${yarn.app.mapreduce.am.staging-dir}/history/done_intermediate</value>
    </property>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>mapreduce.randomwriter.mapsperhost</name>
        <value>1</value>
    </property>
    <property>
        <name>mapreduce.randomwriter.bytespermap</name>
        <value>1073741824</value>
    </property>
    <property>
        <name>mapreduce.randomwriter.minkey</name>
        <value>10</value>
    </property>
    <property>
        <name>mapreduce.randomwriter.maxkey</name>
        <value>1000</value>
    </property>
    <property>
        <name>mapreduce.randomwriter.minvalue</name>
        <value>0</value>
    </property>
    <property>
        <name>mapreduce.randomwriter.maxvalue</name>
        <value>20000</value>
    </property>
</configuration>  

EOF

cat > /root/hadoop/etc/hadoop/yarn-site.xml <<'EOF'
<?xml version="1.0"?>
<configuration>
<!-- Site specific YARN configuration properties -->  
    <property>  
        <name>yarn.nodemanager.aux-services</name>  
        <value>mapreduce_shuffle</value>  
    </property>  
    <property>  
        <name>yarn.resourcemanager.address</name>  
        <value>192.168.10.10:8032</value>  
    </property>  
    <property>  
        <name>yarn.resourcemanager.scheduler.address</name>  
        <value>192.168.10.10:8030</value>  
    </property>  
    <property>  
        <name>yarn.resourcemanager.resource-tracker.address</name>  
        <value>192.168.10.10:8031</value>  
    </property>  
    <property>  
        <name>yarn.resourcemanager.admin.address</name>  
        <value>192.168.10.10:8033</value>  
    </property>  
    <property>  
        <name>yarn.resourcemanager.webapp.address</name>  
        <value>192.168.10.10:8088</value>  
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>2048</value>
    </property> 
</configuration>  
EOF


cat > /root/hadoop/etc/hadoop/slaves <<EOF
Node0
Node1
Node2
EOF



cat > /root/hadoop/etc/hadoop/yarn-env.sh <<'EOF'
export HADOOP_YARN_USER=${HADOOP_YARN_USER:-yarn}
export YARN_CONF_DIR="${YARN_CONF_DIR:-$HADOOP_YARN_HOME/conf}"

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

if [ "$JAVA_HOME" != "" ]; then
  JAVA_HOME=$JAVA_HOME
fi

if [ "$JAVA_HOME" = "" ]; then
  echo "Error: JAVA_HOME is not set."
  exit 1
fi

JAVA=$JAVA_HOME/bin/java
JAVA_HEAP_MAX=-Xmx1000m

if [ "$YARN_HEAPSIZE" != "" ]; then
  JAVA_HEAP_MAX="-Xmx""$YARN_HEAPSIZE""m"
fi


IFS=

if [ "$YARN_LOG_DIR" = "" ]; then
  YARN_LOG_DIR="$HADOOP_YARN_HOME/logs"
fi
if [ "$YARN_LOGFILE" = "" ]; then
  YARN_LOGFILE='yarn.log'
fi

if [ "$YARN_POLICYFILE" = "" ]; then
  YARN_POLICYFILE="hadoop-policy.xml"
fi

unset IFS


YARN_OPTS="$YARN_OPTS -Dhadoop.log.dir=$YARN_LOG_DIR"
YARN_OPTS="$YARN_OPTS -Dyarn.log.dir=$YARN_LOG_DIR"
YARN_OPTS="$YARN_OPTS -Dhadoop.log.file=$YARN_LOGFILE"
YARN_OPTS="$YARN_OPTS -Dyarn.log.file=$YARN_LOGFILE"
YARN_OPTS="$YARN_OPTS -Dyarn.home.dir=$YARN_COMMON_HOME"
YARN_OPTS="$YARN_OPTS -Dyarn.id.str=$YARN_IDENT_STRING"
YARN_OPTS="$YARN_OPTS -Dhadoop.root.logger=${YARN_ROOT_LOGGER:-INFO,console}"
YARN_OPTS="$YARN_OPTS -Dyarn.root.logger=${YARN_ROOT_LOGGER:-INFO,console}"
if [ "x$JAVA_LIBRARY_PATH" != "x" ]; then
  YARN_OPTS="$YARN_OPTS -Djava.library.path=$JAVA_LIBRARY_PATH"
fi
YARN_OPTS="$YARN_OPTS -Dyarn.policy.file=$YARN_POLICYFILE"

EOF

cat > /root/hadoop/etc/hadoop/hadoop-env.sh <<'EOF'
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"/etc/hadoop"}
for f in $HADOOP_HOME/contrib/capacity-scheduler/*.jar; do
  if [ "$HADOOP_CLASSPATH" ]; then
    export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$f
  else
    export HADOOP_CLASSPATH=$f
  fi
done
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"
export HADOOP_NAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_NAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="-Dhadoop.security.logger=ERROR,RFAS $HADOOP_DATANODE_OPTS"
export HADOOP_SECONDARYNAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_NFS3_OPTS="$HADOOP_NFS3_OPTS"
export HADOOP_PORTMAP_OPTS="-Xmx512m $HADOOP_PORTMAP_OPTS"
export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS"
if [ "$HADOOP_HEAPSIZE" = "" ]; then
  export HADOOP_CLIENT_OPTS="-Xmx512m $HADOOP_CLIENT_OPTS"
fi
export HADOOP_SECURE_DN_USER=${HADOOP_SECURE_DN_USER}
export HADOOP_PID_DIR=${HADOOP_PID_DIR}
export HADOOP_SECURE_DN_PID_DIR=${HADOOP_PID_DIR}
export HADOOP_IDENT_STRING=$USER

EOF

#######end of hadoop configurations

cat >> /etc/profile <<'EOF'
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/rt.jar

export SCALA_HOME=/root/scala
export PATH=$SCALA_HOME/bin:$PATH

export HADOOP_HOME=/root/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_ROOT_LOGGER=INFO,console
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"

export SPARK_HOME=/root/spark
export PATH=$PATH:$SPARK_HOME/bin

export M2_HOME=/root/maven
export PATH=${M2_HOME}/bin:${PATH}

EOF

source /etc/profile


#### different node should changes different 'SPARK_LOCAL_IP'
cat > /root/spark/conf/spark-env.sh <<'EOF'
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export SCALA_HOME=/root/scala
export HADOOP_HOME=/root/hadoop
export HADOOP_CONF_DIR=/root/hadoop/etc/hadoop
export SPARK_MASTER_IP=192.168.10.10
#export SPARK_LOCAL_IP=192.168.10.10
export SPARK_WORKER_MEMORY=1g
export SPARK_WORKER_CORES=1
export SPARK_HOME=/root/spark
export SPARK_DIST_CLASSPATH=$(/root/hadoop/bin/hadoop classpath)
EOF
#>>>> do not specify the local ip in order to public access
# If it if spark-2.4.0, use SPARK_MASTER_HOST ; If it is spark-1.6.0, use SPARK_MASTER_IP

cat > /root/spark/conf/slaves <<'EOF'
Node0
Node1
Node2
EOF

### the default dir of spark history logs
mkdir /tmp/spark-events

# apt-get install gdal-bin -y
# ogr2ogr -f GeoJSON -t_srs crs:84 [name].geojson [name].shp