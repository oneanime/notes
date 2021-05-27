1. 求每一行的最大值

```sql
select  *,sort_array(array(date1,date2,date3))[2] as max_value from T0429
```

2. 滚动时间窗口，统计窗口内的数据量

```sql
-- 窗口大小为15min

select from_unixtime(cur_date_ts + floor(sub_min / 15) * 60, 'yyyy-MM-dd HH:mm:ss') as result_date,
	-- 获取时间段
       count(*)
from (
         select *, CAST((cur_time_ts - cur_date_ts) / 60 AS INT) as sub_min   -- 获取当天0点开始的分钟
         from (
                  select *,
                         unix_timestamp(`time`)                                                 as cur_time_ts,
                         unix_timestamp(concat(date_format(`time`, 'yyyy-MM-dd'), ' 00:00:00')) as cur_date_ts
                  from t0524
              ))
group by from_unixtime(cur_date_ts + floor(sub_min / 15) * 60, 'yyyy-MM-dd HH:mm:ss');
```

3.连续问题

```sql
-- 连续座位问题，占座为0，不占为1
select distinct t1.seat_id
from t0527 t1
join t0527 t2
on abs(t2.seat_id-t1.seat_id)=1
where t1.free=1 and t2.free=1
order by t1.seat_id;

-- 日期连续问题，rank() over(),做等差数列，等差数列减等差数列
-- 相同的连续出现问题，lead()/lag() over()
```



