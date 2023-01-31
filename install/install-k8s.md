1. 集群配置免密码
2. 安装docker    
3. 安装kubelet kubeadm kubectl(所有节点)
```
# 官网是谷歌源，配置国内源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum clean all && yum makecache
# k8s 1.24后的版本不支持docker
yum install -y --nogpgcheck kubelet-1.23.16 kubeadm-1.23.16 kubectl-1.23.16
kubeadm version
systemctl enable kubelet #设置开机启动
```
4. 初始化配置文件 (只在master节点执行)
```
mkdir -p k8s-install
cd k8s-install/
kubeadm config print init-defaults > kubeadm.yaml

## 修改配置
advertiseAddress: master_ip
imageRepository: registry.aliyuncs.com/google_containers
networking下添加     podSubnet: 10.244.0.0/16

# 修改配置文件，否则下载镜像会报错
#vim /etc/containerd/config.toml
#disabled_plugins = []
# 拉取镜像
kubeadm config images pull --config kubeadm.yaml
# 初始化
kubeadm init --config kubeadm.yaml

```
5. 添加节点
```
# 查看token
kubeadm token list
# 生成永久token[--token]
kubeadm token create --ttl 0
# 生成 Master 节点的 ca 证书 sha256 编码 hash 值[--discovery-token-ca-cert-hash]
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed  's/^.* //'
# 节点上执行
kubeadm join 192.168.79.105:6443 --token e3eyrb.tf07fdy40mst1umv \
	--discovery-token-ca-cert-hash sha256:f832340c1f33a2deec48d5acb42a1fe6a9f55f102c48fbf15145e9da41bbfd4b

```
6.安装网络插件 kube-flannel.yml 并 应用获取运行中容器
```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
```