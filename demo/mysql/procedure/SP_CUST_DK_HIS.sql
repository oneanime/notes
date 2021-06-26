create
    definer = root@`%` procedure SP_CUST_DK_HIS(IN timefile varchar(30))
BEGIN
    declare vv_proc_name varchar(300) charset utf8;
    declare vv_grade1 int(11);

    set vv_proc_name = '删除当天插入或者更新的数据';
    delete from DATA_CUST_DK_HIS where s_date = timefile;
    commit;

    set vv_proc_name = '无变动的记录的e_date回滚成29990101 (数据重新下发不一致导致的异常)';
    update DATA_CUST_DK_HIS a set a.e_date ='29990101' where a.e_date = timefile;
    commit;

    set vv_proc_name = '将需要更新的数据的结束时间修改为数据下发时间';
    update DATA_CUST_DK_HIS a
    set a.e_date = timefile
    where EXISTS(
                  select 1
                  from ods.cbs_borm_base b
                  where a.acc_no = b.acc_no
                    and a.ident_no = b.ident_no
                    and ifnull(a.LOAN_BAL, 0) <> ifnull(b.LOAN_BAL, 0)
                    and ifnull(a.FIVE_CLASS_TYPE, 0) <> ifnull(b.FIVE_CLASS_TYPE, 0)
                    and a.e_date = '29990101'
              );
    commit;


    set vv_proc_name = '重新插入一条更新的记录';
    insert into DATA_CUST_DK_HIS
    select a.DATA_DATE
         , a.LOAD_DATE
         , a.CUST_ID
         , a.BR_NO
         , a.BR_NAME
         , a.CUST_NAME
         , a.IDENT_TYPE
         , a.IDENT_NO
         , a.ACCT_NO
         , a.VOUCHER_NO
         , a.BUSINESS_NO
         , a.QX_DATE
         , a.END_DATE
         , a.LOAN_KIND
         , a.REMAINING_DAYS
         , a.INT_RATE
         , a.APPLIC_AMOUNT
         , a.ADV_VAL
         , a.LOAN_BAL
         , a.INT_STRT_DATE
         , a.REPAY_DAY
         , a.TF_MCA_SUB_ACCT_TP
         , a.TF_MCA_SUB_INT_CAT
         , a.CAT_TYPE_NAME
         , a.CUST_TYPE
         , a.MAIN_INDUSTRY
         , a.ENT_SCALE
         , a.PURPOSE_TYPE
         , a.AUTO_DBT_ACCT_NO
         , a.PAY_CUST_NAME
         , a.PAY_ACCT_BAL
         , a.FIVE_ADJUST_DATE
         , a.FIVE_CLASS_TYPE
         , a.VOUCH_TYPE
         , a.CUST_CN
         , a.DUTY_CUST_ID
         , a.EMPLOYEE_NAME
         , a.LINKMAN_TEL
         , a.ADDR
         , a.OWE_INTEREST
         , a.TRF_ACCT_NO
         , a.CARD_NO
         , a.REPAY_SCHED
         , a.LOAN_TRM
         , a.BAD_DEBT_IND
         , a.ACT_TYPE
         , a.UNPD_PRIN_BAL
         , a.CAP_UNPD_INT
         , a.UNPD_ARRS_INT_BAL
         , a.CURR
         , a.INT_ACCR
         , a.UNPD_ARR_PRN_BAL
         , a.ARR_INT_ACCR
         , a.FINE2_INT_ACCR
         , a.UNPD_INT_ARR_PRN
         , a.FINE4_INT_ACCR
         , a.GL_CLASS_CODE
         , a.APP_SUM
         , a.INT_INCR
         , a.STOP_ACCRUAL
         , a.SUBJ_NO
         , a.SUBJ_NAME
         , a.LST_FIN_DATE
         , a.CTA_REFERENCE
         , a.ACC_NO
         , a.CURR_INT_CAT
         , a.NEW_INT_CAT
         , a.NEW_ACCT_TYPE
         , a.CURR_ACCT_TYPE
         , a.CURR_EXP_DATE
         , a.NEW_EXP_DATE
         , a.APPROVE_DT
         , a.OLD_RATE
         , a.EXP_FLAG
         , a.GL_BUCKET_DUE_01
         , a.GL_BUCKET_DUE_02
         , a.GL_BUCKET_DUE_03
         , a.GL_BUCKET_DUE_04
         , a.GL_BUCKET_DUE_05
         , a.APP_PUT_OUT_DATE
         , a.APP_MATURITY_DATE
         , a.RE_OLD_ACCT_NO
         , a.PRN_RE_DATE
         , a.INT_RE_DATE
         , a.PRN_RE_AMOUNT
         , a.INT_RE_AMOUNT
         , a.DUE_AMT
         , a.OLD_DUE_AMT
         , a.OLD_LOAN_TRM
         , a.FUND_AGR_NO
         , a.BAD_DEBT_TRF_DTE
         , a.SIGN_DATE
         , a.CONTRACT_PUT_OUT_DATE
         , a.CONTRACT_MATURITY
         , a.APP_DATE
         , a.ORG_ID
         , a.APPLY_CURRENCY
         , a.APP_TERM
         , a.BUSINESS_PHASE
         , a.FIVE_CLASS_DATE
         , a.REM_REPAYS
         , a.STAT
         , a.OWE_AMT_P
         , a.OWE_AMT_I
         , a.OWE_AMT_W
         , a.OWE_AMT_A
         , a.OWE_AMT_E
         , a.BUCKET_CDE_P
         , a.BUCKET_CDE_I
         , a.BUCKET_CDE_W
         , a.BUCKET_CDE_A
         , a.BUCKET_CDE_E
         , a.LEGAL_NO
         , timefile                          as s_date
         , '29990101'                        as e_date
         , date_format(timefile, '%y-%m-%d') as xfsjc
         , current_timestamp                 as gxsjc
    from ods.cbs_borm_base a
    where exists(select 1
                 from DATA_CUST_DK_HIS b
                 where a.acc_no = b.acc_no
                   and a.ident_no = b.ident_no
                   and ifnull(a.LOAN_BAL, 0) <> ifnull(b.LOAN_BAL, 0)
                   and ifnull(a.FIVE_CLASS_TYPE, 0) <> ifnull(b.FIVE_CLASS_TYPE, 0)
                   and b.E_DATE = timefile);
    commit;


    set vv_proc_name = '插入新增的记录';
    insert into DATA_CUST_DK_HIS
    select b.DATA_DATE
         , b.LOAD_DATE
         , b.CUST_ID
         , b.BR_NO
         , b.BR_NAME
         , b.CUST_NAME
         , b.IDENT_TYPE
         , b.IDENT_NO
         , b.ACCT_NO
         , b.VOUCHER_NO
         , b.BUSINESS_NO
         , b.QX_DATE
         , b.END_DATE
         , b.LOAN_KIND
         , b.REMAINING_DAYS
         , b.INT_RATE
         , b.APPLIC_AMOUNT
         , b.ADV_VAL
         , b.LOAN_BAL
         , b.INT_STRT_DATE
         , b.REPAY_DAY
         , b.TF_MCA_SUB_ACCT_TP
         , b.TF_MCA_SUB_INT_CAT
         , b.CAT_TYPE_NAME
         , b.CUST_TYPE
         , b.MAIN_INDUSTRY
         , b.ENT_SCALE
         , b.PURPOSE_TYPE
         , b.AUTO_DBT_ACCT_NO
         , b.PAY_CUST_NAME
         , b.PAY_ACCT_BAL
         , b.FIVE_ADJUST_DATE
         , b.FIVE_CLASS_TYPE
         , b.VOUCH_TYPE
         , b.CUST_CN
         , b.DUTY_CUST_ID
         , b.EMPLOYEE_NAME
         , b.LINKMAN_TEL
         , b.ADDR
         , b.OWE_INTEREST
         , b.TRF_ACCT_NO
         , b.CARD_NO
         , b.REPAY_SCHED
         , b.LOAN_TRM
         , b.BAD_DEBT_IND
         , b.ACT_TYPE
         , b.UNPD_PRIN_BAL
         , b.CAP_UNPD_INT
         , b.UNPD_ARRS_INT_BAL
         , b.CURR
         , b.INT_ACCR
         , b.UNPD_ARR_PRN_BAL
         , b.ARR_INT_ACCR
         , b.FINE2_INT_ACCR
         , b.UNPD_INT_ARR_PRN
         , b.FINE4_INT_ACCR
         , b.GL_CLASS_CODE
         , b.APP_SUM
         , b.INT_INCR
         , b.STOP_ACCRUAL
         , b.SUBJ_NO
         , b.SUBJ_NAME
         , b.LST_FIN_DATE
         , b.CTA_REFERENCE
         , b.ACC_NO
         , b.CURR_INT_CAT
         , b.NEW_INT_CAT
         , b.NEW_ACCT_TYPE
         , b.CURR_ACCT_TYPE
         , b.CURR_EXP_DATE
         , b.NEW_EXP_DATE
         , b.APPROVE_DT
         , b.OLD_RATE
         , b.EXP_FLAG
         , b.GL_BUCKET_DUE_01
         , b.GL_BUCKET_DUE_02
         , b.GL_BUCKET_DUE_03
         , b.GL_BUCKET_DUE_04
         , b.GL_BUCKET_DUE_05
         , b.APP_PUT_OUT_DATE
         , b.APP_MATURITY_DATE
         , b.RE_OLD_ACCT_NO
         , b.PRN_RE_DATE
         , b.INT_RE_DATE
         , b.PRN_RE_AMOUNT
         , b.INT_RE_AMOUNT
         , b.DUE_AMT
         , b.OLD_DUE_AMT
         , b.OLD_LOAN_TRM
         , b.FUND_AGR_NO
         , b.BAD_DEBT_TRF_DTE
         , b.SIGN_DATE
         , b.CONTRACT_PUT_OUT_DATE
         , b.CONTRACT_MATURITY
         , b.APP_DATE
         , b.ORG_ID
         , b.APPLY_CURRENCY
         , b.APP_TERM
         , b.BUSINESS_PHASE
         , b.FIVE_CLASS_DATE
         , b.REM_REPAYS
         , b.STAT
         , b.OWE_AMT_P
         , b.OWE_AMT_I
         , b.OWE_AMT_W
         , b.OWE_AMT_A
         , b.OWE_AMT_E
         , b.BUCKET_CDE_P
         , b.BUCKET_CDE_I
         , b.BUCKET_CDE_W
         , b.BUCKET_CDE_A
         , b.BUCKET_CDE_E
         , b.LEGAL_NO
         , timefile                          as s_date
         , '29990101'                        as e_date
         , date_format(timefile, '%y-%m-%d') as xfsjc
         , current_timestamp                 as gxsjc
    from ods.cbs_borm_base b
    where not exists(select 1 from DATA_CUST_DK_HIS a where a.acc_no = b.acc_no and a.ident_no = b.ident_no);

    commit;

END;

