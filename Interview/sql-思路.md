1. 求每一行的最大值

```sql
select  *,sort_array(array(date1,date2,date3))[2] as max_value from T0429
```

