## nginx
```
./configure   --prefix=/opt/module/nginx
make && make install
sudo setcap cap_net_bind_service=+eip /opt/module/nginx/sbin/nginx
```