一、连续几次出现的问题

> 实质上就是某个唯一标识或者实体在一个表中，在某个计算维度连续出现三次的题目

1. 连续出现次数问题(连续出现至少3次的数字)

   <details>   
       <summary>建表语句</summary>
       <pre>
           <code>
   create table Logs(
       id int,
       num int
   )
   row format delimited fields terminated by '\t';
   insert into table Logs values(1,1),(2,1),(3,1),(4,2),(5,1),(6,2),(7,2);
           </code>
       </pre> 
   </details>

   <details>   
       <summary>答案</summary>
       <pre>
           <code>
   select distinct Num as ConsecutiveNums 
   from
   	(select
   		Num,
   		(
   			row_number() OVER (ORDER BY id ASC) -
   			row_number() OVER (partition by NUM order By id asc)
   		) as series_id
   		from Logs
   	) tmp
   group by Num ,series_id
   HAVING count(1)>=3;
           </code>
       </pre> 
   </details>

2. 用户连续N日登录

   <details>   
       <summary>答案</summary>
       <pre>
           <code>
   # 涉及表字段user_id,以及登陆时间
   SELECT user_id,count(1) cnt
   FROM
   (
   	SELECT user_id,
   		   login_date,
   	       row_number () over (PARTITION BY user_id ORDER BY login_date ) rn
   	FROM Login
   ) a
   GROUP BY a.user_id,date_sub(a.login_date, INTERVAL rn day)
   HAVING count(1) >= 3;
   		</code>
   	</pre> 
   </details>

   <details>   
       <summary>延伸:最大连续登录天数</summary>
       <pre>
           <code>
   #最大连续登录天数
   select uid, max(count)
   from
   (
   	select uid,logindate,
   		data_sub(logindate,rank) as series,
   		count(1) as count --连续登陆天数
   	from
   	(
   		select
   		uid,
   		logindate,
   		row_number() over(partition by uid order by logindate desc) as rank
   		from user_login
   	)a
   	group by uid, data_sub(logindate,rank) -- 连续登陆的id，这个差值是相同的
   )
   group by uid
           </code>
       </pre> 
   </details>

3. 体育馆的人流量问题

编写一个 SQL 查询以找出每行的人数大于或等于 100 且 id 连续的三行或更多行记录。visit_date 升序 排列

<details>   
    <summary>建表</summary>
    <pre>
        <code>
create table stadium(
	id int comment '序号',
	visit_date date comment '日期',
	people int comment '人流量'
)
row format delimited fields terminated by '\t';
# visit_date为主键，每天只有一行记录，日期随着id的增加而增加
        </code>
    </pre> 
</details>

<details>   
    <summary>答案1</summary>
    <pre>
        <code>
--连续三行或者多行 意味着每行记录有共同点 转化成数字是否连续的问题，那么根据100条件筛选后，对id
做排序 求与序号的差值，如果id连续，那么差值必然相等。而后对差值相等的记录做一个累加计数，计数后
数量大于等于3的即为结果
select id,visit_date,people 
from 
(
	select id,
		visit_date,people,
		count(*) over(partition by cz) cnt 
	from (
		select id,
		visit_date,id - (row_number() over(order by id asc)) cz,
		people 
		from Stadium 
		where people >= 100
		) t0
) t1 
where cnt>=3 
order by visit_date;
        </code>
    </pre> 
</details>

4. 连续空座问题

   <details>   
       <summary>预约连续空余的座位，并按照seat_id排序后返回</summary>
       <pre>
           <code>
   create table cinema (
   	seat_id int,
   	free int
   )
   row format delimited fields terminated by '\t';
   inster into table cinema values(1,1),(2,0),(3,1),(4,1),(5,1);
           </code>
       </pre> 
   </details>

   <details>   
       <summary>答案</summary>
       <pre>
           <code>
   select seat_id
   from
   	(
   		select
   			seat_id,
   			count(*) over(partition by cz) as cnt
   		from
   		(
   			select seat_id,
   			(seat_id - row_number() over(order by seat_id)) as cz 
   			from cinema 
   			where free = 1
   		)t0
   	)t1
   where cnt >= 2
           </code>
       </pre> 
   </details>

   