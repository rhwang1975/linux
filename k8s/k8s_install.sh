#!bin/bash
#kubeadm安装Kubernetes V1.10集群详细文档
###########################################################################################
# uname -r                                                                                #
# 3.10.0-862.2.3.el7.x86_64                                                               #
# cat /etc/redhat-release                                                                 #
# CentOS Linux release 7.5.1804 (Core)                                                    #
###########################################################################################


#一、环境初始化（4台主机）
#1.设置主机名称
hostnamectl set-hostname node01
hostnamectl set-hostname node02
hostnamectl set-hostname node03
hostnamectl set-hostname node04
#2.设置主机映射（hosts）
cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.150.181 node01
192.168.150.182 node02
192.168.150.183 node03
192.168.150.184 node04
EOF
#3. node01上执行ssh免密码登陆配置
ssh-keygen
ssh-copy-id  node02
ssh-copy-id  node03
ssh-copy-id  node04
#4. 停防火墙、关闭Swap、关闭Selinux、设置内核、K8S的yum源、安装依赖包、配置ntp（配置完后建议重启一次）
#1）停止防火墙
systemctl stop firewalld
systemctl disable firewalld

#2）关闭Swap
swapoff -a 
sed -i 's/.*swap.*/#&/' /etc/fstab

#3）关闭Selinux
setenforce  0 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config  

#4）设置内核
modprobe br_netfilter
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
ls /proc/sys/net/bridge

#5）配置K8S的yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

#6）安装依赖包
yum install -y epel-release
yum install -y yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools wget vim  ntpdate libseccomp libtool-ltdl 

#7）配置ntp
systemctl enable ntpdate.service
echo '*/30 * * * * /usr/sbin/ntpdate time7.aliyun.com >/dev/null 2>&1' > /tmp/crontab2.tmp
crontab /tmp/crontab2.tmp
systemctl start ntpdate.service
 
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nproc 65536"  >> /etc/security/limits.conf
echo "* hard nproc 65536"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf


#二、安装、配置keepalived
#1.安装keepalived（3台）
yum install -y keepalived
systemctl enable keepalived

#2.编辑node01的keepalived.conf
cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
   router_id LVS_k8s
}

vrrp_script CheckK8sMaster {
    script "curl -k https://192.168.150.186:6443"
    interval 3
    timeout 9
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 61
    priority 100
    advert_int 1
    mcast_src_ip 192.168.150.181
    nopreempt
    authentication {
        auth_type PASS
        auth_pass sqP05dQgMSlzrxHj
    }
    unicast_peer {
        192.168.150.182
        192.168.150.183
    }
    virtual_ipaddress {
        192.168.150.186/24
    }
    track_script {
        CheckK8sMaster
    }

}
EOF

#3.node02的keepalived.conf
cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
   router_id LVS_k8s
}

global_defs {
   router_id LVS_k8s
}

vrrp_script CheckK8sMaster {
    script "curl -k https://192.168.150.186:6443"
    interval 3
    timeout 9
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 61
    priority 90
    advert_int 1
    mcast_src_ip 192.168.150.182
    nopreempt
    authentication {
        auth_type PASS
        auth_pass sqP05dQgMSlzrxHj
    }
    unicast_peer {
        192.168.150.181
        192.168.150.183
    }
    virtual_ipaddress {
        192.168.150.186/24
    }
    track_script {
        CheckK8sMaster
    }

}
EOF

#4.node03的keepalived.conf
cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
   router_id LVS_k8s
}

global_defs {
   router_id LVS_k8s
}

vrrp_script CheckK8sMaster {
    script "curl -k https://192.168.150.186:6443"
    interval 3
    timeout 9
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 61
    priority 80
    advert_int 1
    mcast_src_ip 192.168.150.183
    nopreempt
    authentication {
        auth_type PASS
        auth_pass sqP05dQgMSlzrxHj
    }
    unicast_peer {
        192.168.150.181
        192.168.150.182
    }
    virtual_ipaddress {
        192.168.150.186/24
    }
    track_script {
        CheckK8sMaster
    }

}
EOF

#5.启动keepalived（3台）
systemctl restart keepalived
可以看到VIP已经绑定到node01上面了
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:05:1a:21 brd ff:ff:ff:ff:ff:ff
    inet 192.168.150.181/24 brd 192.168.150.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.150.186/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe05:1a21/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever



#三、创建etcd证书(node01上执行即可)
#1.设置cfssl环境
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
export PATH=/usr/local/bin:$PATH

#2.创建 CA 配置文件（下面配置的IP为etc节点的IP）
mkdir /root/ssl
cd /root/ssl
cat >  ca-config.json <<EOF
{
"signing": {
"default": {
  "expiry": "8760h"
},
"profiles": {
  "kubernetes-Soulmate": {
    "usages": [
        "signing",
        "key encipherment",
        "server auth",
        "client auth"
    ],
    "expiry": "8760h"
  }
}
}
}
EOF

cat >  ca-csr.json <<EOF
{
"CN": "kubernetes-Soulmate",
"key": {
"algo": "rsa",
"size": 2048
},
"names": [
{
  "C": "CN",
  "ST": "shanghai",
  "L": "shanghai",
  "O": "k8s",
  "OU": "System"
}
]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "192.168.150.181",
    "192.168.150.182",
    "192.168.150.183"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "shanghai",
      "L": "shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes-Soulmate etcd-csr.json | cfssljson -bare etcd
  
#3.node01分发etcd证书到node02、node03上面
mkdir -p /etc/etcd/ssl
cp etcd.pem etcd-key.pem ca.pem /etc/etcd/ssl/
ssh -n node02 "mkdir -p /etc/etcd/ssl && exit"
ssh -n node03 "mkdir -p /etc/etcd/ssl && exit"
scp -r /etc/etcd/ssl/*.pem node02:/etc/etcd/ssl/
scp -r /etc/etcd/ssl/*.pem node03:/etc/etcd/ssl/


#四、安装配置etcd (三主节点）
#1.安装etcd
yum -y install etcd
mkdir -p /var/lib/etcd

#1) 配置node01的etcd.service
cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/bin/etcd \
  --name node01 \
  --cert-file=/etc/etcd/ssl/etcd.pem \
  --key-file=/etc/etcd/ssl/etcd-key.pem \
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --initial-advertise-peer-urls https://192.168.150.181:2380 \
  --listen-peer-urls https://192.168.150.181:2380 \
  --listen-client-urls https://192.168.150.181:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://192.168.150.181:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster node01=https://192.168.150.181:2380,node02=https://192.168.150.182:2380,node03=https://192.168.150.183:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#2) 配置node02的etcd.service
cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/bin/etcd \
  --name node02 \
  --cert-file=/etc/etcd/ssl/etcd.pem \
  --key-file=/etc/etcd/ssl/etcd-key.pem \
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --initial-advertise-peer-urls https://192.168.150.182:2380 \
  --listen-peer-urls https://192.168.150.182:2380 \
  --listen-client-urls https://192.168.150.182:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://192.168.150.182:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster node01=https://192.168.150.181:2380,node02=https://192.168.150.182:2380,node03=https://192.168.150.183:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#3) 配置node03的etcd.service
cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/bin/etcd \
  --name node03 \
  --cert-file=/etc/etcd/ssl/etcd.pem \
  --key-file=/etc/etcd/ssl/etcd-key.pem \
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --initial-advertise-peer-urls https://192.168.150.183:2380 \
  --listen-peer-urls https://192.168.150.183:2380 \
  --listen-client-urls https://192.168.150.183:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://192.168.150.183:2379 \
  --initial-cluster-token etcd-cluster-0 \
--initial-cluster node01=https://192.168.150.181:2380,node02=https://192.168.150.182:2380,node03=https://192.168.150.183:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#2.添加自启动（etc集群最少2个节点才能启动，启动报错看mesages日志）
mv etcd.service /usr/lib/systemd/system/
 systemctl daemon-reload
 systemctl enable etcd
 systemctl start etcd
 systemctl status etcd

#3.在三个etcd节点执行一下命令检查cluster healthy状态
etcdctl --endpoints=https://192.168.150.181:2379,https://192.168.150.182:2379,https://192.168.150.183:2379 \
  --ca-file=/etc/etcd/ssl/ca.pem \
  --cert-file=/etc/etcd/ssl/etcd.pem \
  --key-file=/etc/etcd/ssl/etcd-key.pem  cluster-health

#五、所有节点安装配置docker
#1. 安装docker（kubeadm目前支持docker最高版本是17.03.x）
yum install https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm  -y
yum install https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm  -y

#2. 修改配置文件 vim /usr/lib/systemd/system/docker.service
sed -ri '/^ExecStart=/c\ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock  --registry-mirror=https://ms3cfraz.mirror.aliyuncs.com' /usr/lib/systemd/system/docker.service

#3. 启动docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
systemctl status docker

#六、安装、配置kubeadm
#1. 所有节点安装kubelet kubeadm kubectl
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet 

#2. 所有节点修改kubelet配置文件





















