/*********************************************************************************************
建表说明：以下表用于归档或还原负荷数据，脚本应在'tar'用户空间内执行
        1.当负荷数据表结构变化事，归档表结构也需要同步变化
        2.归档表建议建立在独立的用户空间中，以便于管理
**********************************************************************************************/

--[机构摘要表]******************************************************--
--说明：用于归档机构基本参数
CREATE TABLE 归档_机构摘要 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  机构性质 VARCHAR2(50) NULL,
  机构等级 VARCHAR2(50) NULL,
  机构类型 VARCHAR2(50) NULL,
  核定床位 INTEGER NULL,
  定点开始日期 DATE NULL,
  定点停止日期 DATE NULL
);
CREATE INDEX idx_gd_jgzy ON 归档_机构摘要 (档案编号, 行政区划, 机构编码); 

--[门诊就医表]******************************************************--
--说明：用于归档门诊就医数据
CREATE TABLE 归档_门诊就医 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构等级 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  险种类别 VARCHAR2(50) NULL,
  参保区划 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  身份证号 VARCHAR2(50) NULL,
  门诊号 VARCHAR2(50) NULL,
  就医日期 DATE NULL,
  门诊科室 VARCHAR2(100) NULL,
  门诊医生 VARCHAR2(500) NULL,
  疾病编码 VARCHAR2(100) NULL,
  疾病诊断 VARCHAR2(200) NULL,
  次要诊断 VARCHAR2(1000) NULL,
  结算流水号 VARCHAR2(50) NULL,
  结算类别 VARCHAR2(50) NULL,
  结算日期 DATE NULL,
  医疗金额 NUMERIC(18,2) NULL,
  列支金额 NUMERIC(18,2) NULL,
  基金支付 NUMERIC(18,2) NULL,
  个账支付 NUMERIC(18,2) NULL,
  现金支付 NUMERIC(18,2) NULL
);
CREATE INDEX idx_gd_mzjy ON 归档_门诊就医 (档案编号, 行政区划, 机构编码);

--[门诊结算表]******************************************************--
--说明：用于归档门诊结算数据
CREATE TABLE 归档_门诊结算 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  险种类别 VARCHAR2(50) NULL,
  身份证号 VARCHAR2(50) NULL,
  人员姓名 VARCHAR2(50) NULL,
  门诊号 VARCHAR2(50) NULL,
  处方号 VARCHAR2(50) NULL,
  处方组号 VARCHAR2(50) NULL,
  项目代码 VARCHAR2(50) NULL,
  项目名称 VARCHAR2(200) NULL,
  国标代码 VARCHAR2(100) NULL,
  国标名称 VARCHAR2(200) NULL,
  商品名 VARCHAR2(200) NULL,
  规格 VARCHAR2(200) NULL,
  产地厂家 VARCHAR2(200) NULL,
  用法 VARCHAR2(50) NULL,
  剂量 VARCHAR2(50) NULL,
  剂量单位 VARCHAR2(50) NULL,
  频次 VARCHAR2(50) NULL,
  天数 INTEGER NULL,  --处方执行天数
  次数 INTEGER NULL,  --处方每日次数
  收费项目类别 VARCHAR2(50) NULL,
  收费项目等级 VARCHAR2(50) NULL,
  医疗属性类别 VARCHAR2(100) NULL,
  数量 NUMERIC(18,2) NULL,
  数量单位 VARCHAR2(50) NULL,
  单价 NUMERIC(18,2) NULL,
  金额 NUMERIC(18,2) NULL,
  限价 NUMERIC(18,2) NULL,
  自付比例 NUMERIC(18,3) NULL,
  全自费金额 NUMERIC(18,2) NULL,
  超限价金额 NUMERIC(18,2) NULL,
  先行自付金额 NUMERIC(18,2) NULL,
  费用发生日期 DATE NULL,
  费用科室名称 VARCHAR2(100) NULL,
  结算流水号 VARCHAR2(50) NULL
);
CREATE INDEX idx_gd_mzjs ON 归档_门诊结算 (档案编号, 行政区划, 机构编码);

--[门诊处方表]******************************************************--
--说明：用于归档门诊处方记录
CREATE TABLE 归档_门诊处方 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  门诊号 VARCHAR2(50) NULL,
  处置类型 VARCHAR2(50) NULL,
  处方号 VARCHAR2(50) NULL,
  处方组号 VARCHAR2(50) NULL,
  药品代码 VARCHAR2(50) NULL,
  药品名称 VARCHAR2(200) NULL,
  药品规格 VARCHAR2(200) NULL,
  处方用法 VARCHAR2(50) NULL,
  处方剂量 VARCHAR2(50) NULL,
  剂量单位 VARCHAR2(50) NULL,
  处方频次 VARCHAR2(50) NULL,
  处方天数 INTEGER NULL,
  数量 NUMERIC(18,2) NULL,
  数量单位 VARCHAR2(50) NULL,
  单价 NUMERIC(18,2) NULL,
  金额 NUMERIC(18,2) NULL,
  处方开具日期 DATE NULL,
  处方科室名称 VARCHAR2(100) NULL
);
CREATE INDEX idx_gd_mzcf ON 归档_门诊处方 (档案编号, 行政区划, 机构编码);

--[门诊手术表]******************************************************--
--说明：用于归档门诊手术记录
CREATE TABLE 归档_门诊手术 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  门诊号 VARCHAR2(50) NULL,
  就医科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  手术日期 DATE NULL,
  手术开始时间 DATE NULL,
  手术结束时间 DATE NULL,
  手术科室名称 VARCHAR2(100) NULL,
  手术者姓名 VARCHAR2(100) NULL,
  手术操作编码 VARCHAR2(50) NULL,
  手术操作名称 VARCHAR2(200) NULL,
  主要手术 VARCHAR2(50) NULL,
  手术等级 VARCHAR2(50) NULL,
  切口类型 VARCHAR2(50) NULL,
  愈合类型 VARCHAR2(50) NULL
);
CREATE INDEX idx_gd_mzss ON 归档_门诊手术 (档案编号, 行政区划, 机构编码);

--[门诊麻醉表]******************************************************--
--用途说明：用于归档门诊麻醉记录
CREATE TABLE 归档_门诊麻醉 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  门诊号 VARCHAR2(50) NULL,
  就医科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  麻醉日期 DATE NULL,
  麻醉开始时间 DATE NULL,
  麻醉结束时间 DATE NULL,
  麻醉科室名称 VARCHAR2(100) NULL,
  麻醉者姓名 VARCHAR2(100) NULL,
  麻醉方式编码 VARCHAR2(50) NULL,
  麻醉方式名称 VARCHAR2(200) NULL,
  麻醉等级 VARCHAR2(50) NULL,
  术后镇痛方式 VARCHAR2(200) NULL
);
CREATE INDEX idx_gd_mzmz ON 归档_门诊麻醉 (档案编号, 行政区划, 机构编码);

--[住院就医表]******************************************************--
--说明：用于归档住院就医数据
CREATE TABLE 归档_住院就医 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  险种类别 VARCHAR2(50) NULL,
  参保区划 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  身份证号 VARCHAR2(50) NULL,
  住院号 VARCHAR2(50) NULL,
  入院日期 DATE NULL,
  出院日期 DATE NULL,
  住院天数 INTEGER NULL,
  住院科室 VARCHAR2(100) NULL,
  住院医生 VARCHAR2(500) NULL,
  疾病编码 VARCHAR2(100) NULL,
  疾病诊断 VARCHAR2(200) NULL,
  次要诊断 VARCHAR2(1000) NULL,
  结算流水号 VARCHAR2(50) NULL,
  结算类别 VARCHAR2(50) NULL,
  结算日期 DATE NULL,
  医疗金额 NUMERIC(18,2) NULL,
  列支金额 NUMERIC(18,2) NULL,
  基金支付 NUMERIC(18,2) NULL,
  个账支付 NUMERIC(18,2) NULL,
  现金支付 NUMERIC(18,2) NULL
);
CREATE INDEX idx_gd_zyjy ON 归档_住院就医 (档案编号, 行政区划, 机构编码);

--[住院结算表]******************************************************--
--说明：用于归档住院结算数据
CREATE TABLE 归档_住院结算 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  险种类别 VARCHAR2(50) NULL,
  身份证号 VARCHAR2(50) NULL,
  人员姓名 VARCHAR2(50) NULL,
  住院号 VARCHAR2(50) NULL,
  医嘱号 VARCHAR2(50) NULL,
  医嘱组号 VARCHAR2(50) NULL,
  项目代码 VARCHAR2(50) NULL,
  项目名称 VARCHAR2(200) NULL,
  国标代码 VARCHAR2(100) NULL,
  国标名称 VARCHAR2(200) NULL,
  商品名 VARCHAR2(200) NULL,
  规格 VARCHAR2(200) NULL,
  产地厂家 VARCHAR2(200) NULL,
  用法 VARCHAR2(50) NULL,
  剂量 VARCHAR2(50) NULL,
  剂量单位 VARCHAR2(50) NULL,
  频次 VARCHAR2(50) NULL,
  天数 INTEGER NULL,  --医嘱执行天数
  次数 INTEGER NULL,  --医嘱每日次数
  收费项目类别 VARCHAR2(50) NULL,
  收费项目等级 VARCHAR2(50) NULL,
  医疗属性类别 VARCHAR2(100) NULL,
  数量 NUMERIC(18,2) NULL,
  数量单位 VARCHAR2(50) NULL,
  单价 NUMERIC(18,2) NULL,
  金额 NUMERIC(18,2) NULL,
  限价 NUMERIC(18,2) NULL,
  自付比例 NUMERIC(18,3) NULL,
  全自费金额 NUMERIC(18,2) NULL,
  超限价金额 NUMERIC(18,2) NULL,
  先行自付金额 NUMERIC(18,2) NULL,
  费用发生日期 DATE NULL,
  费用科室名称 VARCHAR2(100) NULL,
  结算流水号 VARCHAR2(50) NULL
);
CREATE INDEX idx_gd_zyjs ON 归档_住院结算 (档案编号, 行政区划, 机构编码);

--[住院医嘱表]******************************************************--
--说明：用于归档住院医嘱记录
CREATE TABLE 归档_住院医嘱 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  住院号 VARCHAR2(50) NULL,
  医嘱类型 VARCHAR2(50) NULL,
  医嘱号 VARCHAR2(50) NULL,
  医嘱组号 VARCHAR2(50) NULL,
  医嘱代码 VARCHAR2(50) NULL,
  医嘱名称 VARCHAR2(200) NULL,
  医嘱规格 VARCHAR2(200) NULL,
  医嘱用法 VARCHAR2(50) NULL,
  医嘱剂量 VARCHAR2(50) NULL,
  剂量单位 VARCHAR2(50) NULL,
  医嘱频次 VARCHAR2(50) NULL,
  医嘱天数 INTEGER NULL,
  数量 NUMERIC(18,2) NULL,
  数量单位 VARCHAR2(50) NULL,
  单价 NUMERIC(18,2) NULL,
  金额 NUMERIC(18,2) NULL,
  医嘱开始日期 DATE NULL,
  医嘱停止日期 DATE NULL,
  医嘱科室名称 VARCHAR2(100) NULL,
  开立医生姓名 VARCHAR2(100) NULL
);
CREATE INDEX idx_gd_zyyz ON 归档_住院医嘱 (档案编号, 行政区划, 机构编码);

--[住院手术表]******************************************************--
--说明：用于归档住院手术记录
CREATE TABLE 归档_住院手术 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  住院号 VARCHAR2(50) NULL,
  住院科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  手术日期 DATE NULL,
  手术开始时间 DATE NULL,
  手术结束时间 DATE NULL,
  手术科室名称 VARCHAR2(100) NULL,
  手术者姓名 VARCHAR2(100) NULL,
  手术操作编码 VARCHAR2(50) NULL,
  手术操作名称 VARCHAR2(200) NULL,
  主要手术 VARCHAR2(50) NULL,
  手术等级 VARCHAR2(50) NULL,
  切口类型 VARCHAR2(50) NULL,
  愈合类型 VARCHAR2(50) NULL
);
CREATE INDEX idx_gd_zyss ON 归档_住院手术 (档案编号, 行政区划, 机构编码);

--[住院麻醉表]******************************************************--
--用途说明：用于归档住院院麻醉记录
CREATE TABLE 归档_住院麻醉 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  住院号 VARCHAR2(50) NULL,
  住院科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  麻醉日期 DATE NULL,
  麻醉开始时间 DATE NULL,
  麻醉结束时间 DATE NULL,
  麻醉科室名称 VARCHAR2(100) NULL,
  麻醉者姓名 VARCHAR2(100) NULL,
  麻醉方式编码 VARCHAR2(50) NULL,
  麻醉方式名称 VARCHAR2(200) NULL,
  麻醉等级 VARCHAR2(50) NULL,
  术后镇痛方式 VARCHAR2(200) NULL,
  麻醉复苏开始时间 DATE NULL,
  麻醉复苏结束时间 DATE NULL
);
CREATE INDEX idx_gd_zymz ON 归档_住院麻醉 (档案编号, 行政区划, 机构编码);

--[检查登记表]******************************************************--
--用途说明：用于归档检查登记记录
CREATE TABLE 归档_检查登记 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  就医方式 VARCHAR2(50) NULL,
  就医号 VARCHAR2(50) NULL,
  就医科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  检查登记日期 DATE NULL,
  检查科室名称 VARCHAR2(100) NULL,
  检查者姓名 VARCHAR2(100) NULL,
  检查项目编码 VARCHAR2(50) NULL,
  检查项目名称 VARCHAR2(200) NULL,
  是否外送 VARCHAR2(50) NULL
);
CREATE INDEX idx_gd_jcdj ON 归档_检查登记 (档案编号, 行政区划, 机构编码);

--[检查报告表]******************************************************--
--用途说明：用于归档检查报告记录
CREATE TABLE 归档_检查报告 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  就医方式 VARCHAR2(50) NULL,
  就医号 VARCHAR2(50) NULL,
  就医科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  检查报告时间 DATE NULL,
  检查科室名称 VARCHAR2(100) NULL,
  检查者姓名 VARCHAR2(100) NULL,
  检查部位 VARCHAR2(200) NULL,
  检查方法 VARCHAR2(100) NULL,
  检查报告诊断 VARCHAR2(500) NULL,
  影像编号 VARCHAR2(200) NULL,
  检查报告单位 VARCHAR2(100) NULL
);
CREATE INDEX idx_gd_jcbg ON 归档_检查报告 (档案编号, 行政区划, 机构编码);

--[化验登记表]******************************************************--
--用途说明：用于归档检验登记记录
CREATE TABLE 归档_化验登记 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  就医方式 VARCHAR2(50) NULL,
  就医号 VARCHAR2(50) NULL,
  就医科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  检验登记日期 DATE NULL,
  检验科室名称 VARCHAR2(100) NULL,
  检验者姓名 VARCHAR2(100) NULL,
  检验项目编码 VARCHAR2(50) NULL,
  检验项目名称 VARCHAR2(200) NULL,
  是否外送 VARCHAR2(50) NULL
);
CREATE INDEX idx_gd_hydj ON 归档_化验登记 (档案编号, 行政区划, 机构编码);

--[化验报告表]******************************************************--
--用途说明：用于归档检验报告记录
CREATE TABLE 归档_化验报告 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  就医方式 VARCHAR2(50) NULL,
  就医号 VARCHAR2(50) NULL,
  就医科室名称 VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  检验报告时间 DATE NULL,
  检验科室名称 VARCHAR2(100) NULL,
  检验者姓名 VARCHAR2(100) NULL,
  检验样本 VARCHAR2(100) NULL,
  检验方法 VARCHAR2(100) NULL,
  检验值名称 VARCHAR2(100) NULL, 
	检验值描述 VARCHAR2(100) NULL, 
	检验值范围 VARCHAR2(100) NULL, 
  样本编号 VARCHAR2(200) NULL,
  检验报告单位 VARCHAR2(100) NULL
);
CREATE INDEX idx_gd_hybg ON 归档_化验报告 (档案编号, 行政区划, 机构编码);

--[药库结转表]******************************************************--
--说明：用于归档药库结转记录
CREATE TABLE 归档_药库结转 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  年月 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  药库名称 VARCHAR2(100) NULL,
  项目代码 VARCHAR2(50) NULL,
  国标代码 VARCHAR2(50) NULL,
  商品类型 VARCHAR2(50) NULL,
  商品名称 VARCHAR2(200) NULL,
  商品规格 VARCHAR2(200) NULL,
  生产厂家 VARCHAR2(200) NULL,
  供应商名称 VARCHAR2(100) NULL,
  包装单位 VARCHAR2(50) NULL,
  拆零单位 VARCHAR2(50) NULL,
  拆零比 INTEGER NULL,
  库存单位 VARCHAR2(50) NULL,
  上期结存数 NUMERIC(18,2) NULL,
  本期收入数 NUMERIC(18,2) NULL,
  本期支出数 NUMERIC(18,2) NULL,
  本期结存数 NUMERIC(18,2) NULL,
  购入价 NUMERIC(18,2) NULL,
  零售价 NUMERIC(18,2) NULL,
  结转日期 DATE NULL
 );
CREATE INDEX idx_gd_ykjz ON 归档_药库结转 (档案编号, 行政区划, 机构编码);

--[药库消耗表]******************************************************--
--说明：用于归档药库消耗记录
CREATE TABLE 归档_药库消耗(
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50), 
  机构名称 VARCHAR2(100), 
  药库名称 VARCHAR2(100), 
  项目代码 VARCHAR2(50), 
  国标代码 VARCHAR2(50), 
  商品类型 VARCHAR2(50), 
  商品名称 VARCHAR2(200), 
  商品规格 VARCHAR2(200),  
  包装单位 VARCHAR2(50), 
  拆零单位 VARCHAR2(50), 
  拆零比 INTEGER, 
  数量 NUMBER(18,2), 
  单位 VARCHAR2(50), 
  购入价 NUMBER(18,2), 
  零售价 NUMBER(18,2), 
  业务类型 VARCHAR2(50), 
  业务日期 DATE,
  对方部门 VARCHAR2(100)
);  
CREATE INDEX idx_gd_ykxh ON 归档_药库消耗 (档案编号, 行政区划, 机构编码);

--[药房结转表]******************************************************--
--说明：用于归档药房结转记录
CREATE TABLE 归档_药房结转 (
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  年月 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  药房名称 VARCHAR2(100) NULL,
  项目代码 VARCHAR2(50) NULL,
  国标代码 VARCHAR2(50) NULL,
  商品类型 VARCHAR2(50) NULL,
  商品名称 VARCHAR2(200) NULL,
  商品规格 VARCHAR2(200) NULL,
  生产厂家 VARCHAR2(100) NULL,
  供应商名称 VARCHAR2(100) NULL,
  包装单位 VARCHAR2(50) NULL,
  拆零单位 VARCHAR2(50) NULL,
  拆零比 INTEGER NULL,
  库存单位 VARCHAR2(50) NULL,
  上期结存数 NUMERIC(18,2) NULL,
  本期收入数 NUMERIC(18,2) NULL,
  本期支出数 NUMERIC(18,2) NULL,
  本期结存数 NUMERIC(18,2) NULL,
  购入价 NUMERIC(18,2) NULL,
  零售价 NUMERIC(18,2) NULL,
  结转日期 DATE NULL
);
CREATE INDEX idx_gd_yfjz ON 归档_药房结转 (档案编号, 行政区划, 机构编码);

--[药房消耗表]******************************************************--
--说明：用于归档药房消耗记录
CREATE TABLE 归档_药房消耗(
  档案编号 VARCHAR2(50) NULL,
  行政区划 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50), 
  机构名称 VARCHAR2(100), 
  药房名称 VARCHAR2(100), 
  项目代码 VARCHAR2(50), 
  国标代码 VARCHAR2(50), 
  商品类型 VARCHAR2(50), 
  商品名称 VARCHAR2(200), 
  商品规格 VARCHAR2(200),  
  包装单位 VARCHAR2(50), 
  拆零单位 VARCHAR2(50), 
  拆零比 INTEGER, 
  数量 NUMBER(18,2), 
  单位 VARCHAR2(50), 
  购入价 NUMBER(18,2), 
  零售价 NUMBER(18,2), 
  业务类型 VARCHAR2(50), 
  业务日期 DATE,
  对方部门 VARCHAR2(100)
);
CREATE INDEX idx_gd_yfxh ON 归档_药房消耗 (档案编号, 行政区划, 机构编码);
