1. 找出所有科目成绩都大于某一学科平均成绩的学生(uid,subject_id,score)

   <details>   
       <summary>建表语句</summary>
       <pre>
           <code>
   drop table sc;
   create external table if not exists sc
   (
       uid        int,
       subject_id int,
       score      decimal
   )
   row format delimited fields terminated by '\t'
       null defined as ''
   stored as parquet ;
   insert into table sc
   values (01, 01, 80),
          (01, 02, 90),
          (01, 03, 99),
          (02, 01, 70),
          (02, 02, 60),
          (02, 03, 80),
          (03, 01, 80),
          (03, 02, 80),
          (03, 03, 80),
          (04, 01, 50),
          (04, 02, 30),
          (04, 03, 20),
          (05, 01, 76),
          (05, 02, 87),
          (06, 01, 31),
          (06, 03, 34),
          (07, 02, 89),
          (07, 03, 98);
           </code>
       </pre> 
   </details>

   <details>   
       <summary>答案1</summary>
       <pre>
       	<code>
   select uid
   from sc left join
   (
       select subject_id ,avg(score) as avg_score
       from sc
       group by subject_id
   ) t1 on sc.subject_id=t1.subject_id
   where sc.score>t1.avg_score
   group by uid
   having count(uid)=3
           </code>
       </pre> 
   </details>

   <details>   
       <summary>答案2</summary>
       <pre>
       	<code>
   with t1 as (
       select uid,subject_id,score,avg(score) over(partition by subject_id) as avg_score
       from sc
   ),
   t2 as (
       select uid,subject_id,score,if(t1.score>t1.avg_score,1,0) as flag
       from t1
   )
   select uid
   from t2
   group by uid
   having sum(t2.flag)=3
       	</code>
       </pre> 
   </details>

2. 统计出每个用户的累积访问次数

| userId | visitDate | visitCount |
| ------ | --------- | ---------- |
| u01    | 2017/1/21 | 5          |
| u02    | 2017/1/23 | 6          |
| u03    | 2017/1/22 | 7          |
| u04    | 2017/1/20 | 3          |
| u01    | 2017/1/23 | 6          |
| u01    | 2017/2/21 | 8          |
| u02    | 2017/1/23 | 6          |
| u01    | 2017/2/22 | 4          |

| userId | 月份    | 小计 | 累积 |
| ------ | ------- | ---- | ---- |
| u01    | 2017-01 | 11   | 11   |
| u01    | 2017-02 | 12   | 23   |
| u02    | 2017-01 | 12   | 12   |
| u03    | 2017-01 | 8    | 8    |
| u04    | 2017-01 | 3    | 3    |

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table if not exists user_visit
(
    userId        string,
    visitDate  string,
    visitCount int
)
    row format delimited fields terminated by '\t'
        null defined as ''
    stored as textfile;
insert into table user_visit
values ('u01', '2017/1/21', 5),
       ('u02', '2017/1/23', 6),
       ('u03', '2017/1/22', 7),
       ('u04', '2017/1/20', 3),
       ('u01', '2017/1/23', 6),
       ('u01', '2017/2/21', 8),
       ('u02', '2017/1/23', 6),
       ('u01', '2017/2/22', 4);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
with t1 as (
    select userId, 
            visitDate, 
            visitCount, 
            date_format(regexp_replace(visitDate, '/', '-'), 'yyyy-MM') as fm_date
    from user_visit
),
t2 as (
    select userId,fm_date,sum(visitCount) as vc
    from t1
    group by userId,fm_date
)
select userId,vc,sum(vc) over (partition by userId order by fm_date) as acc
from t2
        </code>
    </pre> 
</details>

3.有50W个京东店铺，每个顾客访客访问任何一个店铺的任何一个商品时都会产生一条访问日志，访问日志存储的表名为Visit，访客的用户id为user_id，被访问的店铺名称为shop，请统计： 

<details>   
    <summary>建表</summary>
    <pre>
        <code>
create table 3jindongshop
(
    userId string,
    shop   string
)
    row format delimited fields terminated by '\t'
    stored as textfile;
insert into table 3jindongshop
values ('u1', 'a'),
       ('u2', 'b'),
       ('u1', 'b'),
       ('u1', 'a'),
       ('u3', 'c'),
       ('u4', 'b'),
       ('u1', 'a'),
       ('u2', 'c'),
       ('u5', 'b'),
       ('u4', 'b'),
       ('u6', 'c'),
       ('u2', 'c'),
       ('u1', 'b'),
       ('u2', 'a'),
       ('u2', 'a'),
       ('u3', 'a'),
       ('u5', 'a'),
       ('u5', 'a'),
       ('u5', 'a');
        </code>
    </pre> 
</details>

- 每个店铺的UV（访客数） 

  <details>   
      <summary>答案1</summary>
      <pre>
          <code>
  select shop,count(userId)
  from (
           select userId, shop
           from 3jindongshop
           group by userId, shop
       )
  group by shop;
          </code>
      </pre> 
  </details>

- 每个店铺访问次数top3的访客信息。输出店铺名称、访客id、访问次数

  <details>   
      <summary>答案1</summary>
      <pre>
          <code>
  with t1 as (
      select userId,shop,count(1) as visitCount
      from 3jindongshop
      group by userId,shop
  ),
  t2 as (
      select userId,shop,visitCount,rank() over (partition by shop order by visitCount desc ) as rk
      from t1
  )
  select shop,userId,visitCount
  from t2
  where rk<=3
          </code>
      </pre> 
  </details>

|userId| shop|
|------|-----|
|u1    |a    |
|u2    |b    |
|u1    |b    |
|u1    |a    |
|u3    |c    |
|u4    |b    |
|u1    |a    |
|u2    |c    |
|u5    |b    |
|u4    |b    |
|u6    |c    |
|u2    |c    |
|u1    |b    |
|u2    |a    |
|u2    |a    |
|u3    |a    |
|u5    |a    |
|u5    |a    |
|u5    |a    |


4.已知一个表STG.ORDER，有如下字段:Date，Order_id，User_id，amount。

|dt        |order_id|user_id   |amount|
|----------|--------|-------   |------|
|2017-01-01|10029028|1000003251|33.57 |

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 4ORDER
(
    user_id string,
    order_id string,
    amount decimal
)
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as textfile;
set hive.exec.dynamic.partition.mode=nonstrict;
insert into table 4ORDER values
('1000003251','10029028',33.57,'2017-01-01')
        </code>
    </pre> 
</details>

- 给出2017年每个月的订单数、用户数、总成交金额。

  <details>   
      <summary>答案1</summary>
      <pre>
          <code>
  with t1 as (
      select date_format(dt, 'yyyy-MM') as mn, user_id ,count(order_id) as count_orders,sum(amount) as total_amount
      from 4ORDER
      where date_format(dt, 'yyyy') = '2017'
      group by date_format(dt, 'yyyy-MM'),user_id
  )
  select mn,count(user_id) as count_visit, sum(count_orders) as ct_order,sum(total_amount) as t_am
  from t1
  group by mn
          </code>
      </pre> 
  </details>

- 给出2017年11月的新客数(指在11月才有第一笔订单)

  <details>   
      <summary>答案1</summary>
      <pre>
          <code>
  select count(user_id)
  from 4ORDER
  group by user_id
  having date_format(min(dt),'yyyy-MM')='2017-11'
          </code>
      </pre> 
  </details>

5.有日志如下，请写出代码求得所有用户和活跃用户的总数及平均年龄。（活跃用户指连续两天都有访问记录的用户）日期 用户 年龄

|dt        |user_id|age|
|----------|-------|---|
|2019-02-11|test_1|23|
|2019-02-11|test_2|19|
|2019-02-11|test_3|39|
|2019-02-11|test_1|23|
|2019-02-11|test_3|39|
|2019-02-11|test_1|23|
|2019-02-12|test_2|19|
|2019-02-13|test_1|23|
|2019-02-15|test_2|19|
|2019-02-16|test_2|19|

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table if not exists 5user
(
    user_id string,
    age int
)
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as textfile;
insert into table 5user values
('test_1',23,'2019-02-11'),
('test_2',19,'2019-02-11'),
('test_3',39,'2019-02-11'),
('test_1',23,'2019-02-11'),
('test_3',39,'2019-02-11'),
('test_1',23,'2019-02-11'),
('test_2',19,'2019-02-12'),
('test_1',23,'2019-02-13'),
('test_2',19,'2019-02-15'),
('test_2',19,'2019-02-16');
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
with t1 as (
--去重后给每组的排序
    select user_id, min(age) as age, dt,dense_rank() over (partition by user_id order by dt) as rk
    from 5user
    group by user_id, dt
),
t2 as (
--日期和排序做差，等差数列减等差数列，结果会相同，求和大于2为连续两天
    select user_id, min(age) as age, date_sub(dt, rk)
    from t1
    group by user_id, date_sub(dt, rk)
    having count(1) > 2
),
t3 as (
--(user_id,age)去重-->user_id
    select user_id,min(age) as age
    from t2
    group by user_id
),
t4 as (
    select 0                                              user_total_count,
           0                                              user_total_avg_age,
           count(1)                                    as twice_count,
           cast(sum(age) / count(1) as decimal(10, 2)) as twice_count_avg_age
    from t3
),
t5 as (
    select user_id,min(age) as age
    from 5user
    group by user_id
),
t6 as (
    select count(1)                                    as user_total_count,
           cast(sum(age) / count(1) as decimal(10, 2)) as user_total_avg_age,
           0                                           as twice_count,
           0                                           as twice_count_avg_age
    from t5
)
select sum(user_total_count) as user_total_count,
       sum(user_total_avg_age) as user_total_avg_age,
       sum(twice_count) as twice_count,
       sum(twice_count_avg_age) as twice_count_avg_age
from (
    select *from t4
    union all
    select * from t6
);
        </code>
    </pre> 
</details>

6.字段[user_id，money，payment_time(购买时间），order_id]，求所有用户中在今年10月份第一次购买商品的金额。

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 6order(
	user_id string,
	money decimal,
	payment_time string,
	order_id string
)
row format delimited fields terminated by '\t'
stored as textfile
insert into table 6order
values ('1', 1, '2017-09-01', '1'),
       ('2', 2, '2017-09-02', '2'),
       ('3', 3, '2017-09-03', '3'),
       ('4', 4, '2017-09-04', '4'),
       ('3', 5, '2017-10-05', '5'),
       ('6', 6, '2017-10-06', '6'),
       ('1', 7, '2017-10-07', '7'),
       ('8', 8, '2017-10-09', '8'),
       ('6', 6, '2017-10-16', '60'),
       ('1', 7, '2017-10-17', '70');
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select user_id, money, payment_time, order_id, rkt
from (
         select user_id,
                money,
                payment_time,
                order_id,
                rank() over (partition by user_id order by payment_time) as rkt
         from 6order
         where date_format(payment_time, 'yyyy-MM') = '2017-10'
     ) t1
where t1.rkt = 1
        </code>
    </pre> 
</details>

7.求11月9号下午14点（14-15点）,访问api/user/login接口的top10的ip地址

| time                | interface        | ip          |
| ------------------- | ---------------- | ----------- |
| 2016-11-09 14:22:05 | /api/user/login  | 110.23.5.33 |
| 2016-11-09 11:23:10 | /api/user/detail | 57.3.2.16   |
| 2016-11-09 14:59:40 | /api/user/login  | 200.6.5.166 |
| 2016-11-09 14:22:05 | /api/user/login  | 110.23.5.34 |
| 2016-11-09 14:22:05 | /api/user/login  | 110.23.5.34 |
| 2016-11-09 14:22:05 | /api/user/login  | 110.23.5.34 |
| 2016-11-09 11:23:10 | /api/user/detail | 57.3.2.16   |
| 2016-11-09 23:59:40 | /api/user/login  | 200.6.5.166 |
| 2016-11-09 14:22:05 | /api/user/login  | 110.23.5.34 |
| 2016-11-09 11:23:10 | /api/user/detail | 57.3.2.16   |
| 2016-11-09 23:59:40 | /api/user/login  | 200.6.5.166 |
| 2016-11-09 14:22:05 | /api/user/login  | 110.23.5.35 |
| 2016-11-09 14:23:10 | /api/user/detail | 57.3.2.16   |
| 2016-11-09 23:59:40 | /api/user/login  | 200.6.5.166 |
| 2016-11-09 14:59:40 | /api/user/login  | 200.6.5.166 |
| 2016-11-09 14:59:40 | /api/user/login  | 200.6.5.166 |

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 7interface
(
    `time`        string,
    interface string,
   ip    string
)
    row format delimited fields terminated by '\t'
    stored as textfile;
insert into table 7interface
values ('2016-11-09 14:22:05', '/api/user/login', '110.23.5.33'),
       ('2016-11-09 11:23:10', '/api/user/detail', '57.3.2.16'),
       ('2016-11-09 14:59:40', '/api/user/login', '200.6.5.166'),
       ('2016-11-09 14:22:05', '/api/user/login', '110.23.5.34'),
       ('2016-11-09 14:22:05', '/api/user/login', '110.23.5.34'),
       ('2016-11-09 14:22:05', '/api/user/login', '110.23.5.34'),
       ('2016-11-09 11:23:10', '/api/user/detail', '57.3.2.16'),
       ('2016-11-09 23:59:40', '/api/user/login', '200.6.5.166'),
       ('2016-11-09 14:22:05', '/api/user/login', '110.23.5.34'),
       ('2016-11-09 11:23:10', '/api/user/detail', '57.3.2.16'),
       ('2016-11-09 23:59:40', '/api/user/login', '200.6.5.166'),
       ('2016-11-09 14:22:05', '/api/user/login', '110.23.5.35'),
       ('2016-11-09 14:23:10', '/api/user/detail', '57.3.2.16'),
       ('2016-11-09 23:59:40', '/api/user/login', '200.6.5.166'),
       ('2016-11-09 14:59:40', '/api/user/login', '200.6.5.166'),
       ('2016-11-09 14:59:40', '/api/user/login', '200.6.5.166');
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select ip,count(1) as ct
from 7interface
where interface='/api/user/login'
    and date_format(`time`,'yyyy-MM-dd HH')>='2016-11-9 14'
    and date_format(`time`,'yyyy-MM-dd HH')<='2016-11-9 15'
group by ip
order by ct desc
limit 10
        </code>
    </pre> 
</details>

8.有一个账号表[dist_id(区组id)，account(账号)，gold(金币)]，查询各自区组的money排名前十的账号（分组取前10）

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 8account(
	dist_id string,
    account string,
    gold int
)
row format delimited fields terminated by '\t'
stored as textflie；
insert into table 8account
values ('1', '11', 100006),
       ('1', '12', 110000),
       ('1', '13', 102000),
       ('1', '14', 100300),
       ('1', '15', 100040),
       ('1', '18', 110000),
       ('1', '16', 100005),
       ('1', '17', 180000),
       ('2', '21', 100800),
       ('2', '22', 100030),
       ('2', '23', 100000),
       ('2', '24', 100010),
       ('2', '25', 100070),
       ('2', '26', 100800),
       ('3', '31', 106000),
       ('3', '32', 100400),
       ('3', '33', 100030),
       ('3', '34', 100003),
       ('3', '35', 100020),
       ('3', '36', 100500),
       ('3', '37', 106000),
       ('3', '38', 100800);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
with t1 as (
    select dist_id, 
    	   account, gold,
           dense_rank() over (partition by dist_id order by gold) as rk
    from 8account
)
select account
from t1
where rk<=10;
        </code>
    </pre> 
</details>

9.分组查出销售表中所有会员购买金额，同时分组查出退货表中所有会员的退货金额，把会员id相同的购买金额-退款金额    	得到的结果更新到表会员表中对应会员的积分字段（credits）

- 有三张表分别为会员表（member）销售表（sale）退货表（regoods)   
  (1)会员表有字段memberid（会员id，主键）credits（积分)   
  (2)销售表有字段memberid（会员id，外键）购买金额（MNAccount)   
  (3)退货表中有字段memberid（会员id，外键）退货金额（RMNAccount) 

- 业务说明   
  (1)销售表中的销售记录可以是会员购买，也可以是非会员购买。（即销售表中的memberid可以为空）  
  (2)销售表中的一个会员可以有多条购买记录   
  (3)退货表中的退货记录可以是会员，也可是非会员   
  (4)一个会员可以有一条或多条退货记录  

  <details>   
      <summary>答案1</summary>
      <pre>
          <code>
          </code>
      </pre> 
  </details>

10.用一条SQL语句查询出每门课都大于80分的学生姓名

|name|class_name|score|
|----|----------|-----|
|张三 |语文      | 81|
|张三 |数学      | 75|
|李四 |语文      | 76|
|李四 |数学      | 90|
|王五 |语文      | 81|
|王五 |数学      | 100|
|王五 |英语      | 90|

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 10sc(
    name string,
    class_name string,
    score decimal
)
row format delimited fields terminated by '\t'
stored as textfile ;
insert into table 10sc
values ('张三', '语文', 81),
       ('张三', '数学', 75),
       ('李四', '语文', 76),
       ('李四', '数学', 90),
       ('王五', '语文', 81),
       ('王五', '数学', 100),
       ('王五', '英语', 90);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select name
from 10sc
where score>80
group by name
having count(*)=3
        </code>
    </pre> 
</details>

<details>   
    <summary>答案2</summary>
    <pre>
        <code>
select name from table group by name having min(fenshu)>80
        </code>
    </pre> 
</details>

11.删除除了自动编号不同, 其他都相同的学生冗余信息

|auto_id|stu_id|name|class_id|class_name|score|
|-------|------|----|--------|----------|-----|
|1     |2005001| 张三|   0001|   数学|   69|
|2     |2005002| 李四|   0001|   数学|   89|
|3     |2005001| 张三|   0001|   数学|   69|

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
drop table if exists 11sc;
create table 11sc
(
    auto_id  int,
    stu_id   string,
    name     string,
    class_id string,
    class_name string,
    score    int
)
    row format delimited fields terminated by '\t'
    stored as textfile;
insert into table 11sc
values (1, '2005001', '张三', '0001', '数学', 69),
       (2, '2005002', '李四', '0001', '数学', 89),
       (3, '2005001', '张三', '0001', '数学', 69);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
delete from 11sc where auto_id not in (
    select min(auto_id)
    from 11sc
    group by stu_id, name, class_id, class_name, score
    )
        </code>
    </pre> 
</details>

12.一个叫team的表，里面只有一个字段name,一共有4条纪录，分别是a,b,c,d,对应四个球队，现在四个球队进行比赛，用	一条sql语句显示所有可能的比赛组合  

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select a.name, b.name
from team a, team b
where a.name < b.name
        </code>
    </pre> 
</details>

13.表1变表2

|year|month|amount|
|----|-----|------|
|1991|   1 |   1.1|
|1991|   2 |   1.2|
|1991|   3 |   1.3|
|1991|   4 |   1.4|
|1992|   1 |   2.1|
|1992|   2 |   2.2|
|1992|   3 |   2.3|
|1992|   4 |   2.4|

| year | m1   | m2   | m3   | m4   |
| ---- | ---- | ---- | ---- | ---- |
| 1991 | 1.1  | 1.2  | 1.3  | 1.4  |
| 1992 | 2.1  | 2.2  | 2.3  | 2.4  |

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
drop table if exists 13account;
create table 13account
(
    `year`  string,
    `month` string,
    account decimal
)
    row format delimited fields terminated by '\t'
    stored as textfile;
insert into table 13account
values ('1991', '1', 1.1),
       ('1991', '2', 1.2),
       ('1991', '3', 1.3),
       ('1991', '4', 1.4),
       ('1992', '1', 2.1),
       ('1992', '2', 2.2),
       ('1992', '3', 2.3),
       ('1992', '4', 2.4);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
        </code>
    </pre> 
</details>

14.表3变表4(及格分数为60)

|course_id|course_name|score|
|---------|-----------|-----|
|1        |java       |70   |
|2        |oracle     |90   |
|3        |xml        |40   |
|4        |jsp        |30   |
|5        |servlet    |80   |

|course_id|course_name|score|mark|
|---------|-----------|-----|----|
|1        |java       |70   |pass|
|2        |oracle     |90   |pass|
|3        |xml        |40   |fail|
|4        |jsp        |30   |fail|
|5        |servlet    |80   |pass|

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 14sc(
	course_id int,
    course_name string,
    score decimal
)
row format delimited fields terminated by '\t'
stored as textfile;
insert into table 14sc values
	(1,'java',70),
	(2,'oracle',90),
	(3,'xml',40),
	(4,'jsp',30),
	(5,'servlet',80);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select course_id,course_name,score,mark,
	case when score>=10 then 'pass' else 'fail'
from 14sc
        </code>
    </pre> 
</details>

15.给出所有购入商品为两种或两种以上的购物人记录

|购物人|商品名称|数量|
|-----|------|----|
|A    |甲    |   2|
|B    |乙    |   4|
|C    |丙    |   1|
|A    |丁    |   2|
|B    |丙    |   5|

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 15order(
	user_name string,
    goods_name string,
    acount int
)
row format delimited fields terminated by '\t'
store as textfile;
insert into table 15sc values 
	('A','甲',2),
	('B','乙',4),
	('C','丙',1),
	('A','丁',2),
	('B','丙',5);
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select user_name
from 15sc
group by user_name
having count(1)>=2
        </code>
    </pre> 
</details>

16.表5变表6

|date|result|
|----|------|
|2005-05-09|win|
|2005-05-09|lose|
|2005-05-09|lose|
|2005-05-09|lose|
|2005-05-10|win |
|2005-05-10|lose|
|2005-05-10|lose|

|   date   | win |lose|
|----------|-----|----|
|2005-05-09|  2  | 2  |
|2005-05-10|  1  | 2  |

<details>   
    <summary>建表语句</summary>
    <pre>
        <code>
create table 16test(
	`date` string,
    result string
)
row format delimited fields terminated by '\t'
stored as textfile;
insert into table 16test values 
('2005-05-09','win'),
('2005-05-09','lose'),
('2005-05-09','lose'),
('2005-05-09','lose'),
('2005-05-10','win'),
('2005-05-10','lose'),
('2005-05-10','lose');
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
select `date`
	sum(case when result='win' then 1 else 0) as win,
	sum(case when result='lose' then 1 else 0) as lose
from 16test
group by `date`
        </code>
    </pre> 
</details>

17.有一个订单表order。

| order_id(订单ID) | user_id(用户ID) | amount(金额) | pay_datetime(付费时间) | channel_id(渠道ID) | dt(分区字段) |
| ---------------- | --------------- | ------------ | ---------------------- | ------------------ | ------------ |
|                  |                 |              |                        |                    |              |

- 在Hive中创建这个表。
- 查询dt=‘2018-09-01‘里每个渠道的订单数，下单人数（去重），总金额。
- 查询dt=‘2018-09-01‘里每个渠道的金额最大3笔订单。
- 有一天发现订单数据重复，请分析原因

| order_id | item_id | create_time | amount |
| -------- | ------- | ----------- | ------ |
| item_id | item_name | category ||
| item_id | item_name | category_1 | category_2 |
- 最近一个月，销售数量最多的10个商品
- 最近一个月，每个种类里销售数量最多的10个商品(一个订单对应一个商品 一个商品对应一个品类)
- 计算平台的每一个用户发过多少日记、获得多少点赞数

18.处理产品版本号，表[版本号，子版本号，阶段版本号]

- 需求A:找出T1表中最大的版本号
- 需求B：计算出如下格式的所有版本号排序，要求对于相同的版本号，顺序号并列

19.求中位数  

20.有张“钻井平台采油量表”，有两个字段，A年月日时分秒，B累计采油量。  

- 求第四次下钻的采油量  
- 求平均每次采油量  

21.有一个分区表，表名T，字段qq，age，按天分区，让写出创建表的语句  

22.分区表，求20200221这个分区中，年龄第N大的qq号列表，找出所有互相关注的qq对   

|qqa|qqb|
|---|---|
|12|56|
|12|78|
|34|56|
|34|12|

23.计算开始时间和结束时间的差值的中位数，多种方法：

|req_id|event|timestamp|
|-------|------|--------|
|1|start|1400xxxxx|
|1|end  |1400xxxxx|

24. 查询出用户连续三天登录的用户

|user_id|login_date|
|-------|----------|
|   1   |20200325  |

25. 求每天新增用户次日、7天、30天留存率。（说明：7天留存是指当天有登录且第7天还登录的用户）

| t_login_all（全量用户登陆表） | t_login_new（新增用户登录日志表） |
| ----------------------------- | --------------------------------- |
| ftime（登录日期）             | ftime（登录日期）                 |
| openid（登录帐号）            | openid（登录帐号）                |

26.每天有收发消息用户最近登录时间、登录区服，输出ftime，user_id，login_loc，login_time

| 消息流水表t_chat all              | 用户登录流水日志表t_login_all |
| --------------------------------- | ----------------------------- |
| Ftime（日期）                     | Ftime（日期）                 |
| send_user id（发消息用户id）      | user_id（用户id）             |
| receive.user id（接收消息用户id） | login_id（登录id）            |
| chat id（消息id）                 | login_loc（登录区服）         |
| send.time（发消息时间）           | login_time（登录时间）        |

27.字段（area、year、temperature），统计每个地区的温度最高的对应的年份。

28.如下表  

| 字段名       | 中文名         | 字段类型 | 字段示例   |
| ------------ | -------------- | -------- | ---------- |
| cuid         | 用户的唯一标识 | string   | ed2s9w     |
| os           | 平台           | string   | android    |
| soft—version | 版本           | string   | 11.0.0.1   |
| event_day    | 日期           | string   | 20190101   |
| ext          | 扩展字段       | array    | [{},{},{}] |

| cuid | os      | soft_version | event_day | ext                                                          |
| ---- | ------- | ------------ | --------- | ------------------------------------------------------------ |
| A1   | Android | 11.0.0.1     | 20190101  | [{"id":1001, "type":"show", "from":"home", "source":"his"}, {"id":1002, "type":"dick", "from":"swan", "sourceM:"rcm"}, {"id":1003, "type":"slide", "from":"tool"( "source":"banner"}, {"id":1001, "type":"del", "from":"wode"( "source":"myswan"}] |
| A2   | iPhone  | 11.19.0.1    | 20190101  | [..]                                                         |
| ...  | ...     | ...          | ...       | ...                                                          |

- 写出用户表 tb_cuid_1d的 20200401 的次日、次7日留存的具体HQL ：

  一条sql统计出以下指标 （4.1号uv，4.1号在4.2号的留存uv，4.1号在4.8号的留存uv）(一条sql写完)  

- 统计当天不同平台、版本下的uv、pv  

- 解析ext中所有的"type"( lateral view explode)  

29.表t_a (uid,os,day) 和表t_b(uid,os,day)  

- 15号在t_a 但是不在t_b的用户  
- t_a中最近30内，所有用户末次活跃日期  
- t_a中最近30内，所有用户末次活跃日期和倒数第二次的差值  

31.把每科最高分前三名统计出来 --成绩表Score（student_name,student_no,subject_no,score）  

32.找出单科成绩高于该科平均成绩的同学名单（无论该学生有多少科，只要有一科满足即可） --成绩表Score（student_name,student_no,subject_no,score）  

33.一个表 test(name,price),构建一个新表,将name相同的,price所有价格合并到一个字段里面  

34.如何将题33中price合并后的prices 字段再拆分为多条记录？  

35.使用HiveSQL,根据shop_id分组，按照money排序，得到r，d，a三列顺序

| shop_id | brand | money | r    | d    | a    |
| ------- | ----- | ----- | ---- | ---- | ---- |
| A       | a     | 10    | 2    | 2    | 2    |
| A       | b     | 12    | 1    | 1    | 1    |
| A       | c     | 5     | 3    | 3    | 3    |
| B       | a     | 8     | 1    | 1    | 1    |
| B       | c     | 8     | 2    | 1    | 1    |
| B       | x     | 1     | 3    | 3    | 2    |
| B       | n     | 0     | 4    | 4    | 3    |

36.已知条件如下：  t_user(uid int) ，t_order(oid int,uid int,otime date,oamout int)  其中用户表和订单表一对多  

- 计算在2017年1月下过单，2月份没有下过订单的用户，在3月份的订单金额分布 ，具体字段如下（注：没有匹配到3月份订单的用0填充）  

  | uid  | 3月份订单金额超过10的订单书 | 3月份首次下单的金额 | 3月份最后一次下单的金额 |
  | ---- | --------------------------- | ------------------- | ----------------------- |
  |      |                             |                     |                         |

  要求：对订单表查询次数大于2次

37.已知有两个数据源，商品访问日志存于HDFS（200G/h）,商品详情存于Mysql  
     访问日志格式：2016-10-16 12：15：18    /detail?itemId=123&userId=i12321  
     Mysql：item_detail(id,name,price,category_id)        item_category(id,desc) 

- 基于hive建立数据模型以满足以下需求，并简述处理过程（ETL,建表等）  
- 计算每类商品的DAU  
- 计算每小时访问TOP100商品  

38.假定你当前有两张交易订单表order和sub_oder，存储于hive环境，其表结构信息如下， 一 个订单id下可能多个子订单， 一 个子订单代表一个买家在一个卖家购买的一种商 品，可能购买多件，整个支付金额是在主订单上。

```sql
create table order (
order_id             bigint       --订单 ID
,sub_order_id        bigint       --子订单 ID
,seller_id           bigint 	  --卖家 ID
,buyer_id            bigint 	  --买家 ID
,pay_time            string       --支付时间
,pay_amt             double       --实际支付金额（元）
,adjust_amt          double       --主订单优惠券金额（元）
)
create table sub_order (
order_id             bigint       --订单 ID
,sub_order_id        bigint       --子订单 ID
,product_id          bigint       --商品 ID
,price               double       --商品价格（元）
,quantity            bigint       --购买商品数量
)
```

现在需要你设计和开发一段数据处理逻辑SQL实现，将实际支付金额基于每个子订单的（商品价格*购买数量）占总的订单的（商品价格* 购买数量）比例进行拆分，获得每个子订单分摊实际支付金额，并输出表结构如下：

```sql
create table order (
order_id               bigint    --订单ID
,sub_order_id         bigint    --子订单ID
,seller_id             bigint    --卖家 ID
,buyer_id              bigint    --买家 ID
,product_id            bigint    --商品 ID
,pay_time              string    --支付时间
,price                 double    --商品i介格（元）
,quantity              bigint    --购买商品数量
,sub_pay_amt           double    --子订单分摊实际支付金额
)
```

请注意几个要求：

- 拆分后金额精确到小数点两位；

- 拆分后的汇总金额要与拆分前完全一致； 

- 拆分的金额保持，每次程序重新运行计算的结果是一致的；

- 如有业务理解有异议的，你可以进行一定假设，在代码注释中标明；

  

39.以下表记录了用户每天的蚂蚁森林低碳生活领取的记录流水蚂蚁森林植物换购表，用于记录申领环保植物所需要减少  的碳排放量  

user_low_carbon [user_id(用户id)，data_dt (日期)，low_carbon(减少碳排放（g)]。  

plant_carbon  [plant_id (植物编号)，plant_name (植物名)，low_carbon (换购植物所需要的碳 )]

- 假设2017年1月1日开始记录低碳数据（user_low_carbon），假设2017年10月1日之前满足申领条件的用户都申领了一颗p004-胡杨，剩余的能量全部用来领取“p002-沙柳”。  
  统计在10月1日累计申领“p002-沙柳” 排名前10的用户信息；以及他比后一名多领了几颗沙柳。得到的统计结果如下表样式：  

  | user_id | plant_count | less_count(比后一名多领了几颗沙柳) |
  | ------- | ----------- | ---------------------------------- |
  | u_101   | 1000        | 100                                |
  | u_088   | 900         | 400                                |
  | u_103   | 500         | …                                  |

- 查询user_low_carbon表中每日流水记录，条件为：  
    1)用户在2017年，连续三天（或以上）的天数里，  
    2)每天减少碳排放（low_carbon）都超过100g的用户低碳流水。  
    3)需要查询返回满足以上条件的user_low_carbon表中的记录流水。  
    例如用户u_002符合条件的记录如下，因为2017/1/2~2017/1/5连续四天的碳排放量之和都大于等于100g   

测试数据：

|seq（key）| user_id| data_dt| low_carbon|
|---------|--------|--------|----------|
|xxxxx10| u_002| 2017/1/2| 150|
|xxxxx11| u_002| 2017/1/2| 70 |
|xxxxx12| u_002| 2017/1/3| 30 |
|xxxxx13| u_002| 2017/1/3| 80 |
|xxxxx14| u_002| 2017/1/4| 150|
|xxxxx14| u_002| 2017/1/5| 101|

|user_id| data_dt|low_carbon|
|-------|--------|----------|
|u_001| 2017/1/1|10|
|u_001| 2017/1/2|150|
|u_001| 2017/1/2|110|
|u_001| 2017/1/2|10|
|u_001| 2017/1/4|50|
|u_001| 2017/1/4|10|
|u_001| 2017/1/6|45|
|u_001| 2017/1/6|90|
|u_002| 2017/1/1|10|
|u_002| 2017/1/2|150|
|u_002| 2017/1/2|70|
|u_002| 2017/1/3|30|
|u_002| 2017/1/3|80|
|u_002| 2017/1/4|150|
|u_002| 2017/1/5|101|
|u_002| 2017/1/6|68|

|plant_id|plant_name|low_carbon|
|--------|----------|----------|
|p001| 梭梭树| 17|
|p002| 沙柳 |19|
|p003| 樟子树| 146|
|p004| 胡杨 |215|

40.使用 Hive SQL计算上下相邻两次uv_time之间的时间间隔

| id   | uv_time             |
| ---- | ------------------- |
| 1    | 2018-05-01 01:00:34 |
| 2    | 2018-05-01 02:12:41 |
| 3    | 2018-05-02 15:31:26 |
| 4    | 2018-06-08 12:40:39 |

41.—个叫team的表，里面只有一个字段name, —共有4条纪录，分别是a,b,c,d,对 应四个球对，现在四个球对进行比赛，只用一条sql语句显示所有可能的比赛组合

42.表user_id，visit_date，page_name

- 统计7天每天到访的新用户数
- 没个渠道7天前用户的3日留存和7日留存

43. 小鹏汽车充电有两种类型，快充、慢充，有如下数据：

    车辆ID  充电时间                  充电类型 

    a         20200601 19:21:09    1

    a         20200611 11:30:09    1

    a         20200621 21:10:09   0

    a         20200701 19:01:09   1

    a         20200701 20:30:09   1

    a         20200701 21:00:09   0

    a         20200702 20:30:00  1

    a        20200703 09:01:09   1

    a        20200704 12:05:09   1

    b        20200706 12:20:09   0

    a        20200706 11:10:09   0

    其中1为快充，0为慢充，求每辆车最长 连续快充次数 

44. a表销售id+销售时间，b表销售id+销售跟进时间，取出销售id的对应销售时间的最近的销售跟进时间

    | a表销售id | 销售时间 |
    | --------- | -------- |
    | id1       | 10:00    |
    | id1       | 12:00    |

    | b表销售id | 销售跟进时间 |
    | --------- | ------------ |
    | id1       | 11:00        |
    | id1       | 11:30        |
    | id1       | 12:30        |

    







 







