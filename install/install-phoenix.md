配置表映射

```
<!-- hbase-site.xml中配置。服务端和客户端中都要配置 -->

<property>
        <name>phoenix.schema.isNamespaceMappingEnabled</name>
        <value>true</value>
</property>
<property>
        <name>phoenix.schema.mapSystemTablesToNamespace</name>
        <value>true</value>
</property>
```

