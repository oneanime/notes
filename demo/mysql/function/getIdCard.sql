create
    definer = root@`%` function getIdCard(HM varchar(20)) returns varchar(20) no sql
BEGIN

    DECLARE  re_zjhm varchar(20)  DEFAULT '' ;
    DECLARE  in_length varchar(20)  DEFAULT ''  ;

    set in_length=LENGTH(TRIM(HM));


    if in_length =15 then
        set re_zjhm=CONCAT (SUBSTRING(HM,1,6),
                            (CASE WHEN SUBSTRING(HM,7,2)>SUBSTRING(YEAR(CURDATE()),3,2)
                                      THEN '19'
                                  ELSE '20'
                                END)
            ,SUBSTRING(HM,7,9)
            ,(
                                CASE  ((SUBSTRING(HM,1,1)*7+
                                        SUBSTRING(HM,2,1)*9+
                                        SUBSTRING(HM,3,1)*10+
                                        SUBSTRING(HM,4,1)*5+
                                        SUBSTRING(HM,5,1)*8+
                                        SUBSTRING(HM,6,1)*4+
                                        (CASE WHEN SUBSTRING(HM,7,2)>SUBSTRING(YEAR(CURDATE()),3,2)
                                                  THEN
                                                          1*2+
                                                          9*1
                                              ELSE
                                                          2*2+
                                                          0*1
                                            END)+
                                        SUBSTRING(HM,7,1)*6+
                                        SUBSTRING(HM,8,1)*3+
                                        SUBSTRING(HM,9,1)*7+
                                        SUBSTRING(HM,10,1)*9+
                                        SUBSTRING(HM,11,1)*10+
                                        SUBSTRING(HM,12,1)*5+
                                        SUBSTRING(HM,13,1)*8+
                                        SUBSTRING(HM,14,1)*4+
                                        SUBSTRING(HM,15,1)*2  )%11)
                                    WHEN 0 THEN '1'
                                    WHEN 1 THEN '0'
                                    WHEN 2 THEN 'X'
                                    WHEN 3 THEN '9'
                                    WHEN 4 THEN '8'
                                    WHEN 5 THEN '7'
                                    WHEN 6 THEN '6'
                                    WHEN 7 THEN '5'
                                    WHEN 8 THEN '4'
                                    WHEN 9 THEN '3'
                                    WHEN 10 THEN '2'
                                    ELSE 'FALSE' END ) );

    else

        set re_zjhm=hm;
    end if;

    RETURN re_zjhm;
END;

