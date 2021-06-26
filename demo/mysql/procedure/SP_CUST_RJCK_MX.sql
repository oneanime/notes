create
    definer = root@localhost procedure SP_CUST_RJCK_MX(IN timefile varchar(30))
begin

    declare vv_proc_name varchar(300) charset utf8;

    declare vv_grade1 int(11);


    set vv_proc_name = '删除当天插入或者更新的数据';
    delete from DATA_CUST_RJCK_MX where s_date = timefile;
    commit;

    set vv_proc_name = '无变动的记录的e_date回滚成29990101 (数据重新下发不一致导致的异常)';
    update DATA_CUST_RJCK_MX a set a.e_date ='29990101' where a.e_date = timefile;
    commit;

    set vv_proc_name = '将需要更新的数据的结束时间修改为数据下发时间';
    update DATA_CUST_RJCK_MX a
    set a.e_date = timefile
    where EXISTS(
                  select 1
                  from bkorig_ods.cbs_invm_base b
                  where a.acc_no = b.acc_no
                    and ifnull(a.curr_bal, 0) <> ifnull(b.curr_bal, 0)
                    and a.e_date = '29990101'
              );
    commit;


    set vv_proc_name = '重新插入一条更新的记录';
    insert into DATA_CUST_RJCK_MX
    select a.acc_no,
           a.mast_acct,
           a.sub_acct_no,
           a.cust_name,
           a.ident_no,
           a.curr_bal,
           a.saving_type,
           timefile                          as s_date,
           '29990101'                        as e_date,
           date_format(timefile, '%y-%m-%d') as xfsjc,
           current_timestamp                 as gxsjc
    from bkorig_ods.cbs_invm_base a
    where exists(select 1
                 from DATA_CUST_RJCK_MX b
                 where a.acc_no = b.acc_no
                   and ifnull(a.curr_bal, 0) <> ifnull(b.curr_bal, 0)
                   and b.E_DATE = timefile);
    commit;

    set vv_proc_name = '插入新增的记录';
    insert into DATA_CUST_RJCK_MX
    select b.acc_no,
           b.mast_acct,
           b.sub_acct_no,
           b.cust_name,
           b.ident_no,
           b.curr_bal,
           b.saving_type,
           timefile                          as s_date,
           '29990101'                        as e_date,
           date_format(timefile, '%y-%m-%d') as xfsjc,
           current_timestamp                 as gxsjc
    from bkorig_ods.cbs_invm_base b
    where not exists(select 1 from DATA_CUST_RJCK_MX a where a.acc_no = b.acc_no);

    commit;


end;

