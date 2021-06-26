create
    definer = root@`%` procedure SP_BILL_APPLY_GRADE_TREND(IN APPLYID varchar(100), IN IDCARD varchar(20),
                                                           IN PTYPE varchar(10), IN AREACODE varchar(30))
BEGIN
    DECLARE VV_TASK VARCHAR(100);
    DECLARE VV_MIN_DATE VARCHAR(20);
    DECLARE VV_MAX_DATE VARCHAR(20);
    DECLARE VV_START_MON VARCHAR(20);
    DECLARE VV_END_MON VARCHAR(20);
    DECLARE vi_date VARCHAR(20);
    DECLARE VV_START VARCHAR(20);
    DECLARE VV_END VARCHAR(20);
    DECLARE VV_RN INT(8);

    set VV_TASK = '删除标准化历史流水';
    delete from data_transaction_detail_trend where APPLY_ID = APPLYID AND AREA_CODE = AREACODE;
    commit;

    set VV_TASK = '删除指标表历史数据';
    delete
    from data_bill_apply_grade_trend
    where APPLY_ID = APPLYID AND ID_CARD = IDCARD AND TYPE = PTYPE AND AREA_CODE = AREACODE;
    commit;


    set VV_TASK = '取得标准化流水';
    insert into data_transaction_detail_trend
    select t1.*
    from data_transaction_detail t1,
         (select t.ORG_CODE, t.ACCOUNT, START_DATE, END_DATE
          from (
                   select ORG_CODE,
                          ACCOUNT,
                          min(TRADE_DATE) START_DATE,
                          max(TRADE_DATE) END_DATE
                   from data_transaction_detail a
                   where date_format(TRADE_DATE, '%Y%m%d') >= date_format(DATE_SUB(now(), INTERVAL 12 month), '%Y%m%d')
                     and a.APPLY_ID = APPLYID
                     and a.AREA_CODE = AREACODE
                   group by ORG_CODE, ACCOUNT
               ) t
          where TIMESTAMPDIFF(month, START_DATE, END_DATE) >= 3
         ) t2
    where t1.ORG_CODE = t2.ORG_CODE
      and ifnull(t1.ACCOUNT, 0) = ifnull(t2.ACCOUNT, 0)
      and t1.TRADE_DATE >= t2.START_DATE
      and t1.TRADE_DATE <= t2.END_DATE
      and t1.APPLY_ID = APPLYID
      and t1.AREA_CODE = AREACODE;

    commit;


    set VV_TASK = '取得标准化流水中 流水最小开始时间、最大结束时间';
    select min(TRADE_DATE)
    into VV_MIN_DATE
    from data_transaction_detail_trend
    where APPLY_ID = APPLYID
      and AREA_CODE = AREACODE;
    select max(TRADE_DATE)
    into VV_MAX_DATE
    from data_transaction_detail_trend
    where APPLY_ID = APPLYID
      and AREA_CODE = AREACODE;

    set VV_TASK = '取流水最小月份作为开始月份，最大日期减去2个月作为结束月份';
    set VV_START_MON = substr(VV_MIN_DATE, 1, 7);
    set VV_END_MON = substr(DATE_SUB(VV_MAX_DATE, INTERVAL 3 month), 1, 7);

    set VV_TASK = '从最小开始月份开始循环 +1月，每个月份 到 该月份+3个月 为一个区间';
    set vi_date = VV_START_MON;
    set VV_RN = 1;

    while vi_date <= VV_END_MON
        do
            SET VV_START = vi_date;
            SET VV_END = substr(DATE_SUB(concat(vi_date, '-01'), INTERVAL -3 month), 1, 7);

            SET VV_TASK = '调用 经营性收入区间函数，流水开始日期：VV_START ，流水终止日期：VV_END';
            CALL SP_BILL_APPLY_GRADE_REGION(APPLYID, IDCARD, PTYPE, AREACODE, VV_START, VV_END);
            SET VV_TASK = '将本次区间经营性总收入指标表';
            insert into data_bill_apply_grade_trend
            select APPLYID           as APPLY_ID,
                   IDCARD            as ID_CARD,
                   PTYPE             as TYPE,
                   AREACODE          as AREA_CODE,
                   CURRENT_TIMESTAMP as UPDATE_TIME,
                   VV_START,
                   VV_END,
                   BUS_INC_AMT,
                   VV_RN
            from DATA_BILL_APPLY_GRADE_REGION
            where APPLY_ID = APPLYID
              AND ID_CARD = IDCARD
              AND TYPE = PTYPE
              AND AREA_CODE = AREACODE;
            commit;


            SET vi_date = substr(DATE_SUB(concat(vi_date, '-01'), INTERVAL -1 month), 1, 7);
            set VV_RN = VV_RN + 1;
        end while;


    set VV_TASK = '删除标准化历史流水';
    delete from data_transaction_detail_trend where APPLY_ID = APPLYID AND AREA_CODE = AREACODE;
    commit;

    set VV_TASK = '删除指标表数据';
    delete
    from data_bill_apply_grade_region
    where APPLY_ID = APPLYID AND ID_CARD = IDCARD AND TYPE = PTYPE AND AREA_CODE = AREACODE;
    commit;

END;

