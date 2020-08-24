## es
```
1. 修改配置文件config/elasticsearch.yml
    cluster.name
    node.name 每个节点都要不同
    bootstrap.memory_lock: false
    network.host 绑定每个节点的ip
    discovery.seed_hosts: ["ip1","ip2"...]
    cluster.initial_master_nodes: ["ip"]  指定master
2. 虚拟机中配置
vim /etc/security/limits.conf 
    * soft nofile 65536 
    * hard nofile 131072 
    * soft nproc 2048 
    * hard nproc 65536
vim /etc/security/limits.d/90-nproc.conf
    soft nproc 4096
vim /etc/sysctl.conf
    vm.max_map_count=262144
vim config/jvm.options
-Xms256m
-Xmx256m

3. 安装kibana
    server.port
    server.host: "0.0.0.0"
    server.name
    elasticsearch.hosts
```