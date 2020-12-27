```
yum install -y epel-release

# 安装supervisor

yum install -y supervisor

# 安装完毕后，我们的supervisord的配置文件默,安装在/etc/supervisord.conf, 我们不需要默认的配置文件，我们编写自己的配置文件，因此我们先把默认配置文件备份一下，执行如下命令

mv /etc/supervisord.conf /etc/supervisord.conf.bak

#之后我们编写自己的配置文件supervisord.conf 放到 /etc/ 目录下

```

```
sudo supervisord -c /etc/supervisord.conf    # 启动
supervisorctl shutdown                       # 关闭
sudo supervisorctl reread                    # 读取配置文件
sudo supervisorctl update prometheus         # 更新启动Prometheus
sudo supervisorctl status prometheus         # 查看启动状态
sudo supervisorctl stop prometheus            
sudo supervisorctl start prometheus
# 注意一旦你修改了配置文件内容，一定要先reread，然后 update 就可以了
```

```
; filename supervisord.conf

[unix_http_server]

file=/var/run/supervisor/supervisor.sock  ; socket 文件路径，supervisorctl使用XML_RPC和supervisord 的通信就是通他进行，必须设置，不然supervisorctl就不可用了

;username=user       ; 可以指定用户名密码，我们这里不开启了
;password=123        ; 

[inet_http_server]     ; 监听在TCP上的scoket，如果想使用Web Server或者使用远程的Supervisorclt，就必须开启，默认不开启，我们这里开启

port=0.0.0.0:9001    ; 监听的地址和端口

;username=user       ; 可以指定用户名密码，我们这里不开启了
;password=123       ; 

[supervisord] ; supervisord 主进程的相关配置

logfile=/var/log/supervisor/supervisord.log ; 主进程的日志文件
logfile_maxbytes=50MB    ; 日志文件多大后会滚动生成一个新的日志文件 默认50MB
logfile_backups=10      ; 最多备份多少个日志文件，默认10 个
loglevel=info        ; log level; default info; others: debug,warn,trace
pidfile=/var/run/supervisor/supervisord.pid ;主进程的 pid文件路径

nodaemon=false        ; 主进程是否在前台运行，默认是false，在后台运行

minfds=1024    ; 最少系统空闲的文件描述符，低于这个值，supervisor将不会启动 默认 1024

minprocs=1024        ; 最小可用进程描述符 低于这个值，supervisor将不会启动 默认200

user=root					; 启动supervisord 的用户


[rpcinterface:supervisor]; 这个选项是给XML_RPC用的，如果使用supervisord 和webserver这个选项必须开启

supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]

serverurl=unix:///var/run/supervisor/supervisor.sock ; 本地连接supervisord的时候使用，注意和[unix_http_server]配置对应

serverurl=http://0.0.0.0:9001 ; 远程连接supervisord

;username=       ; 可以指定用户名密码，我们这里不开启了

;password=        ; 

[include] ;分离的配置文件,我们可以总是将我们应用的配置文件放到单独的目录文件下管理，这样配置清晰，下面是配置的分离配置文件的路径，supervisord会加载我们配置到对于文件加下的文件

files = /etc/supervisord.d/*.conf ; 匹配 /etc/supervisord.d/ 下所有以 .conf 结尾的文件
```

supervisor集成prometheus

```
; prometheus 启动配置文件

[program:prometheus] ; 我们的应用配置格式为 program:我们应用名称(自己定义)
directory=/opt/soft/prometheus/prom ; 运行程序前会切换到配置的目录中
command=/opt/soft/prometheus/prom/prometheus --storage.tsdb.path="/data1/prometheus/data/" --log.level=debug --web.enable-lifecycle --web.enable-admin-api --config.file=/opt/soft/prometheus/prom/prometheus.yml     ; 我们要执行的命令,这就是之前我们再前台启动prometheus的命令

stderr_logfile=/var/log/supervisor/prometheus.err   ;错误日志文件,手动创建目录
stdout_logfile=/var/log/supervisor/prometheus.log   ;标准输出日志文件,我们通过该文件查看Prometheus运行日志

stdout_logfile_maxbytes=10MB ; 标准输出日志文件多大滚动一次
stdout_logfile_backups=10 ; 标准输出日志文件最多备份多少个

user=root ; 以什么用户启动
autostart=true ; 是否在supervisord启动时，直接就启动应用
autorestart=true ; crash 后是否自动重启

startsecs=10  ;应用进程启动多少秒之后，此时状态如果是running状态，就认为是成功

startretries=3 ; 当进程启动失败后，最大尝试启动的次数, 如果超过指定次数，应用会被标记为Fail状态

stopasgroup=true ; 是否停止由应用本身创建的子进程，此选项接受的停止信号是stop信号

killasgroup=true ; 是否停止由应用本身创建的子进程,此选项接受的停止信号是SIGKILL信号

redirect_stderr=false ; 如果是true，stderr的日志会被写入stdout日志文件中
```

集成grafana

```
; grafana 启动配置文件

[program:grafana] ; 我们的应用配置格式为 program:我们应用名称(自己定义)

directory=/opt/soft/grafana/graf/ ; 运行程序前会切换到配置的目录中

command=sh -c "bin/grafana-server -config conf/grafana.ini" ; 我们要执行的命令

stderr_logfile=/var/log/supervisor/grafana.err	;错误日志文件

stdout_logfile=/var/log/supervisor/grafana.log ;标准输出日志文件，我们通过该文件查看grafana运行日志

stdout_logfile_maxbytes=10MB ; 标准输出日志文件多大滚动一次

stdout_logfile_backups=10 ; 标准输出日志文件最多备份多少个

user=root	; 以什么用户启动

autostart=true ; 是否在supervisord启动时，直接就启动应用

autorestart=true ; crash 后是否自动重启

startsecs=10	;应用进程启动多少秒之后，此时状态如果是running状态，就认为是成功

startretries=3 ; 当进程启动失败后，最大尝试启动的次数, 如果超过指定次数，应用会被标记为Fail状态

stopasgroup=true ; 是否停止由应用本身创建的子进程，此选项接受的停止信号是stop信号

killasgroup=true ; 是否停止由应用本身创建的子进程,此选项接受的停止信号是SIGKILL信号

redirect_stderr=false ; 如果是true，stderr的日志会被写入stdout日志文件中
```

