create
    definer = root@`%` function generateUUID(areacode varchar(20)) returns varchar(32)
BEGIN
    DECLARE cur_date VARCHAR(32);
    DECLARE applyId VARCHAR(128);
    DECLARE initCode VARCHAR(8);
    DECLARE codeValue VARCHAR(8);
    DECLARE intValue INT;
    DECLARE con INT;
    SET initCode='00000001';
    SET con=0;
    SELECT CONCAT('2050030101',DATE_FORMAT(CURDATE(),'%Y%m%d')) INTO cur_date FROM dual;
    SELECT MAX(UUID) INTO applyId FROM UUID_FLOW WHERE UUID LIKE  CONCAT(cur_date,'%');
    IF applyId IS NULL THEN
        SET cur_date=CONCAT(cur_date,initCode);
    ELSE
        SET codeValue=REPLACE(applyId,cur_date,'');
        SELECT codeValue+1 INTO intValue FROM DUAL;
        SET codeValue='';
        WHILE con<8-LENGTH(intValue) DO
                SET codeValue=CONCAT(codeValue,'0');
                SET con=con+1;
            END WHILE;
        SET codeValue=CONCAT(codeValue,intValue);
        SET cur_date= CONCAT(cur_date,codeValue);
    END IF;
    RETURN cur_date;
END;

