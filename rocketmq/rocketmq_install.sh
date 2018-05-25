#架构说明：
#OS：CentOS7.5
#主机1：192.168.150.145
#主机2：192.168.150.146
#主机3：192.168.150.147
#soft：jdk1.8.0_161，rocketmq4.2.0，maven3.5.3

#配置hosts（3台主机执行操作）
echo "192.168.150.145 rocketmq-001" >> /etc/hosts
echo "192.168.150.146 rocketmq-002" >> /etc/hosts
echo "192.168.150.147 rocketmq-003" >> /etc/hosts

#安装jdk1.8.0_161和rocketmq4.2.0（3台主机执行操作）
cd /soft
yum install -y unzip
tar zxvf jdk-8u161-linux-x64.tar.gz -C /usr/local/
mv /usr/local/jdk1.8.0_161 /usr/local/java
unzip -d /usr/local/rocketmq rocketmq-all-4.2.0-bin-release.zip

#配置环境变量（3台主机执行操作）
echo "JAVA_HOME=/usr/local/java" >> /etc/profile
echo "M3_HOME=/usr/local/maven" >> /etc/profile
echo "NAMESRV_ADDR=192.168.150.145:9876,192.168.150.146:9876,192.168.150.147:9876" >> /etc/profile
echo "ROCKETMQ_HOME=/usr/local/rocketmq" >> /etc/profile
echo "CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> /etc/profile
echo "export JAVA_HOME" >> /etc/profile
echo "export M3_HOME" >> /etc/profile
echo "export CLASSPATH" >> /etc/profile
echo "export NAMESRV_ADDR" >> /etc/profile
echo "export ROCKETMQ_HOME" >> /etc/profile
echo "export PATH=\$ROCKETMQ_HOME/bin:\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$M3_HOME/bin:\$CLASSPATH:\$PATH" >> /etc/profile
source /etc/profile

#创建存储目录（3台主机执行操作）
mkdir -p /usr/local/rocketmq/store/commitlog
mkdir /usr/local/rocketmq/store/consumequeue
mkdir /usr/local/rocketmq/store/index
mkdir /usr/local/rocketmq/logs

#登录rocketmq-001主机
#编辑brokermq的broker-a.properties配置文件
cd /usr/local/rocketmq/conf/2m-noslave
==============================================================================
sed -ri '/^brokerClusterName=/c\brokerClusterName=rocketmq-cluster' ./broker-a.properties
sed -ri '/^brokerName=/c\brokerName=brokermq-001' ./broker-a.properties
sed -ri '/^fileReservedTime=48/c\fileReservedTime=72' ./broker-a.properties
echo "namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876" >> ./broker-a.properties
echo "listenPort=10911" >> ./broker-a.properties
echo "brokerIP1=192.168.150.145" >> ./broker-a.properties
echo "storePathRootDir=/usr/local/rocketmq/store" >> ./broker-a.properties
echo "storePathCommitLog=/usr/local/rocketmq/store/commitlog" >> ./broker-a.properties
echo "storePathConsumerQueue=/usr/local/rocketmq/store/consumequeue" >> ./broker-a.properties
echo "storePathIndex=/usr/local/rocketmq/store/index" >> ./broker-a.properties
echo "defaultTopicQueueNums=4" >> ./broker-a.properties
echo "autoCreateTopicEnable=true" >> ./broker-a.properties
echo "autoCreateSubscriptionGroup=true" >> ./broker-a.properties
echo "filterServerNums=1" >> ./broker-a.properties
echo "sendMessageThreadPoolNums=128" >> ./broker-a.properties
echo "pullMessageThreadPoolNums=128" >> ./broker-a.properties
echo "cleanFileForciblyEnable=true" >> ./broker-a.properties
echo "flushIntervalCommitLog=1000" >> ./broker-a.properties
echo "flushCommitLogTimed=false" >> ./broker-a.properties
echo "maxTransferBytesOnMessageInMemory=262144" >> ./broker-a.properties
echo "maxTransferCountOnMessageInMemory=32" >> ./broker-a.properties
echo "maxTransferBytesOnMessageInDisk=65536" >> ./broker-a.properties
echo "maxTransferCountOnMessageInDisk=8" >> ./broker-a.properties
echo "rejectTransactionMessage=false" >> ./broker-a.properties
echo "fetchNamesrvAddrByAddressServer=false" >> ./broker-a.properties
echo "messageIndexEnable=true" >> ./broker-a.properties
echo "messageIndexSafe=false" >> ./broker-a.properties
echo "accessMessageInMemoryMaxRatio=40" >> ./broker-a.properties
echo "messageDelyLevel=1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h" >> ./broker-a.properties
==============================================================================

#编辑brokermq的broker-b.properties配置文件
==============================================================================
sed -ri '/^brokerClusterName=/c\brokerClusterName=rocketmq-cluster' ./broker-b.properties
sed -ri '/^brokerName=/c\brokerName=brokermq-001' ./broker-b.properties
sed -ri '/^brokerId=/c\brokerId=10' ./broker-b.properties
sed -ri '/^fileReservedTime=48/c\fileReservedTime=72' ./broker-b.properties
sed -ri '/^brokerRole=/c\brokerRole=SLAVE' ./broker-b.properties
echo "namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876" >> ./broker-b.properties
echo "listenPort=13911" >> ./broker-b.properties
echo "brokerIP1=192.168.150.145" >> ./broker-b.properties
echo "storePathRootDir=/usr/local/rocketmq/store" >> ./broker-b.properties
echo "storePathCommitLog=/usr/local/rocketmq/store/commitlog" >> ./broker-b.properties
echo "storePathConsumerQueue=/usr/local/rocketmq/store/consumequeue" >> ./broker-b.properties
echo "storePathIndex=/usr/local/rocketmq/store/index" >> ./broker-b.properties
echo "defaultTopicQueueNums=4" >> ./broker-b.properties
echo "autoCreateTopicEnable=true" >> ./broker-b.properties
echo "autoCreateSubscriptionGroup=true" >> ./broker-b.properties
echo "filterServerNums=1" >> ./broker-b.properties
echo "sendMessageThreadPoolNums=128" >> ./broker-b.properties
echo "pullMessageThreadPoolNums=128" >> ./broker-b.properties
echo "cleanFileForciblyEnable=true" >> ./broker-b.properties
echo "flushIntervalCommitLog=1000" >> ./broker-b.properties
echo "flushCommitLogTimed=false" >> ./broker-b.properties
echo "maxTransferBytesOnMessageInMemory=262144" >> ./broker-b.properties
echo "maxTransferCountOnMessageInMemory=32" >> ./broker-b.properties
echo "maxTransferBytesOnMessageInDisk=65536" >> ./broker-b.properties
echo "maxTransferCountOnMessageInDisk=8" >> ./broker-b.properties
echo "rejectTransactionMessage=false" >> ./broker-b.properties
echo "fetchNamesrvAddrByAddressServer=false" >> ./broker-b.properties
echo "messageIndexEnable=true" >> ./broker-b.properties
echo "messageIndexSafe=false" >> ./broker-b.properties
echo "accessMessageInMemoryMaxRatio=40" >> ./broker-b.properties
echo "messageDelyLevel=1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h" >> ./broker-b.properties
==============================================================================

#登录rocketmq-002主机
#编辑brokermq的broker-a.properties配置文件
==============================================================================
cd /usr/local/rocketmq/conf/2m-noslave
sed -ri '/^brokerClusterName=/c\brokerClusterName=rocketmq-cluster' ./broker-a.properties
sed -ri '/^brokerName=/c\brokerName=brokermq-002' ./broker-a.properties
sed -ri '/^fileReservedTime=48/c\fileReservedTime=72' ./broker-a.properties
echo "namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876" >> ./broker-a.properties
echo "listenPort=10911" >> ./broker-a.properties
echo "brokerIP1=192.168.150.146" >> ./broker-a.properties
echo "storePathRootDir=/usr/local/rocketmq/store" >> ./broker-a.properties
echo "storePathCommitLog=/usr/local/rocketmq/store/commitlog" >> ./broker-a.properties
echo "storePathConsumerQueue=/usr/local/rocketmq/store/consumequeue" >> ./broker-a.properties
echo "storePathIndex=/usr/local/rocketmq/store/index" >> ./broker-a.properties
echo "defaultTopicQueueNums=4" >> ./broker-a.properties
echo "autoCreateTopicEnable=true" >> ./broker-a.properties
echo "autoCreateSubscriptionGroup=true" >> ./broker-a.properties
echo "filterServerNums=1" >> ./broker-a.properties
echo "sendMessageThreadPoolNums=128" >> ./broker-a.properties
echo "pullMessageThreadPoolNums=128" >> ./broker-a.properties
echo "cleanFileForciblyEnable=true" >> ./broker-a.properties
echo "flushIntervalCommitLog=1000" >> ./broker-a.properties
echo "flushCommitLogTimed=false" >> ./broker-a.properties
echo "maxTransferBytesOnMessageInMemory=262144" >> ./broker-a.properties
echo "maxTransferCountOnMessageInMemory=32" >> ./broker-a.properties
echo "maxTransferBytesOnMessageInDisk=65536" >> ./broker-a.properties
echo "maxTransferCountOnMessageInDisk=8" >> ./broker-a.properties
echo "rejectTransactionMessage=false" >> ./broker-a.properties
echo "fetchNamesrvAddrByAddressServer=false" >> ./broker-a.properties
echo "messageIndexEnable=true" >> ./broker-a.properties
echo "messageIndexSafe=false" >> ./broker-a.properties
echo "accessMessageInMemoryMaxRatio=40" >> ./broker-a.properties
echo "messageDelyLevel=1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h" >> ./broker-a.properties
==============================================================================

#编辑brokermq的broker-b.properties配置文件
==============================================================================
sed -ri '/^brokerClusterName=/c\brokerClusterName=rocketmq-cluster' ./broker-b.properties
sed -ri '/^brokerName=/c\brokerName=brokermq-002' ./broker-b.properties
sed -ri '/^brokerId=/c\brokerId=10' ./broker-b.properties
sed -ri '/^fileReservedTime=48/c\fileReservedTime=72' ./broker-b.properties
sed -ri '/^brokerRole=/c\brokerRole=SLAVE' ./broker-b.properties
echo "namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876" >> ./broker-b.properties
echo "listenPort=13911" >> ./broker-b.properties
echo "brokerIP1=192.168.150.146" >> ./broker-b.properties
echo "storePathRootDir=/usr/local/rocketmq/store" >> ./broker-b.properties
echo "storePathCommitLog=/usr/local/rocketmq/store/commitlog" >> ./broker-b.properties
echo "storePathConsumerQueue=/usr/local/rocketmq/store/consumequeue" >> ./broker-b.properties
echo "storePathIndex=/usr/local/rocketmq/store/index" >> ./broker-b.properties
echo "defaultTopicQueueNums=4" >> ./broker-b.properties
echo "autoCreateTopicEnable=true" >> ./broker-b.properties
echo "autoCreateSubscriptionGroup=true" >> ./broker-b.properties
echo "filterServerNums=1" >> ./broker-b.properties
echo "sendMessageThreadPoolNums=128" >> ./broker-b.properties
echo "pullMessageThreadPoolNums=128" >> ./broker-b.properties
echo "cleanFileForciblyEnable=true" >> ./broker-b.properties
echo "flushIntervalCommitLog=1000" >> ./broker-b.properties
echo "flushCommitLogTimed=false" >> ./broker-b.properties
echo "maxTransferBytesOnMessageInMemory=262144" >> ./broker-b.properties
echo "maxTransferCountOnMessageInMemory=32" >> ./broker-b.properties
echo "maxTransferBytesOnMessageInDisk=65536" >> ./broker-b.properties
echo "maxTransferCountOnMessageInDisk=8" >> ./broker-b.properties
echo "rejectTransactionMessage=false" >> ./broker-b.properties
echo "fetchNamesrvAddrByAddressServer=false" >> ./broker-b.properties
echo "messageIndexEnable=true" >> ./broker-b.properties
echo "messageIndexSafe=false" >> ./broker-b.properties
echo "accessMessageInMemoryMaxRatio=40" >> ./broker-b.properties
echo "messageDelyLevel=1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h" >> ./broker-b.properties
==============================================================================

#登录rocketmq-003主机
#编辑brokermq的broker-a.properties配置文件
==============================================================================
cd /usr/local/rocketmq/conf/2m-noslave
sed -ri '/^brokerClusterName=/c\brokerClusterName=rocketmq-cluster' ./broker-a.properties
sed -ri '/^brokerName=/c\brokerName=brokermq-003' ./broker-a.properties
sed -ri '/^fileReservedTime=48/c\fileReservedTime=72' ./broker-a.properties
echo "namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876" >> ./broker-a.properties
echo "listenPort=10911" >> ./broker-a.properties
echo "brokerIP1=192.168.150.147" >> ./broker-a.properties
echo "storePathRootDir=/usr/local/rocketmq/store" >> ./broker-a.properties
echo "storePathCommitLog=/usr/local/rocketmq/store/commitlog" >> ./broker-a.properties
echo "storePathConsumerQueue=/usr/local/rocketmq/store/consumequeue" >> ./broker-a.properties
echo "storePathIndex=/usr/local/rocketmq/store/index" >> ./broker-a.properties
echo "defaultTopicQueueNums=4" >> ./broker-a.properties
echo "autoCreateTopicEnable=true" >> ./broker-a.properties
echo "autoCreateSubscriptionGroup=true" >> ./broker-a.properties
echo "filterServerNums=1" >> ./broker-a.properties
echo "sendMessageThreadPoolNums=128" >> ./broker-a.properties
echo "pullMessageThreadPoolNums=128" >> ./broker-a.properties
echo "cleanFileForciblyEnable=true" >> ./broker-a.properties
echo "flushIntervalCommitLog=1000" >> ./broker-a.properties
echo "flushCommitLogTimed=false" >> ./broker-a.properties
echo "maxTransferBytesOnMessageInMemory=262144" >> ./broker-a.properties
echo "maxTransferCountOnMessageInMemory=32" >> ./broker-a.properties
echo "maxTransferBytesOnMessageInDisk=65536" >> ./broker-a.properties
echo "maxTransferCountOnMessageInDisk=8" >> ./broker-a.properties
echo "rejectTransactionMessage=false" >> ./broker-a.properties
echo "fetchNamesrvAddrByAddressServer=false" >> ./broker-a.properties
echo "messageIndexEnable=true" >> ./broker-a.properties
echo "messageIndexSafe=false" >> ./broker-a.properties
echo "accessMessageInMemoryMaxRatio=40" >> ./broker-a.properties
echo "messageDelyLevel=1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h" >> ./broker-a.properties
==============================================================================

#编辑brokermq的broker-b.properties配置文件
==============================================================================
sed -ri '/^brokerClusterName=/c\brokerClusterName=rocketmq-cluster' ./broker-b.properties
sed -ri '/^brokerName=/c\brokerName=brokermq-003' ./broker-b.properties
sed -ri '/^brokerId=/c\brokerId=10' ./broker-b.properties
sed -ri '/^fileReservedTime=48/c\fileReservedTime=72' ./broker-b.properties
sed -ri '/^brokerRole=/c\brokerRole=SLAVE' ./broker-b.properties
echo "namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876" >> ./broker-b.properties
echo "listenPort=13911" >> ./broker-b.properties
echo "brokerIP1=192.168.150.147" >> ./broker-b.properties
echo "storePathRootDir=/usr/local/rocketmq/store" >> ./broker-b.properties
echo "storePathCommitLog=/usr/local/rocketmq/store/commitlog" >> ./broker-b.properties
echo "storePathConsumerQueue=/usr/local/rocketmq/store/consumequeue" >> ./broker-b.properties
echo "storePathIndex=/usr/local/rocketmq/store/index" >> ./broker-b.properties
echo "defaultTopicQueueNums=4" >> ./broker-b.properties
echo "autoCreateTopicEnable=true" >> ./broker-b.properties
echo "autoCreateSubscriptionGroup=true" >> ./broker-b.properties
echo "filterServerNums=1" >> ./broker-b.properties
echo "sendMessageThreadPoolNums=128" >> ./broker-b.properties
echo "pullMessageThreadPoolNums=128" >> ./broker-b.properties
echo "cleanFileForciblyEnable=true" >> ./broker-b.properties
echo "flushIntervalCommitLog=1000" >> ./broker-b.properties
echo "flushCommitLogTimed=false" >> ./broker-b.properties
echo "maxTransferBytesOnMessageInMemory=262144" >> ./broker-b.properties
echo "maxTransferCountOnMessageInMemory=32" >> ./broker-b.properties
echo "maxTransferBytesOnMessageInDisk=65536" >> ./broker-b.properties
echo "maxTransferCountOnMessageInDisk=8" >> ./broker-b.properties
echo "rejectTransactionMessage=false" >> ./broker-b.properties
echo "fetchNamesrvAddrByAddressServer=false" >> ./broker-b.properties
echo "messageIndexEnable=true" >> ./broker-b.properties
echo "messageIndexSafe=false" >> ./broker-b.properties
echo "accessMessageInMemoryMaxRatio=40" >> ./broker-b.properties
echo "messageDelyLevel=1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h" >> ./broker-b.properties
==============================================================================

#修改/usr/local/rocketmq/bin目录下的runbroker.sh 和 runserver.sh文件中的参数
cd /usr/local/rocketmq/bin
sed -i '39s/JAVA_OPT="${JAVA_OPT} -server -Xms8g -Xmx8g -Xmn4g"/JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn256m"/' ./runbroker.sh
sed -i '45s/JAVA_OPT="${JAVA_OPT} -XX:MaxDirectMemorySize=15g"/JAVA_OPT="${JAVA_OPT} -XX:MaxDirectMemorySize=512m"/' ./runbroker.sh
sed -i '39s/JAVA_OPT="${JAVA_OPT} -server -Xms4g -Xmx4g -Xmn2g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"/JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn256m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m“/' ./runserver.sh
#说明：以上操作如是在多台独立服务器来做集群可以忽略不做，如是在多台虚拟机集群或搭架伪集群就需要修改。

#启动nameserver和mqbroker（3台主机执行）
#1.启动nameserver
nohup sh mqnamesrv &

#2.启动mqbroker
nohup sh mqbroker -c /usr/local/rocketmq/conf/2m-noslave/broker-a.properties > /usr/local/rocketmq/logs/broker-a.properties.out &
nohup sh mqbroker -c /usr/local/rocketmq/conf/2m-noslave/broker-b.properties > /usr/local/rocketmq/logs/broker-b.properties.out &

netstat -natlp
jps

#停止broker和nameserver
#1.停止broker
sh  mqshutdown broker
#2.停止nameserver
sh  mqshutdown namesrv







#Error
#执行上述命令出错Java HotSpot(TM) 64-Bit Server VM warning: INFO: os::commit_memory(0x00000005c0000000, 8589934592, 0) failed; error='Cannot allocate memory' (errno=12)
#提示内存不足
#解决方法：
#修改/usr/local/rocketmq/bin目录下的runbroker.sh 和 runserver.sh文件中的参数
cd /usr/local/rocketmq/bin
vi runbroker.sh
JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn256m"
JAVA_OPT="${JAVA_OPT} -XX:MaxDirectMemorySize=512m"
 
vi runserver.sh
JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn256m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m"
#说明：-Xms256m -Xmx256m -Xmn256m分别代表了最小堆内存、最大堆内存、新生代大小


