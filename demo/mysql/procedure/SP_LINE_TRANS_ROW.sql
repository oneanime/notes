create
    definer = root@`%` procedure SP_LINE_TRANS_ROW(IN APPLYID varchar(100), IN SEQNO varchar(100),
                                                   IN IDCARD varchar(20), IN PTYPE varchar(10), IN AREACODE varchar(30),
                                                   IN DATATYPE varchar(4)) reads sql data
BEGIN
    DECLARE VV_TASK VARCHAR(200);
    DECLARE VV_LENG INT;
    DECLARE i INT;
    SET i = 0;


    IF DATATYPE = '1' THEN

        SET VV_TASK = '实时申请金融黑名单入黑名单表';
        SELECT max(length(REPLACE(BANK_BLACK_FLAG, ',', '')))
        INTO VV_LENG
        from data_bank_apply_grade_detail
        where APPLY_ID = APPLYID
          AND TYPE = PTYPE
          AND AREA_CODE = AREACODE;
        while i < VV_LENG
            do
                INSERT INTO data_black_info(ID_CARD, name, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                            SOURCE_TYPE, REMARK)
                SELECT ID_CARD,
                       name,
                       1           AS SOURCE,
                       T.DIC_TYPE  AS TYPE,
                       T.DIC_TYPE,
                       AREACODE    as AREA_CODE,
                       CURDATE()   AS CREATE_TIME,
                       1           AS CHECK_FLAG,
                       1           AS SOURCE_TYPE,
                       T2.DIC_NAME AS REMARK
                FROM (
                         SELECT a.ID_CARD,
                                b.MEMBER_NAME                                             as name,
                                substr(REPLACE(BANK_BLACK_FLAG, ',', ''), (i * 2 + 1), 2) as DIC_TYPE
                         from data_bank_apply_grade_detail a
                                  left join cust_family_mx b
                                            on a.APPLY_ID = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and
                                               a.TYPE = b.type and a.AREA_CODE = b.AREA_CODE
                         where a.APPLY_ID = APPLYID
                           AND a.TYPE = PTYPE
                           AND a.AREA_CODE = AREACODE
                     ) T
                         left join DATA_DIC_BLACK_TYPE T2 on T.DIC_TYPE = T2.DIC_TYPE

                WHERE T.dic_type <> ''
                  AND NOT EXISTS(
                        SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE);
                COMMIT;
                set i = i + 1;
            end while;


        SET VV_TASK = '实时申请政务黑名单入黑名单表';
        INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                    SOURCE_TYPE, REMARK)
        SELECT *
        FROM (
                 SELECT a.ID_CARD,
                        b.MEMBER_NAME AS NAME,
                        3             AS SOURCE,
                        BALCK_TYPE    AS TYPE,
                        BALCK_TYPE    AS DIC_TYPE,
                        a.AREA_CODE   as AREA_CODE,
                        CURDATE()     AS CREATE_TIME,
                        1             AS CHECK_FLAG,
                        1             AS SOURCE_TYPE,
                        c.DIC_NAME    as REMARK
                 FROM zw_blacklist a
                          left join cust_family_mx b
                                    on a.APPLY_ID = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and a.TYPE = b.type and
                                       a.AREA_CODE = b.AREA_CODE
                          left join DATA_DIC_BLACK_TYPE c on a.BALCK_TYPE = c.DIC_TYPE

                 WHERE a.APPLY_ID = APPLYID
                   AND a.TYPE = PTYPE
                   AND a.AREA_CODE = AREACODE
             ) T
        WHERE NOT EXISTS(
                SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE
            );
        COMMIT;

        SET VV_TASK = '实时申请互联网黑名单入黑名单表';
        INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                    SOURCE_TYPE, REMARK)
        select distinct ID_CARD,
                        USER_NAME AS NAME,
                        2         AS SOURCE,
                        '60'      AS TYPE,
                        '60'      AS DIC_TYPE,
                        AREA_CODE as AREA_CODE,
                        CURDATE() AS CREATE_TIME,
                        1         AS CHECK_FLAG,
                        1         AS SOURCE_TYPE,
                        '互联网黑名单'  as REMARK
        from public_data_black T
        where UNIQUE_NO = APPLYID
          and AREA_CODE = AREACODE
          and not exists(
                select 1 from data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T1.TYPE = '60'
            );
        commit;

    END IF;


    IF DATATYPE = '0' THEN
        SET VV_TASK = '预授信金融黑名单入黑名单表';
        SELECT max(length(REPLACE(BANK_BLACK_FLAG, ',', '')))
        INTO VV_LENG
        from data_bank_pre_grade_detail
        where SEQ_NO = SEQNO
          AND AREA_CODE = AREACODE;
        while i < VV_LENG
            do
                INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                            SOURCE_TYPE, REMARK)
                SELECT ID_CARD,
                       NAME,
                       1           AS SOURCE,
                       T.DIC_TYPE  AS TYPE,
                       T.DIC_TYPE,
                       AREACODE    as AREA_CODE,
                       CURDATE()   AS CREATE_TIME,
                       1           AS CHECK_FLAG,
                       1           AS SOURCE_TYPE,
                       T2.DIC_NAME AS REMARK
                FROM (
                         SELECT a.ID_CARD,
                                b.MEMBER_NAME                                             AS NAME,
                                substr(REPLACE(BANK_BLACK_FLAG, ',', ''), (i * 2 + 1), 2) as DIC_TYPE
                         from data_bank_pre_grade_detail a
                                  left join cust_family_mx b on a.SEQ_NO = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and
                                                                a.AREA_CODE = b.AREA_CODE
                         where a.SEQ_NO = SEQNO
                           AND a.AREA_CODE = AREACODE
                     ) T
                         left join DATA_DIC_BLACK_TYPE T2 on T.DIC_TYPE = T2.DIC_TYPE
                WHERE T.dic_type <> ''
                  AND NOT EXISTS(
                        SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE);
                COMMIT;
                set i = i + 1;
            end while;

        SET VV_TASK = '预授信政务黑名单入黑名单表';
        INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                    SOURCE_TYPE, REMARK)
        SELECT *
        FROM (
                 SELECT a.ID_CARD,
                        b.MEMBER_NAME AS NAME,
                        3             AS SOURCE,
                        a.BALCK_TYPE  AS TYPE,
                        a.BALCK_TYPE  AS DIC_TYPE,
                        a.AREA_CODE   as AREA_CODE,
                        CURDATE()     AS CREATE_TIME,
                        1             AS CHECK_FLAG,
                        1             AS SOURCE_TYPE,
                        c.DIC_NAME    as REMARK
                 FROM zw_blacklist a
                          left join cust_family_mx b on a.SEQ_NO = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and
                                                        a.AREA_CODE = b.AREA_CODE
                          left join DATA_DIC_BLACK_TYPE c on a.BALCK_TYPE = c.DIC_TYPE

                 WHERE a.SEQ_NO = SEQNO
                   AND a.AREA_CODE = AREACODE
             ) T
        WHERE NOT EXISTS(
                SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE
            );
        COMMIT;

        SET VV_TASK = '预授信互联网黑名单入黑名单表';
        INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                    SOURCE_TYPE, REMARK)
        select distinct ID_CARD,
                        USER_NAME AS NAME,
                        2         AS SOURCE,
                        '60'      AS TYPE,
                        '60'      AS DIC_TYPE,
                        AREA_CODE as AREA_CODE,
                        CURDATE() AS CREATE_TIME,
                        1         AS CHECK_FLAG,
                        1         AS SOURCE_TYPE,
                        '互联网黑名单'  as REMARK
        from public_data_black T
        where UNIQUE_NO = SEQNO
          and AREA_CODE = AREACODE
          and not exists(
                select 1 from data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T1.TYPE = '60'
            );
        commit;

    END IF;


    IF DATATYPE = '2' THEN
        SET VV_TASK = '贷后、催收黑名单入黑名单表';

        SELECT max(length(REPLACE(BANK_BLACK_FLAG, ',', '')))
        INTO VV_LENG
        from data_bank_after_grade_detail
        where APPLY_ID = APPLYID
          AND SEQ_NO = SEQNO
          AND TYPE = PTYPE
          AND AREA_CODE = AREACODE;
        while i < VV_LENG
            do
                INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                            SOURCE_TYPE, REMARK)
                SELECT ID_CARD,
                       NAME,
                       1           AS SOURCE,
                       T.DIC_TYPE  AS TYPE,
                       T.DIC_TYPE,
                       AREACODE    as AREA_CODE,
                       CURDATE()   AS CREATE_TIME,
                       1           AS CHECK_FLAG,
                       1           AS SOURCE_TYPE,
                       T2.DIC_NAME AS REMARK
                FROM (
                         SELECT a.ID_CARD,
                                b.MEMBER_NAME                                             as NAME,
                                substr(REPLACE(BANK_BLACK_FLAG, ',', ''), (i * 2 + 1), 2) as DIC_TYPE
                         from data_bank_after_grade_detail a
                                  left join cust_family_mx b on a.SEQ_NO = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and
                                                                a.AREA_CODE = b.AREA_CODE and a.TYPE = b.TYPE
                         where a.APPLY_ID = APPLYID
                           AND a.SEQ_NO = SEQNO
                           AND a.TYPE = PTYPE
                           AND a.AREA_CODE = AREACODE
                     ) T
                         left join DATA_DIC_BLACK_TYPE T2 on T.DIC_TYPE = T2.DIC_TYPE
                WHERE T.dic_type <> ''
                  AND NOT EXISTS(
                        SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE);
                COMMIT;
                set i = i + 1;
            end while;

        SELECT max(length(REPLACE(BANK_BLACK_FLAG, ',', '')))
        INTO VV_LENG
        from data_bank_ureg_grade_detail
        where APPLY_ID = APPLYID
          AND SEQ_NO = SEQNO
          AND TYPE = PTYPE
          AND AREA_CODE = AREACODE;
        while i < VV_LENG
            do
                INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                            SOURCE_TYPE, REMARK)
                SELECT ID_CARD,
                       NAME,
                       1           AS SOURCE,
                       T.DIC_TYPE  AS TYPE,
                       T.DIC_TYPE,
                       AREACODE    as AREA_CODE,
                       CURDATE()   AS CREATE_TIME,
                       1           AS CHECK_FLAG,
                       1           AS SOURCE_TYPE,
                       T2.DIC_NAME AS REMARK
                FROM (
                         SELECT a.ID_CARD,
                                b.MEMBER_NAME                                             as NAME,
                                substr(REPLACE(BANK_BLACK_FLAG, ',', ''), (i * 2 + 1), 2) as DIC_TYPE
                         from data_bank_ureg_grade_detail a
                                  left join cust_family_mx b on a.SEQ_NO = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and
                                                                a.AREA_CODE = b.AREA_CODE and a.TYPE = b.TYPE
                         where a.APPLY_ID = APPLYID
                           AND a.SEQ_NO = SEQNO
                           AND a.TYPE = PTYPE
                           AND a.AREA_CODE = AREACODE
                     ) T
                         left join DATA_DIC_BLACK_TYPE T2 on T.DIC_TYPE = T2.DIC_TYPE
                WHERE T.dic_type <> ''
                  AND NOT EXISTS(
                        SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE);
                COMMIT;
                set i = i + 1;
            end while;


        SET VV_TASK = '贷后、催收政务黑名单入黑名单表';
        INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                    SOURCE_TYPE, REMARK)
        SELECT *
        FROM (
                 SELECT a.ID_CARD,
                        b.MEMBER_NAME AS NAME,
                        3             AS SOURCE,
                        a.BALCK_TYPE  AS TYPE,
                        a.BALCK_TYPE  AS DIC_TYPE,
                        a.AREA_CODE   as AREA_CODE,
                        CURDATE()     AS CREATE_TIME,
                        1             AS CHECK_FLAG,
                        1             AS SOURCE_TYPE,
                        c.DIC_NAME    as REMARK
                 FROM zw_blacklist a
                          left join cust_family_mx b on a.SEQ_NO = b.SEQ_NO and a.ID_CARD = b.MEMBER_ID_CARD and
                                                        a.AREA_CODE = b.AREA_CODE
                          left join DATA_DIC_BLACK_TYPE c on a.BALCK_TYPE = c.DIC_TYPE

                 WHERE a.APPLY_ID = APPLYID
                   AND a.SEQ_NO = SEQNO
                   AND a.TYPE = PTYPE
                   AND a.AREA_CODE = AREACODE
             ) T
        WHERE NOT EXISTS(
                SELECT 1 FROM data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T.DIC_TYPE = T1.TYPE
            );
        COMMIT;

        SET VV_TASK = '预授信互联网黑名单入黑名单表';
        INSERT INTO data_black_info(ID_CARD, NAME, SOURCE, TYPE, DIC_TYPE, AREA_CODE, CREATE_TIME, CHECK_FLAG,
                                    SOURCE_TYPE, REMARK)
        select distinct ID_CARD,
                        USER_NAME AS NAME,
                        2         AS SOURCE,
                        '60'      AS TYPE,
                        '60'      AS DIC_TYPE,
                        AREA_CODE as AREA_CODE,
                        CURDATE() AS CREATE_TIME,
                        1         AS CHECK_FLAG,
                        1         AS SOURCE_TYPE,
                        '互联网黑名单'  as REMARK
        from public_data_black T
        where UNIQUE_NO = SEQNO
          and AREA_CODE = AREACODE
          and not exists(
                select 1 from data_black_info T1 WHERE T.ID_CARD = T1.ID_CARD AND T1.TYPE = '60'
            );
        commit;

    END IF;

END;

