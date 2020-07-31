### 启动数据库
```
1. sqlplus  /nolog  #管理员登录
2. startup/shutdown
3. lsnrctl start /lsnrctl stop（不用在sqlplus）
```
> sqlplus hp/123456sql@192.168.79.202:1521/hp  
&emsp;&emsp;oracle数据库的概念和mysql中不同，只有一个大数据库，里面可以有多个实例，每个实例里面有多个用户（相当于mysql中的数据库概念），和多个tablenamespace（存储数据，磁盘上的文件），每个用户都有一个对应的表空间，不同用户可以用同一个表空间

### 切换用户
```
conn 用户名[/密码] as sysdba
切换到system账户：conn system/manager
切换sys用户：conn sys/change_on_install as sysdba
```

### 创建用户
```
create user c##用户名 identified by 密码;
grant create session to c##用户名;
GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO c##hp CONTAINER=ALL ;

注：c##用在容器数据库中
```

 
>  遇到过的错误
>>ORA-01109:database not open  
解决方案：1、sqlplus / as sysdba;--管理员登录  
	2、select con_id,name,open_mode from V$pdbs;--查看pdb的状态  
	3、alter pluggable database ORA19CPDB  open;  
	4、alter session set container=ORA19CPDB ;  
	5、commit;  
ora-01261和ora-01262  
安装完后$ORACLE_HOME/dbs下可能没有init<SID>.ora文件，从sampl文件夹下考过去，并把文件下的路径占位符替换，并建立相应的文件夹。

