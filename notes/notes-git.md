搭建最轻型的git服务器
yum install git git-daemon
 mkdir -p /opt/git/repo/
git daemon --verbose --detach --export-all --base-path=/opt/git/repo/ --reuseaddr --enable=receive-pack /opt/git/repo/

/opt/git/repo/ 相当于服务的根目录，在里面创建子目录作为每个单独需求仓库
mkdir script.git;cd script.git;git init --bare;git config daemon.receivepack true
git config daemon.receivepack true  （赋予写权限）


git clone git:hostname/script.git
cd script;git remote -v  （查看版本）
克隆下来够提交一个文件进去如：README