1. 集群配置免密码
```
# 关闭swap，注释掉swap那一行
sudo vim /etc/fstab

```
2. 安装docker(安装20.10.x或以下版本，https://docs.docker.com/engine/release-notes/20.10/)
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
6.安装网络插件kube-flannel.yml并应用获取运行中容器
```
https://github.com/flannel-io/flannel/blob/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
# kube-flannel.yml其中会下载镜像。国内可能会下不下来，去GitHub下载docker离线镜像，导入到docker中
https://github.com/flannel-io/flannel/releases
# 每个节点都有装
#docker load < flanneld-v0.20.2-arm64.docker
#把kube-flannel.yml中镜像换成quay.io/coreos/flannel:v0.20.2-arm64

#已经下载导出到GitHub上
https://github.com/oneanime/notes/tree/master/install/packages
# flannel-cni-plugin和flannel只配置阿里云源，下不下来，docker中多配几个国内源，就可有下载下来，不过网速不一定稳定，多试几次
```
7. 安装ingress
```
https://github.com/kubernetes/ingress-nginx/blob/main/deploy/static/provider/cloud/deploy.yaml
F:\project\git\repo\notes\install\packages
# 复制到本地，修改镜像源和镜像版本，例如
# nginx-ingress-controller
registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.5.1
# kube-webhook-certgen
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v20220916-gd32f8c343



kubectl apply -f deploy.yaml
```
8. 安装dashboard
```
#查看版本兼容，下载deployments文件
https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml
# 修改镜像源
registry.cn-hangzhou.aliyuncs.com/google_containers/dashboard:v2.5.1
registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-scraper:v1.0.7
```
```
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort        #添加NodePort
  externalIPs:
    - 192.168.79.105   #访问的地址
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30000   #暴露的端口
  selector:
    k8s-app: kubernetes-dashboard
```
```
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -L -n
```
```
# 生成证书
mkdir cert
cd cert/
openssl genrsa -out dashboard.key 2048
openssl req -days 36000 -new -out dashboard.csr -key dashboard.key -subj '/CN=**192.168.79.105**'
openssl x509 -req -in dashboard.csr -signkey dashboard.key -out dashboard.crt
kubectl create secret generic kubernetes-dashboard-certs --from-file=dashboard.key --from-file=dashboard.crt -n kubernetes-dashboard
```
```
# 添加证书
args:
- --auto-generate-certificates
- --namespace=kubernetes-dashboard
- --tls-key-file=dashboard.key
- --tls-cert-file=dashboard.crt


kubectl apply -f xxx.yaml     
```
```
# 访问谷歌浏览器时会报错，鼠标点击空包处，键盘打字  thisisunsafe  ,回车。或者用火狐浏览器
# 生成token，浏览器上要使用
vim create-admin.yaml
```
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
 
```
```
kubectl apply -f create-admin.yaml
# 查看sa和secret
kubectl get sa,secrets -n kubernetes-dashboard
kubectl describe secret admin-user-token-xxxx -n kubernetes-dashboard
```