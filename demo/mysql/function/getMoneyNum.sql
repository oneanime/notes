create
    definer = root@`%` function getMoneyNum(money varchar(20)) returns decimal(15, 2)
BEGIN
    DECLARE amt VARCHAR(32);
    DECLARE unit VARCHAR(32);
    DECLARE resultMoney DECIMAL(15,2) DEFAULT 0;
    DECLARE v_length int DEFAULT 0;
    SET v_length=CHAR_LENGTH(money);

    tt:WHILE v_length > 0 DO
            IF (mid(money,v_length,1) REGEXP '[0-9]') THEN
                LEAVE tt;
            END IF;
            SET v_length=v_length - 1;
        END WHILE;

    SELECT SUBSTR(money from 1 For v_length),SUBSTR(money,v_length+1) INTO amt,unit FROM DUAL;

    IF unit REGEXP '亿美元' THEN SET amt = amt*700000000;
    ELSEIF unit REGEXP '万美元' THEN SET amt = amt*70000;
    ELSEIF unit REGEXP '亿' THEN SET amt = amt*100000000;
    ELSEIF unit REGEXP '万' THEN SET amt = amt*10000;
    ELSE SET amt=amt*10000;
    END IF;
    SET resultMoney=amt;
    RETURN resultMoney;
END;

