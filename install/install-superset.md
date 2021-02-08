```
安装minconda，配置国内镜像
```

```
python3 -m venv /mnt/module/superset
cd /mnt/module/superset
source bin/activate
pip install apache-superset

# 配置文件在/mnt/module/superset/lib/python3.8/site-packages/superset下的config.py
SQLALCHEMY_DATABASE_URI配置为mysql，把元数据存在mysql中
SQLALCHEMY_DATABASE_URI = 'mysql://root:123456sql@192.168.79.200/superset'
# 下载驱动
yum install mysql-devel
pip install mysqlclient

# 初始化数据库
superset db upgrade
# 创建管理员用户
export FLASK_APP=superset
superset fab create-admin

# Create default roles and permissions
superset init

# 启动方法1
superset run -p 8088 --with-threads --reload --debugger
# 启动方法2，需要重启一下
pip install gunicorn
gunicorn --workers 5 --timeout 120 --bind hadoop200:8787  "superset.app:create_app()" --daemon
# 停止
ps -ef | awk '/gunicorn/ && !/awk/{print $2}' | xargs kill -9
```

脚本

```
#!/bin/bash

case $1 in
"start")
/mnt/module/superset/bin/gunicorn --workers 5 --timeout 120 --bind 192.168.79.200:8787  "superset.app:create_app()" --daemon
;;
"stop")
ps -ef | awk '/gunicorn/ && !/awk/{print $2}' | xargs kill -9
;;
esac

```

