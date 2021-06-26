create
    definer = root@`%` function InitCollectCode(idcard varchar(20), areacode varchar(20)) returns varchar(32)
BEGIN
    DECLARE cur_date VARCHAR(32);
    DECLARE seqNo VARCHAR(32);
    DECLARE initCode VARCHAR(7);
    DECLARE VI_RN VARCHAR(20);
    DECLARE VI_LEN INT;
    DECLARE con INT;
    SET initCode='0000000';
    SELECT CONCAT(DATE_FORMAT(CURDATE(),'%y%m%d'), areacode ,'66') INTO cur_date FROM dual;
    SELECT RN INTO VI_RN FROM collection_cust_tmp WHERE ID_CARD=idcard ;
    SELECT LENGTH(RN) INTO VI_LEN FROM collection_cust_tmp WHERE ID_CARD=idcard ;
    SET cur_date=CONCAT(cur_date,SUBSTR(initCode,1,LENGTH(initCode)-VI_LEN),VI_RN);


    /**
   SELECT MAX(SEQ_NO) INTO seqNo FROM PRE_CREDIT_CUST WHERE AREA_CODE=areacode and SEQ_NO LIKE  CONCAT(cur_date,'%');
   SELECT MAX(SEQ_NO) INTO seqNo FROM PRE_CREDIT_CUST WHERE AREA_CODE=areacode and SUBSTR(SEQ_NO,1,16) = cur_date;
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
   */

    RETURN cur_date;
END;

