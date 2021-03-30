1. Rowkey的唯一原

   ​		必须在设计上保证其唯一性。由于在HBase中数据存储是Key-Value形式，若HBase中同一表插入相同Rowkey，则原先的数据会被覆盖掉(如果表的version设置为1的话)，所以务必保证Rowkey的唯一性

2. Rowkey的排序原则

   ​		HBase的Rowkey是按照ASCII有序设计的，我们在设计Rowkey时要充分利用这点。比如视频网站上对影片《泰坦尼克号》的弹幕信息，这个弹幕是按照时间倒排序展示视频里，这个时候我们设计的Rowkey要和时间顺序相关。可以使用"Long.MAX_VALUE - 弹幕发表时间"的 long 值作为 Rowkey 的前缀
   

3. Rowkey的散列原则

   ​		我们设计的Rowkey应均匀的分布在各个HBase节点上。拿常见的时间戳举例，假如Rowkey是按系统时间戳的方式递增，Rowkey的第一部分如果是时间戳信息的话将造成所有新数据都在一个RegionServer上堆积的热点现象，也就是通常说的Region热点问题， 热点发生在大量的client直接访问集中在个别RegionServer上（访问可能是读，写或者其他操作），导致单个RegionServer机器自身负载过高，引起性能下降甚至Region不可用，常见的是发生jvm full gc或者显示region too busy异常情况，当然这也会影响同一个RegionServer上的其他Region。

4. Rowkey长度原则

   ​		rowkey是一个二进制码流，可以是任意字符串，最大长度 64kb ，实际应用中一般为10-100bytes，以 byte[] 形式保存，一般设计成定长。
   建议越短越好，不要超过16个字节，原因如下：
   ​		(1) 数据的持久化文件HFile中是按照KeyValue存储的，如果rowkey过长，比如超过100字节，1000w行数据，光rowkey就要占用100*1000w=10亿个字节，将近1G数据，这样会极大影响HFile的存储效率；
   ​		(2) MemStore将缓存部分数据到内存，如果rowkey字段过长，内存的有效利用率就会降低，系统不能缓存更多的数据，这样会降低检索效率。
   ​		(3) 目前操作系统都是64位系统，内存8字节对齐，控制在16个字节，8字节的整数倍利用了操作系统的最佳特性。

5. 加盐操作

   ​		这里所说的加盐不是密码学中的加盐，而是在rowkey的前面增加随机数，具体就是给rowkey分配一个随机前缀以使得它和之前的rowkey的开头不同。分配的前缀种类数量应该和你想使用数据分散到不同的region的数量一致。加盐之后的rowkey就会根据随机生成的前缀分散到各个region上，以避免热点。

6. 哈希操作

   ​		哈希会使同一行永远用一个前缀加盐。哈希也可以使负载分散到整个集群，但是读却是可以预测的。使用确定的哈希可以让客户端重构完整的rowkey，可以使用get操作准确获取某一个行数据

7. 反转操作

   ​		第三种防止热点的方法时反转固定长度或者数字格式的rowkey。这样可以使得rowkey中经常改变的部分（最没有意义的部分）放在前面。这样可以有效的随机rowkey，但是牺牲了rowkey的有序性。
   反转rowkey的例子以手机号为rowkey，可以将手机号反转后的字符串作为rowkey，这样的就避免了以手机号那样比较固定开头导致热点问题

8. 时间戳反转

   ​		一个常见的数据处理问题是快速获取数据的最近版本，使用反转的时间戳作为rowkey的一部分对这个问题十分有用，可以用 Long.Max_Value - timestamp 追加到key的末尾，例如 [key][reverse_timestamp] , [key] 的最新值可以通过scan [key]获得[key]的第一条记录，因为HBase中rowkey是有序的，第一条记录是最后录入的数据。
   比如需要保存一个用户的操作记录，按照操作时间倒序排序，在设计rowkey的时候，可以这样设计
   [userId反转][Long.Max_Value - timestamp]，在查询用户的所有操作记录数据的时候，直接指定反转后的userId，startRow是[userId反转][000000000000],stopRow是[userId反转][Long.Max_Value - timestamp]
   如果需要查询某段时间的操作记录，startRow是[user反转][Long.Max_Value - 起始时间]，stopRow是[userId反转][Long.Max_Value - 结束时间]

9. 案例

   ​		在实际的设计中我们可能更多的是结合多种设计方法来实现Rowkey的最优化设计，比如设计订单状态表时使用：Rowkey: reverse(order_id) + (Long.MAX_VALUE – timestamp)，这样设计的好处一是通过reverse订单号避免Region热点，二是可以按时间倒排显示。

   ​		结合易观方舟使用HBase作为事件(事件指的的终端在APP中发生的行为，比如登录、下单等等统称事件(event))的临时存储(HBase只存储了最近10分钟的热数据)来举例：

   设计event事件的Rowkey为：两位随机数Salt + eventId + Date + kafka的Offset

   ​		这样设计的好处是：

   ​		设计加盐的目的是为了增加查询的并发性，假如Salt的范围是0~n，那我们在查询的时候，可以将数据分为n个split同时做scan操作。经过我们的多次测试验证，增加并发度能够将整体的查询速度提升5～20倍以上。随后的eventId和Date是用来做范围Scan使用的。在我们的查询场景中，大部分都是指定了eventId的，因此我们把eventId放在了第二个位置上，同时呢，eventId的取值有几十个，通过Salt + eventId的方式可以保证不会形成热点。在单机部署版本中，HBase会存储所有的event数据，所以我们把date放在rowkey的第三个位置上以实现按date做scan，批量Scan性能甚至可以做到毫秒级返回。

   ​		这样的rowkey设计能够很好的支持如下几个查询场景：

   ​		1、全表scan

   ​		在这种情况下，我们仍然可以将全表数据切分成n份并发查询，从而实现查询的实时响应。

   ​		2、只按照event_id查询

   ​		3、按照event_id和date查询

   ​		此外易观方舟也使用HBase做用户画像的标签存储方案，存储每个app的用户的人口学属性和商业属性等标签信息，由于其设计的更为复杂，后续会另起篇幅详细展开。

   ​		最后我们顺带提下HBase的表设计，HBase表设计通常可以是宽表（wide table）模式，即一行包括很多列。同样的信息也可以用高表（tall table）形式存储，通常高表的性能比宽表要高出 50%以上，所以推荐大家使用高表来完成表设计。表设计时，我们也应该要考虑HBase数据库的一些特性：

   ​		1、在HBase表中是通过Rowkey的字典序来进行数据排序的

   ​		2、所有存储在HBase表中的数据都是二进制的字节

   ​		3、原子性只在行内保证，HBase不支持跨行事务

   ​		4、列族(Column Family)在表创建之前就要定义好

   ​		5、列族中的列标识(Column Qualifier)可以在表创建完以后动态插入数据时添加

   ​		在做Rowkey设计时，请先考虑业务是读比写多、还是读比写少，HBase本身是为写优化的，即便是这样，也可能会出现热点问题，而如果我们读比较多的话，除了考虑以上Rowkey设计原则外，还可以考虑HBase的Coprocessor甚至elastic search结合的方法，无论哪种方式，都建议做实际业务场景下数据的压力测试以得到最优结果。