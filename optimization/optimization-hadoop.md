1. Map阶段

   （1）增大环形缓冲区大小。由100m扩大到200m

   （2）增大环形缓冲区溢写的比例。由80%扩大到90%

   （3）减少对溢写文件的merge次数。（10个文件，一次20个merge）

   （4）不影响实际业务的前提下，采用Combiner提前合并，减少 I/O。

2. Reduce阶段

   （1）合理设置Map和Reduce数：两个都不能设置太少，也不能设置太多。太少，会导致Task等待，延长处理时间；太多，会导致 Map、Reduce任务间竞争资源，造成处理超时等错误。

   （2）设置Map、Reduce共存：调整slowstart.completedmaps参数，使Map运行到一定程度后，Reduce也开始运行，减少Reduce的等待时间。

   （3）规避使用Reduce，因为Reduce在用于连接数据集的时候将会产生大量的网络消耗。

   （4）增加每个Reduce去Map中拿数据的并行数

   （5）集群性能可以的前提下，增大Reduce端存储数据内存的大小。

3. IO输出

   （1）map输入端主要考虑数据量大小和切片，支持切片的有Bzip2、LZO。注意：LZO要想支持切片必须创建索引；

   （2）map输出端主要考虑速度，速度快的snappy、LZO；

   （3）reduce输出端主要看具体需求，例如作为下一个mr输入需要考虑切片，永久保存考虑压缩率比较大的gzip。

4. 整体

   （1）NodeManager默认内存8G，需要根据服务器实际配置灵活调整，例如128G内存，配置为100G内存左右，yarn.nodemanager.resource.memory-mb。

   （2）单任务默认内存8G，需要根据该任务的数据量灵活调整，例如128m数据，配置1G内存，yarn.scheduler.maximum-allocation-mb。

   （3）mapreduce.map.memory.mb ：控制分配给MapTask内存上限，如果超过会kill掉进程（报：Container is running beyond physical memory limits. Current usage:565MB of512MB physical memory used；Killing Container）。默认内存大小为1G，如果数据量是128m，正常不需要调整内存；如果数据量大于128m，可以增加MapTask内存，最大可以增加到4-5g。

   （4）mapreduce.reduce.memory.mb：控制分配给ReduceTask内存上限。默认内存大小为1G，如果数据量是128m，正常不需要调整内存；如果数据量大于128m，可以增加ReduceTask内存大小为4-5g。

   （5）mapreduce.map.java.opts：控制MapTask堆内存大小。（如果内存不够，报：java.lang.OutOfMemoryError）

   （6）mapreduce.reduce.java.opts：控制ReduceTask堆内存大小。（如果内存不够，报：java.lang.OutOfMemoryError）

   （7）可以增加MapTask的CPU核数，增加ReduceTask的CPU核数

   （8）增加每个Container的CPU核数和内存大小

   （9）在hdfs-site.xml文件中配置多目录（多磁盘）

   （10）NameNode有一个工作线程池，用来处理不同DataNode的并发心跳以及客户端并发的元数据操作。dfs.namenode.handler.count=int(20*math.log(8))，比如集群规模为8台时，此参数设置为41。

5. 数据倾斜

   （1）提前在map进行*combine，减少传输的数据量

   ​       在Mapper加上combiner相当于提前进行reduce，即把一个Mapper中的相同key进行了聚合，减少shuffle过程中传输的数据量，以及Reducer端的计算量。

   ​       如果导致数据倾斜的key大量分布在不同的mapper的时候，这种方法就不是很有效了。

   （2）导致数据倾斜的****key** **大量分布在不同的****mapper**

   （3）局部聚合加全局聚合。

   ​       第一次在map阶段对那些导致了数据倾斜的key 加上1到n的随机前缀，这样本来相同的key 也会被分到多个Reducer中进行局部聚合，数量就会大大降低。

   ​      第二次mapreduce，去掉key的随机前缀，进行全局聚合。

   ​      思想：二次mr，第一次将key随机散列到不同reducer进行处理达到负载均衡目的。第二次再根据去掉key的随机前缀，按原key进行reduce处理。

   ​      这个方法进行两次mapreduce，性能稍差。

   （4）增加Reducer，提升并行度
         JobConf.setNumReduceTasks(int)

   （5）实现自定义分区

   ​      根据数据分布情况，自定义散列函数，将key均匀分配到不同Reducer