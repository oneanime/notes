1. 避免索引失效（explain后key_len判断）

   (1)  全职匹配（索引中有几个字段，where后面就等值几个，顺序无关）

   (2)  最左原则  (查询从索引的最左前列开始并且不跳过索引中的列)

   (3)  不在索引列上做任何操作（计算、函数、(自动or手动)类型转换）

   (4)  索引列上有范围查询时，范围条件右边的列将失效

   (5)  使用不等于(!= 或者<>)的时候索引失效

   (6)  is not null 不能使用索引，is null可以使用索引

   (7)  like以通配符%或_开头索引失效

   (8)  字符串不加单引号索引失效

   (9)  减少使用or

   (10)  尽量使用覆盖索引(即查询列和索引列一致，不要写select *)

   例子：index(a,b,c)；

   | where语句                                               | 索引是否被使用                                               |
   | ------------------------------------------------------- | ------------------------------------------------------------ |
   | where a = 3                                             | Y,使用到a                                                    |
   | where a = 3 and b = 5                                   | Y,使用到a，b                                                 |
   | where a = 3 and b = 5 and c = 4                         | Y,使用到a,b,c                                                |
   | where b = 3 或者 where b = 3 and c = 4 或者 where c = 4 | N                                                            |
   | where a = 3 and c = 5                                   | 使用到a， 但是c不可以，b中间断了                             |
   | where a = 3 and b > 4 and c = 5                         | 使用到a和b， c不能用在范围之后，b断了                        |
   | where a is null and b is not null                       | is null 支持索引 但是is not null 不支持,所以 a 可以使用索引,但是 b不可以使用 |
   | where a <> 3                                            | 不能使用索引                                                 |
   | where  abs(a) =3                                        | 不能使用 索引                                                |
   | where a = 3 and b like 'kk%' and c = 4                  | Y,使用到a,b,c                                                |
   | where a = 3 and b like '%kk' and c = 4                  | Y,只用到a                                                    |
   | where a = 3 and b like '%kk%' and c = 4                 | Y,只用到a                                                    |
   | where a = 3 and b like 'k%kk%' and c = 4                | Y,使用到a,b,c                                                |

   

2. 