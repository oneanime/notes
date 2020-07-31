> 环境 centos7  

>yum localinstall -y oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm  
yum localinstall -y oracle-database-ee-19c-1.0-1.x86_64.rpm  
安装（安装完后，会自动创建oracle用户）

### 创建数据库（一个数据库相当于一个实例）  
> vim /etc/init.d/oracledb_ORCLCDB-19c 配置sid等 
cp /etc/sysconfig/oracledb_ORCLCDB-19c.conf /etc/sysconfig/oracledb_配置的sid-19c.conf  
/etc/init.d/oracledb_ORCLCDB-19c configure

### 配置远程连接
>  /opt/oracle/product/19c/dbhome_1/network/admin/sample下的三个文件拷到../下，创建实例后会自动生成,修改这三个文件  

### 三个文件的作用
* sqlnet.ora
> 通过这个文件来决定怎么样找一个连接中出现的连接字符串  
例如sqlplus sys/oracle@ora  
那么，客户端就会首先在tnsnames.ora文件中找ora的记录.如果没有相应的记录则尝试把ora当作一个主机名，通过网络的途径去解析它的 ip地址然后去连接这个ip上GLOBAL_DBNAME=ora这个实例，当然我这里ora并不是一个主机名  
SQLNET.AUTHENTICATION_SERVICES= (NONE)  
NAMES.DIRECTORY_PATH= (TNSNAMES,HOSTNAME,EZCONNECT)
* tnsnames.ora
> 这个文件类似于unix 的hosts文件，提供的tnsname到主机名或者ip的对应  

>ORA_TEST =  
(DESCRIPTION =  
&emsp;(ADDRESS_LIST =  
&emsp;&emsp;(ADDRESS = (PROTOCOL = TCP)(HOST = LXL)(PORT = 1521))  
&emsp;)  
&emsp;(CONNECT_DATA =  
&emsp;&emsp;(SERVER = DEDICATED)  
&emsp;&emsp;(SERVICE_NAME = ora)  
&emsp;)  
) 

>参数解释  
ORA_TEST：客户端连接服务器端使用的服务别名。注意一定要顶行书写，否则会无法识别服务别名。   
PROTOCOL：客户端与服务器端通讯的协议，一般为TCP，该内容一般不用改。   
HOST：ORACLE服务器端IP地址或者hostname。确保服务器端的监听启动正常。   
PORT：数据库侦听正在侦听的端口，可以察看服务器端的listener.ora文件或在数据库侦听所在的机器的命令提示符下通过lnsrctl status [listener name]命令察看。此处Port的值一定要与数据库侦听正在侦听的端口一样。   
SERVICE_NAME：在服务器端，用system用户登陆后，sqlplus> show parameter service_name命令查、看。  

* listener.ora
> listener监听器进程的配置文件  

> SID_LIST_LISTENER =  
&emsp;(SID_LIST =   
&emsp;&emsp;(SID_DESC =   
&emsp;&emsp;(GLOBAL_DBNAME = hp)    
&emsp;&emsp;(ORACLE_HOME = /opt/oracle/product/19c/dbhome_1/)  
&emsp;&emsp;(SID_NAME = hp)    
&emsp;&emsp;)   
&emsp;)  
LISTENER =  
&emsp;(DESCRIPTION =  
&emsp;&emsp;(ADDRESS = (PROTOCOL = TCP)(HOST = hostname)(PORT = 1521))  
&emsp;)

>参数解释  
LISTENER ：监听名称，可以配置多个监听，多个监听的端口号要区分开来。 
GLOBAL_DBNAME ：全局数据库名。通过select * from global_name; 查询得出  
ORACLE_HOME ：oracle软件的跟目录  
SID_NAME ：服务器端（本机）的SID  
PROTOCOL：监听协议，一般都使用TCP  
HOST：本机IP地址，双机时候使用浮动IP  
PORT：监听的端口号，使用netstat –an 检查该端口不被占用。

>注：  
当你输入sqlplus sys/oracle@orcl的时候  
1． 查询sqlnet.ora看看名称的解析方式，发现是TNSNAME  
2． 则查询tnsnames.ora文件，从里边找orcl的记录，并且找到主机名，端口和service_name  
3． 如果listener进程没有问题的话，建立与listener进程的连接。  
4． 根据不同的服务器模式如专用服务器模式或者共享服务器模式，listener采取接下去的动作。默认是专用服务器模式，没有问题的话客户端就连接上了数据库的server process。  
5． 这时候网络连接已经建立，listener进程的历史使命也就完成了。
### 环境变量配置
```
vim ~/.bash_profile
export LANG=en_US
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19c/dbhome_1
export ORACLE_SID=hp
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export PATH=$PATH:$ORACLE_HOME/bin
```




