1. Mapjoin

    	如果不指定MapJoin或者不符合MapJoin的条件，那么Hive解析器会将Join操作转换成Common Join，即：在Reduce阶段完成join。容易发生数据倾斜。可以用MapJoin把小表全部加载到内存在map端进行join，避免reducer处理。

2. 行列过滤

   ​	列处理：在SELECT中，只拿需要的列，如果有，尽量使用分区过滤，少用SELECT *。

   ​	行处理：在分区剪裁中，当使用外关联时，如果将副表的过滤条件写在Where后面，那么就会先全表关联，之后再过滤。 

3. 列式存储

4. 采用风区技术

5. 合理设置Map数

   ​	mapred.min.split.size: 指的是数据的最小分割单元大小；min的默认值是1B

   ​	mapred.max.split.size: 指的是数据的最大分割单元大小；max的默认值是256MB

   ​	通过调整max可以起到调整map数的作用，减小max可以增加map数，增大max可以减少map数。

   ​	需要提醒的是，直接调整mapred.map.tasks这个参数是没有效果的。

   ​	https://www.cnblogs.com/swordfall/p/11037539.html

6. 合理设置Reduce数

   Reduce个数并不是越多越好

   （1）过多的启动和初始化Reduce也会消耗时间和资源；

   （2）另外，有多少个Reduce，就会有多少个输出文件，如果生成了很多个小文件，那么如果这些小文件作为下一个任务的输入，则也会出现小文件过多的问题；

   ​		在设置Reduce个数的时候也需要考虑这两个原则：处理大数据量利用合适的Reduce数；使单个Reduce任务处理数据量大小要合适；

7. 小文件如何产生的？

   ​	（1）动态分区插入数据，产生大量的小文件，从而导致map数量剧增；

   ​	（2）reduce数量越多，小文件也越多（reduce的个数和输出文件是对应的）；

   ​	（3）数据源本身就包含大量的小文件。

8. 小文件解决方案

   （1）在Map执行前合并小文件，减少Map数：CombineHiveInputFormat具有对小文件进行合并的功能（系统默认的格式）。HiveInputFormat没有对小文件合并功能。

     (2)   merge(合并下文件)

   ​	

   ```sql
   SET hive.merge.mapfiles = true; -- 默认true，在map-only任务结束时合并小文件
   SET hive.merge.mapredfiles = true; -- 默认false，在map-reduce任务结束时合并小文件
   SET hive.merge.size.per.task = 268435456; -- 默认256M
   SET hive.merge.smallfiles.avgsize = 16777216; -- 当输出文件的平均大小小于16m该值时，启动一个独立的map-reduce任务进行文件merge
   
   ```

     (3)  开启jvm重用(弊端，插槽用完后，会一直空着，直到整个任务完成，会浪费资源)

   ```sql
   set mapreduce.job.jvm.numtasks=10
   ```

9. 开启map端combiner（不影响最终业务逻辑）

   ```sql
   set hive.map.aggr=true；
   ```

10. 压缩（选择快的）

    ​	设置map端输出、中间结果压缩。（不完全是解决数据倾斜的问题，但是减少了IO读写和网络传输，能提高很多效率）

    ```sql
    set hive.exec.compress.intermediate=true --启用中间数据压缩
    set mapreduce.map.output.compress=true --启用最终数据压缩
    set mapreduce.map.outout.compress.codec=…; --设置压缩方式
    ```

11. 数据倾斜

    （1）不同数据类型关联产生数据倾斜

    ```sql
    情形：比如用户表中user_id字段为int，log表中user_id字段string类型。当按照user_id进行两个表的Join操作时。
    解决方式：把数字类型转换成字符串类型
    select * from users a
    left outer join logs b
    on a.usr_id = cast(b.user_id as string)
    bug记录：https://www.jianshu.com/p/2181e00d74dc
    
    ```

    （2）控制空值分布

    ​	   在生产环境经常会用大量空值数据进入到一个reduce中去，导致数据倾斜。

    ​		解决办法：

    ​		自定义分区，将为空的key转变为字符串加随机数或纯随机数，将因空值而造成倾斜的数据分不到多个Reducer。

    ​		注意：对于异常值如果不需要的话，最好是提前在where条件里过滤掉，这样可以使计算量大大减少

      (3)  解决数据倾斜的方法

    ​		1) group by

    ​			注：group by 优于distinct group

    ​			解决方式：采用sum() group by的方式来替换count(distinct)完成计算。

    ​		2) mapjoin

    ​		3) 开启数据倾斜时的负载均衡

    ​			

    ```sql
    set hive.groupby.skewindata=true;
    ```

    ​		思想：就是先随机分发并处理，再按照key group by来分发处理。

    ​		操作：当选项设定为true，生成的查询计划会有两个MRJob。

    ​		第一个MRJob中，Map的输出结果集合会随机分布到Reduce中，每个Reduce做部分聚合操作，并输出结果，这样处理的结果是相同的GroupBy Key有可能被分发到不同的Reduce中，从而达到负载均衡的目的；

    ​		第二个MRJob再根据预处理的数据结果按照GroupBy Key分布到Reduce中（这个过程可以保证相同的原始GroupBy Key被分布到同一个Reduce中），最后完成最终的聚合操作。

    ​		点评：它使计算变成了两个mapreduce，先在第一个中在shuffle过程partition时随机给 key打标记，使每个key随机均匀分布到各个reduce上计算，但是这样只能完成部分计算，因为相同key没有分配到相同reduce上。

    ​		所以需要第二次的mapreduce，这次就回归正常shuffle，但是数据分布不均匀的问题在第一次mapreduce已经有了很大的改善，因此基本解决数据倾斜。因为大量计算已经在第一次mr中随机分布到各个节点完成。

    ​		4) 设置reduce个数