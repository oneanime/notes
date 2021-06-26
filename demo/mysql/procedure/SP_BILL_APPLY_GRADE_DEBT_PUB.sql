create
    definer = root@`%` procedure SP_BILL_APPLY_GRADE_DEBT_PUB(IN APPLYID varchar(100), IN IDCARD varchar(20),
                                                              IN PTYPE varchar(10), IN AREACODE varchar(30))
BEGIN
    DECLARE VV_TASK VARCHAR(80);
    DECLARE VV_MON1 VARCHAR(10);
    DECLARE VV_MON2 VARCHAR(10);
    DECLARE VV_LIMIT INT(8);
    DECLARE EXP_AMT DECIMAL(19, 2);
    DECLARE EXP_MON INT(8);

    SET VV_TASK = '将变量赋值';
    SET VV_MON1 = '';
    SET VV_MON2 = '';
    SET VV_LIMIT = 0;
    SET EXP_AMT = 0;
    SET EXP_MON = 0;


    set VV_TASK = '删除  隐形负债流水明细表';
    delete from data_transaction_perdu_debt where APPLY_ID = APPLYID AND AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '将对公账户中 民间借贷类隐形负债流水明细 入中间表';
    insert into data_transaction_perdu_debt
    select *
    from data_transaction_detail
    where (OTHER_NAME like '%小贷%' or OTHER_NAME like '%金融信息%' or OTHER_NAME like '%消费金融%' or OTHER_NAME like '%信息咨询%' or
           OTHER_NAME like '%投资管理%'
        or OTHER_NAME like '%管理咨询%' or OTHER_NAME like '%金融服务%')
      and ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh')
      and ACCOUNT_TYPE = 1
      and EXPEND_AMOUNT > 0
      and APPLY_ID = APPLYID
      AND AREA_CODE = AREACODE;
    commit;

    set VV_TASK = '取得 流水日期近2个月月份';
    select substr(TRADE_DATE, 1, 7)
    into VV_MON1
    from data_transaction_perdu_debt
    where APPLY_ID = APPLYID
    order by substr(TRADE_DATE, 1, 7) desc
    limit 1;
    select substr(TRADE_DATE, 1, 7)
    into VV_MON2
    from data_transaction_perdu_debt
    where APPLY_ID = APPLYID
      and substr(TRADE_DATE, 1, 7) <> VV_MON1
    order by substr(TRADE_DATE, 1, 7) desc
    limit 1;


    set VV_TASK = '取得 流水日期近2个月记录数中最小值';
    select case
               when count(distinct a.TRADE_DATE) > count(distinct b.TRADE_DATE) then count(distinct b.TRADE_DATE)
               else count(distinct a.TRADE_DATE) end
    into VV_LIMIT
    from data_transaction_perdu_debt a,
         (select *
          from data_transaction_perdu_debt b
          where substr(b.TRADE_DATE, 1, 7) = VV_MON2 and b.APPLY_ID = APPLYID) b
    where abs(a.EXPEND_AMOUNT - b.EXPEND_AMOUNT) <= 100
      and abs(substr(a.TRADE_DATE, 9, 2) - substr(b.TRADE_DATE, 9, 2)) <= 3
      and substr(a.TRADE_DATE, 1, 7) = VV_MON1
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE;


    set VV_TASK = '民间借贷类流水隐性负债每月还款额';
    select round(sum(EXPEND_AMOUNT), 2)
    into EXP_AMT
    from (
             select TRADE_DATE, EXPEND_AMOUNT, min(abs(EXPEND_AMOUNT - EXPEND_AMOUNT1)) as AMT
             from (
                      select a.TRADE_DATE,
                             a.EXPEND_AMOUNT,
                             b.TRADE_DATE    as TRADE_DATE1,
                             b.EXPEND_AMOUNT as EXPEND_AMOUNT1
                      from data_transaction_perdu_debt a,
                           (select *
                            from data_transaction_perdu_debt b
                            where substr(b.TRADE_DATE, 1, 7) = VV_MON2 and b.APPLY_ID = APPLYID) b
                      where abs(a.EXPEND_AMOUNT - b.EXPEND_AMOUNT) <= 100
                        and abs(substr(a.TRADE_DATE, 9, 2) - substr(b.TRADE_DATE, 9, 2)) <= 3
                        and substr(a.TRADE_DATE, 1, 7) = VV_MON1
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                  ) t
             group by TRADE_DATE, EXPEND_AMOUNT
         ) tt
    order by AMT
    limit VV_LIMIT;

    set VV_TASK = '民间借贷类流水隐性负债已还款月数';
    select count(distinct substr(TRADE_DATE, 1, 7))
    into EXP_MON
    from data_transaction_perdu_debt
    where APPLY_ID = APPLYID
      and AREA_CODE = AREACODE;

    set VV_TASK = '民间借贷类流水隐性负债信息汇总';
    insert into data_bill_perdu_debt
    select APPLYID,
           IDCARD,
           PTYPE,
           AREACODE,
           CURRENT_TIMESTAMP,
           1,
           1,
           VV_LIMIT,
           EXP_AMT,
           EXP_MON
    from dual;
    commit;


    set VV_TASK = '删除历史数据';
    delete from data_transaction_perdu_debt where APPLY_ID = APPLYID AND AREA_CODE = AREACODE;
    commit;

    set VV_TASK = '将变量重新赋值';
    set VV_MON1 = '';
    set VV_MON2 = '';
    set VV_LIMIT = 0;
    set EXP_AMT = 0;
    set EXP_MON = 0;


    set VV_TASK = '将对私账户中 贷款类隐形负债流水明细 入中间表';
    insert into data_transaction_perdu_debt
    select *
    from data_transaction_detail
    where (concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%贷款还款%' or
           concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%还贷%' or
           concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%贷款到期归还%'
        or concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%归还贷款%' or
           concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%代收%' or
           concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%正常还款%'
        )
      and ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh')
      and ACCOUNT_TYPE = 1
      and EXPEND_AMOUNT > 0
      and APPLY_ID = APPLYID
      and AREA_CODE = AREACODE;
    commit;

    set VV_TASK = '取得 流水日期近2个月月份';
    select substr(TRADE_DATE, 1, 7)
    into VV_MON1
    from data_transaction_perdu_debt
    where APPLY_ID = APPLYID
    order by substr(TRADE_DATE, 1, 7) desc
    limit 1;
    select substr(TRADE_DATE, 1, 7)
    into VV_MON2
    from data_transaction_perdu_debt
    where APPLY_ID = APPLYID
      and substr(TRADE_DATE, 1, 7) <> VV_MON1
    order by substr(TRADE_DATE, 1, 7) desc
    limit 1;


    set VV_TASK = '取得 流水日期近2个月记录数中最小值';
    select case
               when count(distinct a.TRADE_DATE) > count(distinct b.TRADE_DATE) then count(distinct b.TRADE_DATE)
               else count(distinct a.TRADE_DATE) end
    into VV_LIMIT
    from data_transaction_perdu_debt a,
         (select *
          from data_transaction_perdu_debt b
          where substr(b.TRADE_DATE, 1, 7) = VV_MON2 and b.APPLY_ID = APPLYID) b
    where abs(a.EXPEND_AMOUNT - b.EXPEND_AMOUNT) <= 100
      and abs(substr(a.TRADE_DATE, 9, 2) - substr(b.TRADE_DATE, 9, 2)) <= 3
      and substr(a.TRADE_DATE, 1, 7) = VV_MON1
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE;


    set VV_TASK = '贷款类流水隐性负债每月还款额';
    select round(sum(EXPEND_AMOUNT), 2)
    into EXP_AMT
    from (
             select TRADE_DATE, EXPEND_AMOUNT, min(abs(EXPEND_AMOUNT - EXPEND_AMOUNT1)) as AMT
             from (
                      select a.TRADE_DATE,
                             a.EXPEND_AMOUNT,
                             b.TRADE_DATE    as TRADE_DATE1,
                             b.EXPEND_AMOUNT as EXPEND_AMOUNT1
                      from data_transaction_perdu_debt a,
                           (select *
                            from data_transaction_perdu_debt b
                            where substr(b.TRADE_DATE, 1, 7) = VV_MON2 and b.APPLY_ID = APPLYID) b
                      where abs(a.EXPEND_AMOUNT - b.EXPEND_AMOUNT) <= 100
                        and abs(substr(a.TRADE_DATE, 9, 2) - substr(b.TRADE_DATE, 9, 2)) <= 3
                        and substr(a.TRADE_DATE, 1, 7) = VV_MON1
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                  ) t
             group by TRADE_DATE, EXPEND_AMOUNT
         ) tt
    order by AMT
    limit VV_LIMIT;

    set VV_TASK = '贷款类流水隐性负债已还款月数';
    select count(distinct substr(TRADE_DATE, 1, 7))
    into EXP_MON
    from data_transaction_perdu_debt
    where APPLY_ID = APPLYID
      and AREA_CODE = AREACODE;

    set VV_TASK = '贷款类流水隐性负债信息汇总';
    insert into data_bill_perdu_debt
    select APPLYID,
           IDCARD,
           PTYPE,
           AREACODE,
           CURRENT_TIMESTAMP,
           1,
           2,
           VV_LIMIT,
           EXP_AMT,
           EXP_MON
    from dual;
    commit;


END;

