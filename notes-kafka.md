### 排错
```
2020-01-01 00:04:51,876 INFO internals.ConsumerCoordinator: [Consumer clientId=consumer-1, groupId=flume] Revoking previously assigned partitions []
2020-01-01 00:04:51,876 INFO internals.AbstractCoordinator: [Consumer clientId=consumer-1, groupId=flume] (Re-)joining group
2020-01-01 00:04:51,896 INFO internals.AbstractCoordinator: [Consumer clientId=consumer-1, groupId=flume] Successfully joined group with generation 3
2020-01-01 00:04:51,897 INFO internals.ConsumerCoordinator: [Consumer clientId=consumer-1, groupId=flume] Setting newly assigned partitions [test-0]
2020-01-01 00:04:51,897 INFO kafka.SourceRebalanceListener: topic test - partition 0 assigned.
2020-02-04 00:00:00,247 INFO internals.AbstractCoordinator: [Consumer clientId=consumer-1, groupId=flume] Group coordinator 192.168.79.103:9092 (id: 2147483645 rack: null) is unavailable or invalid, will attempt rediscovery
说明kafka中没有可以消费的数据
```
