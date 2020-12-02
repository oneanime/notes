1. 

```sql
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

select uid
from sc left join
     (
         select subject_id ,avg(score) as avg_score
         from sc
         group by subject_id
     ) t1 on sc.subject_id=t1.subject_id
where sc.score>t1.avg_score
group by uid
having count(uid)=3;
-------------------------------------------------------------------------------------
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
having sum(t2.flag)=3;
```

2.

```sql
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

with t1 as (
    select userId, visitDate, visitCount, date_format(regexp_replace(visitDate, '/', '-'), 'yyyy-MM') as fm_date
    from user_visit
),
t2 as (
    select userId,fm_date,sum(visitCount) as vc
    from t1
    group by userId,fm_date
)
select userId,vc,sum(vc) over (partition by userId order by fm_date) as acc
from t2
```

3.

```sql
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
       
       
select shop,count(userId)
from (
         select userId, shop
         from 3jindongshop
         group by userId, shop
     )
group by shop;
-------------------------------------------------------------------------------------------
select shop,count(distinct userId) from 3jindongshop group by shop;

===========================================================================================
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
```

4.

```sql
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

with t1 as (
    select date_format(dt, 'yyyy-MM') as mn, user_id ,count(order_id) as count_orders,sum(amount) as total_amount
    from 4ORDER
    where date_format(dt, 'yyyy') = '2017'
    group by date_format(dt, 'yyyy-MM'),user_id
)
select mn,count(user_id) as count_visit, sum(count_orders) as ct_order,sum(total_amount) as t_am
from t1
group by mn

select count(user_id)
from 4ORDER
group by user_id
having date_format(min(dt),'yyyy-MM')='2017-11'


```

5.

```sql
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

```

6.

```sql
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
```

7.

```sql
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

select ip,count(1) as ct
from 7interface
where interface='/api/user/login'
    and date_format(`time`,'yyyy-MM-dd HH')>='2016-11-9 14'
    and date_format(`time`,'yyyy-MM-dd HH')<='2016-11-9 15'
group by ip
order by ct desc
limit 10

```

8.

```sql
create table 8account(
	dist_id string,
    account string,
    gold int
)
row format delimited fields terminated by '\t'
stored as textflie

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
 
with t1 as (
    select dist_id, 
    	   account, gold,
           dense_rank() over (partition by dist_id order by gold) as rk
    from 8account
)
select account
from t1
where rk<=10;
```

9.

```sql

```

10.

```sql
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
       
select name
from 10sc
where score>80
group by name
having count(*)=3

select name from table group by name having min(fenshu)>80
```

11.

```sql
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
       
delete from 11sc where auto_id not in (
    select min(auto_id)
    from 11sc
    group by stu_id, name, class_id, class_name, score
    )
```

12.

```sql
select a.name, b.name
from team a, team b
where a.name < b.name
```

13.

```
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
       
       
```

14.

```sql
create table 14sc(
	course_id int,
    course_name string,
    score decimal
)
row format delimited fields terminated by '\t'
stored as textfile

insert into table 14sc values
	(1,'java',70),
	(2,'oracle',90),
	(3,'xml',40),
	(4,'jsp',30),
	(5,'servlet',80);

select course_id,course_name,score,mark,
	case when score>=10 then 'pass' else 'fail'
from 14sc
```

15.

```sql
create table 15order(
	user_name string,
    goods_name string,
    acount int
)
row format delimited fields terminated by '\t'
store as textfile

insert into table 15sc values 
	('A','甲',2),
	('B','乙',4),
	('C','丙',1),
	('A','丁',2),
	('B','丙',5);

select user_name
from 15sc
group by user_name
having count(1)>=2

```

16.

```sql
create table 16test(
	`date` string,
    result string
)
row format delimited fields terminated by '\t'
stored as textfile

insert into table 16test values 
('2005-05-09','win'),
('2005-05-09','lose'),
('2005-05-09','lose'),
('2005-05-09','lose'),
('2005-05-10','win'),
('2005-05-10','lose'),
('2005-05-10','lose');

select `date`
	sum(case when result='win' then 1 else 0) as win,
	sum(case when result='lose' then 1 else 0) as lose
from 16test
group by `date`
```

17.

```sql
create table 17order(
	order_id string,
    user_id string,
    amount decimal,
    pay_datetime string,
    channel_id string
)
partition by(dt string)
row format delimited fields terminated by '\t'
stored as textfile

select count(order_id) as ct_order,
	   count(distinct user_id) as ct_user,
	   sum(amount) as total_amount
from 17order
where dt='2018-09-01'
group by channel_id;

select order_id,user_id,amount,pay_datetime,channel_id
from
(select order_id,
	   user_id,
	   amount,
	   pay_datetime,
	   channel_id,
	   rank() over(partition by channel_id order by amount desc) as rk
from 17order
where dt='2018-09-01') t1
where rk<=3


create table 17order2(
	order_id string,
    item_id string,
    create_time string,
    amount decimal
)
row format delimited fields terminated by '\t'
stored as textfile

-- 近一个月
select item_id,sum(amount) as at
from 17order2
where create_time<='2018-09-01' and create_time> add_months('2018-09-1',-1)
group by item_id
order by at
limit 10;

create table 17item(
	item_id string,
    item_name string,
    category string
)
row format delimited fields terminated by '\t'
stored by textfile


select t1.category,t1.item_id
from(
    select category,item_id, rank() over (partition by category order by at desc) as rk
    from(
        select i.category category ,o.item_id item_id,sum(amount) as at
        from 17order2 as o join 17item as i on o.item_id=i.item_id
        where o.create_time <='2018-09-01' and o.create_time>=add_months('2018-09-01',-1)
        group i.category,o.item_id
    ) as t1
) as t2
where rk<=10
```

18.

```sql
create 18version(
	version_id string,
)
row format delimited fields terminated by '\t'
stored as textfile

insert into table 18version values 
	('v9.9.2'),
	('v8.1'),
	('v9.92'),
	('v9.9.2'),
	('v31.0.1'),
	('v31.0.1'),
	('v8.2.1'),
	('v9.99.1'),
	('v9.1.99');


select b.version_id
from(
 select a.version_id as version_id
      ,row_number() over(order by a.main_version desc
      ,a.sub_version desc, a.sec_version desc) as rn    
 from(
  select cast(substring(split(version_id,"\\.")[0],2) as int) as main_version
        ,cast(split(version_id,"\\.")[1] as int) as sub_version
        ,cast(split(version_id,"\\.")[2] as int)as sec_version
        ,version_id
  from version
 ) a
 
) b
where rn = 1


select a.version_id as version_id
      ,rank() over(order by a.main_version desc
      ,a.sub_version desc, a.sec_version desc) as rn    
 from(
  select cast(substring(split(version_id,"\\.")[0],2) as int) as main_version
        ,cast(split(version_id,"\\.")[1] as int) as sub_version
        ,cast(split(version_id,"\\.")[2] as int)as sec_version
        ,version_id
  from version
 ) a
```

19

```sql
with t1 as (
    select score,
       row_number() over (order by score desc ) as row_desc,
       row_number() over (order by score asc ) as row_asc
    from 10sc
)
select avg(score)
from t1
where abs(t1.row_asc-t1.row_desc)=1 or t1.row_desc=t1.row_asc;
```

20.

```sql
cteate table 20oil(
	A string comment '年月日时分秒',
    B string comment '累计采油量'
)
row format delimited fields terminated by '\t'
stored as textfile

select B
from 20oil
order by A asc
limit 4,0

select avg(B)
from 20oil

```

21.

```sql
drop table if exists T;
create table T(
	qq string,
    age int
)
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as parquet;
```

22.

```sql
select qqa,qqb
from 22qq
where dt='20200221'
distribute by dt sort by age desc
limit N,0
```

23.

```sql
create table 23req(
    req_id string,
    event string,
    `timestamp` string
)
row format delimited fields terminated by '\t'
stored as textfile;


insert into table 23req values
    ('1','start','1606929191'),
    ('1','end','1606929193'),
    ('2','start','1606929195'),
    ('2','end','1606929199');

with t1 as (
	select req_id,
       min(if(event = 'start', `timestamp`, null)) as start_event,
       min(if(event = 'end', `timestamp`, null)) as end_event
    from 23req
    group by req_id
),
t2 as(
	select t1.req_id req_id,
	       end_event-start_event as sub_timestrap,
	       row_number() over (order by end_event-start_event desc ) as desc_time,
	       row_number() over (order by end_event-start_event asc) as asc_time
	from t1
)
select avg(sub_timestrap)
from t2
where abs(t2.desc_time-t2.asc_time)=1 or t2.asc_time=t2.desc_time
```

24.

```sql
with t1 as(
select user_id,
login_date,
ROW_NUMBER() over(partition by user_id order by login_date) as rk
from 24login
),
t2 as (
	select user_id,sub_date(login_date,rk) as sub_date
    from t1
)
select login_date
from t2
group by sub_date
having count(1)=3
```

25.

```sql

```

