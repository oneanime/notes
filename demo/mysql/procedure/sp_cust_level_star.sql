create
    definer = root@localhost procedure sp_cust_level_star(IN APPLYID varchar(100), IN IDCARD varchar(20),
                                                          IN PTYPE varchar(10), IN AREACODE varchar(30))
BEGIN
    DECLARE VV_TASK VARCHAR(20);
    DECLARE VV_ZW_HOUSE_VALUE varchar(20);
    DECLARE VV_ZW_WORK_YEAR varchar(20);
    DECLARE VV_ZX_PERSONAL_HOUSELOAN_NUM varchar(20);
    DECLARE VV_ZW_CHILD_CNT varchar(20);
    DECLARE VV_ZW_CAR_FLAG varchar(20);
    DECLARE VV_ZW_SOCI_INS_BASE_AMT varchar(20);
    DECLARE VV_JR_DEPOSIT varchar(20);
    DECLARE VV_JR_PROXY_AMT varchar(20);
    DECLARE VV_MORTGAGE_AMT varchar(20);
    DECLARE VV_JR_STOCKAMT varchar(20);
    DECLARE VV_JR_COOPERATION_LIMIT varchar(20);
    DECLARE VV_ZX_CREDIT_TIME_MONTH varchar(20);
    DECLARE VV_ZW_FUND_BASE_AMT varchar(20);
    DECLARE VV_ZW_BUS_STAFF_CNT varchar(20);
    DECLARE VV_ZW_BUS_YEAR varchar(20);
    DECLARE VV_ZX_CREDIT_AMT varchar(20);
    DECLARE VV_AGE varchar(20);
    DECLARE VV_FAMILY_CNT varchar(20);
    DECLARE VV_MONEY_MIXED varchar(20);
    DECLARE VV_ZX_CREDIT_AVG_AMT varchar(20);
    DECLARE VV_ZW_SPOUSE_JOB varchar(20);

    DECLARE VV_CUST_GROUP varchar(20);
    DECLARE VV_MARRY_STAT varchar(20);
    DECLARE VV_MARRY_STAT1 varchar(20);
    DECLARE VV_HOUSE_MORT_VALUE varchar(20);
    select CUSTOMER_GROUP
    into VV_CUST_GROUP
    from apply_credit
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and AREA_CODE = AREACODE;
    select case when ZW_MARRY = 2 then '1' else '0' end
    into VV_MARRY_STAT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select case when ZW_MARRY in (3, 6) then '3' else ZW_MARRY end
    into VV_MARRY_STAT1
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ifnull(ZW_SPOUSE_JOB, 0)
    into VV_ZW_SPOUSE_JOB
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ifnull(ASSURE_AMT, 0) + ifnull(JR_PROXY_AMT, 0) + ifnull(ZW_FUND_BASE_AMT, 0) +
           ifnull(ZW_SOCI_INS_BASE_AMT, 0) + ifnull(JR_STOCKAMT, 0)
    into VV_MONEY_MIXED
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ifnull(ZW_OLDER_CNT, 0) + ifnull(ZW_CHILD_CNT, 0) + ifnull(ZW_LABOR, 0)
    into VV_FAMILY_CNT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select case when ifnull(ZX_VALID_CNT, 0) = 0 then 0 else round(ifnull(ZX_CREDIT_AMT, 0) / ZX_VALID_CNT, 2) end
    into VV_ZX_CREDIT_AVG_AMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ifnull(ZW_HOUSE_VALUE, 0)
    into VV_ZW_HOUSE_VALUE
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_WORK_YEAR
    into VV_ZW_WORK_YEAR
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZX_PERSONAL_HOUSELOAN_NUM
    into VV_ZX_PERSONAL_HOUSELOAN_NUM
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_CHILD_CNT
    into VV_ZW_CHILD_CNT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_CAR_FLAG
    into VV_ZW_CAR_FLAG
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_SOCI_INS_BASE_AMT
    into VV_ZW_SOCI_INS_BASE_AMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select JR_DEPOSIT
    into VV_JR_DEPOSIT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select JR_PROXY_AMT
    into VV_JR_PROXY_AMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select MORTGAGE_AMT
    into VV_MORTGAGE_AMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select JR_STOCKAMT
    into VV_JR_STOCKAMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select JR_COOPERATION_LIMIT
    into VV_JR_COOPERATION_LIMIT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZX_CREDIT_TIME_MONTH
    into VV_ZX_CREDIT_TIME_MONTH
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_FUND_BASE_AMT
    into VV_ZW_FUND_BASE_AMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_BUS_STAFF_CNT
    into VV_ZW_BUS_STAFF_CNT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZW_BUS_YEAR
    into VV_ZW_BUS_YEAR
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select ZX_CREDIT_AMT
    into VV_ZX_CREDIT_AMT
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select AGE
    into VV_AGE
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    select case when ZW_HOUSE_VALUE = 0 and MORTGAGE_AMT > 0 then round(MORTGAGE_AMT / 0.6, 2) else 0 end
    into VV_HOUSE_MORT_VALUE
    from data_cust_apply_grade
    where APPLY_ID = APPLYID
      and ID_CARD = IDCARD
      and TYPE = PTYPE
      and AREA_CODE = AREACODE;
    set VV_TASK = 'sclssj';
    delete
    from data_factor_value
    where apply_id = APPLYID and id_card = IDCARD and type = PTYPE and area_code = AREACODE;
    commit;
    delete
    from data_factor_result
    where apply_id = APPLYID and id_card = IDCARD and type = PTYPE and area_code = AREACODE;
    commit;
    delete
    from data_factor_score
    where apply_id = APPLYID and id_card = IDCARD and type = PTYPE and area_code = AREACODE;
    commit;
    delete from data_cust_level where apply_id = APPLYID and id_card = IDCARD and type = PTYPE and area_code = AREACODE;
    commit;
    delete from data_cust_star where apply_id = APPLYID and id_card = IDCARD and type = PTYPE and area_code = AREACODE;
    commit;
    set VV_TASK = 'grzbcrzjb';
    insert into data_factor_value
    select a.apply_id,
           a.id_card,
           a.type,
           a.area_code,
           VV_CUST_GROUP as cust_group,
           VV_MARRY_STAT as marry_stat,
           a.factor,
           a.f_value
    from (
             select APPLYID           AS APPLY_ID,
                    IDCARD            AS ID_CARD,
                    PTYPE             AS TYPE,
                    AREACODE          AS AREA_CODE,
                    'ZW_HOUSE_VALUE'  as factor,
                    VV_ZW_HOUSE_VALUE as f_value
             from dual
             union
             select APPLYID         AS APPLY_ID,
                    IDCARD          AS ID_CARD,
                    PTYPE           AS TYPE,
                    AREACODE        AS AREA_CODE,
                    'ZW_WORK_YEAR'  as factor,
                    VV_ZW_WORK_YEAR as f_value
             from dual
             union
             select APPLYID                      AS APPLY_ID,
                    IDCARD                       AS ID_CARD,
                    PTYPE                        AS TYPE,
                    AREACODE                     AS AREA_CODE,
                    'ZX_PERSONAL_HOUSELOAN_NUM'  as factor,
                    VV_ZX_PERSONAL_HOUSELOAN_NUM as f_value
             from dual
             union
             select APPLYID         AS APPLY_ID,
                    IDCARD          AS ID_CARD,
                    PTYPE           AS TYPE,
                    AREACODE        AS AREA_CODE,
                    'ZW_CHILD_CNT'  as factor,
                    VV_ZW_CHILD_CNT as f_value
             from dual
             union
             select APPLYID        AS APPLY_ID,
                    IDCARD         AS ID_CARD,
                    PTYPE          AS TYPE,
                    AREACODE       AS AREA_CODE,
                    'ZW_CAR_FLAG'  as factor,
                    VV_ZW_CAR_FLAG as f_value
             from dual
             union
             select APPLYID                 AS APPLY_ID,
                    IDCARD                  AS ID_CARD,
                    PTYPE                   AS TYPE,
                    AREACODE                AS AREA_CODE,
                    'ZW_SOCI_INS_BASE_AMT'  as factor,
                    VV_ZW_SOCI_INS_BASE_AMT as f_value
             from dual
             union
             select APPLYID       AS APPLY_ID,
                    IDCARD        AS ID_CARD,
                    PTYPE         AS TYPE,
                    AREACODE      AS AREA_CODE,
                    'JR_DEPOSIT'  as factor,
                    VV_JR_DEPOSIT as f_value
             from dual
             union
             select APPLYID         AS APPLY_ID,
                    IDCARD          AS ID_CARD,
                    PTYPE           AS TYPE,
                    AREACODE        AS AREA_CODE,
                    'JR_PROXY_AMT'  as factor,
                    VV_JR_PROXY_AMT as f_value
             from dual
             union
             select APPLYID         AS APPLY_ID,
                    IDCARD          AS ID_CARD,
                    PTYPE           AS TYPE,
                    AREACODE        AS AREA_CODE,
                    'MORTGAGE_AMT'  as factor,
                    VV_MORTGAGE_AMT as f_value
             from dual
             union
             select APPLYID        AS APPLY_ID,
                    IDCARD         AS ID_CARD,
                    PTYPE          AS TYPE,
                    AREACODE       AS AREA_CODE,
                    'JR_STOCKAMT'  as factor,
                    VV_JR_STOCKAMT as f_value
             from dual
             union
             select APPLYID                 AS APPLY_ID,
                    IDCARD                  AS ID_CARD,
                    PTYPE                   AS TYPE,
                    AREACODE                AS AREA_CODE,
                    'JR_COOPERATION_LIMIT'  as factor,
                    VV_JR_COOPERATION_LIMIT as f_value
             from dual
             union
             select APPLYID                 AS APPLY_ID,
                    IDCARD                  AS ID_CARD,
                    PTYPE                   AS TYPE,
                    AREACODE                AS AREA_CODE,
                    'ZX_CREDIT_TIME_MONTH'  as factor,
                    VV_ZX_CREDIT_TIME_MONTH as f_value
             from dual
             union
             select APPLYID             AS APPLY_ID,
                    IDCARD              AS ID_CARD,
                    PTYPE               AS TYPE,
                    AREACODE            AS AREA_CODE,
                    'ZW_FUND_BASE_AMT'  as factor,
                    VV_ZW_FUND_BASE_AMT as f_value
             from dual
             union
             select APPLYID             AS APPLY_ID,
                    IDCARD              AS ID_CARD,
                    PTYPE               AS TYPE,
                    AREACODE            AS AREA_CODE,
                    'ZW_BUS_STAFF_CNT'  as factor,
                    VV_ZW_BUS_STAFF_CNT as f_value
             from dual
             union
             select APPLYID        AS APPLY_ID,
                    IDCARD         AS ID_CARD,
                    PTYPE          AS TYPE,
                    AREACODE       AS AREA_CODE,
                    'ZW_BUS_YEAR'  as factor,
                    VV_ZW_BUS_YEAR as f_value
             from dual
             union
             select APPLYID          AS APPLY_ID,
                    IDCARD           AS ID_CARD,
                    PTYPE            AS TYPE,
                    AREACODE         AS AREA_CODE,
                    'ZX_CREDIT_AMT'  as factor,
                    VV_ZX_CREDIT_AMT as f_value
             from dual
             union
             select APPLYID  AS APPLY_ID,
                    IDCARD   AS ID_CARD,
                    PTYPE    AS TYPE,
                    AREACODE AS AREA_CODE,
                    'AGE'    as factor,
                    VV_AGE   as f_value
             from dual
             union
             select APPLYID       AS APPLY_ID,
                    IDCARD        AS ID_CARD,
                    PTYPE         AS TYPE,
                    AREACODE      AS AREA_CODE,
                    'FAMILY_CNT'  as factor,
                    VV_FAMILY_CNT as f_value
             from dual
             union
             select APPLYID        AS APPLY_ID,
                    IDCARD         AS ID_CARD,
                    PTYPE          AS TYPE,
                    AREACODE       AS AREA_CODE,
                    'MONEY_MIXED'  as factor,
                    VV_MONEY_MIXED as f_value
             from dual
             union
             select APPLYID              AS APPLY_ID,
                    IDCARD               AS ID_CARD,
                    PTYPE                AS TYPE,
                    AREACODE             AS AREA_CODE,
                    'ZX_CREDIT_AVG_AMT'  as factor,
                    VV_ZX_CREDIT_AVG_AMT as f_value
             from dual
             union
             select APPLYID          AS APPLY_ID,
                    IDCARD           AS ID_CARD,
                    PTYPE            AS TYPE,
                    AREACODE         AS AREA_CODE,
                    'ZW_SPOUSE_JOB'  as factor,
                    VV_ZW_SPOUSE_JOB as f_value
             from dual
             union
             select APPLYID       AS APPLY_ID,
                    IDCARD        AS ID_CARD,
                    PTYPE         AS TYPE,
                    AREACODE      AS AREA_CODE,
                    'ZW_MARRY'    as factor,
                    VV_MARRY_STAT as f_value
             from dual
             union
             select APPLYID             AS APPLY_ID,
                    IDCARD              AS ID_CARD,
                    PTYPE               AS TYPE,
                    AREACODE            AS AREA_CODE,
                    'HOUSE_MORT_VALUE'  as factor,
                    VV_HOUSE_MORT_VALUE as f_value
             from dual
             union
             select APPLYID        AS APPLY_ID,
                    IDCARD         AS ID_CARD,
                    PTYPE          AS TYPE,
                    AREACODE       AS AREA_CODE,
                    'ZW_MARRY1'    as factor,
                    VV_MARRY_STAT1 as f_value
             from dual
         ) a;
    commit;
    set VV_TASK = 'tygx';
    update data_factor_value
    set f_value='0'
    where apply_id = APPLYID
      and id_card = IDCARD
      and type = PTYPE
      and area_code = AREACODE
      and f_value = '0.00';
    commit;
    set VV_TASK = 'zbdf';
    insert into data_factor_result
    select a.apply_id,
           a.id_card,
           a.type,
           a.area_code,
           a.cust_group,
           a.marry_stat,
           a.factor,
           max(case when a.f_value > b.s_score and a.f_value <= b.e_score then b.score else 0 end) as score
    from data_factor_value a
             join data_dic_factor b
                  on a.factor = b.factor and a.cust_group = b.cust_group and a.marry_stat = b.marry_stat
    where a.apply_id = APPLYID
      and a.id_card = IDCARD
      and a.type = PTYPE
      and a.area_code = AREACODE
    group by a.apply_id, a.id_card, a.type, a.area_code, a.cust_group, a.marry_stat, a.factor;
    commit;
    set VV_TASK = 'poyzdf';
    insert into data_factor_result
    select APPLY_ID,
           ID_CARD,
           TYPE,
           AREA_CODE,
           cust_group,
           marry_stat,
           'ZW_SPOUSE_JOB' as factor,
           case
               when f_value = 'vip' then 100
               when f_value = 'gzsb' then 80
               when f_value = 'gtgsh' then 60
               when f_value = 'sqsb' then 40
               when f_value = 'cxjm' then 20
               else 0 end  as score
    from data_factor_value
    where factor = 'ZW_SPOUSE_JOB'
      and cust_group = 'gzsb'
      and marry_stat = '1'
      and apply_id = APPLYID
      and id_card = IDCARD
      and type = PTYPE
      and area_code = AREACODE;
    commit;
    set VV_TASK = 'sqsb';
    insert into data_factor_result
    select APPLY_ID,
           ID_CARD,
           TYPE,
           AREA_CODE,
           cust_group,
           marry_stat,
           'ZW_SPOUSE_JOB' as factor,
           case
               when f_value = 'vip' then 100
               when f_value = 'gzsb' then 80
               when f_value = 'gtgsh' then 60
               when f_value = 'sqsb' then 40
               when f_value = 'cxjm' then 20
               else 0 end  as score
    from data_factor_value
    where factor = 'ZW_SPOUSE_JOB'
      and cust_group = 'sqsb'
      and marry_stat = '1'
      and apply_id = APPLYID
      and id_card = IDCARD
      and type = PTYPE
      and area_code = AREACODE;
    commit;
    set VV_TASK = 'gtgsh';
    insert into data_factor_result
    select APPLY_ID,
           ID_CARD,
           TYPE,
           AREA_CODE,
           cust_group,
           marry_stat,
           'ZW_SPOUSE_JOB' as factor,
           case
               when f_value = 'vip' then 100
               when f_value = 'gzsb' then 80
               when f_value = 'gtgsh' then 60
               when f_value = 'sqsb' then 40
               when f_value = 'cxjm' then 20
               else 0 end  as score
    from data_factor_value
    where factor = 'ZW_SPOUSE_JOB'
      and cust_group = 'gtgsh'
      and marry_stat = '1'
      and apply_id = APPLYID
      and id_card = IDCARD
      and type = PTYPE
      and area_code = AREACODE;
    commit;
    set VV_TASK = 'cxjm';
    insert into data_factor_result
    select APPLY_ID,
           ID_CARD,
           TYPE,
           AREA_CODE,
           cust_group,
           marry_stat,
           'ZW_SPOUSE_JOB' as factor,
           case
               when f_value = 'vip' then 100
               when f_value = 'gzsb' then 80
               when f_value = 'gtgsh' then 60
               when f_value = 'sqsb' then 40
               when f_value = 'cxjm' then 20
               else 0 end  as score
    from data_factor_value
    where factor = 'ZW_SPOUSE_JOB'
      and cust_group = 'cxjm'
      and marry_stat = '1'
      and apply_id = APPLYID
      and id_card = IDCARD
      and type = PTYPE
      and area_code = AREACODE;
    commit;
    set VV_TASK = 'jqdf';
    insert into data_factor_score
    select apply_id, id_card, type, area_code, cust_group, marry_stat, sum(sum_score) as sum_score
    from (
             select a.*, b.WEIGHT, a.score * b.WEIGHT as sum_score
             from data_factor_result a,
                  data_dic_factor_weight b
             where a.cust_group = b.cust_group
               and a.marry_stat = b.marry_stat
               and a.factor = b.factor
               and a.apply_id = APPLYID
               and a.id_card = IDCARD
               and a.type = PTYPE
               and a.area_code = AREACODE
         ) t
    group by apply_id, id_card, type, area_code, cust_group, marry_stat;
    commit;
    set VV_TASK = 'jscjxj';
    insert into data_cust_level
    select a.apply_id,
           a.id_card,
           a.type,
           a.area_code,
           max(case when a.sum_score > b.S_SCORE and a.sum_score <= b.E_SCORE then b.LEVEL_ else 0 end) as cust_level
    from data_factor_score a,
         data_dic_level b
    where a.cust_group = b.CUST_GROUP
      and a.marry_stat = b.MARRY_STAT
      and a.apply_id = APPLYID
      and a.id_card = IDCARD
      and a.type = PTYPE
      and a.area_code = AREACODE
    group by a.apply_id, a.id_card, a.type, a.area_code;
    commit;
    set VV_TASK = 'qczjbsj';
    delete
    from data_factor_value
    where apply_id = APPLYID and id_card = IDCARD and type = PTYPE and area_code = AREACODE;
    commit;
    set VV_TASK = 'jsxj';
    insert into data_cust_star
    SELECT A1.APPLY_ID
         , A1.ID_CARD
         , A1.TYPE
         , A1.AREA_CODE
         , CASE
               WHEN A1.ZW_HOUSE_VALUE <= 100000 AND A1.KHXJ = '5' THEN '4'
               WHEN A1.ZW_HOUSE_VALUE <= 100000 AND A1.KHXJ = '4' THEN '3'
               WHEN A1.ZW_HOUSE_VALUE <= 100000 AND A1.KHXJ = '3' THEN '2'
               WHEN A1.ZW_HOUSE_VALUE >= 1000000 AND A1.KHXJ = '1' AND A1.CUSTOMER_GROUP IN ('gzsb', 'sqsb', 'gtgsh')
                   THEN '2'
               WHEN A1.ZW_HOUSE_VALUE >= 1000000 AND A1.KHXJ = '2' AND A1.CUSTOMER_GROUP IN ('gzsb', 'sqsb', 'gtgsh')
                   THEN '3'
               WHEN A1.ZW_HOUSE_VALUE >= 1000000 AND A1.KHXJ = '3' AND A1.CUSTOMER_GROUP IN ('gzsb', 'sqsb', 'gtgsh')
                   THEN '4'
               WHEN A1.ZW_HOUSE_VALUE >= 500000 AND A1.KHXJ = '1' AND A1.CUSTOMER_GROUP IN ('cxjm') THEN '2'
               WHEN A1.ZW_HOUSE_VALUE >= 500000 AND A1.KHXJ = '2' AND A1.CUSTOMER_GROUP IN ('cxjm') THEN '3'
               WHEN A1.ZW_HOUSE_VALUE >= 500000 AND A1.KHXJ = '3' AND A1.CUSTOMER_GROUP IN ('cxjm') THEN '4'
               ELSE A1.KHXJ
        END AS KHXJ2
    FROM (
             SELECT B2.APPLY_ID
                  , B2.ID_CARD
                  , B2.TYPE
                  , B2.AREA_CODE
                  , B1.CUSTOMER_GROUP
                  , COALESCE(B2.ZW_HOUSE_VALUE, 0) AS ZW_HOUSE_VALUE
                  , CASE
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 649421.2 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 100000 AND
                             B2.ZW_WORK_YEAR <= 8.42 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 649421.2 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 100000 AND
                             B2.ZW_WORK_YEAR > 8.42 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 649421.2 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 100000 AND
                             B2.ZW_WORK_YEAR <= 5.67 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 649421.2 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 100000 AND
                             B2.ZW_WORK_YEAR > 5.67 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 649421.2 AND B2.ZW_FUND_BASE_AMT <= 5658.33 AND
                             B2.ZW_WORK_YEAR <= 4.67 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 649421.2 AND B2.ZW_FUND_BASE_AMT <= 5658.33 AND
                             B2.ZW_WORK_YEAR > 4.67 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR <= 8.5 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 649421.2 AND B2.ZW_FUND_BASE_AMT > 5658.33 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR <= 11.25 AND B2.OUTSTANDING_AMT <= 107606 AND
                             B2.ZW_FUND_BASE_AMT <= 5708.33 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR <= 11.25 AND B2.OUTSTANDING_AMT <= 107606 AND B2.ZW_FUND_BASE_AMT > 5708.33
                            THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR <= 11.25 AND B2.OUTSTANDING_AMT > 107606 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR > 11.25 AND B2.ZW_FUND_BASE_AMT <= 5833.33 AND B2.ZW_WORK_YEAR <= 15.5
                            THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR > 11.25 AND B2.ZW_FUND_BASE_AMT <= 5833.33 AND B2.ZW_WORK_YEAR > 15.5
                            THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR > 11.25 AND B2.ZW_FUND_BASE_AMT > 5833.33 AND B2.OUTSTANDING_AMT <= 0
                            THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT <= 6275 AND B2.ZW_WORK_YEAR > 8.5 AND
                             B2.ZW_WORK_YEAR > 11.25 AND B2.ZW_FUND_BASE_AMT > 5833.33 AND B2.OUTSTANDING_AMT > 0
                            THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT <= 25 AND
                             B2.ZW_WORK_YEAR <= 4.08 AND B2.ZW_FUND_BASE_AMT <= 8100 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT <= 25 AND
                             B2.ZW_WORK_YEAR <= 4.08 AND B2.ZW_FUND_BASE_AMT > 8100 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT <= 25 AND
                             B2.ZW_WORK_YEAR > 4.08 AND B2.ZW_FUND_BASE_AMT <= 6650 AND B2.ZW_WORK_YEAR <= 8.67 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT <= 25 AND
                             B2.ZW_WORK_YEAR > 4.08 AND B2.ZW_FUND_BASE_AMT <= 6650 AND B2.ZW_WORK_YEAR > 8.67 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT <= 25 AND
                             B2.ZW_WORK_YEAR > 4.08 AND B2.ZW_FUND_BASE_AMT > 6650 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 2221.76 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT <= 25 AND
                             B2.ZW_WORK_YEAR > 4.08 AND B2.ZW_FUND_BASE_AMT > 6650 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 2221.76 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT > 25 AND
                             B2.ZW_WORK_YEAR <= 6.08 AND B2.ZW_WORK_YEAR <= 2.83 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT > 25 AND
                             B2.ZW_WORK_YEAR <= 6.08 AND B2.ZW_WORK_YEAR > 2.83 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 0
                            THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT > 25 AND
                             B2.ZW_WORK_YEAR <= 6.08 AND B2.ZW_WORK_YEAR > 2.83 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 0
                            THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT > 25 AND
                             B2.ZW_WORK_YEAR > 6.08 AND B2.ZW_WORK_YEAR <= 7.08 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT > 25 AND
                             B2.ZW_WORK_YEAR > 6.08 AND B2.ZW_WORK_YEAR > 7.08 AND B2.ZW_FUND_BASE_AMT <= 6575 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gzsb' AND B2.ZW_FUND_BASE_AMT > 6275 AND B2.OUTSTANDING_AMT > 25 AND
                             B2.ZW_WORK_YEAR > 6.08 AND B2.ZW_WORK_YEAR > 7.08 AND B2.ZW_FUND_BASE_AMT > 6575 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2769.43 AND COALESCE(B2.JR_DEPOSIT, 0) <= 3609.41 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 1098.64 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2769.43 AND COALESCE(B2.JR_DEPOSIT, 0) <= 3609.41 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 1098.64 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2769.43 AND COALESCE(B2.JR_DEPOSIT, 0) > 3609.41 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 0 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2769.43 AND COALESCE(B2.JR_DEPOSIT, 0) > 3609.41 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 0 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2769.43 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 400000 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 148991 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2769.43 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 400000 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 148991 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2769.43 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 400000 AND
                             B2.ZW_WORK_YEAR <= 1.75 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR <= 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2769.43 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 400000 AND
                             B2.ZW_WORK_YEAR > 1.75 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR > 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2801.14 AND B2.ZW_WORK_YEAR <= 7.5 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR > 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2801.14 AND B2.ZW_WORK_YEAR > 7.5 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 974.88 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR > 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT <= 2801.14 AND B2.ZW_WORK_YEAR > 7.5 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 974.88 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR > 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2801.14 AND B2.OUTSTANDING_AMT <= 0 AND B2.ZW_WORK_YEAR <= 9
                            THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR > 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2801.14 AND B2.OUTSTANDING_AMT <= 0 AND B2.ZW_WORK_YEAR > 9
                            THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'sqsb' AND B2.ZW_WORK_YEAR > 6.17 AND
                             B2.ZW_SOCI_INS_BASE_AMT > 2801.14 AND B2.OUTSTANDING_AMT > 0 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR <= 5.75 AND B2.OUTSTANDING_AMT <= 39067 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 359492.1 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 0 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR <= 5.75 AND B2.OUTSTANDING_AMT <= 39067 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 359492.1 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 0 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR <= 5.75 AND B2.OUTSTANDING_AMT <= 39067 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 359492.1 AND COALESCE(B2.JR_DEPOSIT, 0) <= 7246.47
                            THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR <= 5.75 AND B2.OUTSTANDING_AMT <= 39067 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 359492.1 AND COALESCE(B2.JR_DEPOSIT, 0) > 7246.47 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR <= 5.75 AND B2.OUTSTANDING_AMT > 39067 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 600000 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR <= 5.75 AND B2.OUTSTANDING_AMT > 39067 AND
                             COALESCE(B2.ZW_HOUSE_VALUE, 0) > 600000 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE <= 44 AND
                             B2.ZW_BUS_YEAR <= 7.25 AND B2.OUTSTANDING_AMT <= 8000 AND B2.OUTSTANDING_AMT <= 0 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE <= 44 AND
                             B2.ZW_BUS_YEAR <= 7.25 AND B2.OUTSTANDING_AMT <= 8000 AND B2.OUTSTANDING_AMT > 0 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE <= 44 AND
                             B2.ZW_BUS_YEAR <= 7.25 AND B2.OUTSTANDING_AMT > 8000 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE <= 44 AND
                             B2.ZW_BUS_YEAR > 7.25 AND B2.OUTSTANDING_AMT <= 0 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE <= 44 AND
                             B2.ZW_BUS_YEAR > 7.25 AND B2.OUTSTANDING_AMT > 0 AND COALESCE(B2.JR_DEPOSIT, 0) <= 4732.98
                            THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE <= 44 AND
                             B2.ZW_BUS_YEAR > 7.25 AND B2.OUTSTANDING_AMT > 0 AND COALESCE(B2.JR_DEPOSIT, 0) > 4732.98
                            THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE > 44 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 3538.15 AND COALESCE(B2.JR_DEPOSIT, 0) <= 1574.67 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE > 44 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 3538.15 AND COALESCE(B2.JR_DEPOSIT, 0) > 1574.67 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE > 44 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 3538.15 AND B2.ZW_BUS_YEAR <= 6.33 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'gtgsh' AND B2.ZW_BUS_YEAR > 5.75 AND B2.AGE > 44 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 3538.15 AND B2.ZW_BUS_YEAR > 6.33 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT <= 0 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 2268.82 AND
                             (B2.ZW_SOCI_INS_BASE_AMT + B2.ZW_FUND_BASE_AMT) <= 0 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT <= 0 AND
                             COALESCE(B2.JR_DEPOSIT, 0) <= 2268.82 AND
                             (B2.ZW_SOCI_INS_BASE_AMT + B2.ZW_FUND_BASE_AMT) > 0 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT <= 0 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 2268.82 AND B2.AGE <= 35 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT <= 0 AND
                             COALESCE(B2.JR_DEPOSIT, 0) > 2268.82 AND B2.AGE > 35 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT > 0 AND
                             B2.ZW_BUS_YEAR <= 0 AND (B2.ZW_SOCI_INS_BASE_AMT + B2.ZW_FUND_BASE_AMT) <= 0 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT > 0 AND
                             B2.ZW_BUS_YEAR <= 0 AND (B2.ZW_SOCI_INS_BASE_AMT + B2.ZW_FUND_BASE_AMT) > 0 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE <= 36 AND B2.OUTSTANDING_AMT > 0 AND
                             B2.ZW_BUS_YEAR > 0 THEN '5'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE > 36 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 0 AND
                             B2.OUTSTANDING_AMT <= 0 AND COALESCE(B2.JR_DEPOSIT, 0) <= 3000.07 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE > 36 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 0 AND
                             B2.OUTSTANDING_AMT <= 0 AND COALESCE(B2.JR_DEPOSIT, 0) > 3000.07 THEN '2'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE > 36 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) <= 0 AND
                             B2.OUTSTANDING_AMT > 0 THEN '1'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE > 36 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 0 AND
                             B2.OUTSTANDING_AMT <= 0 AND B2.AGE <= 53 THEN '4'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE > 36 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 0 AND
                             B2.OUTSTANDING_AMT <= 0 AND B2.AGE > 53 THEN '3'
                        WHEN B1.CUSTOMER_GROUP = 'cxjm' AND B2.AGE > 36 AND COALESCE(B2.ZW_HOUSE_VALUE, 0) > 0 AND
                             B2.OUTSTANDING_AMT > 0 THEN '5'
                 END                               AS KHXJ
             FROM apply_credit B1
                      JOIN data_cust_apply_grade B2 ON B1.APPLY_ID = B2.APPLY_ID AND B1.ID_CARD = B2.ID_CARD
             WHERE B2.APPLY_ID = APPLYID
               AND B2.ID_CARD = IDCARD
               AND B2.TYPE = PTYPE
               AND B2.AREA_CODE = AREACODE
         ) A1;
    commit;
END;

