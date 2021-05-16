

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

