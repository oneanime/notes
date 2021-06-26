create
    definer = root@`%` procedure SP_DATA_CUST_ASSET_CAR(IN APPLYID varchar(50), IN SEQNO varchar(50),
                                                        IN IDCARD varchar(20), IN PTYPE varchar(10),
                                                        IN AREACODE varchar(30))
BEGIN
    DECLARE V_CP_ID_CARD VARCHAR(20);
    DECLARE VV_TASK VARCHAR(300);
    DECLARE DATATYPE VARCHAR(10);


    SET VV_TASK = '预授信车产';
    IF SEQNO <> '' AND IDCARD <> '' AND AREACODE <> '' AND APPLYID = '' AND PTYPE = '' THEN
        SET DATATYPE = '0';

        -- 取得申请人配偶
        SELECT MEMBER_ID_CARD
        into V_CP_ID_CARD
        FROM cust_family_mx
        WHERE SEQ_NO = SEQNO
          AND apply_relation in (1, 2)
          AND TYPE = PTYPE
          AND ID_CARD = IDCARD
          AND AREA_CODE = AREACODE
          AND MEMBER_ID_CARD <> IDCARD;
        -- select concat('cp:',V_CP_ID_CARD);

        -- 申请人房产数据去重处理
        CALL SP_DATA_CUST_ASSET_CAR_INSERT(APPLYID, SEQNO, IDCARD, PTYPE, AREACODE, DATATYPE);

        -- 申请人配偶房产数据去重处理
        IF V_CP_ID_CARD <> '' THEN
            CALL SP_DATA_CUST_ASSET_CAR_INSERT(APPLYID, SEQNO, V_CP_ID_CARD, PTYPE, AREACODE, DATATYPE);
        END IF;
    END IF;

    SET VV_TASK = '实时授信车产';
    IF APPLYID <> '' AND IDCARD <> '' AND AREACODE <> '' AND PTYPE <> '' AND SEQNO = '' THEN
        SET DATATYPE = '1';
        -- 取得申请人配偶
        SELECT MEMBER_ID_CARD
        into V_CP_ID_CARD
        FROM cust_family_mx
        WHERE SEQ_NO = APPLYID
          AND apply_relation in (1, 2)
          AND TYPE = PTYPE
          AND ID_CARD = IDCARD
          AND AREA_CODE = AREACODE
          AND MEMBER_ID_CARD <> IDCARD;
        -- select concat('cp:',V_CP_ID_CARD);

        CALL SP_DATA_CUST_ASSET_CAR_INSERT(APPLYID, SEQNO, IDCARD, PTYPE, AREACODE, DATATYPE);

        -- 申请人配偶房产数据去重处理
        IF V_CP_ID_CARD <> '' THEN
            select concat('bbb:', V_CP_ID_CARD);
            CALL SP_DATA_CUST_ASSET_CAR_INSERT(APPLYID, SEQNO, V_CP_ID_CARD, PTYPE, AREACODE, DATATYPE);
        END IF;
    END IF;

    SET VV_TASK = '贷后和催收车产';
    IF APPLYID <> '' AND IDCARD <> '' AND AREACODE <> '' AND PTYPE <> '' AND SEQNO <> '' THEN
        SET DATATYPE = '2';
        -- 取得申请人配偶。如果申请人有家庭成员，根据流水号的生成规则不一样，有且仅在贷后或催收的家庭关系表中查到数据，不可能同时在2个表中都有
        SELECT MEMBER_ID_CARD
        into V_CP_ID_CARD
        FROM postloan_family_mx
        WHERE SEQ_NO = SEQNO
          AND apply_relation in (1, 2)
          -- AND TYPE=PTYPE
          AND ID_CARD = IDCARD
          AND AREA_CODE = AREACODE
          AND MEMBER_ID_CARD <> IDCARD;

        -- 如果贷后家庭关系表查不到，有配偶的情况下，则说明是催收的流程
        IF V_CP_ID_CARD IS NULL THEN
            SELECT MEMBER_ID_CARD
            into V_CP_ID_CARD
            FROM collection_family_mx
            WHERE SEQ_NO = SEQNO
              AND apply_relation in (1, 2)
              -- AND TYPE=PTYPE
              AND ID_CARD = IDCARD
              AND AREA_CODE = AREACODE
              AND MEMBER_ID_CARD <> IDCARD;
            -- select concat('cp:',V_CP_ID_CARD);
        END IF;

        select concat('贷后.....');
        select concat('ccc:', V_CP_ID_CARD);
        CALL SP_DATA_CUST_ASSET_CAR_INSERT(APPLYID, SEQNO, IDCARD, PTYPE, AREACODE, DATATYPE);

        -- 申请人配偶房产数据去重处理
        IF V_CP_ID_CARD <> '' THEN
            CALL SP_DATA_CUST_ASSET_CAR_INSERT(APPLYID, SEQNO, V_CP_ID_CARD, PTYPE, AREACODE, DATATYPE);
        END IF;
    END IF;
END;

