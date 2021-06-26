create
    definer = root@`%` function GETEXP(REMARK varchar(100), MS varchar(10)) returns varchar(20)
BEGIN
    DECLARE RE_HM    VARCHAR (100);
    DECLARE V_TEST   VARCHAR (100);
    DECLARE V_PK     INT;
    DECLARE V_INT    INT;

    IF MS = 'YQCS' AND LENGTH (REMARK) > 0
    THEN
        SET V_TEST = REPLACE (REMARK, '1', '');
        SET V_TEST = REPLACE (V_TEST, '2', '');
        SET V_TEST = REPLACE (V_TEST, '3', '');
        SET V_TEST = REPLACE (V_TEST, '4', '');
        SET V_TEST = REPLACE (V_TEST, '5', '');
        SET V_TEST = REPLACE (V_TEST, '6', '');
        SET V_TEST = REPLACE (V_TEST, '7', '');
        SET V_TEST = REPLACE (V_TEST, '8', '');
        SET V_TEST = REPLACE (V_TEST, '9', '');

        SET RE_HM = LENGTH (REMARK) - LENGTH (V_TEST);
    ELSEIF MS = 'YQSC' AND LENGTH (REMARK) > 0
    THEN
        SET V_INT = 7;
        SET V_PK = 1;

        WHILE V_INT > 0 AND V_PK = 1
            DO
                SET RE_HM = LENGTH (REMARK) - LENGTH (REPLACE (REMARK, V_INT, ''));

                IF RE_HM > 0
                THEN
                    SET RE_HM = V_INT;
                    SET V_PK = 0;
                END IF;

                SET V_INT = V_INT - 1;
            END WHILE;
    ELSEIF MS = 'FXBS' AND LENGTH (REMARK) > 0
    THEN
        SET RE_HM = replace (REMARK, 'D', '');

        SET RE_HM = replace (RE_HM, 'G', '');

        SET RE_HM = replace (RE_HM, 'Z', '');

        SET RE_HM = LENGTH (REMARK) - LENGTH (RE_HM);
    ELSE
        SET RE_HM = 0;
    END IF;

    SET RE_HM = COALESCE (RE_HM, 0);
    RETURN RE_HM;
END;

