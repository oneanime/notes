

1、先初始化一张拉链表

​		拉链表中多了两个字段 有效开始日期和结束日期

​		有效开始日期 = 当前的日期

​		有效结束日期 = 极限值(9999-99-99)

2、创建一个临时拉链表,字段和拉链表一模一样

3、制作当天的变动数据导入到hive中

​		增加全部数据

​		更新旧的拉链表,左关联变化表；过滤出接触日期等于极限值的；如果结束日期不是极限值则是最终状态无需更新

​		如果没关联上则说明状态没有变动,结束日期保持不变

​		如果关联上了则结束日期等于当前日期 -1

4、先合并变动信息,在追加新增信息然后添加到临时拉链表中

5、将临时拉链表覆盖给历史拉链表

```sql
CREATE EXTERNAL TABLE ods.user (
  user_num STRING COMMENT '用户编号',
  mobile STRING COMMENT '手机号码',
  reg_date STRING COMMENT '注册日期'
COMMENT '用户资料表'
PARTITIONED BY (dt string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS ORC
LOCATION '/ods/user';
)
```

```sql
CREATE EXTERNAL TABLE ods.user_update (
  user_num STRING COMMENT '用户编号',
  mobile STRING COMMENT '手机号码',
  reg_date STRING COMMENT '注册日期'
COMMENT '每日用户资料更新表'
PARTITIONED BY (dt string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS ORC
LOCATION '/ods/user_update';
)
```

```sql

CREATE EXTERNAL TABLE dws.user_his (
  user_num STRING COMMENT '用户编号',
  mobile STRING COMMENT '手机号码',
  reg_date STRING COMMENT '用户编号',
  t_start_date ,
  t_end_date
COMMENT '用户资料拉链表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS ORC
LOCATION '/dws/user_his';
)
```

```sql

INSERT OVERWRITE TABLE dws.user_his
SELECT * FROM
(
    SELECT A.user_num,
           A.mobile,
           A.reg_date,
           A.t_start_time,
           CASE
                WHEN A.t_end_time = '9999-12-31' AND B.user_num IS NOT NULL THEN '2017-01-01'
                ELSE A.t_end_time
           END AS t_end_time
    FROM dws.user_his AS A
    LEFT JOIN ods.user_update AS B
    ON A.user_num = B.user_num
UNION
    SELECT C.user_num,
           C.mobile,
           C.reg_date,
           '2017-01-02' AS t_start_time,
           '9999-12-31' AS t_end_time
    FROM ods.user_update AS C
) AS T
```

