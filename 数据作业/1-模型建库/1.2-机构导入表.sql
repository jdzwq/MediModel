/*********************************************************************************************
建表说明：以下为导入机构提取数据表的机构专用数据表，包括门诊表、住院表、库房表等
执行位置：脚本应在'usr'用户空间内执行
命名规则：<机构名称>_<导入表名>，在导入不同机构数据时，需替换机构名称
**********************************************************************************************/

--[机构摘要表]******************************************************--
--说明：用于获取机构基本执业信息
--机构性质：['公立','民营']
--机构等级：['三级','二级','一级','社区','诊所','药店'] 
--机构类型：['综合','妇幼','儿童','精神','口腔','眼科','肿瘤','中医','康复','护理','连锁药店','单体药店'] 
CREATE TABLE 测试医院_机构摘要 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  机构性质 VARCHAR2(50) NULL,
  机构等级 VARCHAR2(50) NULL,
  机构类型 VARCHAR2(50) NULL,
  核定床位 INTEGER NULL,
  定点开始日期 DATE NULL,
  定点停止日期 DATE NULL
);

--[机构门诊就医表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构门诊就医记录
--险种类别：['城镇职工','城乡居民',‘少儿医保’,'大学生医保']
--结算类别：['普通门诊','规定病种','普通住院']
CREATE TABLE 测试医院_门诊就医 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  机构等级 VARCHAR2(50) NULL,
  险种类别 VARCHAR2(50) NULL,
  参保地区划 VARCHAR2(50) NULL,
  人员姓名 VARCHAR2(50) NULL,
  人员性别 VARCHAR2(50) NULL,
  人员年龄 INTEGER NULL,
  身份证号 VARCHAR2(50) NULL,
  门诊号 VARCHAR2(50) NULL,
  门诊日期 DATE NULL,
  门诊科室名称 VARCHAR2(100) NULL,
  首诊医生姓名 VARCHAR2(50) NULL,
  疾病编码ICD VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  次要诊断组合 VARCHAR2(1000) NULL,
  结算流水号 VARCHAR2(50) NULL,
  结算类别 VARCHAR2(50) NULL,
  结算日期 DATE NULL,
  医疗金额 NUMERIC(18,2) NULL,
  医保范围金额 NUMERIC(18,2) NULL,
  基金支付 NUMERIC(18,2) NULL,
  个账支付 NUMERIC(18,2) NULL,
  现金支付 NUMERIC(18,2) NULL
);

--[机构门诊结算表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构门诊结算记录
--收费项目类别：['挂号费','诊查费','一般诊疗费',...]
--收费项目等级：['甲','乙','丙']
--频次：['tid','bid','一日三次','一日两次']
CREATE TABLE 测试医院_门诊结算 (
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
  天数 INTEGER NULL,
  收费项目类别 VARCHAR2(50) NULL,
  收费项目等级 VARCHAR2(50) NULL,
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

--[机构门诊处方表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构门诊处方记录
--处置类型：['西成药方','草药方','儿童处方','精麻处方','治疗单',...]
--处方频次：['tid','bid','一日三次','一日两次']
CREATE TABLE 测试医院_门诊处方 (
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
  处方科室名称 VARCHAR2(100) NULL,
  开具医生姓名 VARCHAR2(100) NULL
);

--[机构门诊手术表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构门诊手术记录
--主要手术：['是','否']
--手术等级：['一类手术','二类手术','三类手术','四类手术']
--切口类型：['一类切口','二类切口','三类切口']
--愈合类型：['甲级愈合','乙级愈合','丙级愈合']
CREATE TABLE 测试医院_门诊手术 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  门诊号 VARCHAR2(50) NULL,
  门诊科室名称 VARCHAR2(100) NULL,
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

--[机构门诊麻醉表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构门诊麻醉记录
--麻醉等级：['ASA一级','ASA二级','ASA三级']
CREATE TABLE 测试医院_门诊麻醉 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  门诊号 VARCHAR2(50) NULL,
  门诊科室名称 VARCHAR2(100) NULL,
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

--[机构住院就医表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院就医记录
--险种类别：['城镇职工','城乡居民',‘少儿医保’,'大学生医保']
--结算类别：['普通门诊','规定病种','普通住院']
CREATE TABLE 测试医院_住院就医 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  机构等级 VARCHAR2(50) NULL,
  险种类别 VARCHAR2(50) NULL,
  参保地区划 VARCHAR2(50) NULL,
  人员姓名 VARCHAR2(50) NULL,
  人员性别 VARCHAR2(50) NULL,
  人员年龄 INTEGER NULL,
  身份证号 VARCHAR2(50) NULL,
  住院号 VARCHAR2(50) NULL,
  入院日期 DATE NULL,
  出院日期 DATE NULL,
  住院天数 INTEGER NULL,
  住院科室名称 VARCHAR2(100) NULL,
  主管医生姓名 VARCHAR2(50) NULL,
  疾病编码ICD VARCHAR2(100) NULL,
  疾病诊断名称 VARCHAR2(200) NULL,
  次要诊断组合 VARCHAR2(1000) NULL,
  结算流水号 VARCHAR2(50) NULL,
  结算类别 VARCHAR2(50) NULL,
  结算日期 DATE NULL,
  医疗金额 NUMERIC(18,2) NULL,
  医保范围金额 NUMERIC(18,2) NULL,
  基金支付 NUMERIC(18,2) NULL,
  个账支付 NUMERIC(18,2) NULL,
  现金支付 NUMERIC(18,2) NULL
  );
  
--[机构住院结算表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院结算记录
--收费项目类别：['挂号费','诊查费','一般诊疗费',...]
--收费项目等级：['甲','乙','丙']
--频次：['tid','bid','一日三次','一日两次']
CREATE TABLE 测试医院_住院结算 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  险种类别 VARCHAR2(50) NULL,
  参保地区划 VARCHAR2(50) NULL,
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
  天数 INTEGER NULL,
  收费项目类别 VARCHAR2(50) NULL,
  收费项目等级 VARCHAR2(50) NULL,
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

--[机构住院医嘱表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院医嘱记录
--处置类型：['西成药方','草药方','儿童处方','精麻处方','治疗单',...]
--处方频次：['tid','bid','一日三次','一日两次']
CREATE TABLE 测试医院_住院医嘱 (
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
  开立医生姓名 VARCHAR2(100) NULL);
 
--[机构住院手术表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院手术记录
--主要手术：['是','否']
--手术等级：['一类手术','二类手术','三类手术','四类手术']
--切口类型：['一类切口','二类切口','三类切口']
--愈合类型：['甲级愈合','乙级愈合','丙级愈合']
CREATE TABLE 测试医院_住院手术 (
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

--[机构住院麻醉表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院麻醉记录
--麻醉等级：['ASA一级','ASA二级','ASA三级']
CREATE TABLE 测试医院_住院麻醉 (
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

--[机构检查登记表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院检查登记记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 测试医院_检查登记 (
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

--[机构检查报告表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院检查登记记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 测试医院_检查报告 (
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

--[机构化验登记表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院检查登记记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 测试医院_化验登记 (
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

--[机构化验报告表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构住院检查登记记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 测试医院_化验报告 (
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

--[机构药库结转表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构药库结转记录
--商品类型：['西药','成药','草药','材料']
CREATE TABLE 测试医院_药库结转 (
  年月 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  药库名称 VARCHAR2(100) NULL,
  项目代码 VARCHAR2(50) NULL,
  国标代码 VARCHAR2(50) NULL,
  商品类型 VARCHAR2(50) NULL,
  商品名称 VARCHAR2(200) NULL,
  商品规格 VARCHAR2(200) NULL,
  生产厂家 VARCHAR2(100) NULL,
  供应商名称 VARCHAR2(200) NULL,
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
  结转日期 DATE NULL);
 
--[机构药库消耗表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构药库消耗记录
--出入库类型：['购入入库','购入退库','调拨出库','调拨退库','领用出库','领用退库','其他业务'] 
CREATE TABLE 测试医院_药库消耗 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  药库名称 VARCHAR2(100) NULL,
  项目代码 VARCHAR2(50) NULL,
  国标代码 VARCHAR2(50) NULL,
  商品类型 VARCHAR2(50) NULL,
  商品名称 VARCHAR2(200) NULL,
  商品规格 VARCHAR2(200) NULL,
  生产厂家 VARCHAR2(100) NULL,
  供应商名称 VARCHAR2(200) NULL,
  包装单位 VARCHAR2(50) NULL,
  拆零单位 VARCHAR2(50) NULL,
  拆零比 INTEGER NULL,
  出入库类型 VARCHAR2(50) NULL,
  出入库数量 NUMERIC(18,2) NULL,
  出入库单位 VARCHAR2(50) NULL,
  购入价 NUMERIC(18,2) NULL,
  零售价 NUMERIC(18,2) NULL,
  业务日期 DATE NULL,
  对方单位部门 VARCHAR2(100) NULL);
  
--[机构药房结转表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构药房结转记录
--商品类型：['西药','成药','草药','材料']
CREATE TABLE 测试医院_药房结转 (
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
  供应商名称 VARCHAR2(200) NULL,
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
  结转日期 DATE NULL);
 
--[机构药房消耗表]******************************************************--
--用途说明：用于从CSV文件或外部数据源导入机构药房消耗记录
--出入库类型：['调拨出库','调拨退库','领用出库','领用退库','门诊零售','住院零售','其他业务'] 
CREATE TABLE 测试医院_药房消耗 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  药房名称 VARCHAR2(100) NULL,
  项目代码 VARCHAR2(50) NULL,
  国标代码 VARCHAR2(50) NULL,
  商品类型 VARCHAR2(50) NULL,
  商品名称 VARCHAR2(200) NULL,
  商品规格 VARCHAR2(200) NULL,
  生产厂家 VARCHAR2(100) NULL,
  供应商名称 VARCHAR2(200) NULL,
  包装单位 VARCHAR2(50) NULL,
  拆零单位 VARCHAR2(50) NULL,
  拆零比 INTEGER NULL,
  出入库类型 VARCHAR2(50) NULL,
  出入库数量 NUMERIC(18,2) NULL,
  出入库单位 VARCHAR2(50) NULL,
  购入价 NUMERIC(18,2) NULL,
  零售价 NUMERIC(18,2) NULL,
  业务日期 DATE NULL,
  对方单位部门 VARCHAR2(100) NULL);
