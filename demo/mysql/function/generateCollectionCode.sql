create
    definer = root@`%` function generateCollectionCode(areacode varchar(20)) returns varchar(32)
BEGIN
    DECLARE cur_date VARCHAR(32);
    DECLARE seqNo VARCHAR(128);
    DECLARE initCode VARCHAR(6);
    DECLARE codeValue VARCHAR(6);
    DECLARE intValue INT;
    DECLARE con INT;
    SET initCode='000001';
    SET con=0;
    SELECT CONCAT(DATE_FORMAT(CURDATE(),'%y%m%d'),areacode,'66') INTO cur_date FROM dual;
    SELECT MAX(SEQ_NO) INTO seqNo FROM COLLECTION_CUST_STAT WHERE AREA_CODE=areacode   and SEQ_NO LIKE  CONCAT(cur_date,'%');
    IF seqNo IS NULL THEN
        SET cur_date=CONCAT(cur_date,initCode);
    ELSE
        SET codeValue=REPLACE(seqNo,cur_date,'');
        SELECT codeValue+1 INTO intValue FROM DUAL;
        SET codeValue='';
        WHILE con<6-LENGTH(intValue) DO
                SET codeValue=CONCAT(codeValue,'0');
                SET con=con+1;
            END WHILE;
        SET codeValue=CONCAT(codeValue,intValue);
        SET cur_date=CONCAT(cur_date,codeValue);
    END IF;
    RETURN cur_date;
END;

