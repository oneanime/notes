```python
# 进入虚拟环境
${enve}/bin/activate

# 退出虚拟环境
deactivate
```
win
```
conda create -n your_env_name python=x.x
activate your_env_name
conda install -n your_env_name [package]
activate root
conda remove -n your_env_name --all
conda remove --name $your_env_name  $package_name 
```
安装pyspider
```
#版本太高会报错
conda create -n my_spider python=3.6
activate my_spider
pip install wheel
pip install pycurl
pip install pyspider
#下载 PhantomJS，PhantomJS放到虚拟环境的python.exe同一目录下
```