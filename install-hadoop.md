## 安装
```
1.安装好linux
    /boot 200M 
    /swap 2g 
    / 剩余
```
```
2. *安装VMTools
```
```
3. 关闭防火墙
    sudo service iptables stop
    sudo chkconfig iptables off
```
```
4. 设置静态IP，改主机名
    编辑vim /etc/sysconfig/network-scripts/ifcfg-eth0
    改成
=================================
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.5.101
GATEWAY=192.168.5.2
DNS1=8.8.8.8
DNS2=8.8.4.4
=================================
修改hostname 
hostnamectl set-hostname host名
reboot
```
```
5. 配置/etc/hosts
    vim /etc/hosts
=============================
192.168.1.100   hadoop100
192.168.1.101   hadoop101
192.168.1.102   hadoop102
```
```
6. 创建用户，配密码
useradd hp
passwd hp
```
```
7. 配置这个用户为sudoers
   vim /etc/sudoers
   在root    ALL=(ALL)       ALL
   添加atguigu    ALL=(ALL)       NOPASSWD:ALL
   保存时wq!强制保存
```
```
8. 克隆集群
# 生成密钥对
ssh-keygen -t rsa 三次回车
 
# 发送公钥到本机
ssh-copy-id hadoop102 输入一次密码
 
# 分别ssh登陆一下所有虚拟机
ssh hadoop103
exit
ssh hadoop104
exit
 
# 把/home/hp/.ssh 文件夹发送到集群所有服务器
scp -r /home/hp/.ssh hp@hadoop101:/home/hp/.ssh
        
```
```
配置JAVA_HOME、HADOOP_HOME
```
### core-site.xml
```
<property>
          <name>fs.defaultFS</name>
          <value>hdfs://192.168.79.200:9000</value>
    </property>
    <property>
            <name>hadoop.tmp.dir</name>
            <value>/opt/module/hadoop/data/tmp</value>
    </property>

    <property>
            <name>hadoop.proxyuser.bigdata.hosts</name>
            <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.bigdata.groups</name>
         <value>*</value>
    </property>

    <property>
            <name>hadoop.proxyuser.root.hosts</name>
            <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.root.groups</name>
         <value>*</value>
    </property>

    <property>
        <name>io.compression.codecs</name>
	<value>
	org.apache.hadoop.io.compress.GzipCodec,
	org.apache.hadoop.io.compress.DefaultCodec,
	org.apache.hadoop.io.compress.BZip2Codec,
	org.apache.hadoop.io.compress.SnappyCodec,
	com.hadoop.compression.lzo.LzoCodec,
	com.hadoop.compression.lzo.LzopCodec
	</value>
    </property>

    <property>
    	<name>io.compression.codec.lzo.class</name>
    	<value>com.hadoop.compression.lzo.LzoCodec</value>
    </property>
```
### hdfs-site.xml
```
<property>
    <name>dfs.replication</name>
    <value>1</value>
</property>
<!-- 指定Hadoop辅助名称节点主机配置 -->
<property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>192.168.79.200:50090</value>
</property>
<property>
    <name>dfs.safemode.threshold.pct</name>
    <value>0f</value>
</property>  
```
### mapred-site.xml
```
<property>  
    <name>mapreduce.framework.name</name>  
    <value>yarn</value>  
</property>
```
### workers/slaves
```
配置datanode的地址
```
### yarn-site.xml
```
<!-- Reducer获取数据的方式 -->
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<!-- 指定YARN的ResourceManager的地址 -->
<property>
    <name>yarn.resourcemanager.hostname</name>
    <value>192.168.79.200</value>
</property>
<!-- 日志聚集功能使能 -->
<property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
</property>
<!-- 日志保留时间设置7天 -->
<property>
    <name>yarn.log-aggregation.retain-seconds</name>
    <value>604800</value>
</property>
<property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>4096</value>
</property>
<property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>4096</value>
</property>
<property>
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>5.0</value>
</property>
<property>
    <name>mapred.child.java.opts</name>
    <value>-Xmx1024m</value>
</property>
<property>
    <name>yarn.nodemanager.pmem-check-enabled</name>
    <value>false</value>
</property>

<property>
    <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
</property>

<property>
    <name>yarn.log.server.url</name>
    <value>http://192.168.79.200:19888/jobhistory/logs</value>
</property>
```