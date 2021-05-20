basic complete                     Alt+/
Smart Type                          Ctrl+/
Type Info(返回的类型)            Alt+.
Pararmeter Info                    Alt+,
Reformat Code                    Ctrl+Alt+Enter Ctrl+Alt+L
Reformat File                       Ctrl+Alt+Shift+L
Quick Decoument                Alt+'
Generate                             Alt+n
Go to Implementation(接口实现类)         Alt+;
Type Hierarchy（接口实现类bar）           Ctrl+;
Introduce Variable(抓取变量)                  Ctrl+Alt+V
Comment with Line Comment                                                   Ctrl+Alt+/
Comment with Block Comment                                                     Ctrl+Shift+/



* 启动报错

  ```
  regedit
  找到JavaSoft删除与IDEA相关的目录
  重启os
  ```

  配置phoenix的驱动
  
  ```
  -- 修改用户数据目录下的jdbc-drivers/jdbc-drivers.xml的版本号
  --如：
  <version version="5.1.1">
              <item url="https://repo1.maven.org/maven2/org/apache/phoenix/phoenix-client-embedded-hbase-2.3/5.1.1/phoenix-client-embedded-hbase-2.3-5.1.1.jar"/>
  </version>
  -- 然后下载驱动，下载完后，先备份，然后解压 
  jar -xvf xxx.jar
  -- 再解压后的文件夹中找到hbase-default.xml，其中加入表映射的配置
   <property>
          <name>phoenix.schema.isNamespaceMappingEnabled</name>
          <value>true</value>
   </property>
   <property>
          <name>phoenix.schema.mapSystemTablesToNamespace</name>
          <value>true</value>
   </property>
  -- 然后打包 
  jar cvfm xxx.jar phoenix-client-embedded-hbase-2.3-5.1.1/META-INF/MANIFEST.MF -C phoenix-client-embedded-hbase-2.3-5.1.1/ .
  -- 然后再把原来的文件替换掉
  ```
  
  ```
  # 连接spark hive时没有数据库表列表
  # 添加连接参数 spark.sql.warehouse.dir          /user/hive/warehouse/
  ```
  
  
  
  