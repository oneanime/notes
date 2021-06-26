create
    definer = root@`%` procedure SP_DATA_CUST_ASSET_HOUSE_INSERT(IN APPLYID varchar(100), IN SEQNO varchar(100),
                                                                 IN IDCARD varchar(20), IN PTYPE varchar(10),
                                                                 IN AREACODE varchar(30), IN DATATYPE varchar(4))
BEGIN

    DECLARE VV_TASK VARCHAR(200);

/****************************************实时申请房产****************************************************/
    IF DATATYPE = '1' THEN
        SET VV_TASK = '实时申请房产';

        delete
        from data_cust_asset_house
        where APPLY_ID = APPLYID AND ID_CARD = IDCARD AND TYPE = PTYPE AND AREA_CODE = AREACODE;
        commit;

-- 根据申请人传入的参数进行政务与征信房产的去重操作
        INSERT INTO data_cust_asset_house(APPLY_ID, TYPE, AREA_CODE, ID_CARD, QLRMC, FWZL, JZMJ, AREA_AVGPRICE,
                                          AREA_NAME, BMFHOUSEID, BDBZQSE, ZWLXQSSJ, ZWLXJSSJ, GYQK, GMRQ, HTBAH, XSZJ,
                                          DKYE, BARNAME, BARPWD, FLAG, HOUSE_VALUE)
        select APPLYID  AS APPLY_ID,
               PTYPE    AS TYPE,
               AREACODE AS AREA_CODE,
               T5.ID_CARD,
               T5.QLRMC,
               T5.FWZL,
               T5.JZMJ,
               T5.AREA_AVGPRICE,
               T5.AREA_NAME,
               T5.BMFHOUSEID,
               T5.BDBZQSE,
               T5.ZWLXQSSJ,
               T5.ZWLXJSSJ,
               T5.GYQK,
               T5.GMRQ,
               T5.HTBAH,
               T5.XSZJ,
               T5.DKYE,
               T5.BARNAME,
               T5.BARPWD,
               T5.flag,
               (
                   CASE
                       WHEN T5.FLAG = '1'
                           THEN CASE
                                    WHEN IFNULL(T5.JZMJ, 0) = 0 THEN 300000
                                    ELSE T5.JZMJ * IFNULL(T5.AREA_AVGPRICE, PTYPE) * (T5.GYQK / 100) END
                       WHEN T5.FLAG = '2'
                           THEN CASE
                                    WHEN IFNULL(T5.JZMJ, 0) = 0 THEN 300000
                                    ELSE T5.JZMJ * IFNULL(T5.AREA_AVGPRICE, PTYPE) END
                       WHEN T5.FLAG = '3'
                           THEN round((T5.BDBZQSE / 0.6) * (case
                                                                when power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) >
                                                                     5 then 5
                                                                else power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) end),
                                      2)
                       WHEN T5.FLAG = '4'
                           THEN round((T5.BDBZQSE / 0.6) * (case
                                                                when power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) >
                                                                     5 then 5
                                                                else power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) end),
                                      2)
                       WHEN T5.FLAG = '5'
                           THEN IFNULL(T5.XSZJ, 0)
                       END
                   )
                        AS HOUSE_VALUE
        from (
                 select T4.ID_CARD,
                        T4.QLRMC,
                        T4.FWZL,
                        T4.JZMJ,
                        T4.AREA_AVGPRICE,
                        T4.AREA_NAME,
                        T4.BMFHOUSEID,
                        T4.BDBZQSE,
                        T4.ZWLXQSSJ,
                        T4.ZWLXJSSJ,
                        T4.GYQK,
                        T4.GMRQ,
                        T4.HTBAH,
                        T4.BARNAME,
                        T4.BARPWD,
                        T4.XSZJ,
                        T4.DKYE,
                        MIN(T4.FLAG) AS FLAG
                 from (
                          SELECT T3.ID_CARD,
                                 T3.QLRMC,
                                 T3.FWZL,
                                 T3.JZMJ,
                                 T3.AREA_AVGPRICE,
                                 T3.AREA_NAME,
                                 T3.BMFHOUSEID,
                                 T3.BDBZQSE,
                                 T3.ZWLXQSSJ,
                                 T3.ZWLXJSSJ,
                                 T3.GYQK,
                                 T3.GMRQ,
                                 T3.HTBAH,
                                 T3.BARNAME,
                                 T3.BARPWD,
                                 T3.XSZJ,
                                 T3.DKYE,
                                 T3.FLAG
                          FROM (
                                   SELECT T2.ID_CARD,
                                          T2.QLRMC,
                                          T2.FWZL,
                                          T2.JZMJ,
                                          T2.AREA_AVGPRICE,
                                          T2.AREA_NAME,
                                          T2.BMFHOUSEID,
                                          T2.BDBZQSE,
                                          T2.ZWLXQSSJ,
                                          T2.ZWLXJSSJ,
                                          T2.GYQK,
                                          T2.GMRQ,
                                          T2.HTBAH,
                                          T2.BARNAME,
                                          T2.BARPWD,
                                          T2.XSZJ,
                                          T2.DKYE,
                                          MIN(T2.FLAG) AS FLAG

                                   FROM (
                                            SELECT T1.ID_CARD,
                                                   T1.QLRMC,
                                                   T1.FWZL,
                                                   T1.JZMJ,
                                                   T1.AREA_AVGPRICE,
                                                   T1.AREA_NAME,
                                                   T1.BMFHOUSEID,
                                                   T1.BDBZQSE,
                                                   T1.ZWLXQSSJ,
                                                   T1.ZWLXJSSJ,
                                                   T1.GYQK,
                                                   T1.GMRQ,
                                                   T1.HTBAH,
                                                   T1.BARNAME,
                                                   T1.BARPWD,
                                                   T1.XSZJ,
                                                   T1.DKYE,
                                                   MIN(T1.FLAG) AS FLAG
                                            FROM (
                                                     SELECT R1.*
                                                     FROM (
                                                              select ID_CARD,
                                                                     QLRMC,
                                                                     FWZL,
                                                                     JZMJ,
                                                                     AREA_AVGPRICE,
                                                                     AREA_NAME,
                                                                     BMFHOUSEID,
                                                                     ROUND(IFNULL(BDBZQSE, CONCAT('REMARK', USER_ID))) AS BDBZQSE,
                                                                     IFNULL(ZWLXQSSJ, CONCAT('REMARK', USER_ID))       AS ZWLXQSSJ,
                                                                     IFNULL(ZWLXJSSJ, CONCAT('REMARK', USER_ID))       AS ZWLXJSSJ,
                                                                     GYQK,
                                                                     GMRQ,
                                                                     HTBAH,
                                                                     BARNAME,
                                                                     BARPWD,
                                                                     XSZJ,
                                                                     DKYE,
                                                                     MIN(flag)                                         AS FLAG
                                                              FROM (SELECT * FROM ZW_HOUSE_LOAN ORDER BY FLAG ASC) R
                                                              where id_card = IDCARD
                                                                AND FLAG IN ('1', '2')
                                                                AND APPLY_ID = APPLYID
                                                                AND AREA_CODE = AREACODE -- and TYPE=PTYPE
                                                              GROUP BY BMFHOUSEID


                                                              UNION

                                                              SELECT ID_CARD,
                                                                     QLRMC,
                                                                     FWZL,
                                                                     JZMJ,
                                                                     AREA_AVGPRICE,
                                                                     AREA_NAME,
                                                                     BMFHOUSEID,
                                                                     ROUND(BDBZQSE),
                                                                     ZWLXQSSJ,
                                                                     ZWLXJSSJ,
                                                                     GYQK,
                                                                     GMRQ,
                                                                     HTBAH,
                                                                     BARNAME,
                                                                     BARPWD,
                                                                     XSZJ,
                                                                     DKYE,
                                                                     flag
                                                              FROM ZW_HOUSE_LOAN
                                                              WHERE id_card = IDCARD
                                                                AND FLAG = '3'
                                                                AND APPLY_ID = APPLYID
                                                                AND AREA_CODE = AREACODE -- and TYPE=PTYPE
                                                          ) R1
                                                     ORDER BY FLAG DESC
                                                 ) T1
                                            GROUP BY T1.fwzl, t1.jzmj
                                        ) T2
                                   GROUP BY t2.bdbzqse, t2.zwlxqssj, t2.zwlxjssj

                                   UNION

                                   SELECT TMP1.ID_CARD,
                                          TMP1.QLRMC,
                                          TMP1.FWZL,
                                          TMP1.JZMJ,
                                          TMP1.AREA_AVGPRICE,
                                          TMP1.AREA_NAME,
                                          TMP1.BMFHOUSEID,
                                          ROUND(TMP1.BDBZQSE) AS BDBZQSE,
                                          TMP1.ZWLXQSSJ,
                                          TMP1.ZWLXJSSJ,
                                          TMP1.GYQK,
                                          TMP1.GMRQ,
                                          TMP1.HTBAH,
                                          TMP1.BARNAME,
                                          TMP1.BARPWD,
                                          TMP1.XSZJ,
                                          TMP1.DKYE,
                                          TMP1.FLAG

                                   FROM (
                                            SELECT TMP2.ID_CARD,
                                                   TMP2.QLRMC,
                                                   TMP2.FWZL,
                                                   TMP2.JZMJ,
                                                   TMP2.AREA_AVGPRICE,
                                                   TMP2.AREA_NAME,
                                                   TMP2.BMFHOUSEID,
                                                   TMP2.BDBZQSE,
                                                   MAX(TMP2.ZWLXQSSJ) AS ZWLXQSSJ,
                                                   TMP2.ZWLXJSSJ,
                                                   TMP2.GYQK,
                                                   TMP2.GMRQ,
                                                   TMP2.HTBAH,
                                                   TMP2.BARNAME,
                                                   TMP2.BARPWD,
                                                   TMP2.XSZJ,
                                                   TMP2.DKYE,
                                                   TMP2.FLAG
                                            FROM (
                                                     select ID_CARD,
                                                            name        as QLRMC,
                                                            ''          as FWZL,
                                                            ''          as JZMJ,
                                                            ''          as AREA_AVGPRICE,
                                                            ''          as AREA_NAME,
                                                            ''          as BMFHOUSEID,
                                                            LOAN_AMOUNT as BDBZQSE,
                                                            ISSUE_DATE  as ZWLXQSSJ,
                                                            DUE_DATE    as ZWLXJSSJ,
                                                            ''          as GYQK,
                                                            ''          as GMRQ,
                                                            ''          as HTBAH,
                                                            ''          AS BARNAME,
                                                            ''          AS BARPWD,
                                                            ''          as XSZJ,
                                                            ''          as DKYE,
                                                            IS_CLEAN,
                                                            '4'         as flag
                                                     from report_loan_info
                                                     WHERE id_card = IDCARD
                                                       AND APPLY_ID = APPLYID
                                                       AND AREA_CODE = AREACODE
                                                       AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                            LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                                       AND REPORT_STATUS = 0
                                                       AND IS_CLEAN = 1
                                                       AND NOT EXISTS(SELECT *
                                                                      From report_loan_info
                                                                      WHERE id_card = IDCARD
                                                                        AND APPLY_ID = APPLYID
                                                                        AND AREA_CODE = AREACODE
                                                                        AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                                             LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                                                        AND REPORT_STATUS = 0
                                                                        AND IS_CLEAN = 0)
                                                       AND NOT EXISTS(SELECT *
                                                                      FROM zw_house_loan
                                                                      WHERE id_card = IDCARD
                                                                        AND APPLY_ID = APPLYID
                                                                        AND AREA_CODE = AREACODE
                                                                        AND FLAG IN ('1', '2') /*AND TYPE=PTYPE*/ )
                                                     ORDER BY ISSUE_DATE DESC
                                                 ) TMP2

                                            UNION

                                            select ID_CARD,
                                                   name        as QLRMC,
                                                   ''          as FWZL,
                                                   ''          as JZMJ,
                                                   ''          as AREA_AVGPRICE,
                                                   ''          as AREA_NAME,
                                                   ''          as BMFHOUSEID,
                                                   LOAN_AMOUNT as BDBZQSE,
                                                   ISSUE_DATE  as ZWLXQSSJ,
                                                   DUE_DATE    as ZWLXJSSJ,
                                                   ''          as GYQK,
                                                   ''          as GMRQ,
                                                   ''          as HTBAH,
                                                   ''          AS BARNAME,
                                                   ''          AS BARPWD,
                                                   ''          as XSZJ,
                                                   ''          as DKYE,
                                                   '4'         as flag
                                            from report_loan_info
                                            WHERE id_card = IDCARD
                                              AND APPLY_ID = APPLYID
                                              AND AREA_CODE = AREACODE
                                              AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                   LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                              AND REPORT_STATUS = 0
                                              AND IS_CLEAN = 0
                                        ) TMP1
                                   WHERE TMP1.ID_CARD IS NOT NULL
                                   GROUP BY TMP1.BDBZQSE, TMP1.ZWLXQSSJ, TMP1.ZWLXJSSJ
                               ) T3
                          ORDER BY T3.FLAG ASC
                      ) T4
                 GROUP BY T4.BDBZQSE, T4.ZWLXQSSJ, T4.ZWLXJSSJ

                 UNION

                 SELECT ID_CARD,
                        QLRMC,
                        FWZL,
                        JZMJ,
                        AREA_AVGPRICE,
                        AREA_NAME,
                        BMFHOUSEID,
                        ROUND(BDBZQSE),
                        ZWLXQSSJ,
                        ZWLXJSSJ,
                        GYQK,
                        GMRQ,
                        HTBAH,
                        BARNAME,
                        BARPWD,
                        XSZJ,
                        DKYE,
                        flag
                 FROM ZW_HOUSE_LOAN
                 where id_card = IDCARD
                   AND FLAG = '5'
                   AND APPLY_ID = APPLYID
                   AND AREA_CODE = AREACODE -- and TYPE=PTYPE

             ) T5;

    END IF;

/****************************************预授信房产****************************************************/
    IF DATATYPE = '0' THEN
        SET VV_TASK = '预授信房产';
        delete from data_cust_asset_house where APPLY_ID = SEQNO AND ID_CARD = IDCARD AND AREA_CODE = AREACODE;
        commit;

-- 根据申请人传入的参数进行政务与征信房产的去重操作
        INSERT INTO data_cust_asset_house(APPLY_ID, TYPE, AREA_CODE, ID_CARD, QLRMC, FWZL, JZMJ, AREA_AVGPRICE,
                                          AREA_NAME, BMFHOUSEID, BDBZQSE, ZWLXQSSJ, ZWLXJSSJ, GYQK, GMRQ, HTBAH, XSZJ,
                                          DKYE, BARNAME, BARPWD, FLAG, HOUSE_VALUE)
        select SEQNO    AS APPLY_ID,
               PTYPE    AS TYPE,
               AREACODE AS AREA_CODE,
               T5.ID_CARD,
               T5.QLRMC,
               T5.FWZL,
               T5.JZMJ,
               T5.AREA_AVGPRICE,
               T5.AREA_NAME,
               T5.BMFHOUSEID,
               T5.BDBZQSE,
               T5.ZWLXQSSJ,
               T5.ZWLXJSSJ,
               T5.GYQK,
               T5.GMRQ,
               T5.HTBAH,
               T5.XSZJ,
               T5.DKYE,
               T5.BARNAME,
               T5.BARPWD,
               T5.flag,
               (
                   CASE
                       WHEN T5.FLAG = '1'
                           THEN CASE
                                    WHEN IFNULL(T5.JZMJ, 0) = 0 THEN 300000
                                    ELSE T5.JZMJ * IFNULL(T5.AREA_AVGPRICE, PTYPE) * (T5.GYQK / 100) END
                       WHEN T5.FLAG = '2'
                           THEN CASE
                                    WHEN IFNULL(T5.JZMJ, 0) = 0 THEN 300000
                                    ELSE T5.JZMJ * IFNULL(T5.AREA_AVGPRICE, PTYPE) END
                       WHEN T5.FLAG = '3'
                           THEN round((T5.BDBZQSE / 0.6) * (case
                                                                when power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) >
                                                                     5 then 5
                                                                else power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) end),
                                      2)
                       WHEN T5.FLAG = '4'
                           THEN round((T5.BDBZQSE / 0.6) * (case
                                                                when power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) >
                                                                     5 then 5
                                                                else power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) end),
                                      2)
                       WHEN T5.FLAG = '5'
                           THEN IFNULL(T5.XSZJ, 0)
                       END
                   )
                        AS HOUSE_VALUE
        from (
                 select T4.ID_CARD,
                        T4.QLRMC,
                        T4.FWZL,
                        T4.JZMJ,
                        T4.AREA_AVGPRICE,
                        T4.AREA_NAME,
                        T4.BMFHOUSEID,
                        T4.BDBZQSE,
                        T4.ZWLXQSSJ,
                        T4.ZWLXJSSJ,
                        T4.GYQK,
                        T4.GMRQ,
                        T4.HTBAH,
                        T4.BARNAME,
                        T4.BARPWD,
                        T4.XSZJ,
                        T4.DKYE,
                        MIN(T4.FLAG) AS FLAG
                 from (
                          SELECT T3.ID_CARD,
                                 T3.QLRMC,
                                 T3.FWZL,
                                 T3.JZMJ,
                                 T3.AREA_AVGPRICE,
                                 T3.AREA_NAME,
                                 T3.BMFHOUSEID,
                                 T3.BDBZQSE,
                                 T3.ZWLXQSSJ,
                                 T3.ZWLXJSSJ,
                                 T3.GYQK,
                                 T3.GMRQ,
                                 T3.HTBAH,
                                 T3.BARNAME,
                                 T3.BARPWD,
                                 T3.XSZJ,
                                 T3.DKYE,
                                 T3.FLAG
                          FROM (
                                   SELECT T2.ID_CARD,
                                          T2.QLRMC,
                                          T2.FWZL,
                                          T2.JZMJ,
                                          T2.AREA_AVGPRICE,
                                          T2.AREA_NAME,
                                          T2.BMFHOUSEID,
                                          T2.BDBZQSE,
                                          T2.ZWLXQSSJ,
                                          T2.ZWLXJSSJ,
                                          T2.GYQK,
                                          T2.GMRQ,
                                          T2.HTBAH,
                                          T2.BARNAME,
                                          T2.BARPWD,
                                          T2.XSZJ,
                                          T2.DKYE,
                                          MIN(T2.FLAG) AS FLAG

                                   FROM (
                                            SELECT T1.ID_CARD,
                                                   T1.QLRMC,
                                                   T1.FWZL,
                                                   T1.JZMJ,
                                                   T1.AREA_AVGPRICE,
                                                   T1.AREA_NAME,
                                                   T1.BMFHOUSEID,
                                                   T1.BDBZQSE,
                                                   T1.ZWLXQSSJ,
                                                   T1.ZWLXJSSJ,
                                                   T1.GYQK,
                                                   T1.GMRQ,
                                                   T1.HTBAH,
                                                   T1.BARNAME,
                                                   T1.BARPWD,
                                                   T1.XSZJ,
                                                   T1.DKYE,
                                                   MIN(T1.FLAG) AS FLAG
                                            FROM (
                                                     SELECT R1.*
                                                     FROM (
                                                              select ID_CARD,
                                                                     QLRMC,
                                                                     FWZL,
                                                                     JZMJ,
                                                                     AREA_AVGPRICE,
                                                                     AREA_NAME,
                                                                     BMFHOUSEID,
                                                                     ROUND(IFNULL(BDBZQSE, CONCAT('REMARK', USER_ID))) AS BDBZQSE,
                                                                     IFNULL(ZWLXQSSJ, CONCAT('REMARK', USER_ID))       AS ZWLXQSSJ,
                                                                     IFNULL(ZWLXJSSJ, CONCAT('REMARK', USER_ID))       AS ZWLXJSSJ,
                                                                     GYQK,
                                                                     GMRQ,
                                                                     HTBAH,
                                                                     BARNAME,
                                                                     BARPWD,
                                                                     XSZJ,
                                                                     DKYE,
                                                                     MIN(flag)                                         AS FLAG
                                                              FROM (SELECT * FROM ZW_HOUSE_LOAN ORDER BY FLAG ASC) R
                                                              where id_card = IDCARD
                                                                AND FLAG IN ('1', '2')
                                                                AND APPLY_ID = SEQNO
                                                                AND AREA_CODE = AREACODE
                                                              GROUP BY BMFHOUSEID


                                                              UNION

                                                              SELECT ID_CARD,
                                                                     QLRMC,
                                                                     FWZL,
                                                                     JZMJ,
                                                                     AREA_AVGPRICE,
                                                                     AREA_NAME,
                                                                     BMFHOUSEID,
                                                                     ROUND(BDBZQSE),
                                                                     ZWLXQSSJ,
                                                                     ZWLXJSSJ,
                                                                     GYQK,
                                                                     GMRQ,
                                                                     HTBAH,
                                                                     BARNAME,
                                                                     BARPWD,
                                                                     XSZJ,
                                                                     DKYE,
                                                                     flag
                                                              FROM ZW_HOUSE_LOAN
                                                              WHERE id_card = IDCARD
                                                                AND FLAG = '3'
                                                                AND APPLY_ID = SEQNO
                                                                AND AREA_CODE = AREACODE
                                                          ) R1
                                                     ORDER BY FLAG DESC
                                                 ) T1
                                            GROUP BY T1.fwzl, t1.jzmj
                                        ) T2
                                   GROUP BY t2.bdbzqse, t2.zwlxqssj, t2.zwlxjssj

                                   UNION

                                   SELECT TMP1.ID_CARD,
                                          TMP1.QLRMC,
                                          TMP1.FWZL,
                                          TMP1.JZMJ,
                                          TMP1.AREA_AVGPRICE,
                                          TMP1.AREA_NAME,
                                          TMP1.BMFHOUSEID,
                                          ROUND(TMP1.BDBZQSE) AS BDBZQSE,
                                          TMP1.ZWLXQSSJ,
                                          TMP1.ZWLXJSSJ,
                                          TMP1.GYQK,
                                          TMP1.GMRQ,
                                          TMP1.HTBAH,
                                          TMP1.BARNAME,
                                          TMP1.BARPWD,
                                          TMP1.XSZJ,
                                          TMP1.DKYE,
                                          TMP1.FLAG

                                   FROM (
                                            SELECT TMP2.ID_CARD,
                                                   TMP2.QLRMC,
                                                   TMP2.FWZL,
                                                   TMP2.JZMJ,
                                                   TMP2.AREA_AVGPRICE,
                                                   TMP2.AREA_NAME,
                                                   TMP2.BMFHOUSEID,
                                                   TMP2.BDBZQSE,
                                                   MAX(TMP2.ZWLXQSSJ) AS ZWLXQSSJ,
                                                   TMP2.ZWLXJSSJ,
                                                   TMP2.GYQK,
                                                   TMP2.GMRQ,
                                                   TMP2.HTBAH,
                                                   TMP2.BARNAME,
                                                   TMP2.BARPWD,
                                                   TMP2.XSZJ,
                                                   TMP2.DKYE,
                                                   TMP2.FLAG
                                            FROM (
                                                     select ID_CARD,
                                                            name        as QLRMC,
                                                            ''          as FWZL,
                                                            ''          as JZMJ,
                                                            ''          as AREA_AVGPRICE,
                                                            ''          as AREA_NAME,
                                                            ''          as BMFHOUSEID,
                                                            LOAN_AMOUNT as BDBZQSE,
                                                            ISSUE_DATE  as ZWLXQSSJ,
                                                            DUE_DATE    as ZWLXJSSJ,
                                                            ''          as GYQK,
                                                            ''          as GMRQ,
                                                            ''          as HTBAH,
                                                            ''          AS BARNAME,
                                                            ''          AS BARPWD,
                                                            ''          as XSZJ,
                                                            ''          as DKYE,
                                                            IS_CLEAN,
                                                            '4'         as flag
                                                     from report_loan_info
                                                     WHERE id_card = IDCARD
                                                       AND APPLY_ID = SEQNO
                                                       AND AREA_CODE = AREACODE
                                                       AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                            LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                                       AND REPORT_STATUS = 0
                                                       AND IS_CLEAN = 1
                                                       AND NOT EXISTS(SELECT *
                                                                      From report_loan_info
                                                                      WHERE id_card = IDCARD
                                                                        AND APPLY_ID = SEQNO
                                                                        AND AREA_CODE = AREACODE
                                                                        AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                                             LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                                                        AND REPORT_STATUS = 0
                                                                        AND IS_CLEAN = 0)
                                                       AND NOT EXISTS(SELECT *
                                                                      FROM zw_house_loan
                                                                      WHERE id_card = IDCARD
                                                                        AND APPLY_ID = SEQNO
                                                                        AND AREA_CODE = AREACODE
                                                                        AND FLAG IN ('1', '2'))
                                                     ORDER BY ISSUE_DATE DESC
                                                 ) TMP2

                                            UNION

                                            select ID_CARD,
                                                   name        as QLRMC,
                                                   ''          as FWZL,
                                                   ''          as JZMJ,
                                                   ''          as AREA_AVGPRICE,
                                                   ''          as AREA_NAME,
                                                   ''          as BMFHOUSEID,
                                                   LOAN_AMOUNT as BDBZQSE,
                                                   ISSUE_DATE  as ZWLXQSSJ,
                                                   DUE_DATE    as ZWLXJSSJ,
                                                   ''          as GYQK,
                                                   ''          as GMRQ,
                                                   ''          as HTBAH,
                                                   ''          AS BARNAME,
                                                   ''          AS BARPWD,
                                                   ''          as XSZJ,
                                                   ''          as DKYE,
                                                   '4'         as flag
                                            from report_loan_info
                                            WHERE id_card = IDCARD
                                              AND APPLY_ID = SEQNO
                                              AND AREA_CODE = AREACODE
                                              AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                   LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                              AND REPORT_STATUS = 0
                                              AND IS_CLEAN = 0
                                        ) TMP1
                                   WHERE TMP1.ID_CARD IS NOT NULL
                                   GROUP BY TMP1.BDBZQSE, TMP1.ZWLXQSSJ, TMP1.ZWLXJSSJ
                               ) T3
                          ORDER BY T3.FLAG ASC
                      ) T4
                 GROUP BY T4.BDBZQSE, T4.ZWLXQSSJ, T4.ZWLXJSSJ

                 UNION

                 SELECT ID_CARD,
                        QLRMC,
                        FWZL,
                        JZMJ,
                        AREA_AVGPRICE,
                        AREA_NAME,
                        BMFHOUSEID,
                        ROUND(BDBZQSE),
                        ZWLXQSSJ,
                        ZWLXJSSJ,
                        GYQK,
                        GMRQ,
                        HTBAH,
                        BARNAME,
                        BARPWD,
                        XSZJ,
                        DKYE,
                        flag
                 FROM ZW_HOUSE_LOAN
                 where id_card = IDCARD
                   AND FLAG = '5'
                   AND APPLY_ID = SEQNO
                   AND AREA_CODE = AREACODE
             ) T5;
    END IF;

/****************************************贷后、催收房产****************************************************/
    IF DATATYPE = '2' THEN
        SET VV_TASK = '贷后、催收房产';

        delete
        from data_cust_asset_house
        where APPLY_ID = CONCAT(APPLYID, SEQNO)
          AND ID_CARD = IDCARD /*AND TYPE=PTYPE*/
          AND AREA_CODE = AREACODE;
        commit;

-- 根据申请人传入的参数进行政务与征信房产的去重操作
        INSERT INTO data_cust_asset_house(APPLY_ID, TYPE, AREA_CODE, ID_CARD, QLRMC, FWZL, JZMJ, AREA_AVGPRICE,
                                          AREA_NAME, BMFHOUSEID, BDBZQSE, ZWLXQSSJ, ZWLXJSSJ, GYQK, GMRQ, HTBAH, XSZJ,
                                          DKYE, BARNAME, BARPWD, FLAG, HOUSE_VALUE)
        select CONCAT(APPLYID, SEQNO) AS APPLY_ID,
               PTYPE                  AS TYPE,
               AREACODE               AS AREA_CODE,
               T5.ID_CARD,
               T5.QLRMC,
               T5.FWZL,
               T5.JZMJ,
               T5.AREA_AVGPRICE,
               T5.AREA_NAME,
               T5.BMFHOUSEID,
               T5.BDBZQSE,
               T5.ZWLXQSSJ,
               T5.ZWLXJSSJ,
               T5.GYQK,
               T5.GMRQ,
               T5.HTBAH,
               T5.XSZJ,
               T5.DKYE,
               T5.BARNAME,
               T5.BARPWD,
               T5.flag,
               (
                   CASE
                       WHEN T5.FLAG = '1'
                           THEN CASE
                                    WHEN IFNULL(T5.JZMJ, 0) = 0 THEN 300000
                                    ELSE T5.JZMJ * IFNULL(T5.AREA_AVGPRICE, PTYPE) * (T5.GYQK / 100) END
                       WHEN T5.FLAG = '2'
                           THEN CASE
                                    WHEN IFNULL(T5.JZMJ, 0) = 0 THEN 300000
                                    ELSE T5.JZMJ * IFNULL(T5.AREA_AVGPRICE, PTYPE) END
                       WHEN T5.FLAG = '3'
                           THEN round((T5.BDBZQSE / 0.6) * (case
                                                                when power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) >
                                                                     5 then 5
                                                                else power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) end),
                                      2)
                       WHEN T5.FLAG = '4'
                           THEN round((T5.BDBZQSE / 0.6) * (case
                                                                when power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) >
                                                                     5 then 5
                                                                else power(1.10,
                                                                           TIMESTAMPDIFF(YEAR, date_format(ZWLXQSSJ, '%Y%m%d'), CURRENT_DATE)) end),
                                      2)
                       WHEN T5.FLAG = '5'
                           THEN IFNULL(T5.XSZJ, 0)
                       END
                   )
                                      AS HOUSE_VALUE
        from (
                 select T4.ID_CARD,
                        T4.QLRMC,
                        T4.FWZL,
                        T4.JZMJ,
                        T4.AREA_AVGPRICE,
                        T4.AREA_NAME,
                        T4.BMFHOUSEID,
                        T4.BDBZQSE,
                        T4.ZWLXQSSJ,
                        T4.ZWLXJSSJ,
                        T4.GYQK,
                        T4.GMRQ,
                        T4.HTBAH,
                        T4.BARNAME,
                        T4.BARPWD,
                        T4.XSZJ,
                        T4.DKYE,
                        MIN(T4.FLAG) AS FLAG
                 from (
                          SELECT T3.ID_CARD,
                                 T3.QLRMC,
                                 T3.FWZL,
                                 T3.JZMJ,
                                 T3.AREA_AVGPRICE,
                                 T3.AREA_NAME,
                                 T3.BMFHOUSEID,
                                 T3.BDBZQSE,
                                 T3.ZWLXQSSJ,
                                 T3.ZWLXJSSJ,
                                 T3.GYQK,
                                 T3.GMRQ,
                                 T3.HTBAH,
                                 T3.BARNAME,
                                 T3.BARPWD,
                                 T3.XSZJ,
                                 T3.DKYE,
                                 T3.FLAG
                          FROM (
                                   SELECT T2.ID_CARD,
                                          T2.QLRMC,
                                          T2.FWZL,
                                          T2.JZMJ,
                                          T2.AREA_AVGPRICE,
                                          T2.AREA_NAME,
                                          T2.BMFHOUSEID,
                                          T2.BDBZQSE,
                                          T2.ZWLXQSSJ,
                                          T2.ZWLXJSSJ,
                                          T2.GYQK,
                                          T2.GMRQ,
                                          T2.HTBAH,
                                          T2.BARNAME,
                                          T2.BARPWD,
                                          T2.XSZJ,
                                          T2.DKYE,
                                          MIN(T2.FLAG) AS FLAG

                                   FROM (
                                            SELECT T1.ID_CARD,
                                                   T1.QLRMC,
                                                   T1.FWZL,
                                                   T1.JZMJ,
                                                   T1.AREA_AVGPRICE,
                                                   T1.AREA_NAME,
                                                   T1.BMFHOUSEID,
                                                   T1.BDBZQSE,
                                                   T1.ZWLXQSSJ,
                                                   T1.ZWLXJSSJ,
                                                   T1.GYQK,
                                                   T1.GMRQ,
                                                   T1.HTBAH,
                                                   T1.BARNAME,
                                                   T1.BARPWD,
                                                   T1.XSZJ,
                                                   T1.DKYE,
                                                   MIN(T1.FLAG) AS FLAG
                                            FROM (
                                                     SELECT R1.*
                                                     FROM (
                                                              select ID_CARD,
                                                                     QLRMC,
                                                                     FWZL,
                                                                     JZMJ,
                                                                     AREA_AVGPRICE,
                                                                     AREA_NAME,
                                                                     BMFHOUSEID,
                                                                     ROUND(IFNULL(BDBZQSE, CONCAT('REMARK', USER_ID))) AS BDBZQSE,
                                                                     IFNULL(ZWLXQSSJ, CONCAT('REMARK', USER_ID))       AS ZWLXQSSJ,
                                                                     IFNULL(ZWLXJSSJ, CONCAT('REMARK', USER_ID))       AS ZWLXJSSJ,
                                                                     GYQK,
                                                                     GMRQ,
                                                                     HTBAH,
                                                                     BARNAME,
                                                                     BARPWD,
                                                                     XSZJ,
                                                                     DKYE,
                                                                     MIN(flag)                                         AS FLAG
                                                              FROM (SELECT * FROM ZW_HOUSE_LOAN ORDER BY FLAG ASC) R
                                                              where id_card = IDCARD
                                                                AND FLAG IN ('1', '2')
                                                                AND APPLY_ID = CONCAT(APPLYID, SEQNO)
                                                                AND AREA_CODE = AREACODE -- and TYPE=PTYPE
                                                              GROUP BY BMFHOUSEID


                                                              UNION

                                                              SELECT ID_CARD,
                                                                     QLRMC,
                                                                     FWZL,
                                                                     JZMJ,
                                                                     AREA_AVGPRICE,
                                                                     AREA_NAME,
                                                                     BMFHOUSEID,
                                                                     ROUND(BDBZQSE),
                                                                     ZWLXQSSJ,
                                                                     ZWLXJSSJ,
                                                                     GYQK,
                                                                     GMRQ,
                                                                     HTBAH,
                                                                     BARNAME,
                                                                     BARPWD,
                                                                     XSZJ,
                                                                     DKYE,
                                                                     flag
                                                              FROM ZW_HOUSE_LOAN
                                                              WHERE id_card = IDCARD
                                                                AND FLAG = '3'
                                                                AND APPLY_ID = CONCAT(APPLYID, SEQNO)
                                                                AND AREA_CODE = AREACODE -- and TYPE=PTYPE
                                                          ) R1
                                                     ORDER BY FLAG DESC
                                                 ) T1
                                            GROUP BY T1.fwzl, t1.jzmj
                                        ) T2
                                   GROUP BY t2.bdbzqse, t2.zwlxqssj, t2.zwlxjssj

                                   UNION

                                   SELECT TMP1.ID_CARD,
                                          TMP1.QLRMC,
                                          TMP1.FWZL,
                                          TMP1.JZMJ,
                                          TMP1.AREA_AVGPRICE,
                                          TMP1.AREA_NAME,
                                          TMP1.BMFHOUSEID,
                                          ROUND(TMP1.BDBZQSE) AS BDBZQSE,
                                          TMP1.ZWLXQSSJ,
                                          TMP1.ZWLXJSSJ,
                                          TMP1.GYQK,
                                          TMP1.GMRQ,
                                          TMP1.HTBAH,
                                          TMP1.BARNAME,
                                          TMP1.BARPWD,
                                          TMP1.XSZJ,
                                          TMP1.DKYE,
                                          TMP1.FLAG

                                   FROM (
                                            SELECT TMP2.ID_CARD,
                                                   TMP2.QLRMC,
                                                   TMP2.FWZL,
                                                   TMP2.JZMJ,
                                                   TMP2.AREA_AVGPRICE,
                                                   TMP2.AREA_NAME,
                                                   TMP2.BMFHOUSEID,
                                                   TMP2.BDBZQSE,
                                                   MAX(TMP2.ZWLXQSSJ) AS ZWLXQSSJ,
                                                   TMP2.ZWLXJSSJ,
                                                   TMP2.GYQK,
                                                   TMP2.GMRQ,
                                                   TMP2.HTBAH,
                                                   TMP2.BARNAME,
                                                   TMP2.BARPWD,
                                                   TMP2.XSZJ,
                                                   TMP2.DKYE,
                                                   TMP2.FLAG
                                            FROM (
                                                     select ID_CARD,
                                                            name        as QLRMC,
                                                            ''          as FWZL,
                                                            ''          as JZMJ,
                                                            ''          as AREA_AVGPRICE,
                                                            ''          as AREA_NAME,
                                                            ''          as BMFHOUSEID,
                                                            LOAN_AMOUNT as BDBZQSE,
                                                            ISSUE_DATE  as ZWLXQSSJ,
                                                            DUE_DATE    as ZWLXJSSJ,
                                                            ''          as GYQK,
                                                            ''          as GMRQ,
                                                            ''          as HTBAH,
                                                            ''          AS BARNAME,
                                                            ''          AS BARPWD,
                                                            ''          as XSZJ,
                                                            ''          as DKYE,
                                                            IS_CLEAN,
                                                            '4'         as flag
                                                     from report_loan_info
                                                     WHERE id_card = IDCARD
                                                       AND APPLY_ID = SEQNO
                                                       AND AREA_CODE = AREACODE
                                                       AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                            LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                                       AND REPORT_STATUS = 0
                                                       AND IS_CLEAN = 1
                                                       AND NOT EXISTS(SELECT *
                                                                      From report_loan_info
                                                                      WHERE id_card = IDCARD
                                                                        AND APPLY_ID = SEQNO
                                                                        AND AREA_CODE = AREACODE
                                                                        AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                                             LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                                                        AND REPORT_STATUS = 0
                                                                        AND IS_CLEAN = 0)
                                                       AND NOT EXISTS(SELECT *
                                                                      FROM zw_house_loan
                                                                      WHERE id_card = IDCARD
                                                                        AND APPLY_ID = CONCAT(APPLYID, SEQNO)
                                                                        AND AREA_CODE = AREACODE
                                                                        AND FLAG IN ('1', '2') /*AND TYPE=PTYPE*/ )
                                                     ORDER BY ISSUE_DATE DESC
                                                 ) TMP2

                                            UNION

                                            select ID_CARD,
                                                   name        as QLRMC,
                                                   ''          as FWZL,
                                                   ''          as JZMJ,
                                                   ''          as AREA_AVGPRICE,
                                                   ''          as AREA_NAME,
                                                   ''          as BMFHOUSEID,
                                                   LOAN_AMOUNT as BDBZQSE,
                                                   ISSUE_DATE  as ZWLXQSSJ,
                                                   DUE_DATE    as ZWLXJSSJ,
                                                   ''          as GYQK,
                                                   ''          as GMRQ,
                                                   ''          as HTBAH,
                                                   ''          AS BARNAME,
                                                   ''          AS BARPWD,
                                                   ''          as XSZJ,
                                                   ''          as DKYE,
                                                   '4'         as flag
                                            from report_loan_info
                                            WHERE id_card = IDCARD
                                              AND APPLY_ID = SEQNO
                                              AND AREA_CODE = AREACODE
                                              AND (LOCATE(LOAN_TYPE, '个人住房贷款') > 0 OR
                                                   LOCATE(LOAN_TYPE, '个人商用房（包括商住两用）贷款') > 0)
                                              AND REPORT_STATUS = 0
                                              AND IS_CLEAN = 0
                                        ) TMP1
                                   WHERE TMP1.ID_CARD IS NOT NULL
                                   GROUP BY TMP1.BDBZQSE, TMP1.ZWLXQSSJ, TMP1.ZWLXJSSJ
                               ) T3
                          ORDER BY T3.FLAG ASC
                      ) T4
                 GROUP BY T4.BDBZQSE, T4.ZWLXQSSJ, T4.ZWLXJSSJ

                 UNION

                 SELECT ID_CARD,
                        QLRMC,
                        FWZL,
                        JZMJ,
                        AREA_AVGPRICE,
                        AREA_NAME,
                        BMFHOUSEID,
                        ROUND(BDBZQSE),
                        ZWLXQSSJ,
                        ZWLXJSSJ,
                        GYQK,
                        GMRQ,
                        HTBAH,
                        BARNAME,
                        BARPWD,
                        XSZJ,
                        DKYE,
                        flag
                 FROM ZW_HOUSE_LOAN
                 where id_card = IDCARD
                   AND FLAG = '5'
                   AND APPLY_ID = CONCAT(APPLYID, SEQNO)
                   AND AREA_CODE = AREACODE -- and TYPE=PTYPE

             ) T5;

    END IF;

END;

