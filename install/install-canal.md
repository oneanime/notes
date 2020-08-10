#### 开启mysql的binlog
>1. 在[mysql]区块下添加  
>   log-bin=mysql-bin  
>   binlog_format=row  
>   binlog-do-db=监控的数据库       #不加代表监控所有的数据库
>2. 重启mysql
>3. show variables like 'log_%';    #验证log_bin是否开启
>4. CREATE USER canal IDENTIFIED BY 'canal';  
    GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%' IDENTIFIED BY 'canal';  
    FLUSH PRIVILEGES;  

#### 配置canal
> - canal.properties  
> 1. canal.serverMode=kafka  
> 2. canal.mq.servers=host1:9092,host2:9092...  
> (注) 高可用配置canal.zkServers=host1:2181,host2:2181...  
> - instance.properties(针对要追踪的mysql的实例配置)
> 1. canal.instance.master.address=192.168.79.200:3306  
> 2. canal.mq.topic  

