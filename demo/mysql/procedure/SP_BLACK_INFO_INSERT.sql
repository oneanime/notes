create
    definer = root@`%` procedure SP_BLACK_INFO_INSERT(IN APPLYID varchar(50), IN SEQNO varchar(50),
                                                      IN IDCARD varchar(20), IN TYPE varchar(10),
                                                      IN AREACODE varchar(30)) reads sql data
BEGIN
    DECLARE VV_TASK VARCHAR(300);
    DECLARE DATATYPE VARCHAR(10);

    SET VV_TASK = '预授信黑名单数据入黑名单库';
    IF SEQNO <> '' AND IDCARD <> '' AND AREACODE <> '' AND APPLYID = '' AND TYPE = '' THEN
        SET DATATYPE = '0';
        CALL SP_LINE_TRANS_ROW(APPLYID, SEQNO, IDCARD, TYPE, AREACODE, DATATYPE);
    END IF;

    SET VV_TASK = '实时授信黑名单数据入黑名单库';
    IF APPLYID <> '' AND IDCARD <> '' AND AREACODE <> '' AND TYPE <> '' AND SEQNO = '' THEN
        SET DATATYPE = '1';
        CALL SP_LINE_TRANS_ROW(APPLYID, SEQNO, IDCARD, TYPE, AREACODE, DATATYPE);

    END IF;

    SET VV_TASK = '贷后预警和贷后催收黑名单数据入黑名单库';
    IF APPLYID <> '' AND IDCARD <> '' AND AREACODE <> '' AND TYPE <> '' AND SEQNO <> '' THEN
        SET DATATYPE = '2';
        CALL SP_LINE_TRANS_ROW(APPLYID, SEQNO, IDCARD, TYPE, AREACODE, DATATYPE);
    END IF;


END;

