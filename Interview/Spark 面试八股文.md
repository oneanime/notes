<details>   
    <summary>1. Spark 的运行流程？</summary>
<img src="https://github.com/oneanime/notes/tree/master/Interview/image/spark运行图.png">
<pre>
1. SparkContext 向资源管理器注册并向资源管理器申请运行Executor
2. 资源管理器分配 Executor，然后资源管理器启动Executor
3. Executor 发送心跳至资源管理器
4. SparkContext 构建 DAG 有向无环图
5. 将 DAG 分解成 Stage（TaskSet）
6. 把 Stage 发送给 TaskScheduler
7. Executor 向 SparkContext 申请 Task
8. TaskScheduler 将 Task 发送给 Executor 运行
9. 同时 SparkContext 将应用程序代码发放给 Executor
10.Task 在 Executor 上运行，运行完毕释放所有资源   
</pre> 
</details>

<details>   
    <summary>2.Spark 有哪些组件？</summary>
<pre>
1. master：管理集群和节点，不参与计算。
2. worker：计算节点，进程本身不参与计算，和 master 汇报。
3. Driver：运行程序的 main 方法，创建 spark context 对象。4. spark context：控制整个 application 的生命周期，包括dagsheduler和 task scheduler 等组件。
5. client：用户提交程序的入口。
</pre> 
</details>

<details>   
    <summary>3.Spark 中的 RDD 机制理解吗？</summary>
<pre>
rdd 分布式弹性数据集，简单的理解成一种数据结构，是spark 框架上的通用货币。所有算子都是基于 rdd 来执行的，不同的场景会有不同的rdd 实现类，但是都可以进行互相转换。rdd 执行过程中会形成 dag 图，然后形成lineage保证容错性等。从物理的角度来看 rdd 存储的是 block 和node 之间的映射。RDD 是 spark 提供的核心抽象，全称为弹性分布式数据集。RDD 在逻辑上是一个 hdfs 文件，在抽象上是一种元素集合，包含了数据。它是被分区的，分为多个分区，每个分区分布在集群中的不同结点上，从而让RDD中的数据可以被并行操作（分布式数据集）
</pre>
<pre>
比如有个 RDD 有 90W 数据，3 个 partition，则每个分区上有30W 数据。RDD通常通过 Hadoop 上的文件，即 HDFS 或者 HIVE 表来创建，还可以通过应用程序中的集合来创建；RDD 最重要的特性就是容错性，可以自动从节点失败中恢复过来。即如果某个结点上的 RDD partition 因为节点故障，导致数据丢失，那么 RDD 可以通过自己的数据来源重新计算该 partition。这一切对使用者都是透明的。
</pre>
<pre>
RDD 的数据默认存放在内存中，但是当内存资源不足时，spark 会自动将RDD数据写入磁盘。比如某结点内存只能处理 20W 数据，那么这20W 数据就会放入内存中计算，剩下 10W 放到磁盘中。RDD 的弹性体现在于RDD 上自动进行内存和磁盘之间权衡和切换的机制。    
</pre> 
</details>

<details>   
    <summary>4.RDD 中 reduceBykey 与 groupByKey 哪个性能好，为什么？</summary>
<pre>
reduceByKey：reduceByKey 会在结果发送至 reducer 之前会对每个mapper在本地进行 merge，有点类似于在 MapReduce 中的 combiner。这样做的好处在于，在 map 端进行一次 reduce 之后，数据量会大幅度减小，从而减小传输，保证reduce 端能够更快的进行结果计算。
</pre> 
<pre>
groupByKey：groupByKey 会对每一个 RDD 中的 value 值进行聚合形成一个序列(Iterator)，此操作发生在 reduce 端，所以势必会将所有的数据通过网络进行传输，造成不必要的浪费。同时如果数据量十分大，可能还会造成OutOfMemoryError。
</pre>
所以在进行大量数据的 reduce 操作时候建议使用 reduceByKey。不仅可以提高速度，还可以防止使用 groupByKey 造成的内存溢出问题。
</details>

<details>   
    <summary>5. 介绍一下 cogroup rdd 实现原理，你在什么场景下用过这个rdd？</summary>
<pre>
cogroup：对多个（2~4）RDD 中的 KV 元素，每个 RDD 中相同key 中的元素分别聚合成一个集合。
与 reduceByKey 不同的是：reduceByKey 针对一个 RDD 中相同的key 进行合并。而 cogroup 针对多个 RDD 中相同的 key 的元素进行合并。cogroup 的函数实现：这个实现根据要进行合并的两个RDD 操作，生成一个CoGroupedRDD 的实例，这个 RDD 的返回结果是把相同的key 中两个RDD 分别进行合并操作，最后返回的 RDD 的 value 是一个 Pair 的实例，这个实例包含两个 Iterable 的值，第一个值表示的是 RDD1 中相同KEY 的值，第二个值表示的是 RDD2 中相同 key 的值。
由于做 cogroup 的操作，需要通过 partitioner 进行重新分区的操作，因此，执行这个流程时，需要执行一次 shuffle 的操作(如果要进行合并的两个RDD的都已经是 shuffle 后的 rdd，同时他们对应的 partitioner 相同时，就不需要执行 shuffle)。
场景：表关联查询或者处理重复的 key。
</pre> 
</details>

<details>   
    <summary>6.如何区分RDD的宽窄依赖？</summary>
<pre>
窄依赖:父 RDD 的一个分区只会被子 RDD 的一个分区依赖；宽依赖:父 RDD 的一个分区会被子 RDD 的多个分区依赖(涉及到shuffle)。    
</pre> 
</details>

<details>   
    <summary>7. 为什么要设计宽窄依赖？</summary>
<pre>
1. 对于窄依赖：
窄依赖的多个分区可以并行计算；
窄依赖的一个分区的数据如果丢失只需要重新计算对应的分区的数据就可以了。
2. 对于宽依赖：
划分 Stage(阶段)的依据:对于宽依赖,必须等到上一阶段计算完成才能计算下一阶段。    
</pre> 
</details>

<details>   
    <summary>8. DAG 是什么？</summary>
<pre>
DAG(Directed Acyclic Graph 有向无环图)指的是数据转换执行的过程，有方向，无闭环(其实就是 RDD 执行的流程)；
原始的 RDD 通过一系列的转换操作就形成了 DAG 有向无环图，任务执行时，可以按照 DAG 的描述，执行真正的计算(数据被操作的一个过程)。    
</pre> 
</details>

<details>   
    <summary>9. DAG 中为什么要划分 Stage？</summary>
<pre>
并行计算。
一个复杂的业务逻辑如果有 shuffle，那么就意味着前面阶段产生结果后，才能执行下一个阶段，即下一个阶段的计算要依赖上一个阶段的数据。那么我们按照shuffle 进行划分(也就是按照宽依赖就行划分)，就可以将一个DAG 划分成多个 Stage/阶段，在同一个 Stage 中，会有多个算子操作，可以形成一个pipeline 流水线，流水线内的多个平行的分区可以并行执行。        
</pre> 
</details>

<details>   
    <summary>10. 如何划分 DAG 的 stage？</summary>
<pre>
对于窄依赖，partition 的转换处理在 stage 中完成计算，不划分(将窄依赖尽量放在在同一个 stage 中，可以实现流水线计算)。
对于宽依赖，由于有 shuffle 的存在，只能在父 RDD 处理完成后，才能开始接下来的计算，也就是说需要要划分 stage。        
</pre> 
</details>

<details>   
    <summary>11. DAG 划分为 Stage 的算法了解吗？</summary>
<pre>
核心算法：回溯算法
从后往前回溯/反向解析，遇到窄依赖加入本 Stage，遇见宽依赖进行Stage 切分。Spark 内核会从触发 Action 操作的那个 RDD 开始从后往前推，首先会为最后一个 RDD 创建一个 Stage，然后继续倒推，如果发现对某个RDD 是宽依赖，那么就会将宽依赖的那个 RDD 创建一个新的 Stage，那个RDD 就是新的Stage的最后一个 RDD。 然后依次类推，继续倒推，根据窄依赖或者宽依赖进行Stage的划分，直到所有的 RDD 全部遍历完成为止。
具体划分算法请参考：AMP 实验室发表的论文
《Resilient Distributed Datasets: A Fault-Tolerant Abstraction for
In-Memory Cluster Computing》        
</pre> 
</details>

<details>   
    <summary>12. 对于 Spark 中的数据倾斜问题你有什么好的方案？</summary>
<pre>
1. 前提是定位数据倾斜，是 OOM 了，还是任务执行缓慢，看日志，看WebUI
2. 解决方法，有多个方面:
- 避免不必要的 shuffle，如使用广播小表的方式，将reduce-side-join提升为 map-side-join
- 分拆发生数据倾斜的记录，分成几个部分进行，然后合并join 后的结果 改变并行度，可能并行度太少了，导致个别 task 数据压力大 两阶段聚合，先局部聚合，再全局聚合
- 自定义 paritioner，分散 key 的分布，使其更加均匀        
</pre> 
</details>

<details>   
    <summary>13. Spark 中的 OOM 问题？</summary>
<pre>
1. map 类型的算子执行中内存溢出如 flatMap，mapPatitions
- 原因：map 端过程产生大量对象导致内存溢出：这种溢出的原因是在单个map 中产生了大量的对象导致的针对这种问题。        
</pre> 
<pre>
2. 解决方案：
- 增加堆内内存。
- 在不增加内存的情况下，可以减少每个 Task 处理数据量，使每个Task产生大量的对象时，Executor 的内存也能够装得下。具体做法可以在会产生大量对象的 map 操作之前调用 repartition 方法，分区成更小的块传入 map。     
</pre>
<pre>
3. shuffle 后内存溢出如 join，reduceByKey，repartition。
- shuffle 内存溢出的情况可以说都是 shuffle 后，单个文件过大导致的。在 shuffle 的使用，需要传入一个 partitioner，大部分Spark 中的shuffle 操作，默认的 partitioner 都是 HashPatitioner，默认值是父RDD 中最大的分区数．这个参数 spark.default.parallelism 只对HashPartitioner 有效．如果是别的 partitioner 导致的shuffle 内存溢出就需要重写 partitioner 代码了。       
</pre>
<pre>
4. driver 内存溢出
- 用户在 Dirver 端口生成大对象，比如创建了一个大的集合数据结构。解决方案：将大对象转换成 Executor 端加载，比如调用sc.textfile或者评估大对象占用的内存，增加 dirver 端的内存
- 从 Executor 端收集数据（collect）回 Dirver 端，建议将driver端对 collect 回来的数据所作的操作，转换成 executor 端rdd 操作。
</pre>
</details>

<details>   
    <summary>14. Spark 中数据的位置是被谁管理的？</summary>
<pre>
每个数据分片都对应具体物理位置，数据的位置是被 blockManager 管理，无论数据是在磁盘，内存还是 tacyan，都是由 blockManager 管理。        
</pre> 
</details>

<details>   
    <summary>15. Spark 程序执行，有时候默认为什么会产生很多task，怎么修改默认 task 执行个数？</summary>
<pre>
1. 输入数据有很多 task，尤其是有很多小文件的时候，有多少个输入block就会有多少个 task 启动；
2. spark 中有 partition 的概念，每个 partition 都会对应一个task，task 越多，在处理大规模数据的时候，就会越有效率。不过task 并不是越多越好，如果平时测试，或者数据量没有那么大，则没有必要task数量太多。
3. 参数可以通过 spark_home/conf/spark-default.conf 配置文件设置:
针对spark sql的task数量：spark.sql.shuffle.partitions=50   
非spark sql程序设置生效：spark.default.parallelism=10     
</pre> 
</details>

<details>   
    <summary>16. 介绍一下 join 操作优化经验？</summary>
<pre>
这道题常考，这里只是给大家一个思路，简单说下！面试之前还需做更多准备。join 其实常见的就分为两类： map-side join 和 reduce-side join。当大表和小表 join 时，用 map-side join 能显著提高效率。将多份数据进行关联是数据处理过程中非常普遍的用法，不过在分布式计算系统中，这个问题往往会变的非常麻烦，因为框架提供的 join 操作一般会将所有数据根据 key 发送到所有的 reduce 分区中去，也就是shuffle 的过程。造成大量的网络以及磁盘 IO 消耗，运行效率极其低下，这个过程一般被称为reduce-side-join。
如果其中有张表较小的话，我们则可以自己实现在 map 端实现数据关联，跳过大量数据进行 shuffle 的过程，运行时间得到大量缩短，根据不同数据可能会有几倍到数十倍的性能提升。
在大数据量的情况下，join 是一中非常昂贵的操作，需要在join 之前应尽可能的先缩小数据量。        
</pre> 
<pre>
对于缩小数据量，有以下几条建议：
1. 若两个 RDD 都有重复的 key，join 操作会使得数据量会急剧的扩大。所有，最好先使用 distinct 或者 combineByKey 操作来减少key 空间或者用 cogroup 来处理重复的 key，而不是产生所有的交叉结果。在combine 时，进行机智的分区，可以避免第二次shuffle。
2. 如果只在一个 RDD 出现，那你将在无意中丢失你的数据。所以使用外连接会更加安全，这样你就能确保左边的 RDD 或者右边的RDD 的数据完整性，在 join 之后再过滤数据。
3. 如果我们容易得到 RDD 的可以的有用的子集合，那么我们可以先用filter 或者 reduce，如何在再用 join。        
</pre>
</details>

<details>   
    <summary>17. Spark 与 MapReduce 的 Shuffle 的区别？</summary>
<pre>
1. 相同点：都是将 mapper（Spark 里是 ShuffleMapTask）的输出进行partition，不同的 partition 送到不同的 reducer（Spark 里reducer可能是下一个 stage 里的 ShuffleMapTask，也可能是ResultTask） 
2. 不同点：  
- MapReduce 默认是排序的，spark 默认不排序，除非使用sortByKey算子。
- MapReduce 可以划分成 split，map()、spill、merge、shuffle、sort、reduce()等阶段，spark 没有明显的阶段划分，只有不同的stage 和算子操作。
- MR 落盘，Spark 不落盘，spark 可以解决 mr 落盘导致效率低下的问题。 
</pre> 
</details>

<details>   
    <summary>18. Spark SQL 执行的流程？</summary>
<pre>
这个问题如果深挖还挺复杂的，这里简单介绍下总体流程：

1. parser：基于 antlr 框架对 sql 解析，生成抽象语法树。2. 变量替换：通过正则表达式找出符合规则的字符串，替换成系统缓存环境的变量
SQLConf 中的 spark.sql.variable.substitute，默认是可用的；参考SparkSqlParser
3. parser：将 antlr 的 tree 转成 spark catalyst 的LogicPlan，也就是 未解析的逻辑计划；详细参考 AstBuild, ParseDriver
4. analyzer：通过分析器，结合 catalog，把 logical plan 和实际的数据绑定起来，将 未解析的逻辑计划 生成 逻辑计划；详细参考QureyExecution
5. 缓存替换：通过 CacheManager，替换有相同结果的logical plan（逻辑计划）
6. logical plan 优化，基于规则的优化；优化规则参考Optimizer，优化执行器 RuleExecutor
7. 生成 spark plan，也就是物理计划；参考QueryPlanner和SparkStrategies8. spark plan 准备阶段
9. 构造 RDD 执行，涉及 spark 的 wholeStageCodegenExec 机制，基于janino 框架生成 java 代码并编译
</pre> 
</details>

<details>   
    <summary>19. Spark SQL 是如何将数据写到 Hive 表的？</summary>
<pre>
方式一：是利用 Spark RDD 的 API 将数据写入hdfs 形成hdfs 文件，之后再将 hdfs 文件和 hive 表做加载映射。
方式二：利用 Spark SQL 将获取的数据 RDD 转换成DataFrame，再将DataFrame 写成缓存表，最后利用 Spark SQL 直接插入hive 表中。而对于利用 Spark SQL 写 hive 表官方有两种常见的API，第一种是利用JavaBean 做映射，第二种是利用 StructType 创建Schema 做映射。        
</pre> 
</details>

<details>   
    <summary>20. 通常来说，Spark 与 MapReduce 相比，Spark 运行效率更高。请说明效率更高来源于 Spark 内置的哪些机制？</summary>
<pre>
1. 基于内存计算，减少低效的磁盘交互；
2. 高效的调度算法，基于 DAG；
3. 容错机制 Linage。    
重点部分就是 DAG 和 Lingae    
</pre> 
</details>

<details>   
    <summary>21. Hadoop 和 Spark 的相同点和不同点？</summary>
<pre>
Hadoop 底层使用 MapReduce 计算架构，只有 map 和 reduce 两种操作，表达能力比较欠缺，而且在 MR 过程中会重复的读写 hdfs，造成大量的磁盘io 读写操作，所以适合高时延环境下批处理计算的应用        
</pre> 
<pre>
Spark 是基于内存的分布式计算架构，提供更加丰富的数据集操作类型，主要分成转化操作和行动操作，包括 map、reduce、filter、flatmap、groupbykey、reducebykey、union 和 join 等，数据分析更加快速，所以适合低时延环境下计算的应用        
</pre>
<pre>
spark 与 hadoop 最大的区别在于迭代式计算模型。基于mapreduce 框架的Hadoop 主要分为 map 和 reduce 两个阶段，两个阶段完了就结束了，所以在一个 job 里面能做的处理很有限；spark 计算模型是基于内存的迭代式计算模型，可以分为 n 个阶段，根据用户编写的 RDD 算子和程序，在处理完一个阶段后可以继续往下处理很多个阶段，而不只是两个阶段。所以spark 相较于mapreduce，计算模型更加灵活，可以提供更强大的功能        
</pre>
<pre>
但是 spark 也有劣势，由于 spark 基于内存进行计算，虽然开发容易，但是真正面对大数据的时候，在没有进行调优的情况下，可能会出现各种各样的问题，比如 OOM 内存溢出等情况，导致 spark 程序可能无法运行起来，而mapreduce虽然运行缓慢，但是至少可以慢慢运行完。        
</pre>
</details>