create
    definer = root@`%` function generateApplyContractNum(areacode varchar(20)) returns varchar(64)
BEGIN
    DECLARE cur_date VARCHAR(64);
    DECLARE contractNum VARCHAR(128);
    DECLARE initCode VARCHAR(5);
    DECLARE codeValue VARCHAR(5);
    DECLARE intValue INT;
    DECLARE con INT;
    SET initCode='00001';
    SET con=0;
    SELECT DATE_FORMAT(CURDATE(),'%Y%m%d') INTO cur_date FROM dual;
    set cur_date = CONCAT(CONCAT('101',areacode),cur_date);
    SELECT MAX(CONTRACT_NUMBER) INTO contractNum FROM APPLY_CONTRACT_INFO WHERE AREA_CODE=areacode and CONTRACT_NUMBER LIKE  CONCAT(cur_date,'%');
    IF contractNum IS NULL THEN
        SET cur_date=CONCAT(cur_date,initCode);
    ELSE
        SET codeValue=REPLACE(contractNum,cur_date,'');
        SELECT codeValue+1 INTO intValue FROM DUAL;
        SET codeValue='';
        WHILE con<5-LENGTH(intValue) DO
                SET codeValue=CONCAT(codeValue,'0');
                SET con=con+1;
            END WHILE;
        SET codeValue=CONCAT(codeValue,intValue);
        SET cur_date=CONCAT(cur_date,codeValue);
    END IF;
    RETURN cur_date;
END;

