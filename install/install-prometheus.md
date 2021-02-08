```
https://prometheus.io/download/

# 创建目录，存放Prometheus 拉取过来的数据，我们这里选择local storage

mkdir -p /mnt/data/prometheus/

# 启动Prometheus

/opt/soft/prometheus/prom/prometheus --storage.tsdb.path="/data1/prometheus/data/" --log.level=debug --web.enable-lifecycle --web.enable-admin-api --config.file=/opt/soft/prometheus/prom/prometheus.yml

# 至此Prometheus就可以正常工作了

插件更新
curl -XPOST http://host1:ip/-/reload
```

安装Node Exporter

```
prometheu_home下的prometheu.yml

scrape_configs:
- job_name: node
  static_configs:
  - targets: ['localhost:9100']
```

