定义变量
```
	declare @name  nvarchar(50)
	set @name='张三'
	select @name
```
循环
```
	declare @num int
	set @num=0
	while @num<5
	begin
    		select @num
    		set @num=@num+1
	end
```
游标
```
declare ZF_DataTable cursor scroll for select 城市名称 from ZF_城市

open ZF_DataTable
    declare @zf_table varchar(50)
    fetch next from ZF_DataTable into @zf_table

    while (@@FETCH_STATUS=0)
    begin
        select @zf_table
        fetch next from ZF_DataTable into @zf_table
    end

close ZF_DataTable
deallocate ZF_DataTable
```
