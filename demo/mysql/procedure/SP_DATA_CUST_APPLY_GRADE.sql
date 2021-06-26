create
    definer = root@`%` procedure SP_DATA_CUST_APPLY_GRADE(IN APPLYID varchar(100), IN IDCARD varchar(20),
                                                          IN PTYPE varchar(10), IN AREACODE varchar(30))
BEGIN
    DECLARE VV_TASK VARCHAR(80);
    DECLARE V_CNT INT(2) DEFAuLT 0;


    set VV_TASK = '查询数据是否存在';
    SELECT COUNT(0)
    INTO V_CNT
    FROM data_cust_apply_grade_copy1
    WHERE APPLY_ID = APPLYID
      AND ID_CARD = IDCARD
      AND TYPE = PTYPE
      AND AREA_CODE = AREACODE;


    IF V_CNT > 0 THEN
        SELECT ('进行更新操作');

        UPDATE data_cust_apply_grade_copy1 T1
            INNER JOIN
            (
                SELECT A.APPLY_ID,
                       A.ID_CARD,
                       A.TYPE,
                       A.AREA_CODE,
                       CURRENT_TIMESTAMP                                                                          UPDATE_TIME,
                       B.AGE,
                       B.SEX,
                       B.ZW_HOUSEHOLD,
                       B.ZW_IS_INCITY,
                       case
                           when instr(ZX_EDUCATION, '小学') + instr(ZX_EDUCATION, '初中') + instr(ZX_EDUCATION, '文盲') >= 1
                               then 1
                           when instr(ZX_EDUCATION, '高中') + instr(ZX_EDUCATION, '中等专业学校') +
                                instr(ZX_EDUCATION, '技术学校') >= 1 then 2
                           when instr(ZX_EDUCATION, '专科') >= 1 then 3
                           when instr(ZX_EDUCATION, '本科') + instr(ZX_EDUCATION, '研究生') + instr(ZX_EDUCATION, '博士') >= 1
                               then 4
                           else 5 end                                                                          as ZW_EDU_LEVEL,
                       B.ZW_MARRY,
                       B.ZW_POLITICAL,
                       B.ZW_HEALTH,
                       B.ZW_SELF_BUILD_AREA,
                       B.ZW_FOREST_AREA,
                       B.ZW_FARM_AREA,
                       IFNULL(N.ASSET_HOUSE_FLAG, 0)                                                           AS ZW_HOUSE_FLAG,
                       B.ZW_CAR_FLAG,
                       B.ZW_PUNISH_CNT,
                       B.ZW_DETAIN_CNT,
                       B.ZW_CONFISCATE_CNT,
                       B.ZW_VIOLATION,
                       B.ZW_HONOR_CNT,
                       B.ZW_ELEC_OVER_CNT,
                       B.ZW_HIGH_CIRCLE_NUM,
                       B.ZW_LOW_CIRCLE_NUM,
                       CASE
                           WHEN IFNULL(B.ZW_GROUP_FLAG, 0) + IFNULL(D.JR_GROUP_FLAG, 0) > 0 THEN 1
                           ELSE 0 END                                                                          AS GROUP_FLAG,
                       B.ZW_PERSON_STATUS,
                       CASE
                           WHEN IFNULL(M.ZW_ALLOWANCES_FLAG, 0) + IFNULL(D.JR_ALLOWANCES_FLAG, 0) > 0 THEN 1
                           ELSE 0 END                                                                          AS ALLOWANCES_FLAG,
                       B.ZW_POOR_FLAG,
                       B.ZW_POOR_EDU_FLAG,
                       B.ZW_BAD_HOUSE_FLAG,
                       B.ZW_COM_REPORT_FLAG,
                       B.ZW_XNH_FLAG,
                       B.ZW_HOSPITAL_DAY,
                       B.ZW_HOSPITAL_FEE,
                       B.ZW_BAD_DISEASE_FLAG,
                       B.ZW_MEDICAL_RESCUE_FLAG,
                       B.ZW_DISABILITY_FLAG,
                       B.ZW_HOUSE_FREEZED_FLAG,
                       B.ZW_CAR_FREEZED_FLAG,
                       B.ZW_WATER_OVER_FLAG,
                       B.ZW_COM_OVER_FLAG,
                       B.ZW_ELEC_OVER_FLAG,
                       B.ZW_DISAP_FLAG,
                       F.CUSTOMER_GROUP                                                                        AS ZW_SPOUSE_JOB,
                       IFNULL(N.ASSET_HOUSE_VALUE, 0)                                                          AS ZW_HOUSE_VALUE,
                       B.ZW_CAR_VALUE,
                       if(B.ZW_RURAL_MULTIPLE_SUBSIDY >= D.JR_RURAL_MULTIPLE_SUBSIDY, B.ZW_RURAL_MULTIPLE_SUBSIDY,
                          D.JR_RURAL_MULTIPLE_SUBSIDY)                                                         AS ZW_RURAL_MULTIPLE_SUBSIDY,
                       if(B.ZW_FARM_SUBSIDY >= D.JR_FARM_SUBSIDY, B.ZW_FARM_SUBSIDY,
                          D.JR_FARM_SUBSIDY)                                                                   AS ZW_FARM_SUBSIDY,
                       if(B.ZW_FARM_MACHINE_SUBSIDY >= D.JR_FARM_MACHINE_SUBSIDY, B.ZW_FARM_MACHINE_SUBSIDY,
                          D.JR_FARM_MACHINE_SUBSIDY)                                                           AS ZW_FARM_MACHINE_SUBSIDY,
                       if(B.ZW_LAND_SUBSIDY >= D.JR_LAND_SUBSIDY, B.ZW_LAND_SUBSIDY,
                          D.JR_LAND_SUBSIDY)                                                                   AS ZW_LAND_SUBSIDY,
                       if(B.ZW_SEED_SUBSIDY >= D.JR_SEED_SUBSIDY, B.ZW_SEED_SUBSIDY,
                          D.JR_SEED_SUBSIDY)                                                                   AS ZW_SEED_SUBSIDY,
                       B.ZW_WATER_AVG,
                       B.ZW_ELEC_AVG,
                       S.ZW_OLDER_CNT,
                       S.ZW_CHILD_CNT,
                       S.ZW_LABOR,
                       B.ZW_BUS_LIC_DXSL,
                       B.ZW_BUS_YEAR,
                       B.ZW_BUS_REJECT_FLAG,
                       B.ZW_BUS_INDUSTRY,
                       B.ZW_BUS_STAFF_CNT,
                       B.ZW_BUS_QUOTA_TAX,
                       B.ZW_BUS_OWN_AREA,
                       B.ZW_BUS_LEASE_AREA,
                       B.ZW_BUS_OPE_FLAG,
                       B.ZW_FUND_LEAST_MON,
                       B.ZW_FUND_REJECT_FLAG,
                       B.ZW_FUND_BASE_AMT,
                       B.ZW_WORK_YEAR,
                       B.ZW_JOB_TYPE,
                       B.ZW_ENT_REJECT_FLAG,
                       B.ZW_ENT_SCALE,
                       B.ZW_SOCI_INS_BASE_AMT,
                       B.ZW_SOCI_INS_MON,
                       B.ZW_JOB_CHANGE_CNT,
                       B.ZW_GZDW_AREA,
                       IFNULL(B.ZW_GZDW_NAME, C.ZX_GZDW_NAME)                                                  AS GZDW_NAME,
                       0                                                                                       AS GZDW_IS_RISK,
                       B.ZW_BUSI_NAME,
                       B.ZW_BUSI_REGNO,
                       0                                                                                       AS BUSI_IS_RISK,
                       B.ZW_UNEMPLOY_SYBXLQSL,
                       B.ZW_GGJYB_DWJNRS,
                       B.ZW_HOSPITAL_FEE_SELF,
                       B.ZW_INCITY_HOUSE_FLAG,
                       S.ZW_LABOR_FULLFAMILY_CNT,
                       B.ZW_IS_SBGJJ,
                       M.ZW_HOSPITAL_FEE_REIM,
                       IFNULL(C.ZX_BH_ASSURE_BALANCE, 0) +
                       IFNULL(C.ZX_TH_ASSURE_BALANCE, 0)                                                       AS ASSURE_AMT,
                       IFNULL(C.ZX_BH_CUR_ASSURE_CNT, 0) +
                       IFNULL(C.ZX_TH_CUR_ASSURE_CNT, 0)                                                       AS ASSURE_CNT,
                       C.ZX_TH_BAD_ASSURE_AMT,
                       C.ZX_BH_BAD_ASSURE_AMT,
                       D.JR_CUR_ASS_OVERDUE_MAX_DAY,
                       IFNULL(C.ZX_BH_OUTSTANDING_CNT, 0) +
                       IFNULL(ZX_TH_OUTSTANDING_CNT, 0)                                                        AS OUTSTANDING_CNT,
                       IFNULL(ZX_TH_OUTSTANDING_AMT, 0)                                                        AS OUTSTANDING_AMT,
                       C.ZX_LOAN_OVERDUE_CNT,
                       C.ZX_LOAN_OVERDUE_MON,
                       C.ZX_LOAN_MAX_OVERDUE_AMT,
                       C.ZX_LOAN_MAX_OVERDUE_MON,
                       C.ZX_LOAN_QUERY_CNT,
                       C.ZX_LOAN_PASS_CNT,
                       CASE WHEN IFNULL(C.ZX_LOAN_ACCT_STATUS, 0) >= 1 THEN 1 ELSE 0 END                       AS LOAN_ACCT_STATUS,
                       C.ZX_LOAN_CUR_OVERDUE_CNT,
                       C.ZX_VALID_CNT,
                       C.ZX_AVG_USED_AMT,
                       C.ZX_CREDIT_AMT,
                       C.ZX_AVG_USED_RATE,
                       C.ZX_CREDIT_OVERDUE_ACCT_CNT,
                       C.ZX_CREDIT_OVERDUE_MON,
                       C.ZX_CREDIT_MAX_OVERDUE_AMT,
                       C.ZX_CREDIT_MAX_OVERDUE_MON,
                       C.ZX_CREDIT_QUERY_CNT,
                       C.ZX_CREDIT_PASS_CNT,
                       C.ZX_CREDIT_PASS_RATE,
                       C.ZX_CREDIT_ACCT_STATUS,
                       C.ZX_CREDIT_CUR_OVERDUE_CNT,
                       C.ZX_BAD_INFORMATION,
                       C.ZX_FOECED_PREPAYMENT,
                       C.ZX_PERSONAL_HOUSELOAN_NUM,
                       C.ZX_FIRST_LOAN_MONTH,
                       C.ZX_FIRST_CREDIT_CARD_MONTH,
                       C.ZX_SEQ_NO,
                       C.ZX_QUERY_DATE,
                       C.RECORD_FLAG,
                       C.ZX_LOAN_ORG_CNT,
                       C.ZX_CREDIT_TIME_MONTH,
                       E.JR_DG_LOAN_OVERDUE_CNT,
                       E.JR_DG_LOAN_STATUS,
                       E.JR_DEPOSIT,
                       D.JR_PREPAYMENT_CNT,
                       D.JR_PROVISIONS_PAYMENT_CNT,
                       D.JR_DELAY_PAYMENT_CNT,
                       D.JR_TOTAL_PAYMENT_CNT,
                       D.JR_PART_PAYMENT_CNT,
                       D.JR_PROXY_FLAG,
                       D.JR_PROXY_AMT,
                       D.JR_COOPERATION_LIMIT,
                       D.JR_ELEC_PROD_CNT,
                       D.JR_BUS_TRADE_AMT,
                       D.JR_STOCKAMT,
                       CASE
                           WHEN IFNULL(G.ID_CARD, 0) > 0 THEN '1'
                           WHEN IFNULL(H.ID_CARD, 0) > 0 THEN '2'
                           END                                                                                 AS IS_WHITE,
                       K.BLACK_SCORE,
                       K.BEFORE_SCORE,
                       K.AFTER_SCORE,
                       K.UREG_SCORE,
                       IFNULL(N.ASSET_HOUSE_VALUE, 0)                                                          AS ASSET_HOUSE_VALUE,
                       IFNULL(N.ASSET_HOUSE_FLAG, 0)                                                           AS ASSET_HOUSE_FLAG,
                       IFNULL(O.ASSET_CAR_VALUE, 0)                                                            AS ASSET_CAR_VALUE,
                       CAST(IFNULL(P.CLOUD_RISKAPP_CNT, 0) AS DECIMAL(10, 2))                                  AS CLOUD_RISKAPP_CNT,
                       C.ZX_NOHOUSE_LOAN_BALANCE,
                       C.ZX_HOUSE_LOAN_PER_MONTH,
                       C.ZX_LOAN_BALANCE,
                       D.MORTGAGE_AMT,
                       Q.GZDW_NONLOCAL,
                       IFNULL(D.JR_CUST_FLAG, 0)                                                               AS JR_CUST_FLAG,
                       IFNULL(B.ZW_LHCS, 0)                                                                    AS ZW_LHCS,

                       IFNULL(B.ZW_CORP_NAME, 0)                                                               AS ZW_CORP_NAME,
                       IFNULL(B.PRIPID, 0)                                                                     AS PRIPID,
                       IFNULL(B.ZW_CORP_ENTTYPE, 0)                                                            AS ZW_CORP_ENTTYPE,
                       IFNULL(B.ZW_CORP_INDUSTRYPHY, 0)                                                        AS ZW_CORP_INDUSTRYPHY,
                       IFNULL(B.ZW_CORP_JYNX, 0)                                                               AS ZW_CORP_JYNX,
                       IFNULL(B.ZW_CORP_IS_JYDZ_INCITY, 0)                                                     AS ZW_CORP_IS_JYDZ_INCITY,
                       IFNULL(B.ZW_CORP_IS_JYDZ_CHANGE, 0)                                                     AS ZW_CORP_IS_JYDZ_CHANGE,
                       IFNULL(B.ZW_CORP_IS_ZCZB_REDUCE, 0)                                                     AS ZW_CORP_IS_ZCZB_REDUCE,
                       IFNULL(B.ZW_CORP_IS_FR_CHANGE, 0)                                                       AS ZW_CORP_IS_FR_CHANGE,
                       IFNULL(B.ZW_CORP_IS_GQ_CHANGE, 0)                                                       AS ZW_CORP_IS_GQ_CHANGE,
                       IFNULL(B.ZW_CORP_IS_QYSX, 0)                                                            AS ZW_CORP_IS_QYSX,
                       IFNULL(B.ZW_CORP_IS_SJSFSS, 0)                                                          AS ZW_CORP_IS_SJSFSS,
                       IFNULL(B.ZW_CORP_GSXZCFCS, 0)                                                           AS ZW_CORP_GSXZCFCS,
                       IFNULL(B.ZW_CORP_IS_DXYYZZ, 0)                                                          AS ZW_CORP_IS_DXYYZZ,
                       IFNULL(B.ZW_CORP_IS_SWWF, 0)                                                            AS ZW_CORP_IS_SWWF,
                       IFNULL(B.ZW_CORP_IS_FGWWFWG, 0)                                                         AS ZW_CORP_IS_FGWWFWG,
                       IFNULL(B.ZW_CORP_QYFCSL, 0)                                                             AS ZW_CORP_QYFCSL,
                       IFNULL(B.ZW_CORP_QYCCSL, 0)                                                             AS ZW_CORP_QYCCSL,
                       IFNULL(B.ZW_CORP_GLQYSL, 0)                                                             AS ZW_CORP_GLQYSL,
                       IFNULL(B.ZW_CORP_GLQYKHYSL, 0)                                                          AS ZW_CORP_GLQYKHYSL,
                       IFNULL(B.ZW_CORP_GDSL, 0)                                                               AS ZW_CORP_GDSL,
                       IFNULL(B.ZW_CORP_IS_GLQYSX, 0)                                                          AS ZW_CORP_IS_GLQYSX,
                       IFNULL(B.ZW_CORP_IS_GLQYSS, 0)                                                          AS ZW_CORP_IS_GLQYSS,
                       IFNULL(B.ZW_CORP_IS_GDSX, 0)                                                            AS ZW_CORP_IS_GDSX,
                       IFNULL(B.ZW_CORP_IS_GDSS, 0)                                                            AS ZW_CORP_IS_GDSS,
                       IFNULL(B.ZW_NSJE, 0)                                                                    AS ZW_NSJE,
                       IFNULL(B.ZW_NSSBXSSR, 0)                                                                AS ZW_NSSBXSSR,
                       IFNULL(B.ZW_LSBYS, 0)                                                                   AS ZW_LSBYS,
                       IFNULL(B.ZW_XSSR, 0)                                                                    AS ZW_XSSR,
                       IFNULL(B.ZW_SJNSCS, 0)                                                                  AS ZW_SJNSCS,
                       IFNULL(B.ZW_COPR_ESDATE, 0)                                                             AS ZW_COPR_ESDATE,
                       IFNULL(B.ZW_COPR_REGORG, 0)                                                             AS ZW_COPR_REGORG,
                       IFNULL(B.ZW_COPR_REGCAP, 0)                                                             AS ZW_COPR_REGCAP,
                       IFNULL(B.ZW_COPR_RECCAP, 0)                                                             AS ZW_COPR_RECCAP,
                       IFNULL(B.ZW_COPR_OPLOC, 0)                                                              AS ZW_COPR_OPLOC,

                       IFNULL(R.INC_AMT, 0)                                                                    AS INC_AMT,
                       IFNULL(R.BUS_INC_AMT, 0)                                                                AS BUS_INC_AMT,
                       IFNULL(R.VALID_BILL_DAYS, 0)                                                            AS VALID_BILL_DAYS,
                       IFNULL(R.BILL_DAYS, 0)                                                                  AS BILL_DAYS,
                       IFNULL(R.TRANS_ACTIVE_RATE, 0)                                                          AS TRANS_ACTIVE_RATE,
                       IFNULL(R.BUS_INCOME_MON_STD, 0)                                                         AS BUS_INCOME_MON_STD,
                       IFNULL(R.BUS_INCOME_MON_AVG, 0)                                                         AS BUS_INCOME_MON_AVG,
                       IFNULL(R.BUS_INCOME_MON_RATE, 0)                                                        AS BUS_INCOME_MON_RATE,
                       IFNULL(R.BILL_CNT_MON_STD, 0)                                                           AS BILL_CNT_MON_STD,
                       IFNULL(R.BILL_CNT_MON_AVG, 0)                                                           AS BILL_CNT_MON_AVG,
                       IFNULL(R.BILL_CNT_MON_RATE, 0)                                                          AS BILL_CNT_MON_RATE,
                       IFNULL(R.BUS_AMT_MON_THREE, 0)                                                          AS BUS_AMT_MON_THREE,
                       IFNULL(R.BUS_AMT_MON_RATE, 0)                                                           AS BUS_AMT_MON_RATE,
                       IFNULL(R.BUS_INC_FIVE_AMT, 0)                                                           AS BUS_INC_FIVE_AMT,
                       IFNULL(R.BUS_INC_FIVE_RATE, 0)                                                          AS BUS_INC_FIVE_RATE,
                       IFNULL(R.BUS_BILL_FIVE_CNT, 0)                                                          AS BUS_BILL_FIVE_CNT,
                       IFNULL(R.BUS_BILL_CNT, 0)                                                               AS BUS_BILL_CNT,
                       IFNULL(R.BUS_BILL_FIVE_RATE, 0)                                                         AS BUS_BILL_FIVE_RATE,
                       IFNULL(R.CIRCLE_AMT, 0)                                                                 AS CIRCLE_AMT,
                       IFNULL(R.SALE_AMT, 0)                                                                   AS SALE_AMT,
                       IFNULL(R.CIRCLE_RATE, 0)                                                                AS CIRCLE_RATE,
                       IFNULL(R.DEPOSIT_AMT, 0)                                                                AS DEPOSIT_AMT,
                       IFNULL(R.TREND_FLAG, 0)                                                                 AS TREND_FLAG,
                       IFNULL(R.PERDU_DEBT_CNT, 0)                                                             AS PERDU_DEBT_CNT,
                       IFNULL(R.PERDU_DEBT_AMT, 0)                                                             AS PERDU_DEBT_AMT,
                       CASE WHEN IFNULL(B.ZW_NSJE, 0) > 0 THEN 1 ELSE 0 END                                    AS ZW_TAX_FLAG,
                       CASE WHEN IFNULL(R.INC_AMT, 0) > 0 THEN 1 ELSE 0 END                                    AS JR_TRANS_FLAG,
                       IFNULL((CASE
                                   WHEN P.CLOUD_BOOK_KEY_STAFF >= 5 THEN -1
                                   WHEN U.IMEI IS NOT NULL THEN -1
                                   ELSE P.CLOUD_BOOK_KEY
                           END),
                              0)                                                                               AS CLOUD_YSZJ,
                       IFNULL(V.ASSET_OTHER_VALUE, 0)                                                          AS ASSET_OTHER_VALUE
                FROM (SELECT APPLYID AS APPLY_ID, PTYPE AS TYPE, IDCARD AS ID_CARD, AREACODE AS AREA_CODE FROM DUAL) A
                         LEFT JOIN data_social_apply_grade_detail B
                                   ON A.APPLY_ID = B.APPLY_ID AND A.ID_CARD = B.ID_CARD AND A.AREA_CODE = B.AREA_CODE
                         LEFT JOIN data_credit_apply_grade_detail C
                                   ON A.APPLY_ID = C.APPLY_ID AND A.TYPE = C.TYPE AND A.ID_CARD = C.ID_CARD AND
                                      A.AREA_CODE = C.AREA_CODE
                         LEFT JOIN data_bank_apply_grade_detail D
                                   ON A.APPLY_ID = D.APPLY_ID AND A.ID_CARD = D.ID_CARD AND A.AREA_CODE = D.AREA_CODE

                         LEFT JOIN (
                    select APPLYID                                                                AS APPLY_ID,
                           IDCARD                                                                 AS ID_CARD,
                           PTYPE                                                                  AS TYPE,
                           AREACODE                                                               AS AREA_CODE,
                           MAX(a.JR_DG_LOAN_STATUS)                                               AS JR_DG_LOAN_STATUS,
                           SUM(a.JR_DG_LOAN_OVERDUE_CNT)                                          AS JR_DG_LOAN_OVERDUE_CNT,
                           SUM(case when b.apply_relation in (1, 2) then a.JR_DEPOSIT else 0 end) AS JR_DEPOSIT
                    from data_bank_apply_grade_detail a
                             JOIN cust_family_mx b on a.ID_CARD = b.MEMBER_ID_CARD and a.apply_id = b.SEQ_NO and
                                                      a.AREA_CODE = b.AREA_CODE
                    WHERE a.APPLY_ID = APPLYID
                      and a.AREA_CODE = AREACODE
                      and b.TYPE = PTYPE
                ) E ON A.APPLY_ID = E.APPLY_ID AND A.ID_CARD = E.ID_CARD AND A.AREA_CODE = E.AREA_CODE

                         LEFT JOIN (
                    select MEMBER_ID_CARD as ID_CARD,
                           CUSTOMER_GROUP as CUSTOMER_GROUP
                    from cust_family_mx
                    WHERE SEQ_NO = APPLYID
                      AND TYPE = PTYPE
                      AND AREA_CODE = AREACODE
                      and APPLY_RELATION = 2
                ) F ON A.ID_CARD <> F.ID_CARD

                         LEFT JOIN DATA_WHITE_VIP_INFO G ON A.ID_CARD = G.ID_CARD

                         LEFT JOIN DATA_WHITE_LIST_INFO H ON A.ID_CARD = H.ID_CARD

                         LEFT JOIN data_graph_apply_grade K
                                   ON A.APPLY_ID = K.APPLY_ID AND A.TYPE = K.MEMBER_TYPE AND A.ID_CARD = K.ID_CARD AND
                                      A.AREA_CODE = K.AREA_CODE

                         LEFT JOIN (
                    select a.APPLY_ID,
                           A.AREA_CODE,
                           MAX(a.ZW_ALLOWANCES_FLAG)                                               AS ZW_ALLOWANCES_FLAG,
                           SUM(CASE WHEN AGE < 60 THEN IFNULL(ZW_HOSPITAL_FEE_REIM, 0) ELSE 0 END) AS ZW_HOSPITAL_FEE_REIM
                    FROM DATA_SOCIAL_APPLY_GRADE_DETAIL a
                             join cust_family_mx b on a.ID_CARD = b.MEMBER_ID_CARD and a.APPLY_ID = b.SEQ_NO and
                                                      a.AREA_CODE = b.AREA_CODE
                    where a.APPLY_ID = APPLYID
                      and a.ID_CARD = IDCARD
                      and a.AREA_CODE = AREACODE
                      and b.TYPE = PTYPE
                      and b.APPLY_RELATION in (1, 2)
                ) M ON A.APPLY_ID = M.APPLY_ID AND A.AREA_CODE = M.AREA_CODE

                         LEFT JOIN (
                    SELECT APPLYID                                    AS APPLY_ID,
                           IDCARD                                     AS ID_CARD,
                           PTYPE                                      AS TYPE,
                           AREACODE                                   AS AREA_CODE,
                           SUM(A.HOUSE_VALUE)                         AS ASSET_HOUSE_VALUE,
                           (CASE WHEN COUNT(0) = 0 THEN 0 ELSE 1 END) AS ASSET_HOUSE_FLAG
                    FROM DATA_CUST_ASSET_HOUSE A
                    WHERE A.APPLY_ID = APPLYID
                      AND A.AREA_CODE = AREACODE
                      AND A.TYPE = PTYPE
                      AND A.ID_CARD IN
                          (
                              SELECT MEMBER_ID_CARD
                              FROM cust_family_mx
                              WHERE SEQ_NO = APPLYID
                                AND apply_relation in (1, 2)
                                AND TYPE = PTYPE
                                and AREA_CODE = AREACODE
                          )
                ) N ON A.ID_CARD = N.ID_CARD AND A.APPLY_ID = N.APPLY_ID AND A.AREA_CODE = N.AREA_CODE AND
                       A.TYPE = N.TYPE

                         LEFT JOIN
                     (
                         SELECT APPLYID  AS APPLY_ID,
                                IDCARD   AS ID_CARD,
                                PTYPE    AS TYPE,
                                AREACODE AS AREA_CODE,
                                SUM(CASE
                                        WHEN A.CLLX IN
                                             ('K30', 'K31', 'K32', 'K33', 'K34', 'K40', 'K41', 'K42', 'K43', 'K16',
                                              'K25', 'K26') AND A.CL <= 15
                                            THEN A.CAR_VALUE
                                        ELSE 0
                                    END) AS ASSET_CAR_VALUE
                         FROM DATA_CUST_ASSET_CAR A
                         WHERE A.APPLY_ID = APPLYID
                           AND A.AREA_CODE = AREACODE
                           AND A.TYPE = PTYPE
                           AND A.ID_CARD IN
                               (
                                   SELECT MEMBER_ID_CARD
                                   FROM cust_family_mx
                                   WHERE SEQ_NO = APPLYID
                                     AND apply_relation in (1, 2)
                                     AND TYPE = PTYPE
                                     and AREA_CODE = AREACODE
                               )
                     ) O ON A.ID_CARD = O.ID_CARD AND A.APPLY_ID = O.APPLY_ID AND A.AREA_CODE = O.AREA_CODE AND
                            A.TYPE = O.TYPE

                         LEFT JOIN public_data_autifraud P
                                   ON A.APPLY_ID = P.UNIQUE_NO AND A.ID_CARD = P.ID_CARD AND A.AREA_CODE = P.AREA_CODE

                         left join (
                    select T.*,
                           max(ifnull(T3.NONLOCAL_FLAG, 0)) AS GZDW_NONLOCAL
                    from data_social_apply_grade_detail T
                             left join data_government_dep_info T3 on T.zw_gjj_dwzh = T3.COMPANY_NO
                    WHERE T.APPLY_ID = APPLYID
                      AND T.ID_CARD = IDCARD
                      AND T.AREA_CODE = AREACODE
                ) Q on A.APPLY_ID = Q.APPLY_ID AND A.ID_CARD = Q.ID_CARD AND A.AREA_CODE = Q.AREA_CODE

                         left join data_bill_apply_grade_detail R
                                   ON A.APPLY_ID = R.APPLY_ID AND A.TYPE = R.TYPE AND A.ID_CARD = R.ID_CARD AND
                                      A.AREA_CODE = R.AREA_CODE

                         LEFT JOIN (
                    select APPLYID                                                      AS APPLY_ID,
                           IDCARD                                                       AS ID_CARD,
                           PTYPE                                                        AS TYPE,
                           AREACODE                                                     AS AREA_CODE,
                           sum(case
                                   when a.AGE >= 22 and a.AGE <= 55 and b.apply_relation in (1, 2) then 1
                                   else 0 end)                                          AS ZW_LABOR,
                           sum(case when a.AGE >= 22 and a.AGE <= 55 then 1 else 0 end) AS ZW_LABOR_FULLFAMILY_CNT,
                           sum(case when a.AGE < 18 then 1 else 0 end)                  AS ZW_CHILD_CNT,
                           sum(case when a.AGE > 60 then 1 else 0 end)                  AS ZW_OLDER_CNT
                    from data_social_apply_grade_detail a
                             join cust_family_mx b on a.ID_CARD = b.MEMBER_ID_CARD and a.APPLY_ID = b.SEQ_NO and
                                                      a.AREA_CODE = b.AREA_CODE
                    where a.APPLY_ID = APPLYID
                      and a.AREA_CODE = AREACODE
                      and b.TYPE = PTYPE
                ) S ON A.APPLY_ID = S.APPLY_ID AND A.ID_CARD = S.ID_CARD AND A.AREA_CODE = S.AREA_CODE and
                       A.TYPE = S.TYPE

-- LEFT JOIN public_data_autifraud T ON A.APPLY_ID = T.UNIQUE_NO AND A.ID_CARD = T.ID_CARD AND A.AREA_CODE = T.AREA_CODE

                         LEFT JOIN
                     (
                         SELECT A.APPLY_ID, A.ID_CARD, A.AREA_CODE, B.IMEI
                         FROM apply_credit A
                                  LEFT JOIN DATA_WHITE_EQUIPMENT_INFO B ON A.IMEI = B.IMEI
                         WHERE A.APPLY_ID = APPLYID
                           AND A.ID_CARD = IDCARD
                           AND A.AREA_CODE = AREACODE
                     ) U ON A.APPLY_ID = U.APPLY_ID AND A.ID_CARD = U.ID_CARD AND A.AREA_CODE = U.AREA_CODE


                         LEFT JOIN (
                    SELECT APPLYID                  AS APPLY_ID,
                           IDCARD                   AS ID_CARD,
                           PTYPE                    AS TYPE,
                           AREACODE                 AS AREA_CODE,
                           SUM(C.ASSET_OTHER_VALUE) AS ASSET_OTHER_VALUE
                    FROM (
-- 计算本人抵押质押
                             SELECT IFNULL(SUM(ROUND(A.LOAN_AMOUNT / 0.7, 2)), 0) AS ASSET_OTHER_VALUE
                             FROM report_loan_info A
                                      LEFT JOIN
                                  (
                                      SELECT APPLY_ID, ID_CARD, TYPE, AREA_CODE
                                      FROM DATA_CUST_ASSET_HOUSE
                                      WHERE APPLY_ID = APPLYID
                                        AND AREA_CODE = AREACODE
                                        AND TYPE = PTYPE
                                        AND ID_CARD = IDCARD
                                  ) B
                                  ON A.APPLY_ID = B.APPLY_ID AND A.ID_CARD = B.ID_CARD AND A.AREA_CODE = B.AREA_CODE
                             WHERE A.APPLY_ID = APPLYID
                               AND A.AREA_CODE = AREACODE
                               AND A.ID_CARD = IDCARD
                               AND B.APPLY_ID IS NULL
                               AND A.REPORT_STATUS = 0
                               AND A.IS_CLEAN = 0
                               AND (instr(A.LOAN_WAY, '抵押') > 0 OR instr(A.LOAN_WAY, '质押') > 0)
                               AND instr(A.loan_type, '房') <= 0
                               AND instr(A.loan_type, '车') <= 0

                             UNION
-- 计算配偶抵押质押
                             SELECT IFNULL(SUM(ROUND(A.LOAN_AMOUNT / 0.7, 2)), 0) AS ASSET_OTHER_VALUE
                             FROM report_loan_info A
                                      LEFT JOIN
                                  (
                                      SELECT APPLY_ID, ID_CARD, TYPE, AREA_CODE
                                      FROM DATA_CUST_ASSET_HOUSE
                                      WHERE APPLY_ID = APPLYID
                                        AND AREA_CODE = AREACODE
                                        AND TYPE = PTYPE
                                        AND ID_CARD =
                                            (
                                                SELECT MEMBER_ID_CARD
                                                FROM cust_family_mx
                                                WHERE SEQ_NO = APPLYID
                                                  AND apply_relation in (1, 2)
                                                  AND TYPE = PTYPE
                                                  and AREA_CODE = AREACODE
                                                  AND MEMBER_ID_CARD <> IDCARD
                                            )
                                  ) B
                                  ON A.APPLY_ID = B.APPLY_ID AND A.ID_CARD = B.ID_CARD AND A.AREA_CODE = B.AREA_CODE
                             WHERE A.APPLY_ID = APPLYID
                               AND A.AREA_CODE = AREACODE
                               AND A.ID_CARD =
                                   (
                                       SELECT MEMBER_ID_CARD
                                       FROM cust_family_mx
                                       WHERE SEQ_NO = APPLYID
                                         AND apply_relation in (1, 2)
                                         AND TYPE = PTYPE
                                         and AREA_CODE = AREACODE
                                         AND MEMBER_ID_CARD <> IDCARD
                                   )
                               AND B.APPLY_ID IS NULL
                               AND A.REPORT_STATUS = 0
                               AND A.IS_CLEAN = 0
                               AND (instr(A.LOAN_WAY, '抵押') > 0 OR instr(A.LOAN_WAY, '质押') > 0)
                               AND instr(A.loan_type, '房') <= 0
                               AND instr(A.loan_type, '车') <= 0
                         ) C
                ) V ON A.ID_CARD = V.ID_CARD AND A.APPLY_ID = V.APPLY_ID AND A.AREA_CODE = V.AREA_CODE AND
                       A.TYPE = V.TYPE
            ) T2
            ON T1.APPLY_ID = T2.APPLY_ID AND T1.ID_CARD = T2.ID_CARD AND T1.TYPE = T2.TYPE AND
               T1.AREA_CODE = T2.AREA_CODE

        SET T1.UPDATE_TIME               = T2.UPDATE_TIME,
            T1.AGE                       = T2.AGE,
            T1.SEX=T2.SEX,
            T1.ZW_HOUSEHOLD=T2.ZW_HOUSEHOLD,
            T1.ZW_IS_INCITY=T2.ZW_IS_INCITY,
            T1.ZW_EDU_LEVEL=T2.ZW_EDU_LEVEL,
            T1.ZW_MARRY=T2.ZW_MARRY,
            T1.ZW_POLITICAL=T2.ZW_POLITICAL,
            T1.ZW_HEALTH=T2.ZW_HEALTH,
            T1.ZW_SELF_BUILD_AREA=T2.ZW_SELF_BUILD_AREA,
            T1.ZW_FOREST_AREA=T2.ZW_FOREST_AREA,
            T1.ZW_FARM_AREA=T2.ZW_FARM_AREA,
            T1.ZW_HOUSE_FLAG=T2.ZW_HOUSE_FLAG,
            T1.ZW_CAR_FLAG=T2.ZW_CAR_FLAG,
            T1.ZW_PUNISH_CNT=T2.ZW_PUNISH_CNT,
            T1.ZW_DETAIN_CNT=T2.ZW_DETAIN_CNT,
            T1.ZW_CONFISCATE_CNT=T2.ZW_CONFISCATE_CNT,
            T1.ZW_VIOLATION=T2.ZW_VIOLATION,
            T1.ZW_HONOR_CNT=T2.ZW_HONOR_CNT,
            T1.ZW_ELEC_OVER_CNT=T2.ZW_ELEC_OVER_CNT,
            T1.ZW_HIGH_CIRCLE_NUM=T2.ZW_HIGH_CIRCLE_NUM,
            T1.ZW_LOW_CIRCLE_NUM=T2.ZW_LOW_CIRCLE_NUM,
            T1.GROUP_FLAG=T2.GROUP_FLAG,
            T1.ZW_PERSON_STATUS=T2.ZW_PERSON_STATUS,
            T1.ALLOWANCES_FLAG=T2.ALLOWANCES_FLAG,
            T1.ZW_POOR_FLAG=T2.ZW_POOR_FLAG,
            T1.ZW_POOR_EDU_FLAG=T2.ZW_POOR_EDU_FLAG,
            T1.ZW_BAD_HOUSE_FLAG=T2.ZW_BAD_HOUSE_FLAG,
            T1.ZW_COM_REPORT_FLAG=T2.ZW_COM_REPORT_FLAG,
            T1.ZW_XNH_FLAG=T2.ZW_XNH_FLAG,
            T1.ZW_HOSPITAL_DAY=T2.ZW_HOSPITAL_DAY,
            T1.ZW_HOSPITAL_FEE=T2.ZW_HOSPITAL_FEE,
            T1.ZW_BAD_DISEASE_FLAG=T2.ZW_BAD_DISEASE_FLAG,
            T1.ZW_MEDICAL_RESCUE_FLAG=T2.ZW_MEDICAL_RESCUE_FLAG,
            T1.ZW_DISABILITY_FLAG=T2.ZW_DISABILITY_FLAG,
            T1.ZW_HOUSE_FREEZED_FLAG=T2.ZW_HOUSE_FREEZED_FLAG,
            T1.ZW_CAR_FREEZED_FLAG=T2.ZW_CAR_FREEZED_FLAG,
            T1.ZW_WATER_OVER_FLAG=T2.ZW_WATER_OVER_FLAG,
            T1.ZW_COM_OVER_FLAG=T2.ZW_COM_OVER_FLAG,
            T1.ZW_ELEC_OVER_FLAG=T2.ZW_ELEC_OVER_FLAG,
            T1.ZW_DISAP_FLAG=T2.ZW_DISAP_FLAG,
            T1.ZW_SPOUSE_JOB=T2.ZW_SPOUSE_JOB,
            T1.ZW_HOUSE_VALUE=T2.ZW_HOUSE_VALUE,
            T1.ZW_CAR_VALUE=T2.ZW_CAR_VALUE,
            T1.ZW_RURAL_MULTIPLE_SUBSIDY=T2.ZW_RURAL_MULTIPLE_SUBSIDY,
            T1.ZW_FARM_SUBSIDY=T2.ZW_FARM_SUBSIDY,
            T1.ZW_FARM_MACHINE_SUBSIDY=T2.ZW_FARM_MACHINE_SUBSIDY,
            T1.ZW_LAND_SUBSIDY=T2.ZW_LAND_SUBSIDY,
            T1.ZW_SEED_SUBSIDY=T2.ZW_SEED_SUBSIDY,
            T1.ZW_WATER_AVG=T2.ZW_WATER_AVG,
            T1.ZW_ELEC_AVG=T2.ZW_ELEC_AVG,
            T1.ZW_OLDER_CNT=T2.ZW_OLDER_CNT,
            T1.ZW_CHILD_CNT=T2.ZW_CHILD_CNT,
            T1.ZW_LABOR=T2.ZW_LABOR,
            T1.ZW_BUS_LIC_DXSL=T2.ZW_BUS_LIC_DXSL,
            T1.ZW_BUS_YEAR=T2.ZW_BUS_YEAR,
            T1.ZW_BUS_REJECT_FLAG=T2.ZW_BUS_REJECT_FLAG,
            T1.ZW_BUS_INDUSTRY=T2.ZW_BUS_INDUSTRY,
            T1.ZW_BUS_STAFF_CNT=T2.ZW_BUS_STAFF_CNT,
            T1.ZW_BUS_QUOTA_TAX=T2.ZW_BUS_QUOTA_TAX,
            T1.ZW_BUS_OWN_AREA=T2.ZW_BUS_OWN_AREA,
            T1.ZW_BUS_LEASE_AREA=T2.ZW_BUS_LEASE_AREA,
            T1.ZW_BUS_OPE_FLAG=T2.ZW_BUS_OPE_FLAG,
            T1.ZW_FUND_LEAST_MON=T2.ZW_FUND_LEAST_MON,
            T1.ZW_FUND_REJECT_FLAG=T2.ZW_FUND_REJECT_FLAG,
            T1.ZW_FUND_BASE_AMT=T2.ZW_FUND_BASE_AMT,
            T1.ZW_WORK_YEAR=T2.ZW_WORK_YEAR,
            T1.ZW_JOB_TYPE=T2.ZW_JOB_TYPE,
            T1.ZW_ENT_REJECT_FLAG=T2.ZW_ENT_REJECT_FLAG,
            T1.ZW_ENT_SCALE=T2.ZW_ENT_SCALE,
            T1.ZW_SOCI_INS_BASE_AMT=T2.ZW_SOCI_INS_BASE_AMT,
            T1.ZW_SOCI_INS_MON=T2.ZW_SOCI_INS_MON,
            T1.ZW_JOB_CHANGE_CNT=T2.ZW_JOB_CHANGE_CNT,
            T1.ZW_GZDW_AREA=T2.ZW_GZDW_AREA,
            T1.GZDW_NAME=T2.GZDW_NAME,
            T1.GZDW_IS_RISK=T2.GZDW_IS_RISK,
            T1.ZW_BUSI_NAME=T2.ZW_BUSI_NAME,
            T1.ZW_BUSI_REGNO=T2.ZW_BUSI_REGNO,
            T1.BUSI_IS_RISK=T2.BUSI_IS_RISK,
            T1.ZW_UNEMPLOY_SYBXLQSL=T2.ZW_UNEMPLOY_SYBXLQSL,
            T1.ZW_GGJYB_DWJNRS=T2.ZW_GGJYB_DWJNRS,
            T1.ZW_HOSPITAL_FEE_SELF=T2.ZW_HOSPITAL_FEE_SELF,
            T1.ZW_INCITY_HOUSE_FLAG=T2.ZW_INCITY_HOUSE_FLAG,
            T1.ZW_LABOR_FULLFAMILY_CNT=T2.ZW_LABOR_FULLFAMILY_CNT,
            T1.ZW_IS_SBGJJ=T2.ZW_IS_SBGJJ,
            T1.ZW_HOSPITAL_FEE_REIM=T2.ZW_HOSPITAL_FEE_REIM,
            T1.ASSURE_AMT=T2.ASSURE_AMT,
            T1.ASSURE_CNT=T2.ASSURE_CNT,
            T1.ZX_TH_BAD_ASSURE_AMT=T2.ZX_TH_BAD_ASSURE_AMT,
            T1.ZX_BH_BAD_ASSURE_AMT=T2.ZX_BH_BAD_ASSURE_AMT,
            T1.JR_CUR_ASS_OVERDUE_MAX_DAY=T2.JR_CUR_ASS_OVERDUE_MAX_DAY,
            T1.OUTSTANDING_CNT=T2.OUTSTANDING_CNT,
            T1.OUTSTANDING_AMT=T2.OUTSTANDING_AMT,
            T1.ZX_LOAN_OVERDUE_CNT=T2.ZX_LOAN_OVERDUE_CNT,
            T1.ZX_LOAN_OVERDUE_MON=T2.ZX_LOAN_OVERDUE_MON,
            T1.ZX_LOAN_MAX_OVERDUE_AMT=T2.ZX_LOAN_MAX_OVERDUE_AMT,
            T1.ZX_LOAN_MAX_OVERDUE_MON=T2.ZX_LOAN_MAX_OVERDUE_MON,
            T1.ZX_LOAN_QUERY_CNT=T2.ZX_LOAN_QUERY_CNT,
            T1.ZX_LOAN_PASS_CNT=T2.ZX_LOAN_PASS_CNT,
            T1.LOAN_ACCT_STATUS=T2.LOAN_ACCT_STATUS,
            T1.ZX_LOAN_CUR_OVERDUE_CNT=T2.ZX_LOAN_CUR_OVERDUE_CNT,
            T1.ZX_VALID_CNT=T2.ZX_VALID_CNT,
            T1.ZX_AVG_USED_AMT=T2.ZX_AVG_USED_AMT,
            T1.ZX_CREDIT_AMT=T2.ZX_CREDIT_AMT,
            T1.ZX_AVG_USED_RATE=T2.ZX_AVG_USED_RATE,
            T1.ZX_CREDIT_OVERDUE_ACCT_CNT=T2.ZX_CREDIT_OVERDUE_ACCT_CNT,
            T1.ZX_CREDIT_OVERDUE_MON=T2.ZX_CREDIT_OVERDUE_MON,
            T1.ZX_CREDIT_MAX_OVERDUE_AMT=T2.ZX_CREDIT_MAX_OVERDUE_AMT,
            T1.ZX_CREDIT_MAX_OVERDUE_MON=T2.ZX_CREDIT_MAX_OVERDUE_MON,
            T1.ZX_CREDIT_QUERY_CNT=T2.ZX_CREDIT_QUERY_CNT,
            T1.ZX_CREDIT_PASS_CNT=T2.ZX_CREDIT_PASS_CNT,
            T1.ZX_CREDIT_PASS_RATE=T2.ZX_CREDIT_PASS_RATE,
            T1.ZX_CREDIT_ACCT_STATUS=T2.ZX_CREDIT_ACCT_STATUS,
            T1.ZX_CREDIT_CUR_OVERDUE_CNT=T2.ZX_CREDIT_CUR_OVERDUE_CNT,
            T1.ZX_BAD_INFORMATION=T2.ZX_BAD_INFORMATION,
            T1.ZX_FOECED_PREPAYMENT=T2.ZX_FOECED_PREPAYMENT,
            T1.ZX_PERSONAL_HOUSELOAN_NUM=T2.ZX_PERSONAL_HOUSELOAN_NUM,
            T1.ZX_FIRST_LOAN_MONTH=T2.ZX_FIRST_LOAN_MONTH,
            T1.ZX_FIRST_CREDIT_CARD_MONTH=T2.ZX_FIRST_CREDIT_CARD_MONTH,
            T1.ZX_SEQ_NO=T2.ZX_SEQ_NO,
            T1.ZX_QUERY_DATE=T2.ZX_QUERY_DATE,
            T1.RECORD_FLAG=T2.RECORD_FLAG,
            T1.ZX_LOAN_ORG_CNT=T2.ZX_LOAN_ORG_CNT,
            T1.ZX_CREDIT_TIME_MONTH=T2.ZX_CREDIT_TIME_MONTH,
            T1.JR_DG_LOAN_OVERDUE_CNT=T2.JR_DG_LOAN_OVERDUE_CNT,
            T1.JR_DG_LOAN_STATUS=T2.JR_DG_LOAN_STATUS,
            T1.JR_DEPOSIT=T2.JR_DEPOSIT,
            T1.JR_PREPAYMENT_CNT=T2.JR_PREPAYMENT_CNT,
            T1.JR_PROVISIONS_PAYMENT_CNT=T2.JR_PROVISIONS_PAYMENT_CNT,
            T1.JR_DELAY_PAYMENT_CNT=T2.JR_DELAY_PAYMENT_CNT,
            T1.JR_TOTAL_PAYMENT_CNT=T2.JR_TOTAL_PAYMENT_CNT,
            T1.JR_PART_PAYMENT_CNT=T2.JR_PART_PAYMENT_CNT,
            T1.JR_PROXY_FLAG=T2.JR_PROXY_FLAG,
            T1.JR_PROXY_AMT=T2.JR_PROXY_AMT,
            T1.JR_COOPERATION_LIMIT=T2.JR_COOPERATION_LIMIT,
            T1.JR_ELEC_PROD_CNT=T2.JR_ELEC_PROD_CNT,
            T1.JR_BUS_TRADE_AMT=T2.JR_BUS_TRADE_AMT,
            T1.JR_STOCKAMT=T2.JR_STOCKAMT,
            T1.IS_WHITE=T2.IS_WHITE,
            T1.BLACK_SCORE=T2.BLACK_SCORE,
            T1.BEFORE_SCORE=T2.BEFORE_SCORE,
            T1.AFTER_SCORE=T2.AFTER_SCORE,
            T1.UREG_SCORE=T2.UREG_SCORE,
            T1.ASSET_HOUSE_VALUE=T2.ASSET_HOUSE_VALUE,
            T1.ASSET_HOUSE_FLAG=T2.ASSET_HOUSE_FLAG,
            T1.ASSET_CAR_VALUE=T2.ASSET_CAR_VALUE,
            T1.CLOUD_RISKAPP_CNT=T2.CLOUD_RISKAPP_CNT,
            T1.ZX_NOHOUSE_LOAN_BALANCE=T2.ZX_NOHOUSE_LOAN_BALANCE,
            T1.ZX_HOUSE_LOAN_PER_MONTH=T2.ZX_HOUSE_LOAN_PER_MONTH,
            T1.ZX_LOAN_BALANCE=T2.ZX_LOAN_BALANCE,
            T1.MORTGAGE_AMT=T2.MORTGAGE_AMT,
            T1.GZDW_NONLOCAL=T2.GZDW_NONLOCAL,
            T1.JR_CUST_FLAG=T2.JR_CUST_FLAG,
            T1.ZW_LHCS=T2.ZW_LHCS,
            T1.ZW_CORP_NAME=T2.ZW_CORP_NAME,
            T1.PRIPID=T2.PRIPID,
            T1.ZW_CORP_ENTTYPE=T2.ZW_CORP_ENTTYPE,
            T1.ZW_CORP_INDUSTRYPHY=T2.ZW_CORP_INDUSTRYPHY,
            T1.ZW_CORP_JYNX=T2.ZW_CORP_JYNX,
            T1.ZW_CORP_IS_JYDZ_INCITY=T2.ZW_CORP_IS_JYDZ_INCITY,
            T1.ZW_CORP_IS_JYDZ_CHANGE=T2.ZW_CORP_IS_JYDZ_CHANGE,
            T1.ZW_CORP_IS_ZCZB_REDUCE=T2.ZW_CORP_IS_ZCZB_REDUCE,
            T1.ZW_CORP_IS_FR_CHANGE=T2.ZW_CORP_IS_FR_CHANGE,
            T1.ZW_CORP_IS_GQ_CHANGE=T2.ZW_CORP_IS_GQ_CHANGE,
            T1.ZW_CORP_IS_QYSX=T2.ZW_CORP_IS_QYSX,
            T1.ZW_CORP_IS_SJSFSS=T2.ZW_CORP_IS_SJSFSS,
            T1.ZW_CORP_GSXZCFCS=T2.ZW_CORP_GSXZCFCS,
            T1.ZW_CORP_IS_DXYYZZ=T2.ZW_CORP_IS_DXYYZZ,
            T1.ZW_CORP_IS_SWWF=T2.ZW_CORP_IS_SWWF,
            T1.ZW_CORP_IS_FGWWFWG=T2.ZW_CORP_IS_FGWWFWG,
            T1.ZW_CORP_QYFCSL=T2.ZW_CORP_QYFCSL,
            T1.ZW_CORP_QYCCSL=T2.ZW_CORP_QYCCSL,
            T1.ZW_CORP_GLQYSL=T2.ZW_CORP_GLQYSL,
            T1.ZW_CORP_GLQYKHYSL=T2.ZW_CORP_GLQYKHYSL,
            T1.ZW_CORP_GDSL=T2.ZW_CORP_GDSL,
            T1.ZW_CORP_IS_GLQYSX=T2.ZW_CORP_IS_GLQYSX,
            T1.ZW_CORP_IS_GLQYSS=T2.ZW_CORP_IS_GLQYSS,
            T1.ZW_CORP_IS_GDSX=T2.ZW_CORP_IS_GDSX,
            T1.ZW_CORP_IS_GDSS=T2.ZW_CORP_IS_GDSS,
            T1.ZW_NSJE=T2.ZW_NSJE,
            T1.ZW_NSSBXSSR=T2.ZW_NSSBXSSR,
            T1.ZW_LSBYS=T2.ZW_LSBYS,
            T1.ZW_XSSR=T2.ZW_XSSR,
            T1.ZW_SJNSCS=T2.ZW_SJNSCS,
            T1.ZW_COPR_ESDATE=T2.ZW_COPR_ESDATE,
            T1.ZW_COPR_REGORG=T2.ZW_COPR_REGORG,
            T1.ZW_COPR_REGCAP=T2.ZW_COPR_REGCAP,
            T1.ZW_COPR_RECCAP=T2.ZW_COPR_RECCAP,
            T1.ZW_COPR_OPLOC=T2.ZW_COPR_OPLOC,
            T1.INC_AMT=T2.INC_AMT,
            T1.BUS_INC_AMT=T2.BUS_INC_AMT,
            T1.VALID_BILL_DAYS=T2.VALID_BILL_DAYS,
            T1.BILL_DAYS=T2.BILL_DAYS,
            T1.TRANS_ACTIVE_RATE=T2.TRANS_ACTIVE_RATE,
            T1.BUS_INCOME_MON_STD=T2.BUS_INCOME_MON_STD,
            T1.BUS_INCOME_MON_AVG=T2.BUS_INCOME_MON_AVG,
            T1.BUS_INCOME_MON_RATE=T2.BUS_INCOME_MON_RATE,
            T1.BILL_CNT_MON_STD=T2.BILL_CNT_MON_STD,
            T1.BILL_CNT_MON_AVG=T2.BILL_CNT_MON_AVG,
            T1.BILL_CNT_MON_RATE=T2.BILL_CNT_MON_RATE,
            T1.BUS_AMT_MON_THREE=T2.BUS_AMT_MON_THREE,
            T1.BUS_AMT_MON_RATE=T2.BUS_AMT_MON_RATE,
            T1.BUS_INC_FIVE_AMT=T2.BUS_INC_FIVE_AMT,
            T1.BUS_INC_FIVE_RATE=T2.BUS_INC_FIVE_RATE,
            T1.BUS_BILL_FIVE_CNT=T2.BUS_BILL_FIVE_CNT,
            T1.BUS_BILL_CNT=T2.BUS_BILL_CNT,
            T1.BUS_BILL_FIVE_RATE=T2.BUS_BILL_FIVE_RATE,
            T1.CIRCLE_AMT=T2.CIRCLE_AMT,
            T1.SALE_AMT=T2.SALE_AMT,
            T1.CIRCLE_RATE=T2.CIRCLE_RATE,
            T1.DEPOSIT_AMT=T2.DEPOSIT_AMT,
            T1.TREND_FLAG=T2.TREND_FLAG,
            T1.PERDU_DEBT_CNT=T2.PERDU_DEBT_CNT,
            T1.PERDU_DEBT_AMT=T2.PERDU_DEBT_AMT,
            T1.ZW_TAX_FLAG=T2.ZW_TAX_FLAG,
            T1.JR_TRANS_FLAG=T2.JR_TRANS_FLAG,
            T1.CLOUD_YSZJ=T2.CLOUD_YSZJ,
            T1.ASSET_OTHER_VALUE=T2.ASSET_OTHER_VALUE;

    ELSE

        SELECT ('进行插入操作');
        INSERT INTO data_cust_apply_grade_copy1
        (APPLY_ID,
         ID_CARD,
         TYPE,
         AREA_CODE,
         UPDATE_TIME,
         AGE,
         SEX,
         ZW_HOUSEHOLD,
         ZW_IS_INCITY,
         ZW_EDU_LEVEL,
         ZW_MARRY,
         ZW_POLITICAL,
         ZW_HEALTH,
         ZW_SELF_BUILD_AREA,
         ZW_FOREST_AREA,
         ZW_FARM_AREA,
         ZW_HOUSE_FLAG,
         ZW_CAR_FLAG,
         ZW_PUNISH_CNT,
         ZW_DETAIN_CNT,
         ZW_CONFISCATE_CNT,
         ZW_VIOLATION,
         ZW_HONOR_CNT,
         ZW_ELEC_OVER_CNT,
         ZW_HIGH_CIRCLE_NUM,
         ZW_LOW_CIRCLE_NUM,
         GROUP_FLAG,
         ZW_PERSON_STATUS,
         ALLOWANCES_FLAG,
         ZW_POOR_FLAG,
         ZW_POOR_EDU_FLAG,
         ZW_BAD_HOUSE_FLAG,
         ZW_COM_REPORT_FLAG,
         ZW_XNH_FLAG,
         ZW_HOSPITAL_DAY,
         ZW_HOSPITAL_FEE,
         ZW_BAD_DISEASE_FLAG,
         ZW_MEDICAL_RESCUE_FLAG,
         ZW_DISABILITY_FLAG,
         ZW_HOUSE_FREEZED_FLAG,
         ZW_CAR_FREEZED_FLAG,
         ZW_WATER_OVER_FLAG,
         ZW_COM_OVER_FLAG,
         ZW_ELEC_OVER_FLAG,
         ZW_DISAP_FLAG,
         ZW_SPOUSE_JOB,
         ZW_HOUSE_VALUE,
         ZW_CAR_VALUE,
         ZW_RURAL_MULTIPLE_SUBSIDY,
         ZW_FARM_SUBSIDY,
         ZW_FARM_MACHINE_SUBSIDY,
         ZW_LAND_SUBSIDY,
         ZW_SEED_SUBSIDY,
         ZW_WATER_AVG,
         ZW_ELEC_AVG,
         ZW_OLDER_CNT,
         ZW_CHILD_CNT,
         ZW_LABOR,
         ZW_BUS_LIC_DXSL,
         ZW_BUS_YEAR,
         ZW_BUS_REJECT_FLAG,
         ZW_BUS_INDUSTRY,
         ZW_BUS_STAFF_CNT,
         ZW_BUS_QUOTA_TAX,
         ZW_BUS_OWN_AREA,
         ZW_BUS_LEASE_AREA,
         ZW_BUS_OPE_FLAG,
         ZW_FUND_LEAST_MON,
         ZW_FUND_REJECT_FLAG,
         ZW_FUND_BASE_AMT,
         ZW_WORK_YEAR,
         ZW_JOB_TYPE,
         ZW_ENT_REJECT_FLAG,
         ZW_ENT_SCALE,
         ZW_SOCI_INS_BASE_AMT,
         ZW_SOCI_INS_MON,
         ZW_JOB_CHANGE_CNT,
         ZW_GZDW_AREA,
         GZDW_NAME,
         GZDW_IS_RISK,
         ZW_BUSI_NAME,
         ZW_BUSI_REGNO,
         BUSI_IS_RISK,
         ZW_UNEMPLOY_SYBXLQSL,
         ZW_GGJYB_DWJNRS,
         ZW_HOSPITAL_FEE_SELF,
         ZW_INCITY_HOUSE_FLAG,
         ZW_LABOR_FULLFAMILY_CNT,
         ZW_IS_SBGJJ,
         ZW_HOSPITAL_FEE_REIM,
         ASSURE_AMT,
         ASSURE_CNT,
         ZX_TH_BAD_ASSURE_AMT,
         ZX_BH_BAD_ASSURE_AMT,
         JR_CUR_ASS_OVERDUE_MAX_DAY,
         OUTSTANDING_CNT,
         OUTSTANDING_AMT,
         ZX_LOAN_OVERDUE_CNT,
         ZX_LOAN_OVERDUE_MON,
         ZX_LOAN_MAX_OVERDUE_AMT,
         ZX_LOAN_MAX_OVERDUE_MON,
         ZX_LOAN_QUERY_CNT,
         ZX_LOAN_PASS_CNT,
         LOAN_ACCT_STATUS,
         ZX_LOAN_CUR_OVERDUE_CNT,
         ZX_VALID_CNT,
         ZX_AVG_USED_AMT,
         ZX_CREDIT_AMT,
         ZX_AVG_USED_RATE,
         ZX_CREDIT_OVERDUE_ACCT_CNT,
         ZX_CREDIT_OVERDUE_MON,
         ZX_CREDIT_MAX_OVERDUE_AMT,
         ZX_CREDIT_MAX_OVERDUE_MON,
         ZX_CREDIT_QUERY_CNT,
         ZX_CREDIT_PASS_CNT,
         ZX_CREDIT_PASS_RATE,
         ZX_CREDIT_ACCT_STATUS,
         ZX_CREDIT_CUR_OVERDUE_CNT,
         ZX_BAD_INFORMATION,
         ZX_FOECED_PREPAYMENT,
         ZX_PERSONAL_HOUSELOAN_NUM,
         ZX_FIRST_LOAN_MONTH,
         ZX_FIRST_CREDIT_CARD_MONTH,
         ZX_SEQ_NO,
         ZX_QUERY_DATE,
         RECORD_FLAG,
         ZX_LOAN_ORG_CNT,
         ZX_CREDIT_TIME_MONTH,
         JR_DG_LOAN_OVERDUE_CNT,
         JR_DG_LOAN_STATUS,
         JR_DEPOSIT,
         JR_PREPAYMENT_CNT,
         JR_PROVISIONS_PAYMENT_CNT,
         JR_DELAY_PAYMENT_CNT,
         JR_TOTAL_PAYMENT_CNT,
         JR_PART_PAYMENT_CNT,
         JR_PROXY_FLAG,
         JR_PROXY_AMT,
         JR_COOPERATION_LIMIT,
         JR_ELEC_PROD_CNT,
         JR_BUS_TRADE_AMT,
         JR_STOCKAMT, IS_WHITE,
         BLACK_SCORE,
         BEFORE_SCORE,
         AFTER_SCORE,
         UREG_SCORE,
         ASSET_HOUSE_VALUE,
         ASSET_HOUSE_FLAG,
         ASSET_CAR_VALUE,
         CLOUD_RISKAPP_CNT,
         ZX_NOHOUSE_LOAN_BALANCE,
         ZX_HOUSE_LOAN_PER_MONTH,
         ZX_LOAN_BALANCE,
         MORTGAGE_AMT,
         GZDW_NONLOCAL,
         JR_CUST_FLAG,
         ZW_LHCS,
         ZW_CORP_NAME,
         PRIPID,
         ZW_CORP_ENTTYPE,
         ZW_CORP_INDUSTRYPHY,
         ZW_CORP_JYNX,
         ZW_CORP_IS_JYDZ_INCITY,
         ZW_CORP_IS_JYDZ_CHANGE,
         ZW_CORP_IS_ZCZB_REDUCE,
         ZW_CORP_IS_FR_CHANGE,
         ZW_CORP_IS_GQ_CHANGE,
         ZW_CORP_IS_QYSX,
         ZW_CORP_IS_SJSFSS,
         ZW_CORP_GSXZCFCS,
         ZW_CORP_IS_DXYYZZ,
         ZW_CORP_IS_SWWF,
         ZW_CORP_IS_FGWWFWG,
         ZW_CORP_QYFCSL,
         ZW_CORP_QYCCSL,
         ZW_CORP_GLQYSL,
         ZW_CORP_GLQYKHYSL,
         ZW_CORP_GDSL,
         ZW_CORP_IS_GLQYSX,
         ZW_CORP_IS_GLQYSS,
         ZW_CORP_IS_GDSX,
         ZW_CORP_IS_GDSS,
         ZW_NSJE,
         ZW_NSSBXSSR,
         ZW_LSBYS,
         ZW_XSSR,
         ZW_SJNSCS,
         ZW_COPR_ESDATE,
         ZW_COPR_REGORG,
         ZW_COPR_REGCAP,
         ZW_COPR_RECCAP,
         ZW_COPR_OPLOC,
         INC_AMT,
         BUS_INC_AMT,
         VALID_BILL_DAYS,
         BILL_DAYS,
         TRANS_ACTIVE_RATE,
         BUS_INCOME_MON_STD,
         BUS_INCOME_MON_AVG,
         BUS_INCOME_MON_RATE,
         BILL_CNT_MON_STD,
         BILL_CNT_MON_AVG,
         BILL_CNT_MON_RATE,
         BUS_AMT_MON_THREE,
         BUS_AMT_MON_RATE,
         BUS_INC_FIVE_AMT,
         BUS_INC_FIVE_RATE,
         BUS_BILL_FIVE_CNT,
         BUS_BILL_CNT,
         BUS_BILL_FIVE_RATE,
         CIRCLE_AMT,
         SALE_AMT,
         CIRCLE_RATE,
         DEPOSIT_AMT,
         TREND_FLAG,
         PERDU_DEBT_CNT,
         PERDU_DEBT_AMT,
         ZW_TAX_FLAG,
         JR_TRANS_FLAG,
         CLOUD_YSZJ,
         ASSET_OTHER_VALUE)
        SELECT A.APPLY_ID,
               A.ID_CARD,
               A.TYPE,
               A.AREA_CODE,
               CURRENT_TIMESTAMP                                                                                    UPDATE_TIME,
               B.AGE,
               B.SEX,
               B.ZW_HOUSEHOLD,
               B.ZW_IS_INCITY,
               case
                   when instr(ZX_EDUCATION, '小学') + instr(ZX_EDUCATION, '初中') + instr(ZX_EDUCATION, '文盲') >= 1 then 1
                   when instr(ZX_EDUCATION, '高中') + instr(ZX_EDUCATION, '中等专业学校') + instr(ZX_EDUCATION, '技术学校') >= 1
                       then 2
                   when instr(ZX_EDUCATION, '专科') >= 1 then 3
                   when instr(ZX_EDUCATION, '本科') + instr(ZX_EDUCATION, '研究生') + instr(ZX_EDUCATION, '博士') >= 1 then 4
                   else 5 end                                                                                    as ZW_EDU_LEVEL,
               B.ZW_MARRY,
               B.ZW_POLITICAL,
               B.ZW_HEALTH,
               B.ZW_SELF_BUILD_AREA,
               B.ZW_FOREST_AREA,
               B.ZW_FARM_AREA,
               IFNULL(N.ASSET_HOUSE_FLAG, 0)                                                                     AS ZW_HOUSE_FLAG,
               B.ZW_CAR_FLAG,
               B.ZW_PUNISH_CNT,
               B.ZW_DETAIN_CNT,
               B.ZW_CONFISCATE_CNT,
               B.ZW_VIOLATION,
               B.ZW_HONOR_CNT,
               B.ZW_ELEC_OVER_CNT,
               B.ZW_HIGH_CIRCLE_NUM,
               B.ZW_LOW_CIRCLE_NUM,
               CASE
                   WHEN IFNULL(B.ZW_GROUP_FLAG, 0) + IFNULL(D.JR_GROUP_FLAG, 0) > 0 THEN 1
                   ELSE 0 END                                                                                    AS GROUP_FLAG,
               B.ZW_PERSON_STATUS,
               CASE
                   WHEN IFNULL(M.ZW_ALLOWANCES_FLAG, 0) + IFNULL(D.JR_ALLOWANCES_FLAG, 0) > 0 THEN 1
                   ELSE 0 END                                                                                    AS ALLOWANCES_FLAG,
               B.ZW_POOR_FLAG,
               B.ZW_POOR_EDU_FLAG,
               B.ZW_BAD_HOUSE_FLAG,
               B.ZW_COM_REPORT_FLAG,
               B.ZW_XNH_FLAG,
               B.ZW_HOSPITAL_DAY,
               B.ZW_HOSPITAL_FEE,
               B.ZW_BAD_DISEASE_FLAG,
               B.ZW_MEDICAL_RESCUE_FLAG,
               B.ZW_DISABILITY_FLAG,
               B.ZW_HOUSE_FREEZED_FLAG,
               B.ZW_CAR_FREEZED_FLAG,
               B.ZW_WATER_OVER_FLAG,
               B.ZW_COM_OVER_FLAG,
               B.ZW_ELEC_OVER_FLAG,
               B.ZW_DISAP_FLAG,
               F.CUSTOMER_GROUP                                                                                  AS ZW_SPOUSE_JOB,
               IFNULL(N.ASSET_HOUSE_VALUE, 0)                                                                    AS ZW_HOUSE_VALUE,
               B.ZW_CAR_VALUE,
               if(B.ZW_RURAL_MULTIPLE_SUBSIDY >= D.JR_RURAL_MULTIPLE_SUBSIDY, B.ZW_RURAL_MULTIPLE_SUBSIDY,
                  D.JR_RURAL_MULTIPLE_SUBSIDY)                                                                   AS ZW_RURAL_MULTIPLE_SUBSIDY,
               if(B.ZW_FARM_SUBSIDY >= D.JR_FARM_SUBSIDY, B.ZW_FARM_SUBSIDY,
                  D.JR_FARM_SUBSIDY)                                                                             AS ZW_FARM_SUBSIDY,
               if(B.ZW_FARM_MACHINE_SUBSIDY >= D.JR_FARM_MACHINE_SUBSIDY, B.ZW_FARM_MACHINE_SUBSIDY,
                  D.JR_FARM_MACHINE_SUBSIDY)                                                                     AS ZW_FARM_MACHINE_SUBSIDY,
               if(B.ZW_LAND_SUBSIDY >= D.JR_LAND_SUBSIDY, B.ZW_LAND_SUBSIDY,
                  D.JR_LAND_SUBSIDY)                                                                             AS ZW_LAND_SUBSIDY,
               if(B.ZW_SEED_SUBSIDY >= D.JR_SEED_SUBSIDY, B.ZW_SEED_SUBSIDY,
                  D.JR_SEED_SUBSIDY)                                                                             AS ZW_SEED_SUBSIDY,
               B.ZW_WATER_AVG,
               B.ZW_ELEC_AVG,
               S.ZW_OLDER_CNT,
               S.ZW_CHILD_CNT,
               S.ZW_LABOR,
               B.ZW_BUS_LIC_DXSL,
               B.ZW_BUS_YEAR,
               B.ZW_BUS_REJECT_FLAG,
               B.ZW_BUS_INDUSTRY,
               B.ZW_BUS_STAFF_CNT,
               B.ZW_BUS_QUOTA_TAX,
               B.ZW_BUS_OWN_AREA,
               B.ZW_BUS_LEASE_AREA,
               B.ZW_BUS_OPE_FLAG,
               B.ZW_FUND_LEAST_MON,
               B.ZW_FUND_REJECT_FLAG,
               B.ZW_FUND_BASE_AMT,
               B.ZW_WORK_YEAR,
               B.ZW_JOB_TYPE,
               B.ZW_ENT_REJECT_FLAG,
               B.ZW_ENT_SCALE,
               B.ZW_SOCI_INS_BASE_AMT,
               B.ZW_SOCI_INS_MON,
               B.ZW_JOB_CHANGE_CNT,
               B.ZW_GZDW_AREA,
               IFNULL(B.ZW_GZDW_NAME, C.ZX_GZDW_NAME)                                                            AS GZDW_NAME,
               0                                                                                                 AS GZDW_IS_RISK,
               B.ZW_BUSI_NAME,
               B.ZW_BUSI_REGNO,
               0                                                                                                 AS BUSI_IS_RISK,
               B.ZW_UNEMPLOY_SYBXLQSL,
               B.ZW_GGJYB_DWJNRS,
               B.ZW_HOSPITAL_FEE_SELF,
               B.ZW_INCITY_HOUSE_FLAG,
               S.ZW_LABOR_FULLFAMILY_CNT,
               B.ZW_IS_SBGJJ,
               M.ZW_HOSPITAL_FEE_REIM,
               IFNULL(C.ZX_BH_ASSURE_BALANCE, 0) +
               IFNULL(C.ZX_TH_ASSURE_BALANCE, 0)                                                                 AS ASSURE_AMT,
               IFNULL(C.ZX_BH_CUR_ASSURE_CNT, 0) +
               IFNULL(C.ZX_TH_CUR_ASSURE_CNT, 0)                                                                 AS ASSURE_CNT,
               C.ZX_TH_BAD_ASSURE_AMT,
               C.ZX_BH_BAD_ASSURE_AMT,
               D.JR_CUR_ASS_OVERDUE_MAX_DAY,
               IFNULL(C.ZX_BH_OUTSTANDING_CNT, 0) +
               IFNULL(ZX_TH_OUTSTANDING_CNT, 0)                                                                  AS OUTSTANDING_CNT,
               IFNULL(ZX_TH_OUTSTANDING_AMT, 0)                                                                  AS OUTSTANDING_AMT,
               C.ZX_LOAN_OVERDUE_CNT,
               C.ZX_LOAN_OVERDUE_MON,
               C.ZX_LOAN_MAX_OVERDUE_AMT,
               C.ZX_LOAN_MAX_OVERDUE_MON,
               C.ZX_LOAN_QUERY_CNT,
               C.ZX_LOAN_PASS_CNT,
               CASE WHEN IFNULL(C.ZX_LOAN_ACCT_STATUS, 0) >= 1 THEN 1 ELSE 0 END                                 AS LOAN_ACCT_STATUS,
               C.ZX_LOAN_CUR_OVERDUE_CNT,
               C.ZX_VALID_CNT,
               C.ZX_AVG_USED_AMT,
               C.ZX_CREDIT_AMT,
               C.ZX_AVG_USED_RATE,
               C.ZX_CREDIT_OVERDUE_ACCT_CNT,
               C.ZX_CREDIT_OVERDUE_MON,
               C.ZX_CREDIT_MAX_OVERDUE_AMT,
               C.ZX_CREDIT_MAX_OVERDUE_MON,
               C.ZX_CREDIT_QUERY_CNT,
               C.ZX_CREDIT_PASS_CNT,
               C.ZX_CREDIT_PASS_RATE,
               C.ZX_CREDIT_ACCT_STATUS,
               C.ZX_CREDIT_CUR_OVERDUE_CNT,
               C.ZX_BAD_INFORMATION,
               C.ZX_FOECED_PREPAYMENT,
               C.ZX_PERSONAL_HOUSELOAN_NUM,
               C.ZX_FIRST_LOAN_MONTH,
               C.ZX_FIRST_CREDIT_CARD_MONTH,
               C.ZX_SEQ_NO,
               C.ZX_QUERY_DATE,
               C.RECORD_FLAG,
               C.ZX_LOAN_ORG_CNT,
               C.ZX_CREDIT_TIME_MONTH,
               E.JR_DG_LOAN_OVERDUE_CNT,
               E.JR_DG_LOAN_STATUS,
               E.JR_DEPOSIT,
               D.JR_PREPAYMENT_CNT,
               D.JR_PROVISIONS_PAYMENT_CNT,
               D.JR_DELAY_PAYMENT_CNT,
               D.JR_TOTAL_PAYMENT_CNT,
               D.JR_PART_PAYMENT_CNT,
               D.JR_PROXY_FLAG,
               D.JR_PROXY_AMT,
               D.JR_COOPERATION_LIMIT,
               D.JR_ELEC_PROD_CNT,
               D.JR_BUS_TRADE_AMT,
               D.JR_STOCKAMT,
               CASE
                   WHEN IFNULL(G.ID_CARD, 0) > 0 THEN '1'
                   WHEN IFNULL(H.ID_CARD, 0) > 0 THEN '2'
                   END                                                                                           AS IS_WHITE,
               K.BLACK_SCORE,
               K.BEFORE_SCORE,
               K.AFTER_SCORE,
               K.UREG_SCORE,
               IFNULL(N.ASSET_HOUSE_VALUE, 0)                                                                    AS ASSET_HOUSE_VALUE,
               IFNULL(N.ASSET_HOUSE_FLAG, 0)                                                                     AS ASSET_HOUSE_FLAG,
               IFNULL(O.ASSET_CAR_VALUE, 0)                                                                      AS ASSET_CAR_VALUE,
               CAST(IFNULL(P.CLOUD_RISKAPP_CNT, 0) AS DECIMAL(10, 2))                                            AS CLOUD_RISKAPP_CNT,
               C.ZX_NOHOUSE_LOAN_BALANCE,
               C.ZX_HOUSE_LOAN_PER_MONTH,
               C.ZX_LOAN_BALANCE,
               D.MORTGAGE_AMT,
               Q.GZDW_NONLOCAL,
               IFNULL(D.JR_CUST_FLAG, 0)                                                                         AS JR_CUST_FLAG,
               IFNULL(B.ZW_LHCS, 0)                                                                              AS ZW_LHCS,

               IFNULL(B.ZW_CORP_NAME, 0)                                                                         AS ZW_CORP_NAME,
               IFNULL(B.PRIPID, 0)                                                                               AS PRIPID,
               IFNULL(B.ZW_CORP_ENTTYPE, 0)                                                                      AS ZW_CORP_ENTTYPE,
               IFNULL(B.ZW_CORP_INDUSTRYPHY, 0)                                                                  AS ZW_CORP_INDUSTRYPHY,
               IFNULL(B.ZW_CORP_JYNX, 0)                                                                         AS ZW_CORP_JYNX,
               IFNULL(B.ZW_CORP_IS_JYDZ_INCITY, 0)                                                               AS ZW_CORP_IS_JYDZ_INCITY,
               IFNULL(B.ZW_CORP_IS_JYDZ_CHANGE, 0)                                                               AS ZW_CORP_IS_JYDZ_CHANGE,
               IFNULL(B.ZW_CORP_IS_ZCZB_REDUCE, 0)                                                               AS ZW_CORP_IS_ZCZB_REDUCE,
               IFNULL(B.ZW_CORP_IS_FR_CHANGE, 0)                                                                 AS ZW_CORP_IS_FR_CHANGE,
               IFNULL(B.ZW_CORP_IS_GQ_CHANGE, 0)                                                                 AS ZW_CORP_IS_GQ_CHANGE,
               IFNULL(B.ZW_CORP_IS_QYSX, 0)                                                                      AS ZW_CORP_IS_QYSX,
               IFNULL(B.ZW_CORP_IS_SJSFSS, 0)                                                                    AS ZW_CORP_IS_SJSFSS,
               IFNULL(B.ZW_CORP_GSXZCFCS, 0)                                                                     AS ZW_CORP_GSXZCFCS,
               IFNULL(B.ZW_CORP_IS_DXYYZZ, 0)                                                                    AS ZW_CORP_IS_DXYYZZ,
               IFNULL(B.ZW_CORP_IS_SWWF, 0)                                                                      AS ZW_CORP_IS_SWWF,
               IFNULL(B.ZW_CORP_IS_FGWWFWG, 0)                                                                   AS ZW_CORP_IS_FGWWFWG,
               IFNULL(B.ZW_CORP_QYFCSL, 0)                                                                       AS ZW_CORP_QYFCSL,
               IFNULL(B.ZW_CORP_QYCCSL, 0)                                                                       AS ZW_CORP_QYCCSL,
               IFNULL(B.ZW_CORP_GLQYSL, 0)                                                                       AS ZW_CORP_GLQYSL,
               IFNULL(B.ZW_CORP_GLQYKHYSL, 0)                                                                    AS ZW_CORP_GLQYKHYSL,
               IFNULL(B.ZW_CORP_GDSL, 0)                                                                         AS ZW_CORP_GDSL,
               IFNULL(B.ZW_CORP_IS_GLQYSX, 0)                                                                    AS ZW_CORP_IS_GLQYSX,
               IFNULL(B.ZW_CORP_IS_GLQYSS, 0)                                                                    AS ZW_CORP_IS_GLQYSS,
               IFNULL(B.ZW_CORP_IS_GDSX, 0)                                                                      AS ZW_CORP_IS_GDSX,
               IFNULL(B.ZW_CORP_IS_GDSS, 0)                                                                      AS ZW_CORP_IS_GDSS,
               IFNULL(B.ZW_NSJE, 0)                                                                              AS ZW_NSJE,
               IFNULL(B.ZW_NSSBXSSR, 0)                                                                          AS ZW_NSSBXSSR,
               IFNULL(B.ZW_LSBYS, 0)                                                                             AS ZW_LSBYS,
               IFNULL(B.ZW_XSSR, 0)                                                                              AS ZW_XSSR,
               IFNULL(B.ZW_SJNSCS, 0)                                                                            AS ZW_SJNSCS,
               IFNULL(B.ZW_COPR_ESDATE, 0)                                                                       AS ZW_COPR_ESDATE,
               IFNULL(B.ZW_COPR_REGORG, 0)                                                                       AS ZW_COPR_REGORG,
               IFNULL(B.ZW_COPR_REGCAP, 0)                                                                       AS ZW_COPR_REGCAP,
               IFNULL(B.ZW_COPR_RECCAP, 0)                                                                       AS ZW_COPR_RECCAP,
               IFNULL(B.ZW_COPR_OPLOC, 0)                                                                        AS ZW_COPR_OPLOC,

               IFNULL(R.INC_AMT, 0)                                                                              AS INC_AMT,
               IFNULL(R.BUS_INC_AMT, 0)                                                                          AS BUS_INC_AMT,
               IFNULL(R.VALID_BILL_DAYS, 0)                                                                      AS VALID_BILL_DAYS,
               IFNULL(R.BILL_DAYS, 0)                                                                            AS BILL_DAYS,
               IFNULL(R.TRANS_ACTIVE_RATE, 0)                                                                    AS TRANS_ACTIVE_RATE,
               IFNULL(R.BUS_INCOME_MON_STD, 0)                                                                   AS BUS_INCOME_MON_STD,
               IFNULL(R.BUS_INCOME_MON_AVG, 0)                                                                   AS BUS_INCOME_MON_AVG,
               IFNULL(R.BUS_INCOME_MON_RATE, 0)                                                                  AS BUS_INCOME_MON_RATE,
               IFNULL(R.BILL_CNT_MON_STD, 0)                                                                     AS BILL_CNT_MON_STD,
               IFNULL(R.BILL_CNT_MON_AVG, 0)                                                                     AS BILL_CNT_MON_AVG,
               IFNULL(R.BILL_CNT_MON_RATE, 0)                                                                    AS BILL_CNT_MON_RATE,
               IFNULL(R.BUS_AMT_MON_THREE, 0)                                                                    AS BUS_AMT_MON_THREE,
               IFNULL(R.BUS_AMT_MON_RATE, 0)                                                                     AS BUS_AMT_MON_RATE,
               IFNULL(R.BUS_INC_FIVE_AMT, 0)                                                                     AS BUS_INC_FIVE_AMT,
               IFNULL(R.BUS_INC_FIVE_RATE, 0)                                                                    AS BUS_INC_FIVE_RATE,
               IFNULL(R.BUS_BILL_FIVE_CNT, 0)                                                                    AS BUS_BILL_FIVE_CNT,
               IFNULL(R.BUS_BILL_CNT, 0)                                                                         AS BUS_BILL_CNT,
               IFNULL(R.BUS_BILL_FIVE_RATE, 0)                                                                   AS BUS_BILL_FIVE_RATE,
               IFNULL(R.CIRCLE_AMT, 0)                                                                           AS CIRCLE_AMT,
               IFNULL(R.SALE_AMT, 0)                                                                             AS SALE_AMT,
               IFNULL(R.CIRCLE_RATE, 0)                                                                          AS CIRCLE_RATE,
               IFNULL(R.DEPOSIT_AMT, 0)                                                                          AS DEPOSIT_AMT,
               IFNULL(R.TREND_FLAG, 0)                                                                           AS TREND_FLAG,
               IFNULL(R.PERDU_DEBT_CNT, 0)                                                                       AS PERDU_DEBT_CNT,
               IFNULL(R.PERDU_DEBT_AMT, 0)                                                                       AS PERDU_DEBT_AMT,
               CASE WHEN IFNULL(B.ZW_NSJE, 0) > 0 THEN 1 ELSE 0 END                                              AS ZW_TAX_FLAG,
               CASE WHEN IFNULL(R.INC_AMT, 0) > 0 THEN 1 ELSE 0 END                                              AS JR_TRANS_FLAG,
               IFNULL((CASE
                           WHEN P.CLOUD_BOOK_KEY_STAFF >= 5 THEN -1
                           WHEN U.IMEI IS NOT NULL THEN -1
                           ELSE P.CLOUD_BOOK_KEY
                   END),
                      0)                                                                                         AS CLOUD_YSZJ,
               IFNULL(V.ASSET_OTHER_VALUE, 0)                                                                    AS ASSET_OTHER_VALUE
        FROM (SELECT APPLYID AS APPLY_ID, PTYPE AS TYPE, IDCARD AS ID_CARD, AREACODE AS AREA_CODE FROM DUAL) A
                 LEFT JOIN data_social_apply_grade_detail B
                           ON A.APPLY_ID = B.APPLY_ID AND A.ID_CARD = B.ID_CARD AND A.AREA_CODE = B.AREA_CODE
                 LEFT JOIN data_credit_apply_grade_detail C
                           ON A.APPLY_ID = C.APPLY_ID AND A.TYPE = C.TYPE AND A.ID_CARD = C.ID_CARD AND
                              A.AREA_CODE = C.AREA_CODE
                 LEFT JOIN data_bank_apply_grade_detail D
                           ON A.APPLY_ID = D.APPLY_ID AND A.ID_CARD = D.ID_CARD AND A.AREA_CODE = D.AREA_CODE

                 LEFT JOIN (
            select APPLYID                                                                AS APPLY_ID,
                   IDCARD                                                                 AS ID_CARD,
                   PTYPE                                                                  AS TYPE,
                   AREACODE                                                               AS AREA_CODE,
                   MAX(a.JR_DG_LOAN_STATUS)                                               AS JR_DG_LOAN_STATUS,
                   SUM(a.JR_DG_LOAN_OVERDUE_CNT)                                          AS JR_DG_LOAN_OVERDUE_CNT,
                   SUM(case when b.apply_relation in (1, 2) then a.JR_DEPOSIT else 0 end) AS JR_DEPOSIT
            from data_bank_apply_grade_detail a
                     JOIN cust_family_mx b
                          on a.ID_CARD = b.MEMBER_ID_CARD and a.apply_id = b.SEQ_NO and a.AREA_CODE = b.AREA_CODE
            WHERE a.APPLY_ID = APPLYID
              and a.AREA_CODE = AREACODE
              and b.TYPE = PTYPE
        ) E ON A.APPLY_ID = E.APPLY_ID AND A.ID_CARD = E.ID_CARD AND A.AREA_CODE = E.AREA_CODE

                 LEFT JOIN (
            select MEMBER_ID_CARD as ID_CARD,
                   CUSTOMER_GROUP as CUSTOMER_GROUP
            from cust_family_mx
            WHERE SEQ_NO = APPLYID
              AND TYPE = PTYPE
              AND AREA_CODE = AREACODE
              and APPLY_RELATION = 2
        ) F ON A.ID_CARD <> F.ID_CARD

                 LEFT JOIN DATA_WHITE_VIP_INFO G ON A.ID_CARD = G.ID_CARD

                 LEFT JOIN DATA_WHITE_LIST_INFO H ON A.ID_CARD = H.ID_CARD

                 LEFT JOIN data_graph_apply_grade K
                           ON A.APPLY_ID = K.APPLY_ID AND A.TYPE = K.MEMBER_TYPE AND A.ID_CARD = K.ID_CARD AND
                              A.AREA_CODE = K.AREA_CODE

                 LEFT JOIN (
            select a.APPLY_ID,
                   A.AREA_CODE,
                   MAX(a.ZW_ALLOWANCES_FLAG)                                               AS ZW_ALLOWANCES_FLAG,
                   SUM(CASE WHEN AGE < 60 THEN IFNULL(ZW_HOSPITAL_FEE_REIM, 0) ELSE 0 END) AS ZW_HOSPITAL_FEE_REIM
            FROM DATA_SOCIAL_APPLY_GRADE_DETAIL a
                     join cust_family_mx b
                          on a.ID_CARD = b.MEMBER_ID_CARD and a.APPLY_ID = b.SEQ_NO and a.AREA_CODE = b.AREA_CODE
            where a.APPLY_ID = APPLYID
              and a.ID_CARD = IDCARD
              and a.AREA_CODE = AREACODE
              and b.TYPE = PTYPE
              and b.APPLY_RELATION in (1, 2)
        ) M ON A.APPLY_ID = M.APPLY_ID AND A.AREA_CODE = M.AREA_CODE

                 LEFT JOIN (
            SELECT APPLYID                                    AS APPLY_ID,
                   IDCARD                                     AS ID_CARD,
                   PTYPE                                      AS TYPE,
                   AREACODE                                   AS AREA_CODE,
                   SUM(A.HOUSE_VALUE)                         AS ASSET_HOUSE_VALUE,
                   (CASE WHEN COUNT(0) = 0 THEN 0 ELSE 1 END) AS ASSET_HOUSE_FLAG
            FROM DATA_CUST_ASSET_HOUSE A
            WHERE A.APPLY_ID = APPLYID
              AND A.AREA_CODE = AREACODE
              AND A.TYPE = PTYPE
              AND A.ID_CARD IN
                  (
                      SELECT MEMBER_ID_CARD
                      FROM cust_family_mx
                      WHERE SEQ_NO = APPLYID
                        AND apply_relation in (1, 2)
                        AND TYPE = PTYPE
                        and AREA_CODE = AREACODE
                  )
        ) N ON A.ID_CARD = N.ID_CARD AND A.APPLY_ID = N.APPLY_ID AND A.AREA_CODE = N.AREA_CODE AND A.TYPE = N.TYPE

                 LEFT JOIN
             (
                 SELECT APPLYID  AS APPLY_ID,
                        IDCARD   AS ID_CARD,
                        PTYPE    AS TYPE,
                        AREACODE AS AREA_CODE,
                        SUM(CASE
                                WHEN A.CLLX IN
                                     ('K30', 'K31', 'K32', 'K33', 'K34', 'K40', 'K41', 'K42', 'K43', 'K16', 'K25',
                                      'K26') AND A.CL <= 15
                                    THEN A.CAR_VALUE
                                ELSE 0
                            END) AS ASSET_CAR_VALUE
                 FROM DATA_CUST_ASSET_CAR A
                 WHERE A.APPLY_ID = APPLYID
                   AND A.AREA_CODE = AREACODE
                   AND A.TYPE = PTYPE
                   AND A.ID_CARD IN
                       (
                           SELECT MEMBER_ID_CARD
                           FROM cust_family_mx
                           WHERE SEQ_NO = APPLYID
                             AND apply_relation in (1, 2)
                             AND TYPE = PTYPE
                             and AREA_CODE = AREACODE
                       )
             ) O ON A.ID_CARD = O.ID_CARD AND A.APPLY_ID = O.APPLY_ID AND A.AREA_CODE = O.AREA_CODE AND A.TYPE = O.TYPE

                 LEFT JOIN public_data_autifraud P
                           ON A.APPLY_ID = P.UNIQUE_NO AND A.ID_CARD = P.ID_CARD AND A.AREA_CODE = P.AREA_CODE

                 left join (
            select T.*,
                   max(ifnull(T3.NONLOCAL_FLAG, 0)) AS GZDW_NONLOCAL
            from data_social_apply_grade_detail T
                     left join data_government_dep_info T3 on T.zw_gjj_dwzh = T3.COMPANY_NO
            WHERE T.APPLY_ID = APPLYID
              AND T.ID_CARD = IDCARD
              AND T.AREA_CODE = AREACODE
        ) Q on A.APPLY_ID = Q.APPLY_ID AND A.ID_CARD = Q.ID_CARD AND A.AREA_CODE = Q.AREA_CODE

                 left join data_bill_apply_grade_detail R
                           ON A.APPLY_ID = R.APPLY_ID AND A.TYPE = R.TYPE AND A.ID_CARD = R.ID_CARD AND
                              A.AREA_CODE = R.AREA_CODE

                 LEFT JOIN (
            select APPLYID AS                                                      APPLY_ID,
                   IDCARD AS                                                       ID_CARD,
                   PTYPE AS                                                        TYPE,
                   AREACODE AS                                                     AREA_CODE,
                   sum(case
                           when a.AGE >= 22 and a.AGE <= 55 and b.apply_relation in (1, 2) then 1
                           else 0 end) AS                                          ZW_LABOR,
                   sum(case when a.AGE >= 22 and a.AGE <= 55 then 1 else 0 end) AS ZW_LABOR_FULLFAMILY_CNT,
                   sum(case when a.AGE < 18 then 1 else 0 end) AS                  ZW_CHILD_CNT,
                   sum(case when a.AGE > 60 then 1 else 0 end) AS                  ZW_OLDER_CNT
            from data_social_apply_grade_detail a
                     join cust_family_mx b
                          on a.ID_CARD = b.MEMBER_ID_CARD and a.APPLY_ID = b.SEQ_NO and a.AREA_CODE = b.AREA_CODE
            where a.APPLY_ID = APPLYID
              and a.AREA_CODE = AREACODE
              and b.TYPE = PTYPE
        ) S ON A.APPLY_ID = S.APPLY_ID AND A.ID_CARD = S.ID_CARD AND A.AREA_CODE = S.AREA_CODE and A.TYPE = S.TYPE

-- LEFT JOIN public_data_autifraud T ON A.APPLY_ID = T.UNIQUE_NO AND A.ID_CARD = T.ID_CARD AND A.AREA_CODE = T.AREA_CODE

                 LEFT JOIN
             (
                 SELECT A.APPLY_ID, A.ID_CARD, A.AREA_CODE, B.IMEI
                 FROM apply_credit A
                          LEFT JOIN DATA_WHITE_EQUIPMENT_INFO B ON A.IMEI = B.IMEI
                 WHERE A.APPLY_ID = APPLYID
                   AND A.ID_CARD = IDCARD
                   AND A.AREA_CODE = AREACODE
             ) U ON A.APPLY_ID = U.APPLY_ID AND A.ID_CARD = U.ID_CARD AND A.AREA_CODE = U.AREA_CODE


                 LEFT JOIN (
            SELECT APPLYID                  AS APPLY_ID,
                   IDCARD                   AS ID_CARD,
                   PTYPE                    AS TYPE,
                   AREACODE                 AS AREA_CODE,
                   SUM(C.ASSET_OTHER_VALUE) AS ASSET_OTHER_VALUE
            FROM (
-- 计算本人抵押质押
                     SELECT IFNULL(SUM(ROUND(A.LOAN_AMOUNT / 0.7, 2)), 0) AS ASSET_OTHER_VALUE
                     FROM report_loan_info A
                              LEFT JOIN
                          (
                              SELECT APPLY_ID, ID_CARD, TYPE, AREA_CODE
                              FROM DATA_CUST_ASSET_HOUSE
                              WHERE APPLY_ID = APPLYID
                                AND AREA_CODE = AREACODE
                                AND TYPE = PTYPE
                                AND ID_CARD = IDCARD
                          ) B
                          ON A.APPLY_ID = B.APPLY_ID AND A.ID_CARD = B.ID_CARD AND A.AREA_CODE = B.AREA_CODE
                     WHERE A.APPLY_ID = APPLYID
                       AND A.AREA_CODE = AREACODE
                       AND A.ID_CARD = IDCARD
                       AND B.APPLY_ID IS NULL
                       AND A.REPORT_STATUS = 0
                       AND A.IS_CLEAN = 0
                       AND (instr(A.LOAN_WAY, '抵押') > 0 OR instr(A.LOAN_WAY, '质押') > 0)
                       AND instr(A.loan_type, '房') <= 0
                       AND instr(A.loan_type, '车') <= 0

                     UNION
-- 计算配偶抵押质押
                     SELECT IFNULL(SUM(ROUND(A.LOAN_AMOUNT / 0.7, 2)), 0) AS ASSET_OTHER_VALUE
                     FROM report_loan_info A
                              LEFT JOIN
                          (
                              SELECT APPLY_ID, ID_CARD, TYPE, AREA_CODE
                              FROM DATA_CUST_ASSET_HOUSE
                              WHERE APPLY_ID = APPLYID
                                AND AREA_CODE = AREACODE
                                AND TYPE = PTYPE
                                AND ID_CARD =
                                    (
                                        SELECT MEMBER_ID_CARD
                                        FROM cust_family_mx
                                        WHERE SEQ_NO = APPLYID
                                          AND apply_relation in (1, 2)
                                          AND TYPE = PTYPE
                                          and AREA_CODE = AREACODE
                                          AND MEMBER_ID_CARD <> IDCARD
                                    )
                          ) B
                          ON A.APPLY_ID = B.APPLY_ID AND A.ID_CARD = B.ID_CARD AND A.AREA_CODE = B.AREA_CODE
                     WHERE A.APPLY_ID = APPLYID
                       AND A.AREA_CODE = AREACODE
                       AND A.ID_CARD =
                           (
                               SELECT MEMBER_ID_CARD
                               FROM cust_family_mx
                               WHERE SEQ_NO = APPLYID
                                 AND apply_relation in (1, 2)
                                 AND TYPE = PTYPE
                                 and AREA_CODE = AREACODE
                                 AND MEMBER_ID_CARD <> IDCARD
                           )
                       AND B.APPLY_ID IS NULL
                       AND A.REPORT_STATUS = 0
                       AND A.IS_CLEAN = 0
                       AND (instr(A.LOAN_WAY, '抵押') > 0 OR instr(A.LOAN_WAY, '质押') > 0)
                       AND instr(A.loan_type, '房') <= 0
                       AND instr(A.loan_type, '车') <= 0
                 ) C
        ) V ON A.ID_CARD = V.ID_CARD AND A.APPLY_ID = V.APPLY_ID AND A.AREA_CODE = V.AREA_CODE AND A.TYPE = V.TYPE;


    END IF;

    COMMIT;


END;

