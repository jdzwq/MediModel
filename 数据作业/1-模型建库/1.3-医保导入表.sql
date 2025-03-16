/*********************************************************************************************
建表说明：以下为导入医保提取数据表的终结数据表
执行位置：脚本应在'usr'用户空间内执行
**********************************************************************************************/

--[医保就诊表]******************************************************--
--用途说明：用于导入原始医保就医数据
CREATE TABLE MDTRT_D (
  MDTRT_ID VARCHAR2(200), --就诊ID
	PSN_NO VARCHAR2(200), --人员编号
	CERTNO VARCHAR2(200), --身份证号
	PSN_NAME VARCHAR2(200), --姓名
	GEND VARCHAR2(200), --性别
	AGE VARCHAR2(200), --年龄
	INSUTYPE VARCHAR2(200), --险种
	PSN_TYPE VARCHAR2(200), --人员类别
	INSU_ADMDVS VARCHAR2(200), --参保地区划
	FIXMEDINS_CODE VARCHAR2(200), --机构编码
	FIXMEDINS_NAME VARCHAR2(500), --机构名称
	HOSP_LV VARCHAR2(200), --机构等级
	BEGNTIME VARCHAR2(200), --入院时间
	ENDTIME VARCHAR2(200), --出院时间 
	MED_TYPE VARCHAR2(200), --医疗类别
	IPT_OTP_NO VARCHAR2(200), --住院号
	ADM_DEPT_NAME VARCHAR2(200), --入院科室名称
	DSCG_DEPT_NAME VARCHAR2(200), --出院科室名称
	DSCG_MAINDIAG_CODE VARCHAR2(200), --主诊断编码
	DISE_TYPE_CODE VARCHAR2(500), --病种类型
	DISE_NO VARCHAR2(200), --病种代码
	DISE_NAME VARCHAR2(500), --病种名称
	IPT_DAYS VARCHAR2(200), --住院天数
	CHFPDR_NAME VARCHAR2(200), --医生姓名
	DSCG_MAINDIAG_NAME VARCHAR2(500), --主诊断名称
	DISE_TYPE_CODE VARCHAR2(500) --病种类型
);
--******************************************************************--

--[医保结算表]******************************************************--
--用途说明：用于导入原始医保结算数据
CREATE TABLE SETL_D (
  SETL_ID VARCHAR2(200), --结算ID
	MDTRT_ID VARCHAR2(200), --就诊ID
	PSN_NO VARCHAR2(200), --人员编号
	PSN_NAME VARCHAR2(200), --姓名
	CERTNO VARCHAR2(200), --身份证号
	GEND VARCHAR2(200), --性别
	AGE VARCHAR2(200), --年龄
	INSUTYPE VARCHAR2(200), --险种
	PSN_TYPE VARCHAR2(200), --人员类别
	INSU_ADMDVS VARCHAR2(200), --参保地区划
	FIXMEDINS_CODE VARCHAR2(200), --机构编码
	FIXMEDINS_NAME VARCHAR2(500), --机构编码
	HOSP_LV VARCHAR2(200), --机构等级
	BEGNDATE VARCHAR2(200), --入院时间
	ENDDATE VARCHAR2(200), --出院时间
	SETL_TIME VARCHAR2(200), --结算日期
	MED_TYPE VARCHAR2(200), --医疗类别
	SETL_TYPE VARCHAR2(200), --结算类别
	MEDFEE_SUMAMT VARCHAR2(100), --医疗费用总额
	FULAMT_OWNPAY_AMT VARCHAR2(100), --全自费金额
	OVERLMT_SELFPAY VARCHAR2(100), --超限价自费费用
	PRESELFPAY_AMT VARCHAR2(100), --先行自付金额
	INSCP_AMT VARCHAR2(100), --医保范围金额
	FUND_PAY_SUMAMT VARCHAR2(100), --基金支付总额
	ACCT_PAY VARCHAR2(100), --个人账户支出
	CASH_PAYAMT VARCHAR2(100) --现金支付金额
);
--******************************************************************--

--[医保医保费用明细表]**********************************************--
--用途说明：用于导入原始医保费用明细数据
CREATE TABLE FEE_LIST_D (
  SETL_ID VARCHAR2(200), --结算ID
	RX_DRORD_NO VARCHAR2(200), --医嘱号
	MDTRT_ID VARCHAR2(200), --就诊ID
	FIXMEDINS_CODE VARCHAR2(200), --机构编码
	FIXMEDINS_NAME VARCHAR2(500), --机构名称
	PSN_NO VARCHAR2(200), --人员编号
	FEE_OCUR_TIME VARCHAR2(200), --费用发生日期
	CNT VARCHAR2(100), --数量
	PRIC VARCHAR2(100), --单价
	DET_ITEM_FEE_SUMAMT VARCHAR2(100), --总额
	PRIC_UPLMT_AMT VARCHAR2(100), --限价
	SELFPAY_PROP VARCHAR2(100), --自付比例
	FULAMT_OWNPAY_AMT VARCHAR2(100), --全自费金额
	OVERLMT_SELFPAY VARCHAR2(100), --超限价自费费用
	PRESELFPAY_AMT VARCHAR2(100), --先行自付金额
	INSCP_AMT VARCHAR2(100), --医保范围金额
	CHRGITM_LV VARCHAR2(100), --收费项目等级
	HILIST_CODE VARCHAR2(200), --医保目录编码
	HILIST_NAME VARCHAR2(500), --医保目录名称
	LIST_TYPE VARCHAR2(100), --目录类别
	MED_LIST_CODG VARCHAR2(200), --医疗目录编码
	MEDINS_LIST_CODG VARCHAR2(200), --医药机构目录编码
	MEDINS_LIST_NAME VARCHAR2(500), --医药机构目录名称
	MED_CHRGITM_TYPE VARCHAR2(200), --医疗收费项目类别
	PRODNAME VARCHAR2(500), --商品名
	SPEC VARCHAR2(500), --规格
	DOSFORM_NAME VARCHAR2(500), --剂型名称
	BILG_DEPT_NAME VARCHAR2(500), --开单科室名称
	BILG_DR_NAME VARCHAR2(500), --开单医师姓名
	ACORD_DEPT_NAME VARCHAR2(200), --执行科室名称
	ACORD_DR_NAME VARCHAR2(200),  --执行人员姓名
	TCMDRUG_USED_WAY VARCHAR2(200), --中药使用方式
	SIN_DOS_DSCR VARCHAR2(200), --单次剂量描述
	USED_FRQU_DSCR VARCHAR2(200), --使用频次描述
	PRD_DAYS VARCHAR2(200), --周期天数
	MEDC_WAY_DSCR VARCHAR2(500), --用药途径描述
	DISE_CODG VARCHAR2(500), --病种编码
	OPRN_OPRT_CODE VARCHAR2(500) --手术操作代码
);
--******************************************************************--

--[医保医保诊断明细表]**********************************************--
--用途说明：用于导入原始医保诊断列表数据
CREATE TABLE SETL_LIST_DIAG_D (
  SETL_ID VARCHAR2(200), --结算ID
	MDTRT_ID VARCHAR2(200),  --就诊ID
	PSN_NO VARCHAR2(200), --人员编号
	DIAG_TYPE VARCHAR2(200), --诊断类别
	MAINDIAG_FLAG VARCHAR2(200), --主诊断标志
	DIAG_CODE VARCHAR2(500), --诊断代码
	DIAG_NAME VARCHAR2(500), --诊断名称
	ADM_COND_TYPE VARCHAR2(200) --入院病情类型
);
--******************************************************************--

--[医保医保手术操作表]**********************************************--
--用途说明：用于导入原始医保手术操作数据
CREATE TABLE SETL_LIST_OPRN_D (
  SETL_ID VARCHAR2(200), --结算ID
	PSN_NO VARCHAR2(200), --人员编号
	MDTRT_ID VARCHAR2(200), --就诊ID
	MAIN_OPRN_FLAG VARCHAR2(200), --主手术操作标志
	OPRN_OPRT_NAME VARCHAR2(500), --手术操作名称
	OPRN_OPRT_CODE VARCHAR2(200), --手术操作代码
	OPRN_OPRT_DATE VARCHAR2(100), --手术操作日期
	ANST_WAY VARCHAR2(200), --麻醉方式
	OPER_DR_NAME VARCHAR2(200), --术者医师姓名
	ANST_DR_NAME VARCHAR2(200), --麻醉医师姓名
	OPRN_OPRT_BEGNTIME VARCHAR2(100), --手术操作开始时间
	OPRN_OPRT_ENDTIME VARCHAR2(100), --手术操作结束时间
	ANST_BEGNTIME VARCHAR2(100), --麻醉开始时间
	ANST_ENDTIME VARCHAR2(100) --麻醉结束时间
);
--******************************************************************--
