#下载rocketmq-externals-master并使用rz命令上传/soft目录中
#下载地址：https://github.com/apache/rocketmq-externals
cd /soft/
rz

#解压rocketmq-externals-master到/usr/local
unzip rocketmq-externals-master.zip -d /usr/local/

#查找并修改application.properties配置文件
cd /usr/local/rocketmq-externals-master/
find ./ -name application.properties
cd /usr/local/rocketmq-externals-master/rocketmq-console/src/main/resources 
sed -ri '/^rocketmq.config.namesrvAddr=/c\rocketmq.config.namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876' ./application.properties
cd /usr/local/rocketmq-externals-master/rocketmq-console/src/test/resources
sed -ri '/^rocketmq.config.namesrvAddr=/c\rocketmq.config.namesrvAddr=192.168.150.145:9876;192.168.150.146:9876;192.168.150.147:9876' ./application.properties

#安装maven3.5.3
#下载maven3.5.3并使用rz命令上传/soft目录中
cd /soft/
rz

#解压maven3.5.3到/usr/local
tar zxvf apache-maven-3.5.3-bin.tar.gz -C /usr/local/
cd /usr/local/
mv apache-maven-3.5.3 maven

#编辑maven环境变量
echo "export M3_HOME=/usr/local/maven" >> /etc/profile
echo "export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$M3_HOME/bin:$PATH" >> /etc/profile
source /etc/profile

#检测maven
mvn -v

#使用maven编译rocketmq-externals-master
cd /usr/local/rocketmq-externals-master/rocketmq-console/
mvn clean package -Dmaven.test.skip=true
