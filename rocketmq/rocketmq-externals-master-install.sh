cd /soft/
unzip rocketmq-externals-master.zip -d /usr/local/
cd /usr/local/rocketmq-externals-master/
find ./ -name application.properties
cd /usr/local/rocketmq-externals-master/rocketmq-console/src/main/resources 
sed -ri '/^rocketmq.config.namesrvAddr=/c\rocketmq.config.namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876' ./application.properties
cd /usr/local/rocketmq-externals-master/rocketmq-console/src/test/resources
sed -ri '/^rocketmq.config.namesrvAddr=/c\rocketmq.config.namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876' ./application.properties
cd /usr/local/rocketmq-externals-master/rocketmq-console/

