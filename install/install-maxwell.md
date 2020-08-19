#### 开启mysql的binlog
>1. 在[mysql]区块下添加  
>   log-bin=mysql-bin  
>   binlog_format=row  
>   binlog-do-db=监控的数据库       #不加代表监控所有的数据库
>2. 重启mysql
>3. show variables like 'log_%';    #验证log_bin是否开启
>4. CREATE DATABASE maxwell ;  
>   CREATE USER maxwell IDENTIFIED BY '123456sql';  
>   GRANT ALL ON maxwell.* TO 'maxwell'@'%' IDENTIFIED BY '123456sql';  
>   GRANT SELECT ,REPLICATION SLAVE , REPLICATION CLIENT ON \*.* TO maxwell@'%'  
>   FLUSH PRIVILEGES;    

      
    
    

#### 配置maxwell
```
producer=kafka
kafka.bootstrap.servers=hadoop1:9092,hadoop2:9092,hadoop3:9092
kafka_topic=ODS_DB_GMALL2020_M
            maxwell_%{database}_%{table}  分流
host=hadoop2
user=maxwell
password=123123

client_id=maxwell_1
```
```
# 启动
/ext/maxwell-1.25.0/bin/maxwell --config  /xxx/xxxx/maxwell.properties >/dev/null 2>&1 &
```

#### 启动bootstrap初始化导入数据
```
法一 bin/maxwell-bootstrap --user maxwell  --password 123456sql --host 192.168.79.200  --database gmall01 --table base_province --client_id maxwell_1
法二、 insert into maxwell.bootstrap (database_name, table_name) values ("fooDB", "barTable");
具体文档：https://github.com/zendesk/maxwell/blob/master/docs/docs/bootstrapping.md
```