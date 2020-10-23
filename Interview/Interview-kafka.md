##### 1. Kafka中的ISR、AR又代表什么?
```
ISR：与leader保持同步的follower集合
AR：分区的所有副本
```
##### 2. Kafka中的HW、LEO等分别代表什么?
```
LEO：没个副本的最后条消息的offset
HW：一个分区中所有副本最小的offset
```
##### 3. Kafka中是怎么体现消息顺序性的?
```
每个分区内，每条消息都有一个offset，故只能保证分区内有序。
```
##### 4. Kafka中的分区器、序列化器、拦截器是否了解？它们之间的处理顺序是什么？
```
拦截器 -> 序列化器 -> 分区器
```
##### 5. Kafka生产者客户端的整体结构是什么样子的？使用了几个线程来处理？分别是什么？
```
两个##### 线程处理；main线程和send线程
```
##### 6. 消费组中的消费者个数如果超过topic的分区，那么就会有消费者消费不到数据”这句话是否正确？
```
true
```
##### 7. 消费者提交消费位移时提交的是当前消费到的最新消息的offset还是offset+1？
```
offset+1
```
##### 8. 有哪些情形会造成重复消费？
```
1. 设置offset为自动提交，关闭kafka时，如果在close之前，调用 consumer.unsubscribe() 则有可能部分offset没提交，下次重启会重复消费
2. 消费后的数据，当offset还没有提交时，partition就断开连接
```
##### 9. 那些情景会造成消息漏消费？
```
先提交offset，后消费，有可能造成数据的漏消费
```
##### 10. 当你使用kafka-topics.sh创建（删除）了一个topic之后，Kafka背后会执行什么逻辑？
```
1）会在zookeeper中的/brokers/topics节点下创建一个新的topic节点，如：/brokers/topics/first
2）触发Controller的监听程序
3）kafka Controller 负责topic的创建工作，并更新metadata cache
```
##### 11. topic的分区数可不可以增加？如果可以怎么增加？如果不可以，那又是为什么？
```
可以增加
bin/kafka-topics.sh --zookeeper localhost:2181/kafka --alter --topic topic-config --partitions 3
```
##### 12. topic的分区数可不可以减少？如果可以怎么减少？如果不可以，那又是为什么？
```
不可以减少，被删除的分区数据难以处理。
```
##### 13. Kafka有内部的topic吗？如果有是什么？有什么所用？
```
__consumer_offsets,保存消费者offset
```
##### 14. Kafka分区分配的概念？
```
一个topic多个分区，一个消费者组多个消费者，故需要将分区分配个消费者(roundrobin、range)
```
##### 15. 简述Kafka的日志目录结构？
```
每个分区对应一个文件夹，文件夹的命名为topic-0，topic-1，内部为.log和.index文件
```
##### 16. 如果我指定了一个offset，Kafka Controller怎么查找到对应的消息？
```
1. kafka每个topic会分为多个partition，每个partition分为多个segment。每个segment在磁盘上存储为.log文件和.index文件
2. 会先根据offset去.index文件中查找指向.log文件元数据（指向log文件中message的物理偏移量），再去log文件中查找对应的数据
```
##### 17. 聊一聊Kafka Controller的作用？
```
负责管理集群broker的上下线，所有topic的分区副本分配和leader选举等工作。
```
##### 18. Kafka中有那些地方需要选举？这些地方的选举策略又有哪些？
```
partition leader（ISR），controller（先到先得）
```
##### 19. 失效副本是指什么？有那些应对措施？
```
不能及时与leader同步，暂时踢出ISR，等其追上leader之后再重新加入
```
##### 20. Kafka的那些设计让它有如此高的性能？
```
分区，顺序写磁盘，0-copy
```
##### 21. 生产的过程是怎么做到数据的一致性的？
```
ack
```
##### 22. kakfa的leader和follower之间是怎么同步的数据的？
```
HW
```
##### 23. streaming消费kafka的时候怎么做到数据一致性?
```
事务、幂等、结果和offset绑定到一起
```
##### 24. kafka数据积压问题？
```
streaming参数配置，配置消费kafka数据的上限（限速参数：spark.streaming.kafka.maxRatePerPartition  每秒每个分区获取的记录数），接下来再配置动态资源分配
```
