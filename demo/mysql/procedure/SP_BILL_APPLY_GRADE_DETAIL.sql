create
    definer = root@`%` procedure SP_BILL_APPLY_GRADE_DETAIL(IN APPLYID varchar(100), IN IDCARD varchar(20),
                                                            IN PTYPE varchar(10), IN AREACODE varchar(30))
BEGIN
    DECLARE VV_TASK VARCHAR(200);
    DECLARE VV_RN1 INT(8);
    DECLARE VV_RN2 INT(8);
    DECLARE VV_RN3 INT(8);
    DECLARE VV_AMT1 DECIMAL(15, 2);
    DECLARE VV_AMT2 DECIMAL(15, 2);
    DECLARE VV_AMT3 DECIMAL(15, 2);

    set VV_TASK = '删除指标表数据';
    delete
    from DATA_BILL_APPLY_GRADE_DETAIL
    where APPLY_ID = APPLYID
      AND ID_CARD = IDCARD
      AND TYPE = PTYPE
      AND AREA_CODE = AREACODE;
    commit;
    set VV_TASK = '删除临时表数据';
    delete
    from DATA_BILL_APPLY_GRADE_DETAIL_TEMP
    where APPLY_ID = APPLYID
      AND ID_CARD = IDCARD
      AND TYPE = PTYPE
      AND AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '删除关系人表数据';
    delete
    from data_bill_apply_rela
    where APPLY_ID = APPLYID
      AND ID_CARD = IDCARD
      AND TYPE = PTYPE
      AND AREA_CODE = AREACODE;
    commit;

    set VV_TASK = '将申请人的关系人姓名插入关联人表';
    insert into data_bill_apply_rela
    select APPLYID   as APPLY_ID,
           IDCARD    as ID_CARD,
           PTYPE     as TYPE,
           AREACODE  as AREA_CODE,
           CORP_NAME as CUST_NAME,
           2         as CUST_TYPE
    from zw_xwd_ls_corp_info
    where APPLY_ID = APPLYID
      AND AREA_CODE = AREACODE
      and ID_CARD in (
        select MEMBER_ID_CARD
        from cust_family_mx
        where APPLY_RELATION in (1, 2)
          and SEQ_NO = APPLYID
          and ID_CARD = IDCARD
          and TYPE = PTYPE
          and AREA_CODE = AREACODE
          and MEMBER_ID_CARD <> IDCARD
    )
    union
    select APPLYID     as APPLY_ID,
           IDCARD      as ID_CARD,
           PTYPE       as TYPE,
           AREACODE    as AREA_CODE,
           MEMBER_NAME AS CUST_NAME,
           1           AS CUST_TYPE
    from cust_family_mx
    where SEQ_NO = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE
      and MEMBER_ID_CARD <> IDCARD;
    commit;


    set VV_TASK = '将各项收入之和插入临时表';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, INC_AMT)
    select APPLYID            as APPLY_ID,
           IDCARD             as ID_CARD,
           PTYPE              as TYPE,
           AREACODE           as AREA_CODE,
           sum(INCOME_AMOUNT) as INC_AMT
    from data_transaction_detail
    where date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and APPLY_ID = APPLYID
      and AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '调用 经营性收入计算函数';
    call SP_BILL_APPLY_GRADE_INCOME(APPLYID, IDCARD, PTYPE, AREACODE);
    set VV_TASK = '将经营性总收入、有效交易日数、流水期间日数、交易活跃度 入临时表 ';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BUS_INC_AMT, VALID_BILL_DAYS,
                                                  BILL_DAYS, TRANS_ACTIVE_RATE)
    select APPLYID                                                             as APPLY_ID,
           IDCARD                                                              as ID_CARD,
           PTYPE                                                               as TYPE,
           AREACODE                                                            as AREA_CODE,
           BUS_INC_AMT,
           VALID_BILL_DAYS,
           BILL_DAYS,
           case when BILL_DAYS = 0 then 0 else VALID_BILL_DAYS / BILL_DAYS end as TRANS_ACTIVE_RATE
    from DATA_BILL_APPLY_GRADE_INCOME
    where APPLY_ID = APPLYID
      AND ID_CARD = IDCARD
      AND TYPE = PTYPE
      AND AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '调用 月度经营性收入总额、交易笔数变异函数';
    call SP_BILL_APPLY_GRADE_STD(APPLYID, IDCARD, PTYPE, AREACODE);
    set VV_TASK = '将 月度经营性收入总额标准差、均值、交易笔数标准差、均值 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BUS_INCOME_MON_STD,
                                                  BUS_INCOME_MON_AVG, BILL_CNT_MON_STD, BILL_CNT_MON_AVG)
    select APPLYID                        as APPLY_ID,
           IDCARD                         as ID_CARD,
           PTYPE                          as TYPE,
           AREACODE                       as AREA_CODE,
           std(bus_inc_amt)               as BUS_INCOME_MON_STD,
           sum(bus_inc_amt) / count(1)    as BUS_INCOME_MON_AVG,
           std(VALID_BILL_CNT)            as BILL_CNT_MON_STD,
           sum(VALID_BILL_CNT) / count(1) as BILL_CNT_MON_AVG
    from data_bill_apply_grade_std
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '月度经营性收入总额最大前3个月的收入总和';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BUS_AMT_MON_THREE)
    select APPLYID          as APPLY_ID,
           IDCARD           as ID_CARD,
           PTYPE            as TYPE,
           AREACODE         as AREA_CODE,
           sum(BUS_INC_AMT) as BUS_AMT_MON_THREE
    from (
             select *
             from data_bill_apply_grade_std
             where APPLY_ID = APPLYID
               and ID_CARD = IDCARD
               and TYPE = PTYPE
               and AREA_CODE = AREACODE
             order by BUS_INC_AMT desc
             limit 3
         ) t;
    commit;


    set VV_TASK = '调用客户集中度函数';
    call SP_BILL_APPLY_GRADE_FOCUS(APPLYID, IDCARD, PTYPE, AREACODE);
    set VV_TASK = '经营性收入总额前5大客户收入总和';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BUS_INC_FIVE_AMT)
    select APPLYID          as APPLY_ID,
           IDCARD           as ID_CARD,
           PTYPE            as TYPE,
           AREACODE         as AREA_CODE,
           sum(BUS_INC_AMT) as BUS_INC_FIVE_AMT
    from (
             select *
             from DATA_BILL_APPLY_GRADE_FOCUS
             where OPP_NAME is not null
               and APPLY_ID = APPLYID
               and ID_CARD = IDCARD
               and TYPE = PTYPE
               and AREA_CODE = AREACODE
             order by BUS_INC_AMT desc
             limit 5) t;
    commit;


    set VV_TASK = '经营性收入交易笔数前5大客户总笔数';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BUS_BILL_FIVE_CNT)
    select APPLYID             as APPLY_ID,
           IDCARD              as ID_CARD,
           PTYPE               as TYPE,
           AREACODE            as AREA_CODE,
           sum(VALID_BILL_CNT) as BUS_BILL_FIVE_CNT
    from (select *
          from DATA_BILL_APPLY_GRADE_FOCUS
          where OPP_NAME is not null
            and OPP_NAME <> ''
            and APPLY_ID = APPLYID
            and ID_CARD = IDCARD
            and TYPE = PTYPE
            and AREA_CODE = AREACODE
          order by VALID_BILL_CNT desc
          limit 5
         ) t;
    commit;


    set VV_TASK = '经营性收入交易总笔数';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BUS_BILL_CNT)
    select APPLYID             as APPLY_ID,
           IDCARD              as ID_CARD,
           PTYPE               as TYPE,
           AREACODE            as AREA_CODE,
           sum(VALID_BILL_CNT) as BUS_BILL_CNT
    from DATA_BILL_APPLY_GRADE_FOCUS
    where OPP_NAME is not null
      and OPP_NAME <> ''
      and APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '3.2.8 交易流水循环指数';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, CIRCLE_AMT)
    select APPLYID                                                        as APPLY_ID,
           IDCARD                                                         as ID_CARD,
           PTYPE                                                          as TYPE,
           AREACODE                                                       as AREA_CODE,
           sum(case when EXP_AMT > INC_AMT then INC_AMT else EXP_AMT end) as CIRCLE_AMT
    from (
             select a.OTHER_NAME,
                    sum(a.EXPEND_AMOUNT) EXP_AMT,
                    b.INC_AMT
             from data_transaction_detail a
                      join (
                 select OTHER_NAME, sum(INCOME_AMOUNT) as INC_AMT
                 from data_transaction_detail t1
                          LEFT JOIN data_bill_apply_rela t2
                                    on t1.OTHER_NAME = t2.CUST_NAME and t2.APPLY_ID = APPLYID and
                                       t2.ID_CARD = IDCARD and t2.TYPE = PTYPE and t2.AREA_CODE = AREACODE
                 where date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                   and t1.OTHER_NAME is not null
                   and t2.CUST_NAME is null
                   and t1.APPLY_ID = APPLYID
                   and t1.AREA_CODE = AREACODE
                 group by t1.OTHER_NAME
                 ORDER BY INC_AMT desc
                 limit 10
             ) b on a.OTHER_NAME = b.OTHER_NAME

             where date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
               and a.OTHER_NAME is not null
               and EXPEND_AMOUNT > 50000
               and APPLY_ID = APPLYID
               and AREA_CODE = AREACODE
             group by a.OTHER_NAME, b.INC_AMT
             order by b.INC_AMT desc
         ) t
    where round(EXP_AMT / INC_AMT, 2) > 0.3;
    commit;


    set VV_TASK = '3.2.9日均存款余额';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, DEPOSIT_AMT)
    select APPLYID                         as APPLY_ID,
           IDCARD                          as ID_CARD,
           PTYPE                           as TYPE,
           AREACODE                        as AREA_CODE,
           round(sum(amt / cnt) * 1158, 2) as DEPOSIT_AMT
    from (
             select ORG_CODE,
                    sum(INCOME_AMOUNT) as amt,
                    count(1)           as cnt
             from data_transaction_detail
             where substr(TRADE_DATE, 6, 2) in ('03', '06', '09', '12')
               and substr(TRADE_DATE, 9, 2) in ('20', '21')
               and (concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%结息%' or
                    concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%利息%'
                 or (length(INCOME_AMOUNT) - length(SUBSTRING_INDEX(INCOME_AMOUNT, '.', 1))) = 3 and
                    INCOME_AMOUNT <= 300)
               and date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
               and ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh')
               and APPLY_ID = APPLYID
               and AREA_CODE = AREACODE
             group by ORG_CODE
         ) t;
    commit;


    set VV_TASK = '调用经营性收入金额变化趋势 函数';
    call SP_BILL_APPLY_GRADE_TREND(APPLYID, IDCARD, PTYPE, AREACODE);

    set VV_TASK = '计算三分位序号';
    select round(max(RN) / 3)
    into VV_RN1
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select round(2 * max(RN) / 3)
    into VV_RN2
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select round(3 * max(RN) / 3)
    into VV_RN3
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;

    select max(BUS_INC_AMT)
    into VV_AMT1
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE
      and RN <= VV_RN1;
    select max(BUS_INC_AMT)
    into VV_AMT2
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE
      and RN > VV_RN1
      AND RN <= VV_RN2;
    select max(BUS_INC_AMT)
    into VV_AMT3
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE
      and RN > VV_RN2
      AND RN <= VV_RN3;

    set VV_TASK = '将经营性收入变化趋势 入临时表';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, TREND_FLAG)
    select APPLYID  as                                                         APPLY_ID,
           IDCARD   as                                                         ID_CARD,
           PTYPE    as                                                         TYPE,
           AREACODE as                                                         AREA_CODE,
           case when VV_AMT1 > VV_AMT2 and VV_AMT2 > VV_AMT3 then 1 else 0 end TREND_FLAG
    from dual;
    commit;


    set VV_TASK = '删除隐性负债表历史数据';
    delete
    from data_bill_perdu_debt
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    commit;
    set VV_TASK = '调用对私隐性负债流水信息';
    call SP_BILL_APPLY_GRADE_DEBT_PRI(APPLYID, IDCARD, PTYPE, AREACODE);
    set VV_TASK = '调用对公隐性负债流水信息';
    call SP_BILL_APPLY_GRADE_DEBT_PUB(APPLYID, IDCARD, PTYPE, AREACODE);
    set VV_TASK = '获取隐性负债笔数和金额信息';
    insert into DATA_BILL_APPLY_GRADE_DETAIL_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, PERDU_DEBT_CNT, PERDU_DEBT_AMT)
    select APPLYID       as                                                                       APPLY_ID,
           IDCARD        as                                                                       ID_CARD,
           PTYPE         as                                                                       TYPE,
           AREACODE      as                                                                       AREA_CODE,
           sum(DEBT_CNT) as                                                                       PERDU_DEBT_CNT,
           sum(case when ACCOUNT_TYPE = 1 then EXP_AMT * (36 - EXP_MON) else EXP_AMT / 0.012 end) PERDU_DEBT_AMT
    from data_bill_perdu_debt
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '将 临时表数据汇总';
    insert into DATA_BILL_APPLY_GRADE_DETAIL(APPLY_ID, ID_CARD, TYPE, AREA_CODE, UPDATE_TIME, INC_AMT, BUS_INC_AMT,
                                             VALID_BILL_DAYS, BILL_DAYS, BUS_INCOME_MON_STD, BUS_INCOME_MON_AVG,
                                             BILL_CNT_MON_STD, BILL_CNT_MON_AVG, BUS_AMT_MON_THREE, BUS_INC_FIVE_AMT,
                                             BUS_BILL_FIVE_CNT, BUS_BILL_CNT, CIRCLE_AMT, DEPOSIT_AMT, TREND_FLAG,
                                             PERDU_DEBT_CNT, PERDU_DEBT_AMT)
    select APPLY_ID,
           ID_CARD,
           TYPE,
           AREA_CODE,
           CURRENT_TIMESTAMP as UPDATE_TIME,
           max(ifnull(INC_AMT, 0)),
           max(ifnull(BUS_INC_AMT, 0)),
           max(ifnull(VALID_BILL_DAYS, 0)),
           max(ifnull(BILL_DAYS, 0)),
           max(ifnull(BUS_INCOME_MON_STD, 0)),
           max(ifnull(BUS_INCOME_MON_AVG, 0)),
           max(ifnull(BILL_CNT_MON_STD, 0)),
           max(ifnull(BILL_CNT_MON_AVG, 0)),
           max(ifnull(BUS_AMT_MON_THREE, 0)),
           max(ifnull(BUS_INC_FIVE_AMT, 0)),
           max(ifnull(BUS_BILL_FIVE_CNT, 0)),
           max(ifnull(BUS_BILL_CNT, 0)),
           max(ifnull(CIRCLE_AMT, 0)),
           max(ifnull(DEPOSIT_AMT, 0)),
           max(ifnull(TREND_FLAG, 0)),
           max(ifnull(PERDU_DEBT_CNT, 0)),
           max(ifnull(PERDU_DEBT_AMT, 0))
    from DATA_BILL_APPLY_GRADE_DETAIL_TEMP
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;

    commit;


    set VV_TASK = '更新部分字段值';

    update DATA_BILL_APPLY_GRADE_DETAIL
    set TRANS_ACTIVE_RATE   = (case when BILL_DAYS = 0 then 0 else round(VALID_BILL_DAYS / BILL_DAYS, 2) end),
        BUS_INCOME_MON_RATE = (case
                                   when BUS_INCOME_MON_AVG = 0 then 0
                                   else round(BUS_INCOME_MON_STD / BUS_INCOME_MON_AVG, 2) end),
        BILL_CNT_MON_RATE   = (case
                                   when BILL_CNT_MON_AVG = 0 then 0
                                   else round(BILL_CNT_MON_STD / BILL_CNT_MON_AVG, 2) end),
        BUS_AMT_MON_RATE    = (case when BUS_INC_AMT = 0 then 0 else round(BUS_AMT_MON_THREE / BUS_INC_AMT, 2) end),
        BUS_INC_FIVE_RATE   = (case when BUS_INC_AMT = 0 then 0 else round(BUS_INC_FIVE_AMT / BUS_INC_AMT, 2) end),
        BUS_BILL_FIVE_RATE  = (case when BUS_BILL_CNT = 0 then 0 else round(BUS_BILL_FIVE_CNT / BUS_BILL_CNT, 2) end),
        SALE_AMT            = (BUS_INC_AMT - CIRCLE_AMT)

    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;

    commit;


    update DATA_BILL_APPLY_GRADE_DETAIL
    set CIRCLE_RATE =(case when INC_AMT = 0 then 0 else (INC_AMT - SALE_AMT) / INC_AMT end)

    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    commit;


END;

