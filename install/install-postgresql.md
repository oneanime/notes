## [postgresql](https://www.postgresql.org/download/)
- 按步骤安装  
>PostgreSQL会创建一个默认的linux用户postgres

- 改密码  
命令行进入  
sudo -u postgres psql;  
ALTER USER postgres WITH PASSWORD 'postgres';  改密码 

- 密码有要求：
```
/etc/pam.d/system-auth
password requisite pam_cracklib.so try_first_pass retry=3
password sufficient pam_unix.so md5 shadow nullok try_first_pass use_authtok
password required pam_deny.so
注释掉
添加password sufficient pam_unix.so nullok md5 shadow
```
- 远程连接
```
vim /var/lib/pgsql/<版本>/data/pg_hba.conf
host    all             all             0.0.0.0/0     METHOD(可选ident，md5，password，trust，reject)
vim /var/lib/pgsql/<版本>/data/postgresql.conf
listen_addresses = '*'
```