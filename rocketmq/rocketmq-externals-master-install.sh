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

#启动rocketmq web界面
#编译成功后，在rocketmq-console目录下会生成一个target目录，该目录下有启动rocketmq web界面的jar文件
cd /usr/local/rocketmq-externals-master/rocketmq-console/target
nohup java -jar rocketmq-console-ng-1.0.0.jar >>/usr/local/rocketmq/log.out 2>&1 &

#确认启动成功
ps -ef |grep rocketmq-console-ng-1.0.0
tail -f /usr/local/rocketmq/log.out
#出现以下2行表示启动成功
#[2018-05-24 18:38:59.301]  INFO Tomcat started on port(s): 8080 (http)
#[2018-05-24 18:38:59.326]  INFO Started App in 11.294 seconds (JVM running for 13.45)

#客户端启动web浏览器输入http://192.168.150.145:8080打开rocketmq-console界面












