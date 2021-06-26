create
    definer = root@`*` function getSex(HM varchar(20)) returns varchar(4)
BEGIN
    DECLARE RE_SEX VARCHAR(4);
    DECLARE V_SEX VARCHAR(4);


    IF LENGTH(HM)=18
    THEN
        SET V_SEX= SUBSTRING(HM,17,1) ;
        IF V_SEX%2=0
        THEN
            SET RE_SEX='0' ;
        else
            SET RE_SEX='1';
        end if;
    ELSEIF
            LENGTH(HM)=15
    THEN

        SET V_SEX= SUBSTRING(HM,15,1) ;
        IF V_SEX%2=0
        THEN
            SET RE_SEX='0';
        else
            SET RE_SEX='1';
        end if;


    ELSE
        SET RE_SEX='3';

    END IF;


    RETURN RE_SEX;
END;

