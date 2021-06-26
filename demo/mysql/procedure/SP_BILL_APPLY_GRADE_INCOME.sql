create
    definer = root@`%` procedure SP_BILL_APPLY_GRADE_INCOME(IN APPLYID varchar(100), IN IDCARD varchar(20),
                                                            IN PTYPE varchar(10), IN AREACODE varchar(30))
BEGIN
    DECLARE VV_TASK VARCHAR(100);


    set VV_TASK = '删除指标表数据';
    delete
    from DATA_BILL_APPLY_GRADE_INCOME
    where APPLY_ID = APPLYID AND ID_CARD = IDCARD AND TYPE = PTYPE AND AREA_CODE = AREACODE;
    commit;
    set VV_TASK = '删除临时表数据';
    delete
    from DATA_BILL_APPLY_GRADE_INCOME_TEMP
    where APPLY_ID = APPLYID
      AND ID_CARD = IDCARD
      AND TYPE = PTYPE
      AND AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '将 收入总额、关系人收入总额、关系人支出总额 插入临时表';

    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE,
                                                  CARD_INC_AMT, CARD_INC_RELA_AMT, CARD_EXP_RELA_AMT,
                                                  ALIPAYSH_INC_AMT, ALIPAYSH_INC_RELA_AMT, ALIPAYSH_EXP_RELA_AMT,
                                                  ALIPAY_INC_AMT, ALIPAY_INC_RELA_AMT, ALIPAY_EXP_RELA_AMT,
                                                  WECHATSH_INC_AMT, WECHATSH_INC_RELA_AMT, WECHATSH_EXP_RELA_AMT,
                                                  WECHAT_INC_AMT, WECHAT_INC_RELA_AMT, WECHAT_EXP_RELA_AMT)
    select APPLYID as                                                                APPLY_ID,
           IDCARD as                                                                 ID_CARD,
           PTYPE as                                                                  TYPE,
           AREACODE as                                                               AREA_CODE,
           sum(case
                   when a.ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh') then a.INCOME_AMOUNT
                   else 0 end) as                                                    CARD_INC_AMT,
           sum(case
                   when a.ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh') and b.CUST_NAME is not null
                       then a.INCOME_AMOUNT
                   else 0 end) as                                                    CARD_INC_RELA_AMT,
           sum(case
                   when a.ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh') and b.CUST_NAME is not null
                       then a.EXPEND_AMOUNT
                   else 0 end) as                                                    CARD_EXP_RELA_AMT,

           sum(case when a.ORG_CODE = 'alipaysh' then a.INCOME_AMOUNT else 0 end) as ALIPAYSH_INC_AMT,
           sum(case
                   when a.ORG_CODE = 'alipaysh' and b.CUST_NAME is not null then a.INCOME_AMOUNT
                   else 0 end) as                                                    ALIPAYSH_INC_RELA_AMT,
           sum(case
                   when a.ORG_CODE = 'alipaysh' and b.CUST_NAME is not null then a.EXPEND_AMOUNT
                   else 0 end) as                                                    ALIPAYSH_EXP_RELA_AMT,

           sum(case when a.ORG_CODE = 'alipay' then a.INCOME_AMOUNT else 0 end) as   ALIPAY_INC_AMT,
           sum(case
                   when a.ORG_CODE = 'alipay' and b.CUST_NAME is not null then a.INCOME_AMOUNT
                   else 0 end) as                                                    ALIPAY_INC_RELA_AMT,
           sum(case
                   when a.ORG_CODE = 'alipay' and b.CUST_NAME is not null then a.EXPEND_AMOUNT
                   else 0 end) as                                                    ALIPAY_EXP_RELA_AMT,

           sum(case when a.ORG_CODE = 'wechatsh' then a.INCOME_AMOUNT else 0 end) as WECHATSH_INC_AMT,
           sum(case
                   when a.ORG_CODE = 'wechatsh' and b.CUST_NAME is not null then a.INCOME_AMOUNT
                   else 0 end) as                                                    WECHATSH_INC_RELA_AMT,
           sum(case
                   when a.ORG_CODE = 'wechatsh' and b.CUST_NAME is not null then a.EXPEND_AMOUNT
                   else 0 end) as                                                    WECHATSH_EXP_RELA_AMT,

           sum(case when a.ORG_CODE = 'wechat' then a.INCOME_AMOUNT else 0 end) as   WECHAT_INC_AMT,
           sum(case
                   when a.ORG_CODE = 'wechat' and b.CUST_NAME is not null then a.INCOME_AMOUNT
                   else 0 end) as                                                    WECHAT_INC_RELA_AMT,
           sum(case
                   when a.ORG_CODE = 'wechat' and b.CUST_NAME is not null then a.EXPEND_AMOUNT
                   else 0 end) as                                                    WECHAT_EXP_RELA_AMT

    from data_transaction_detail a
             LEFT JOIN data_bill_apply_rela b
                       on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and b.ID_CARD = IDCARD and
                          b.TYPE = PTYPE and b.AREA_CODE = AREACODE
    where date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE;

    commit;


    set VV_TASK = '将 银行卡异常收入总额 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, CARD_INC_ABNORMAL_AMT)
    select APPLYID                    as APPLY_ID,
           IDCARD                     as ID_CARD,
           PTYPE                      as TYPE,
           AREACODE                   as AREA_CODE,
           sum(CARD_INC_ABNORMAL_AMT) as CARD_INC_ABNORMAL_AMT
    from (
             select sum(INCOME_AMOUNT) as CARD_INC_ABNORMAL_AMT
             from (
                      select INCOME_AMOUNT,
                             OTHER_NAME,
                             concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) as REMARK
                      from data_transaction_detail a
                               LEFT JOIN data_bill_apply_rela b
                                         on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and
                                            b.ID_CARD = IDCARD and b.TYPE = PTYPE and b.AREA_CODE = AREACODE
                      where ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh')
                        and date_format(TRADE_DATE, '%Y%m%d') >=
                            date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                        and b.CUST_NAME is null
                  ) t
             where OTHER_NAME like '%银行%'
                or OTHER_NAME like '%小额贷款%'
                or OTHER_NAME like '%小贷%'
                or OTHER_NAME like '%担保%'
                or OTHER_NAME like '%融资租赁%'
                or OTHER_NAME like '%P2P%'
                or REMARK like '%贷款发放%'
         ) tt;

    commit;


    set VV_TASK = '将 银行卡提现收入总额 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, CARD_INC_WITHDRAW_AMT)
    select APPLYID            as APPLY_ID,
           IDCARD             as ID_CARD,
           PTYPE              as TYPE,
           AREACODE           as AREA_CODE,
           sum(INCOME_AMOUNT) as CARD_INC_WITHDRAW_AMT
    from data_transaction_detail a
             LEFT JOIN data_bill_apply_rela b
                       on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and b.ID_CARD = IDCARD and
                          b.TYPE = PTYPE and b.AREA_CODE = AREACODE
    where ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh')
      and date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%提现%'
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE
      and b.CUST_NAME is null;

    commit;


    set VV_TASK = '将 支付宝商户收费支出总金额 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, ALIPAYSH_EXP_AMT)
    select APPLYID            as APPLY_ID,
           IDCARD             as ID_CARD,
           PTYPE              as TYPE,
           AREACODE           as AREA_CODE,
           sum(EXPEND_AMOUNT) as ALIPAYSH_EXP_AMT
    from data_transaction_detail a
             LEFT JOIN data_bill_apply_rela b
                       on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and b.ID_CARD = IDCARD and
                          b.TYPE = PTYPE and b.AREA_CODE = AREACODE
    where ORG_CODE = 'alipaysh'
      and date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%收费%'
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE
      and b.CUST_NAME is null;

    commit;

    set VV_TASK = '将 支付宝个人退款金额 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, ALIPAY_REFUND_AMT)
    select APPLYID            as APPLY_ID,
           IDCARD             as ID_CARD,
           PTYPE              as TYPE,
           AREACODE           as AREA_CODE,
           sum(INCOME_AMOUNT) as ALIPAY_REFUND_AMT
    from data_transaction_detail a
             LEFT JOIN data_bill_apply_rela b
                       on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and b.ID_CARD = IDCARD and
                          b.TYPE = PTYPE and b.AREA_CODE = AREACODE
    where ORG_CODE = 'alipay'
      and date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%退款成功%'
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE
      and b.CUST_NAME is null;

    commit;


    set VV_TASK = '将 微信商户扣除交易费用、退款金额 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, WECHATSH_SERVICE_AMT,
                                                  WECHATSH_REFUND_AMT)
    select APPLYID                                                                                                    as APPLY_ID,
           IDCARD                                                                                                     as ID_CARD,
           PTYPE                                                                                                      as TYPE,
           AREACODE                                                                                                   as AREA_CODE,
           sum(case
                   when concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%扣除交易费用%' then EXPEND_AMOUNT
                   else 0 end)                                                                                        as WECHATSH_SERVICE_AMT,
           sum(case
                   when concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) like '%退款%' then EXPEND_AMOUNT
                   else 0 end)                                                                                        as WECHATSH_REFUND_AMT
    from data_transaction_detail a
             LEFT JOIN data_bill_apply_rela b
                       on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and b.ID_CARD = IDCARD and
                          b.TYPE = PTYPE and b.AREA_CODE = AREACODE
    where ORG_CODE = 'alipaysh'
      and date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE
      and b.CUST_NAME is null;

    commit;


    set VV_TASK = '将 有效交易日 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, VALID_BILL_DAYS)
    select APPLYID         as APPLY_ID,
           IDCARD          as ID_CARD,
           PTYPE           as TYPE,
           AREACODE        as AREA_CODE,
           sum(VALID_FLAG) as VALID_BILL_DAYS
    from (
             select TRADE_DATE, max(VALID_FLAG) as VALID_FLAG
             from (
                      select TRADE_DATE,
                             case when b.CUST_NAME is null then 1 else 0 end as VALID_FLAG
                      from data_transaction_detail a
                               left join data_bill_apply_rela b
                                         on a.OTHER_NAME = b.CUST_NAME and b.APPLY_ID = APPLYID and
                                            b.ID_CARD = IDCARD and b.TYPE = PTYPE and b.AREA_CODE = AREACODE
                      where a.ORG_CODE not in ('alipay', 'alipaysh', 'wechat', 'wechatsh')
                        and date_format(TRADE_DATE, '%Y%m%d') >=
                            date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                      union all
                      select TRADE_DATE,
                             case when b.CUST_NAME is null then 1 else 0 end as VALID_FLAG
                      from data_transaction_detail a
                               left join data_bill_apply_rela b
                                         on a.OTHER_NAME = b.CUST_NAME and b.CUST_TYPE = 1 and b.APPLY_ID = APPLYID and
                                            b.ID_CARD = IDCARD and b.TYPE = PTYPE and b.AREA_CODE = AREACODE
                      where a.ORG_CODE = 'alipaysh'
                        and date_format(TRADE_DATE, '%Y%m%d') >=
                            date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                      union all
                      select TRADE_DATE,
                             case
                                 when b.CUST_NAME is null and
                                      concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) not like '%退款成功%' then 1
                                 else 0 end as VALID_FLAG
                      from data_transaction_detail a
                               left join data_bill_apply_rela b
                                         on a.OTHER_NAME = b.CUST_NAME and b.CUST_TYPE = 1 and b.APPLY_ID = APPLYID and
                                            b.ID_CARD = IDCARD and b.TYPE = PTYPE and b.AREA_CODE = AREACODE
                      where a.ORG_CODE = 'alipay'
                        and date_format(TRADE_DATE, '%Y%m%d') >=
                            date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                      union all
                      select TRADE_DATE,
                             case
                                 when b.CUST_NAME is null and
                                      concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) not like '%扣除交易费用%' and
                                      concat_ws('', REMARK, POSTSCRIPT, TRADE_TYPE) not like '%退款%' then 1
                                 else 0 end as VALID_FLAG
                      from data_transaction_detail a
                               left join data_bill_apply_rela b
                                         on a.OTHER_NAME = b.CUST_NAME and b.CUST_TYPE = 1 and b.APPLY_ID = APPLYID and
                                            b.ID_CARD = IDCARD and b.TYPE = PTYPE and b.AREA_CODE = AREACODE
                      where a.ORG_CODE = 'wechatsh'
                        and date_format(TRADE_DATE, '%Y%m%d') >=
                            date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                        and a.APPLY_ID = APPLYID
                        and a.AREA_CODE = AREACODE
                  ) t
             group by TRADE_DATE
         ) t;

    commit;

    set VV_TASK = '将 流水期间日 插入临时表';
    insert into DATA_BILL_APPLY_GRADE_INCOME_TEMP(APPLY_ID, ID_CARD, TYPE, AREA_CODE, BILL_DAYS)
    select APPLYID                                               as APPLY_ID,
           IDCARD                                                as ID_CARD,
           PTYPE                                                 as TYPE,
           AREACODE                                              as AREA_CODE,
           timestampdiff(day, min(TRADE_DATE), max(CREATE_TIME)) as BILL_DAYS
    from data_transaction_detail a
    where date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
      and a.APPLY_ID = APPLYID
      and a.AREA_CODE = AREACODE;

    commit;


    set VV_TASK = '将 临时表数据汇总';
    insert into DATA_BILL_APPLY_GRADE_INCOME
    select APPLY_ID,
           ID_CARD,
           TYPE,
           AREA_CODE,
           CURRENT_TIMESTAMP as UPDATE_TIME,
           max(ifnull(CARD_INC_AMT, 0)),
           max(ifnull(CARD_INC_RELA_AMT, 0)),
           max(ifnull(CARD_EXP_RELA_AMT, 0)),
           max(ifnull(CARD_INC_ABNORMAL_AMT, 0)),
           max(ifnull(CARD_INC_WITHDRAW_AMT, 0)),
           max(ifnull(ALIPAYSH_INC_AMT, 0)),
           max(ifnull(ALIPAYSH_INC_RELA_AMT, 0)),
           max(ifnull(ALIPAYSH_EXP_RELA_AMT, 0)),
           max(ifnull(ALIPAYSH_EXP_AMT, 0)),
           max(ifnull(ALIPAY_INC_AMT, 0)),
           max(ifnull(ALIPAY_INC_RELA_AMT, 0)),
           max(ifnull(ALIPAY_EXP_RELA_AMT, 0)),
           max(ifnull(ALIPAY_REFUND_AMT, 0)),
           max(ifnull(WECHATSH_INC_AMT, 0)),
           max(ifnull(WECHATSH_INC_RELA_AMT, 0)),
           max(ifnull(WECHATSH_EXP_RELA_AMT, 0)),
           max(ifnull(WECHATSH_SERVICE_AMT, 0)),
           max(ifnull(WECHATSH_REFUND_AMT, 0)),
           max(ifnull(WECHAT_INC_AMT, 0)),
           max(ifnull(WECHAT_INC_RELA_AMT, 0)),
           max(ifnull(WECHAT_EXP_RELA_AMT, 0)),
           null              as BUS_INC_AMT,
           max(ifnull(VALID_BILL_DAYS, 0)),
           max(ifnull(BILL_DAYS, 0))
    from DATA_BILL_APPLY_GRADE_INCOME_TEMP
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;

    commit;


    set VV_TASK = '计算月度经营性总收入';
    update DATA_BILL_APPLY_GRADE_INCOME
    set BUS_INC_AMT =
                                            CARD_INC_AMT - CARD_INC_RELA_AMT - CARD_INC_ABNORMAL_AMT -
                                            CARD_INC_WITHDRAW_AMT + (case
                                                                         when CARD_INC_RELA_AMT - CARD_EXP_RELA_AMT > 0
                                                                             then CARD_INC_RELA_AMT - CARD_EXP_RELA_AMT
                                                                         else 0 end)
                                        +
                                            ALIPAYSH_INC_AMT - ALIPAYSH_INC_RELA_AMT - ALIPAYSH_EXP_AMT
                                +
                                            ALIPAY_INC_AMT - ALIPAY_INC_RELA_AMT - ALIPAY_REFUND_AMT + (case
                                                                                                            when ALIPAY_INC_RELA_AMT - ALIPAY_EXP_RELA_AMT > 0
                                                                                                                then ALIPAY_INC_RELA_AMT - ALIPAY_EXP_RELA_AMT
                                                                                                            else 0 end)
                        +
                                            WECHATSH_INC_AMT - WECHATSH_SERVICE_AMT - WECHATSH_REFUND_AMT
                + (WECHAT_INC_AMT * 0.5)
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;

    commit;


END;

