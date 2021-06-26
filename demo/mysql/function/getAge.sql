create
    definer = root@`%` function getAge(HM varchar(20)) returns varchar(4) no sql
BEGIN

    DECLARE RE_AGE VARCHAR(20);
    DECLARE V_HM VARCHAR(20);
    DECLARE C_PK VARCHAR(20);

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @info='Incorrect datetime value';

    IF LENGTH(HM)=15
    THEN

        SET V_HM=getIdCard(HM);

    ELSE
        SET V_HM=HM ;

    END IF;


    IF  LENGTH(V_HM)=18
    THEN
        SET RE_AGE=TIMESTAMPDIFF(YEAR, DATE_FORMAT( substr(V_HM,7,8), '%Y-%m-%d'), CURDATE());
    ELSE
        SET RE_AGE=0;
    END IF ;

    IF RE_AGE >=100 OR RE_AGE<0  OR RE_AGE IS NULL
    THEN
        SET RE_AGE=0;
    END IF;

    RETURN RE_AGE;
END;

