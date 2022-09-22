1. 安装oracle
2. 创建用户（oracle的用户相当于mysql的数据库概念）。在安装时可以选择安装额组件，至少，要创建前两个用户
```
#Domain
create user c##infa_domain_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_domain_test;
alter user c##infa_domain_test default role all;
alter user c##infa_domain_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_domain_test;
# alter user c##infa_domain_test quota unlimited on INFORTBS;
```
```
#Model_Repository_Service
create user c##infa_rep_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_rep_test;
alter user c##infa_rep_test default role all;
alter user c##infa_rep_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_rep_test;
# alter user c##infa_rep_test quota unlimited on INFORTBS;	
```
```
create user c##infa_integ_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_integ_test;
alter user c##infa_integ_test default role all;
alter user c##infa_integ_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_integ_test;
# alter user c##infa_integ_test quota unlimited on INFORTBS;
```
```
#Content_Management_Service
create user c##infa_content_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_content_test;
alter user c##infa_content_test default role all;
alter user c##infa_content_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_content_test;
# alter user c##infa_content_test quota unlimited on INFORTBS;
```
```
#profiling warehouse
create user c##infa_profiling_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_profiling_test;
alter user c##infa_profiling_test default role all;
alter user c##infa_profiling_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_profiling_test;
# alter user c##infa_profiling_test quota unlimited on INFORTBS;
```
```
#PowerCenter repository
create user c##infa_power_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_power_test;
alter user c##infa_power_test default role all;
alter user c##infa_power_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_power_test;
# alter user c##infa_power_test quota unlimited on INFORTBS;
```
```
#storge repository
create user c##infa_storge_test identified by 123456;
grant connect,resource,create view,select any table to c##infa_storge_test;
alter user c##infa_storge_test default role all;
alter user c##infa_storge_test quota unlimited on users;
# revoke unlimited tablespace from c##infa_storge_test;
# alter user c##infa_storge_test quota unlimited on INFORTBS;
```

3. 创建组和用户
```
# 装完oracle后，会自动创建oinstall组
sudo groupadd -g 1023 oinstall
sudo useradd -m infor -g 1023
sudo usermod -g oinstall infor
```
4. 解压安装包，加压之前要创建一个文件夹，解压到文件夹，正常解压不会创建文件夹
5. sudo chown -R infor.oinstall 安装目录
6. 安装jdk
7. 切换到infor用户下
8. 进入安装目录，直接执行./install.sh，会报错，
```
unset DISPLAY
./install.sh
```
9. 安装时的选项
```
# 要连数据库，选连接字符串
jdbc:informatica:oracle://192.168.79.202:1521;ServiceName=ORCLCDB
# data access string
jdbc:informatica:oracle://192.168.79.202:1521;ServiceName=ORCLCDB
# 创建域domain，密码123456Test
# encryption key，123456Test
```
10. 启动关闭
```
/opt/informatica/10.4.1/server/tomcat/bin/infaservice.sh shutdown
/opt/informatica/10.4.1/server/tomcat/bin/infaservice.sh startup
```
11. web管理平台登录
```
用户：administrator
密码：123456
```
> 注：安装完后oracle+informatica差不多53g，两个都启动8g内存差不多会吃满