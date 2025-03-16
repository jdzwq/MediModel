/*********************************************************************************************
脚本说明：以下脚本仅用于演示如何从外部数据源中检出机构导入表数据，运行时请替换实际的机构编码和机构名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

--第一个阶段：从外源数据库中检出数据并注入到本地医保临时表中

--脚本：创建外部数据链接
--说明：以下链接仅适用于Oracle数据库
--注意：请将<user>、<password>、<dbname>替换为实际的用户名、密码和数据库名
CREATE DATABASE LINK YB_LINK CONNECT TO '<user>' IDENTIFIED BY VALUES '<password>' USING '<dbname>';

--脚本：从外源数据库中检出数据并注入到临时医保就医表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM MDTRT_D;
COMMIT;

INSERT INTO MDTRT_D 
SELECT 
    MDTRT_ID,
    PSN_NO,
    CERTNO,
    PSN_NAME,
    GEND,
    to_char(AGE) AGE,
    INSUTYPE,
    PSN_TYPE,
    INSU_ADMDVS,
    FIXMEDINS_CODE,
    FIXMEDINS_NAME,
    HOSP_LV,
    to_char(BEGNTIME,'YYYY-MM-DD') BEGNTIME,
    to_char(ENDTIME,'YYYY-MM-DD') ENDTIME,
    MED_TYPE,
    IPT_OTP_NO,
    ADM_DEPT_NAME,
    DSCG_DEPT_NAME,
    DSCG_MAINDIAG_CODE,
    DISE_NO,
    DISE_NAME,
    to_char(IPT_DAYS) IPT_DAYS,
    CHFPDR_NAME,
    DSCG_MAINDIAG_NAME,
    DISE_TYPE_CODE
FROM MDTRT_D@YB_LINK
COMMIT;

--脚本：从外源数据库中检出数据并注入到临时医保结算表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM SETL_D;
COMMIT;

INSERT INTO SETL_D 
SELECT 
    SETL_ID,
    MDTRT_ID,
    PSN_NO,
    PSN_NAME,
    CERTNO,
    GEND,
    to_char(AGE) AGE,
    INSUTYPE,
    PSN_TYPE,
    INSU_ADMDVS,
    FIXMEDINS_CODE,
    FIXMEDINS_NAME,
    HOSP_LV,
    to_char(BEGNDATE,'YYYY-MM-DD') BEGNDATE,
    to_char(ENDDATE,'YYYY-MM-DD') ENDDATE,
    SETL_TIME,
    MED_TYPE,
    SETL_TYPE,
    to_char(MEDFEE_SUMAMT,'999999999.99') MEDFEE_SUMAMT,
    to_char(FULAMT_OWNPAY_AMT,'999999999.99') FULAMT_OWNPAY_AMT,
    to_char(OVERLMT_SELFPAY,'999999999.99') OVERLMT_SELFPAY,
    to_char(PRESELFPAY_AMT,'999999999.99') PRESELFPAY_AMT,
    to_char(INSCP_AMT,'999999999.99') INSCP_AMT,
    to_char(FUND_PAY_SUMAMT,'999999999.99') FUND_PAY_SUMAMT,
	to_char(ACCT_PAY,'999999999.99') ACCT_PAY,
    to_char(CASH_PAYAMT,'999999999.99') CASH_PAYAMT
FROM SETL_ID@YB_LINK
COMMIT;

--脚本：从外源数据库中检出数据并注入到临时医保结算明细表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM FEE_LIST_D;
COMMIT;

INSERT INTO FEE_LIST_D 
SELECT 
	SETL_ID,
    RX_DRORD_NO,
    MDTRT_ID,
    FIXMEDINS_CODE,
    FIXMEDINS_NAME,
    PSN_NO,
    to_char(FEE_OCUR_TIME,'YYYY-MM-DD HH24:MI:SS') FEE_OCUR_TIME,
    to_char(CNT,'999999999.99') CNT,
    to_char(PRIC,'999999999.99') PRIC,
    to_char(DET_ITEM_FEE_SUMAMT,'999999999.99') DET_ITEM_FEE_SUMAMT,
    to_char(PRIC_UPLMT_AMT,'999999999.99') PRIC_UPLMT_AMT,
    to_char(SELFPAY_PROP,'999.999') SELFPAY_PROP,
    to_char(FULAMT_OWNPAY_AMT,'999999999.99') FULAMT_OWNPAY_AMT,
    to_char(OVERLMT_SELFPAY,'999999999.99') OVERLMT_SELFPAY,
    to_char(PRESELFPAY_AMT,'999999999.99') PRESELFPAY_AMT,
    to_char(INSCP_AMT,'999999999.99') INSCP_AMT,
    CHRGITM_LV,
    HILIST_CODE,
    HILIST_NAME,
    LIST_TYPE,
    MED_LIST_CODG,
    MEDINS_LIST_CODG,
    MEDINS_LIST_NAME,
    MED_CHRGITM_TYPE,
    PRODNAME,
    SPEC,
    DOSFORM_NAME,
    BILG_DEPT_NAME,
    BILG_DR_NAME,
    ACORD_DEPT_NAME,
    ACORD_DR_NAME,
    TCMDRUG_USED_WAY,
    SIN_DOS_DSCR,
    USED_FRQU_DSCR,
    to_char(PRD_DAYS) PRD_DAYS,
    MEDC_WAY_DSCR,
    DISE_CODG,
    OPRN_OPRT_CODE
FROM FEE_LIST_D@YB_LINK
COMMIT;

--脚本：从外源数据库中检出数据并注入到临时医保诊断明细表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM SETL_LIST_DIAG_D;
COMMIT;

INSERT INTO SETL_LIST_DIAG_D 
SELECT 
	SETL_ID,
    MDTRT_ID,
    PSN_NO,
    DIAG_TYPE,
    MAINDIAG_FLAG,
    DIAG_CODE,
    DIAG_NAME,
    ADM_COND_TYPE
FROM SETL_LIST_DIAG_D@YB_LINK
COMMIT;

--脚本：从外源数据库中检出数据并注入到临时医保手术明细表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM SETL_LIST_OPRN_D;
COMMIT;

INSERT INTO SETL_LIST_OPRN_D 
SELECT 
	SETL_ID,
    PSN_NO,
    MDTRT_ID,
    MAIN_OPRN_FLAG,
    OPRN_OPRT_NAME,
    OPRN_OPRT_CODE,
    to_char(OPRN_OPRT_DATE,'YYYY-MM-DD') OPRN_OPRT_DATE,
    ANST_WAY,
    OPER_DR_NAME,
    ANST_DR_NAME,
    to_char(OPRN_OPRT_BEGNTIME,'YYYY-MM-DD HH24:MI:SS') OPRN_OPRT_BEGNTIME,
	to_char(OPRN_OPRT_ENDTIME,'YYYY-MM-DD HH24:MI:SS') OPRN_OPRT_ENDTIME,
    to_char(ANST_BEGNTIME,'YYYY-MM-DD HH24:MI:SS') ANST_BEGNTIME,
	to_char(ANST_ENDTIME,'YYYY-MM-DD HH24:MI:SS') ANST_ENDTIME
FROM SETL_LIST_OPRN_D@YB_LINK
COMMIT;

--第二个阶段：将本地医保临时表中数据注入到机构导入表中

--脚本：编录一条机构摘要数据
--说明：以下脚本仅用于演示，需根据实际情况修改
DELETE FROM 测试医院_机构摘要;
COMMIT;

INSERT INTO 测试医院_机构摘要 (机构编码,机构名称,机构性质,机构等级,机构类型,核定床位,定点开始日期,定点停止日期)
VALUES ('H00000000000','测试医院','综合医院','三级','公立',1000,to_date('2024-01-01','YYYY-MM-DD'),to_date('2024-12-31','YYYY-MM-DD'));
COMMIT;

--脚本：从医保临时表中检出数据并注入到机构门诊就医表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_门诊就医;
COMMIT;

INSERT INTO 测试医院_门诊就医
SELECT 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	case when a.HOSP_LV in ('01','02','03','04') then '三级'
		when a.HOSP_LV in ('05','06','07') then '二级'
		when a.HOSP_LV in ('08','09','10') then '一级'
		else a.HOSP_LV end as 机构等级,
	CASE WHEN a.INSUTYPE IN('310','340') THEN '城镇职工' 
		WHEN a.INSUTYPE IN ('390','391','392') THEN '城乡居民' 
		ELSE a.INSUTYPE END as 险种类别,
	substr(a.INSU_ADMDVS,1,50) as 参保地区划,
	substr(a.psn_name,1,50) as 人员姓名,
	CASE WHEN a.GEND IN ('1') THEN '男' 
		WHEN a.GEND IN ('2') THEN '女'
		ELSE a.GEND END as 人员性别,
	to_number(a.AGE) as 人员年龄,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.mdtrt_id,1,50) as 门诊号,
	trunc(to_date(a.begntime,'YYYY-MM-DD HH24:MI:SS')) as 门诊日期,
	substr(a.DSCG_DEPT_NAME,1,100) as 门诊科室名称,
	substr(a.CHFPDR_NAME,1,100) as 首诊医生姓名,
	substr(a.DSCG_MAINDIAG_CODE,1,100) as 疾病编码ICD,
	substr(a.DSCG_MAINDIAG_NAME,1,200) as 疾病诊断名称,
	'' as 次要诊断组合,
	substr(b.SETL_ID,1,50) as 结算流水号,
	CASE WHEN b.med_type in ('11','12','120','13') THEN '门诊' 
		WHEN b.med_type in ('140104','140201','140401','991702','992102') THEN '慢特' 
		WHEN b.med_type in ('28') THEN '日间' 
		WHEN b.med_type in ('21','210104') THEN '住院' 
		WHEN b.med_type in ('41') THEN '购药' 
		WHEN b.med_type in ('71') THEN '家床' 
		ELSE b.med_type END as 结算类别,
	to_date(b.setl_time,'YYYY-MM-DD HH24:MI:SS') as 结算日期,
	to_number(b.medfee_sumamt) as 医疗金额,
	to_number(b.inscp_amt) as 医保范围金额,
	to_number(b.fund_pay_sumamt) as 基金支付,
	to_number(b.acct_pay) as 个账支付,
	to_number(b.cash_payamt) as 现金支付
FROM MDTRT_D a INNER JOIN SETL_D b ON a.fixmedins_code = b.fixmedins_code and a.mdtrt_id = b.mdtrt_id
WHERE b.med_type NOT IN ('21','210104');
commit;

--脚本：从医保临时表中检出数据并更新到机构门诊就医表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
create table 临时_门诊诊断 as
select b.MDTRT_ID,listagg(b.DIAG_NAME,'、') within group(order by b.MAINDIAG_FLAG) as DIAG_LIST 
from MDTRT_D a,SETL_LIST_DIAG_D b 
where a.psn_no = b.psn_no and a.MDTRT_ID = b.MDTRT_ID
and a.med_type NOT IN ('21','210104')
group by b.MDTRT_ID;

begin
	for cur in (select a.rowid,b.DIAG_LIST from 测试医院_门诊就医 a inner join 临时_门诊诊断 b on a.门诊号 = b.MDTRT_ID) loop
		update 测试医院_门诊就医 set 次要诊断组合 = substr(cur.DIAG_LIST,1,500) where rowid = cur.rowid;
	end loop;
	commit;
end;

drop table 临时_门诊诊断 purge;

--脚本：从医保临时表中检出数据并注入到机构门诊结算表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_门诊结算;
COMMIT;

INSERT INTO 测试医院_门诊结算
select 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	CASE WHEN a.INSUTYPE IN('310','340') THEN '城镇职工' 
		WHEN a.INSUTYPE IN ('390','391','392') THEN '城乡居民' 
		ELSE a.INSUTYPE END as 险种类别,
	substr(a.INSU_ADMDVS,1,50) as 参保地区划,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.psn_name,1,50) as 人员姓名,
	substr(a.mdtrt_id,1,50) as 门诊号,
	substr(b.rx_drord_no,1,100) as 处方号,
	substr(b.rx_drord_no,1,100) as 处方组号,
	substr(b.medins_list_codg,1,50) as 项目代码,
	substr(b.MEDINS_LIST_NAME,1,200) as 项目名称,
	substr(b.hilist_code,1,50) as 国标代码,
	substr(b.hilist_name,1,200) as 国标名称,
	substr(b.prodname,1,200) as 商品名,
	substr(b.spec,1,200) as 规格,
	'' as 产地厂家,
	substr(b.medc_way_dscr,1,100) as 用法,
	substr(b.sin_dos_dscr,1,100) as 剂量,
	'' as 剂量单位,
	substr(b.used_frqu_dscr,1,100) as 频次,
	to_number(b.prd_days) as 天数,
	case when b.med_chrgitm_type in ('01') then '床位费' 
		when b.med_chrgitm_type in ('02') then '诊查费' 
		when b.med_chrgitm_type in ('03','1408','1409','1410','145301') then '检查费'
		when b.med_chrgitm_type in ('04') then '化验费'
		when b.med_chrgitm_type in ('05') then '治疗费'
		when b.med_chrgitm_type in ('06') then '手术费'
		when b.med_chrgitm_type in ('07') then '护理费'
		when b.med_chrgitm_type in ('08','0801','14011','1402','1403') then '材料费'
		when b.med_chrgitm_type in ('09') then '西药费'
		when b.med_chrgitm_type in ('10') then '中草药'
		when b.med_chrgitm_type in ('11') then '中成药'
		when b.med_chrgitm_type in ('12') then '治疗费'
		when b.med_chrgitm_type in ('13') then '挂号费'
		when b.med_chrgitm_type in ('14') then '其他费'
		when b.med_chrgitm_type in ('1411','1412') then '治疗费'
		when b.med_chrgitm_type in ('1413') then '手术费'
		else '其他费' end as 收费项目类别,
	case when b.chrgitm_lv in ('01') then '甲类' 
		when b.chrgitm_lv in ('02') then '乙类' 
		when b.chrgitm_lv in ('03') then '丙类' 
		when b.chrgitm_lv in ('04') then '可报丙类' 
		else b.chrgitm_lv end as 收费项目等级,
	to_number(b.cnt) as 数量,
	'' as 数量单位,
	to_number(b.pric) as 单价,
	to_number(b.det_item_fee_sumamt) as 金额,
	to_number(b.pric_uplmt_amt) as 限价,
	to_number(b.selfpay_prop) as 自付比例,
	to_number(b.fulamt_ownpay_amt) as 全自费金额,
	to_number(b.overlmt_selfpay) as 超限价金额,
	to_number(b.preselfpay_amt) as 先行自付金额,
	to_date(b.fee_ocur_time,'YYYY-MM-DD HH24:MI:SS') as 费用发生时间,
	substr(b.bilg_dept_name,1,100) as 费用科室名称,
	substr(b.SETL_ID,1,50) as 结算流水号
from SETL_D a INNER JOIN FEE_LIST_D b ON a.fixmedins_code = b.fixmedins_code and a.SETL_ID = b.SETL_ID
and a.med_type NOT IN ('21','210104');
commit;

--脚本：从医保临时表中检出数据并注入到机构门诊手术表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_门诊手术;
COMMIT;

INSERT INTO 测试医院_门诊手术
SELECT 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.psn_name,1,50) as 姓名,
	CASE WHEN a.GEND IN ('1') THEN '男' 
		WHEN a.GEND IN ('2') THEN '女'
		ELSE a.GEND END as 性别,
	to_number(a.AGE) as 年龄,
	substr(a.mdtrt_id,1,50) as 门诊号,
	substr(a.DSCG_DEPT_NAME,1,100) as 门诊科室名称,
	substr(a.DSCG_MAINDIAG_NAME,1,200) as 疾病诊断名称,
	to_date(b.oprn_oprt_date,'YYYY-MM-DD') as 手术日期,
	to_date(b.oprn_oprt_begntime,'YYYY-MM-DD HH24:MI:SS') as 手术开始时间,
	to_date(b.oprn_oprt_endtime,'YYYY-MM-DD HH24:MI:SS') as 手术结束时间,
	'' as 手术科室名称,
	substr(b.oper_dr_name,1,100) as 手术者姓名,
	substr(b.oprn_oprt_code,1,50) as 手术操作编码,
	substr(b.oprn_oprt_name,1,200) as 手术操作名称,
	case when b.MAIN_OPRN_FLAG in ('1') then '主要手术' 
		when b.MAIN_OPRN_FLAG in ('2') then '次要手术' 
		else b.MAIN_OPRN_FLAG end as 主要手术, 
	'' as 手术等级,
	'' as 切口类型,
	'' as 愈合类型
FROM MDTRT_D a INNER JOIN SETL_LIST_OPRN_D b ON a.psn_no = b.psn_no and a.mdtrt_id = b.mdtrt_id
WHERE a.med_type NOT IN ('21','210104');
commit;

--脚本：从医保临时表中检出数据并注入到机构门诊麻醉表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_门诊麻醉;
COMMIT;

INSERT INTO 测试医院_门诊麻醉
SELECT 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.psn_name,1,50) as 姓名,
	CASE WHEN a.GEND IN ('1') THEN '男' 
		WHEN a.GEND IN ('2') THEN '女'
		ELSE a.GEND END as 性别,
	to_number(a.AGE) as 年龄,
	substr(a.mdtrt_id,1,50) as 门诊号,
	substr(a.DSCG_DEPT_NAME,1,100) as 门诊科室名称,
	substr(a.DSCG_MAINDIAG_NAME,1,200) as 疾病诊断名称,
	to_date(b.oprn_oprt_date,'YYYY-MM-DD') as 麻醉日期,
	to_date(b.ANST_BEGNTIME,'YYYY-MM-DD HH24:MI:SS') as 麻醉开始时间,
	to_date(b.ANST_ENDTIME,'YYYY-MM-DD HH24:MI:SS') as 麻醉结束时间,
	'' as 麻醉科室名称,
	substr(b.ANST_DR_NAME,1,100) as 麻醉者姓名,
	'' as 麻醉方式编码,
	substr(b.ANST_WAY,1,200) as 麻醉方式名称,
	'' as 麻醉等级,
	'' as 术后镇痛方式
FROM MDTRT_D a INNER JOIN SETL_LIST_OPRN_D b ON a.psn_no = b.psn_no and a.mdtrt_id = b.mdtrt_id
WHERE a.med_type NOT IN ('21','210104');
commit;

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

--脚本：从医保临时表中检出数据并注入到机构住院就医表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_住院就医;
COMMIT;

INSERT INTO 测试医院_住院就医
SELECT 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	case when a.HOSP_LV in ('01','02','03','04') then '三级'
		when a.HOSP_LV in ('05','06','07') then '二级'
		when a.HOSP_LV in ('08','09','10') then '一级'
		else a.HOSP_LV end as 机构等级,
	CASE WHEN a.INSUTYPE IN('310','340') THEN '城镇职工' 
		WHEN a.INSUTYPE IN ('390','391','392') THEN '城乡居民' 
		ELSE a.INSUTYPE END as 险种类别,
	substr(a.INSU_ADMDVS,1,50) as 参保地区划,
	substr(a.psn_name,1,50) as 人员姓名,
	CASE WHEN a.GEND IN ('1') THEN '男' 
		WHEN a.GEND IN ('2') THEN '女'
		ELSE a.GEND END as 人员性别,
	to_number(a.AGE) as 人员年龄,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.mdtrt_id,1,50) as 住院号,
	trunc(to_date(a.begntime,'YYYY-MM-DD HH24:MI:SS')) as 入院日期,
	trunc(to_date(a.endtime,'YYYY-MM-DD HH24:MI:SS')) as 出院日期,
	to_number(a.ipt_days) as 住院天数,
	substr(a.DSCG_DEPT_NAME,1,100) as 住院科室名称,
	substr(a.CHFPDR_NAME,1,100) as 主管医生姓名,
	substr(a.DSCG_MAINDIAG_CODE,1,100) as 疾病编码ICD,
	substr(a.DSCG_MAINDIAG_NAME,1,200) as 疾病诊断名称,
	'' as 次要诊断组合,
	substr(b.SETL_ID,1,50) as 结算流水号,
	CASE WHEN b.med_type in ('11','12','120','13') THEN '门诊' 
		WHEN b.med_type in ('140104','140201','140401','991702','992102') THEN '慢特' 
		WHEN b.med_type in ('21','210104','28') THEN '住院' 
		WHEN b.med_type in ('41') THEN '购药' 
		WHEN b.med_type in ('71') THEN '家床' 
		ELSE b.med_type END as 结算类别,
	to_date(b.setl_time,'YYYY-MM-DD HH24:MI:SS') as 结算日期,
	to_number(b.medfee_sumamt) as 医疗金额,
	to_number(b.inscp_amt) as 医保范围金额,
	to_number(b.fund_pay_sumamt) as 基金支付,
	to_number(b.acct_pay) as 个账支付,
	to_number(b.cash_payamt) as 现金支付
FROM MDTRT_D a INNER JOIN SETL_D b ON a.fixmedins_code = b.fixmedins_code and a.mdtrt_id = b.mdtrt_id
WHERE b.med_type IN ('21','210104');
commit;

--脚本：从医保临时表中检出数据并更新到机构住院就医表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
create table 临时_住院诊断 as
select b.MDTRT_ID,listagg(b.DIAG_NAME,'、') within group(order by b.MAINDIAG_FLAG) as DIAG_LIST 
from MDTRT_D a,SETL_LIST_DIAG_D b 
where a.psn_no = b.psn_no and a.MDTRT_ID = b.MDTRT_ID
and a.med_type IN ('21','210104')
group by b.MDTRT_ID;

begin
	for cur in (select a.rowid,b.DIAG_LIST from 测试医院_住院就医 a inner join 临时_住院诊断 b on a.住院号 = b.MDTRT_ID) loop
		update 测试医院_住院就医 set 次要诊断组合 = substr(cur.DIAG_LIST,1,500) where rowid = cur.rowid;
	end loop;
	commit;
end;

--脚本：删除临时表
drop table 临时_住院诊断 purge;

--脚本：从医保临时表中检出数据并注入到机构住院结算表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_住院结算;
COMMIT;

INSERT INTO 测试医院_住院结算
select 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	CASE WHEN a.INSUTYPE IN('310','340') THEN '城镇职工' 
		WHEN a.INSUTYPE IN ('390','391','392') THEN '城乡居民' 
		ELSE a.INSUTYPE END as 险种类别,
	substr(a.INSU_ADMDVS,1,50) as 参保地区划,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.psn_name,1,50) as 人员姓名,
	substr(a.mdtrt_id,1,50) as 住院号,
	substr(b.rx_drord_no,1,100) as 医嘱号,
	substr(b.rx_drord_no,1,100) as 医嘱组号,
	substr(b.medins_list_codg,1,50) as 项目代码,
	substr(b.MEDINS_LIST_NAME,1,200) as 项目名称,
	substr(b.hilist_code,1,50) as 国标代码,
	substr(b.hilist_name,1,200) as 国标名称,
	substr(b.prodname,1,200) as 商品名,
	substr(b.spec,1,200) as 规格,
	'' as 产地厂家,
	substr(b.medc_way_dscr,1,100) as 用法,
	substr(b.sin_dos_dscr,1,100) as 剂量,
	'' as 剂量单位,
	substr(b.used_frqu_dscr,1,100) as 频次,
	to_number(b.prd_days) as 天数,
	case when b.med_chrgitm_type in ('01') then '床位费' 
		when b.med_chrgitm_type in ('02') then '诊查费' 
		when b.med_chrgitm_type in ('03','1408','1409','1410','145301') then '检查费'
		when b.med_chrgitm_type in ('04') then '化验费'
		when b.med_chrgitm_type in ('05') then '治疗费'
		when b.med_chrgitm_type in ('06') then '手术费'
		when b.med_chrgitm_type in ('07') then '护理费'
		when b.med_chrgitm_type in ('08','0801','14011','1402','1403') then '材料费'
		when b.med_chrgitm_type in ('09') then '西药费'
		when b.med_chrgitm_type in ('10') then '中草药'
		when b.med_chrgitm_type in ('11') then '中成药'
		when b.med_chrgitm_type in ('12') then '治疗费'
		when b.med_chrgitm_type in ('13') then '挂号费'
		when b.med_chrgitm_type in ('14') then '其他费'
		when b.med_chrgitm_type in ('1411','1412') then '治疗费'
		when b.med_chrgitm_type in ('1413') then '手术费'
		else '其他费' end as 收费项目类别,
	case when b.chrgitm_lv in ('01') then '甲类' 
		when b.chrgitm_lv in ('02') then '乙类' 
		when b.chrgitm_lv in ('03') then '丙类' 
		when b.chrgitm_lv in ('04') then '可报丙类' 
		else b.chrgitm_lv end as 收费项目等级,
	to_number(b.cnt) as 数量,
	'' as 数量单位,
	to_number(b.pric) as 单价,
	to_number(b.det_item_fee_sumamt) as 金额,
	to_number(b.pric_uplmt_amt) as 限价,
	to_number(b.selfpay_prop) as 自付比例,
	to_number(b.fulamt_ownpay_amt) as 全自费金额,
	to_number(b.overlmt_selfpay) as 超限价金额,
	to_number(b.preselfpay_amt) as 先行自付金额,
	to_date(b.fee_ocur_time,'YYYY-MM-DD HH24:MI:SS') as 费用发生时间,
	substr(b.bilg_dept_name,1,100) as 费用科室名称,
	substr(b.SETL_ID,1,50) as 结算流水号
from SETL_D a INNER JOIN FEE_LIST_D b ON a.fixmedins_code = b.fixmedins_code and a.SETL_ID = b.SETL_ID
and a.med_type IN ('21','210104');
commit;

--脚本：从医保临时表中检出数据并注入到机构住院手术表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_住院手术;
COMMIT;

INSERT INTO 测试医院_住院手术
SELECT 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.psn_name,1,50) as 姓名,
	CASE WHEN a.GEND IN ('1') THEN '男' 
		WHEN a.GEND IN ('2') THEN '女'
		ELSE a.GEND END as 性别,
	to_number(a.AGE) as 年龄,
	substr(a.mdtrt_id,1,50) as 住院号,
	substr(a.DSCG_DEPT_NAME,1,100) as 住院科室名称,
	substr(a.DSCG_MAINDIAG_NAME,1,200) as 疾病诊断名称,
	to_date(b.oprn_oprt_date,'YYYY-MM-DD') as 手术日期,
	to_date(b.oprn_oprt_begntime,'YYYY-MM-DD HH24:MI:SS') as 手术开始时间,
	to_date(b.oprn_oprt_endtime,'YYYY-MM-DD HH24:MI:SS') as 手术结束时间,
	'' as 手术科室名称,
	substr(b.oper_dr_name,1,100) as 手术者姓名,
	substr(b.oprn_oprt_code,1,50) as 手术操作编码,
	substr(b.oprn_oprt_name,1,200) as 手术操作名称,
	case when b.MAIN_OPRN_FLAG in ('1') then '主要手术' 
		when b.MAIN_OPRN_FLAG in ('2') then '次要手术' 
		else b.MAIN_OPRN_FLAG end as 主要手术, 
	'' as 手术等级,
	'' as 切口类型,
	'' as 愈合类型
FROM MDTRT_D a INNER JOIN SETL_LIST_OPRN_D b ON a.psn_no = b.psn_no and a.mdtrt_id = b.mdtrt_id
WHERE a.med_type IN ('21','210104');
commit;

--脚本：从医保临时表中检出数据并注入到机构住院麻醉表
--说明：请先确定本地医保临时表可用后，再执行以下脚本
DELETE FROM 测试医院_住院麻醉;
COMMIT;

INSERT INTO 测试医院_住院麻醉
SELECT 
	substr(a.fixmedins_code,1,50) as 机构编码,
	substr(a.fixmedins_name,1,100) as 机构名称,
	substr(a.CERTNO,1,50) as 身份证号,
	substr(a.psn_name,1,50) as 姓名,
	CASE WHEN a.GEND IN ('1') THEN '男' 
		WHEN a.GEND IN ('2') THEN '女'
		ELSE a.GEND END as 性别,
	to_number(a.AGE) as 年龄,
	substr(a.mdtrt_id,1,50) as 住院号,
	substr(a.DSCG_DEPT_NAME,1,100) as 住院科室名称,
	substr(a.DSCG_MAINDIAG_NAME,1,200) as 疾病诊断名称,
	to_date(b.oprn_oprt_date,'YYYY-MM-DD') as 麻醉日期,
	to_date(b.ANST_BEGNTIME,'YYYY-MM-DD HH24:MI:SS') as 麻醉开始时间,
	to_date(b.ANST_ENDTIME,'YYYY-MM-DD HH24:MI:SS') as 麻醉结束时间,
	'' as 麻醉科室名称,
	substr(b.ANST_DR_NAME,1,100) as 麻醉者姓名,
	'' as 麻醉方式编码,
	substr(b.ANST_WAY,1,200) as 麻醉方式名称,
	'' as 麻醉等级,
	'' as 术后镇痛方式,
	'' as 麻醉复苏开始时间,
	'' as 麻醉复苏结束时间
FROM MDTRT_D a INNER JOIN SETL_LIST_OPRN_D b ON a.psn_no = b.psn_no and a.mdtrt_id = b.mdtrt_id
WHERE a.med_type IN ('21','210104');
commit;
