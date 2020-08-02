>搭建最轻型的git服务器  
>yum install git git-daemon  
> mkdir -p /opt/git/repo/  
>git daemon --verbose --detach --export-all --base-path=/opt/git/repo/ --reuseaddr --enable=receive-pack /opt/git/repo/  
>  
>/opt/git/repo/ 相当于服务的根目录，在里面创建子目录作为每个单独需求仓库  
>mkdir script.git;cd script.git;git init --bare;git config daemon.receivepack true  
>git config daemon.receivepack true  （赋予写权限）  
>
>
>git clone git:hostname/script.git  
>cd script;git remote -v  （查看版本）  
>克隆下来够提交一个文件进去如：README  
#
-  

### 本地常用命令
1.初始化git
```
/*
1、 会在文件夹下创建一个.git文件，相当于git仓库创建完成
2、 .git为版本库,版本库存储了很多配置信息，日志信息和版本信息等
3、 工作目录（工作区），就是 包含.git文件夹的目录，存放开发的代码
4、 暂存区为.git文件夹中的index文件，也可以叫stage，临时保存修改文件的地方
      git add        git commit
工作区--------->暂存区------------->版本库
*/
git init
```
2.查看文件状态
```
//加-s使输出更加简洁
git status [-s]
```
3.加入暂存区
```
// 加入暂存区
git add 文件
// 取消暂存区
git reset 文件
```
4.提交到本地仓库
```
git commit -m "日志"
加-a 相当于不用再git add了
```
5.删除文件
```
//加到了暂存区的，步骤git中操作删除，不会加入到暂存区必须git add操作
git rm 文件
git commit -m "日志"
```
6. .gitignore文件
```
*.a
!lib.a  取反，表示不忽略
/aaa.java    不会忽略子目录下的
build/
doc/*.txt
doc/**/*.pdf   忽略所有doc下的包括子目录下的
```
7. 查看日志
```
git log
```
#
- 
###远程常用命令
```
查看远程服务器仓库
git remote
git remote -v
```
1.添加远程仓库
```
git remote add 简写名称(origin) url
```
2.下载到本地
```
git clone
```
3.删除远程仓库（把本地和远程仓库的关联移除）
```
git remote rm
```
4.从远程仓库抓取和拉取
```
git fetch  //不会自动合并
git pull   //最新，会自动合并
```
5.推送到远程仓库
```
git push 项目名 分支
```
#
- 
### 分支操作
1.查看分支
```
git branch
git branch -r   查看远程的分支
git branch -a   查看本地和远程的
```
2.创建分支
```
git branch 分支名
```
3.切换分支
```
git checkout 分支名
```
4.推送到远程仓库
```
git push 项目名(origin) 分支
```
5.合并分支
```
// 在要合并的分支的目录下执行
git merge 其他分支
//合并有冲突的话，解决后要，git add
```
6.删除分支
```
git branch -d 分支名
git push 项目名(origin) -d 分支
```
7.场景(已经有master分支了)
```
git branch dev    // 创建dev分支
git checkout dev  //在分支下开发需求
git branch fix    //有bug要修改
git checkout fix  
git commit -a -m "fix over"
git checkout master
git merge fix   // 合并分支
git push origin master    // 推送到远程仓库
```
#
- 
###git 标签
1.创建标签
```
git tag 标签名（一般可以用版本号）
```
2.查看标签信息
```
git show [tag]
```
3.推送标签名
```
git push [remote][tag]
git push origin 标签名
```
4.检出标签
```
//新建一个分支，指向某个tag
git checkout -b [分支名] [标签名]
```
5.删除标签
```
git tag -d [tag]
git push origin :refs/tags/[tag]
```