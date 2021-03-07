1. 安装准备

   ```
   环境centos7
   oracle-database-preinstall下载地址 http://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/
   安装包官网下载
   ```

2. 安装

   ```
   yum localinstall -y oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm  
   yum localinstall -y oracle-database-ee-19c-1.0-1.x86_64.rpm  
   # 安装（安装完后，会自动创建oracle用户）
   
   # 创建数据库（一个数据库相当于一个实例）
   /etc/init.d/oracledb_ORCLCDB-19c configure
   # 修改oracle密码，之后的操作都在oracle用户下
   passwd oracle
   ```

3. 配置环境变量(~/.bash_profile)

   ```
   export ORACLE_BASe=/opt/oracle
   export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
   
   export ORACLE_VERSION=19c
   export ORACLE_SID=ORCLCDB
   #export TEMPLATE_NAME=General_Purpose.dbc
   #export CHARSET=AL32UTF8
   #export PDB_NAME=ORCLPDB1
   #export LISTENER_NAME=LISTENER
   #export NUMBER_OF_PDBS=1
   #export CREATE_AS_CDB=true
   export ORACLE_OWNER=oracle
   
   export PATH=$ORACLE_HOME/bin:$PATH
   
   ```

3. 配置远程连接

   >配置远程连接的文件在/opt/oracle/product/19c/dbhome_1/network/admin下的tnsnames.ora、sqlnet.ora、tnsnames.ora
   >
   >创建数据库实例后，会创建这三个文件
   >
   >文件中默认的hostname 是当前机器的hostname，在/etc/hosts中配置当前hostname的ip即可

4.  创建用户

   ```
   #linux oracle用户下
   sqlplus / as sysdba
   create user c##hp identified by 123456;
   grant connect,resource,dba to c##hp;
   # 切换用户
   conn 用户名[/密码] as sysdba
   # 切换到system账户：conn system/manager
   # 切换sys用户：conn sys/change_on_install as sysdba
   ```

5. 启动关闭

   ```
   # sqlplus / as sysdba下
   startup/shutdown
   lsnrctl start /lsnrctl stop（不用在sqlplus）
   ```

6.  [样例数据库](https://codeload.github.com/oracle/db-sample-schemas/tar.gz/v19c)

   ```
   @mksample.sql 1 1 1 1 1 1 1 1 USERS temp /opt/software/db-sample-schemas-19.2/logs/ db:1521/ora19cpdb
   alter session set container=ora19cpdb
   ORA19CPDB
   
   alter pluggable database ora19cpdb  open;
   
   SELECT OWNER,OBJECT_TYPE, COUNT(1) FROM DBA_OBJECTS where owner='HR';
   
   create tablespace ora19cpdb01 datafile '/opt/oracle/oradata/ORA19C/ora19cpdb01.dbf' size 1024m;
   
   drop tablespace XFTBS including contents and datafiles cascade constraint;
   ```

   

注：

>oracle从12c开始增加了增加了CDB和PDB的概念，数据库引入的多租用户环境（Multitenant Environment）中，允许一个数据库容器（CDB）承载多个可插拔数据库（PDB）。CDB全称为Container Database，中文翻译为数据库容器，PDB全称为Pluggable Database，即可插拔数据库。在ORACLE 12C之前，实例与数据库是一对一或多对一关系（RAC）：即一个实例只能与一个数据库相关联，数据库可以被多个实例所加载。而实例与数据库不可能是一对多的关系。当进入ORACLE 12C后，实例与数据库可以是一对多的关系。

#### 三个文件的作用

- sqlnet.ora

  >通过这个文件来决定怎么样找一个连接中出现的连接字符串  
  >例如sqlplus sys/oracle@ora  
  >那么，客户端就会首先在tnsnames.ora文件中找ora的记录.如果没有相应的记录则尝试把ora当作一个主机名，通过网络的途径去解析它的 ip地址然后去连接这个ip上GLOBAL_DBNAME=ora这个实例，当然我这里ora并不是一个主机名  

- tnsnames.ora

  >这个文件类似于unix 的hosts文件，提供的tnsname到主机名或者ip的对应

  ```
  ORA_TEST =  
  (DESCRIPTION =  
      (ADDRESS_LIST =  
          (ADDRESS = (PROTOCOL = TCP)(HOST = LXL)(PORT = 1521))  
      )  
      (CONNECT_DATA =  
          (SERVER = DEDICATED)  
          (SERVICE_NAME = ora)  
      )  
  ) 
  ```

  >参数解释  
  >ORA_TEST：客户端连接服务器端使用的服务别名。注意一定要顶行书写，否则会无法识别服务别名。   
  >PROTOCOL：客户端与服务器端通讯的协议，一般为TCP，该内容一般不用改。   
  >HOST：ORACLE服务器端IP地址或者hostname。确保服务器端的监听启动正常。   
  >PORT：数据库侦听正在侦听的端口，可以察看服务器端的listener.ora文件或在数据库侦听所在的机器的命令提示符下通过lnsrctl status [listener name]命令察看。此处Port的值一定要与数据库侦听正在侦听的端口一样。   
  >SERVICE_NAME：在服务器端，用system用户登陆后，sqlplus> show parameter service_name命令查、看。  

- istener.ora

>listener监听器进程的配置文件  

```
SID_LIST_LISTENER =  
    (SID_LIST =   
        (SID_DESC =   
        (GLOBAL_DBNAME = hp)    
        (ORACLE_HOME = /opt/oracle/product/19c/dbhome_1/)  
        (SID_NAME = hp)    
        )   
    )  

LISTENER =  
    (DESCRIPTION =  
        (ADDRESS = (PROTOCOL = TCP)(HOST = hostname)(PORT = 1521))  
    )
```

>参数解释  
>LISTENER ：监听名称，可以配置多个监听，多个监听的端口号要区分开来。 
>GLOBAL_DBNAME ：全局数据库名。通过select * from global_name; 查询得出  
>ORACLE_HOME ：oracle软件的跟目录  
>SID_NAME ：服务器端（本机）的SID  
>PROTOCOL：监听协议，一般都使用TCP  
>HOST：本机IP地址，双机时候使用浮动IP  
>PORT：监听的端口号，使用netstat –an 检查该端口不被占用。

>注：  
>当你输入sqlplus sys/oracle@orcl的时候  
>1． 查询sqlnet.ora看看名称的解析方式，发现是TNSNAME  
>2． 则查询tnsnames.ora文件，从里边找orcl的记录，并且找到主机名，端口和service_name  
>3． 如果listener进程没有问题的话，建立与listener进程的连接。  
>4． 根据不同的服务器模式如专用服务器模式或者共享服务器模式，listener采取接下去的动作。默认是专用服务器模式，没有问题的话客户端就连接上了数据库的server process。  
>5． 这时候网络连接已经建立，listener进程的历史使命也就完成了。