/*********************************************************************************************
建表说明：以下为运行数据表，从机构或医保导入表中加载
执行位置：脚本应在'medi'用户空间内执行
命名规则：字典_*，用于编录药品、材料、诊疗分类目录
命名规则：负荷_*，用于加载机构原始数据或外部数据源数据
命名规则：统计_*，用于归集、统计与规则运算相关的数据项目或指标
命名规则：应用_*，用于输出问题线索
**********************************************************************************************/

/***********************************（一）字典类表**********************************************/
--[字段码值表]******************************************************--
--用途说明：用于构造字段匹配码值
CREATE TABLE 字典_字段码值 (
  字段名 VARCHAR2(50) NULL,
  字段值 VARCHAR2(100) NULL
);

--[药品分类表]******************************************************--
--用途说明：用于分类药品目录
--目录级别：['0','1','2','3','4']，'0'用于匹配药品，其他用于层级分类
CREATE TABLE 字典_药品分类 (
  类目编码 VARCHAR2(50) NULL,    --药品国标代码的前缀码
  类目名称 VARCHAR2(100) NULL,   --药品医疗属性名称
  费用项目 VARCHAR2(100) NULL,   --药品费用项目名称
  目录级别 VARCHAR2(10) NULL     --类目编码的等级
);

--[材料分类表]******************************************************--
--用途说明：用于分类材料目录
--目录级别：['0','1','2','3','4']，'0'用于匹配材料，其他用于层级分类
CREATE TABLE 字典_材料分类 (
  类目编码 VARCHAR2(50) NULL,    --材料国标代码的前缀码
  类目名称 VARCHAR2(100) NULL,   --材料医通用名称
  费用项目 VARCHAR2(100) NULL,   --材料费用项目名称
  目录级别 VARCHAR2(10) NULL     --类目编码的等级
);

--[诊疗分类表]******************************************************--
--说明：用于分类诊疗项目
--目录级别：['0','1','2','3','4']
CREATE TABLE 字典_诊疗分类 (
  类目编码 VARCHAR2(50) NULL,
  类目名称 VARCHAR2(200) NULL, --医疗属性名称
  费用项目 VARCHAR2(100) NULL, --收费项目名称
  国标通配 VARCHAR2(50) NULL,
  省标通配 VARCHAR2(50) NULL,
  目录级别 VARCHAR2(10) NULL --'0'为通配项目
);

--[医嘱频次表]******************************************************--
--说明：用于计算处方或医嘱执行次数
CREATE TABLE 字典_医嘱频次(
  英文名称 VARCHAR2(50) NULL,
  中文名称 VARCHAR2(50) NULL,
  中文别名 VARCHAR2(50) NULL,
  执行周期 INTEGER NULL,  --间隔天数
	执行频次 INTEGER NULL   --每天次数
);

--[疾病分类表]******************************************************--
--说明：用于根据诊断前缀码归类疾病名称
--类目类型：['西医诊断','肿瘤诊断','中医诊断','中医证候']
CREATE TABLE 字典_疾病分类(
  类目类型 VARCHAR2(50) NULL,
	类目编码 VARCHAR2(50) NULL,
	类目名称 VARCHAR2(200) NULL,
	归并名称 VARCHAR2(100) NULL    --西医系统分类名称，及中医类疾病
);

--[规则分类表]******************************************************--
--说明：用于根据描述规则分类
--就医方式：['门诊','住院']
--项目来源：['药品','材料','诊疗']
--规则类型：['超范围支付','超标准支付','超适应症支付','超标准支付','关联缺失','不规范处方']
CREATE TABLE 字典_规则分类(
  就医方式 VARCHAR2(50) NULL,
	项目来源 VARCHAR2(50) NULL,
	规则类型 VARCHAR2(50) NULL,
  规则情形 VARCHAR2(50) NULL,
  规则说明 VARCHAR2(100) NULL
);

--[药品限制表]******************************************************--
--说明：用于限定药品使用范围
--险种限制：['工伤','生育']
--机构限制：['三级','二级','一级','社区','诊所','药店']
--就医限制：['门诊','住院']
--专科限制：['妇科用药','眼科用药','肿瘤用药','检查用药','重症感染',...]
--性别限制：['男','女']
--年龄限制：['新生儿','小儿']
--阶梯限制：['二线','三线']
CREATE TABLE 规则_药品限制(
	药品编码 VARCHAR2(50) NULL,
	药品名称 VARCHAR2(200)  NULL,
  险种限制 VARCHAR2(50) NULL,
  机构限制 VARCHAR2(50)  NULL, 
  就医限制 VARCHAR2(50)  NULL,
  专科限制 VARCHAR2(50)  NULL,
  性别限制 VARCHAR2(50)  NULL,
  年龄限制 VARCHAR2(50)  NULL,   --年龄上界（包含）
  疾病限制 VARCHAR2(1000) NULL,   --疾病名称（关键词）
  操作限制 VARCHAR2(200) NULL,   --操作名称（关键词）
  阶梯限制 VARCHAR2(50)  NULL,
  用量限制 INTEGER NULL,         --单次最大用量
  额度限制 NUMERIC(18,2) NULL,   --年度的额度上限
  疗程限制 INTEGER NULL,         --疗程最大天数
  领域标识 VARCHAR2(50) NULL
);
create index idx_gz_ypxz on 规则_药品限制 (药品编码);

--[诊疗限制表]******************************************************--
--说明：用于限定诊疗开展范围
--险种限制：['工伤','生育']
--机构限制：['三级','二级','一级','社区','诊所','药店']
--就医限制：['门诊','住院']
--专科限制：['精神','康复','中医','放射','检查','化验',...]
--性别限制：['男','女']
--年龄限制：['新生儿','小儿']
CREATE TABLE 规则_诊疗限制(
	诊疗编码 VARCHAR2(50) NULL,
	诊疗名称 VARCHAR2(200) NULL,
  险种限制 VARCHAR2(50)  NULL, 
  机构限制 VARCHAR2(50)  NULL, 
  就医限制 VARCHAR2(50)  NULL,
  专科限制 VARCHAR2(50)  NULL,
  性别限制 VARCHAR2(50)  NULL,
  年龄限制 VARCHAR2(50)  NULL,   --年龄上界（包含）
  疾病限制 VARCHAR2(1000) NULL,  --疾病名称（关键词）
  人次限制 INTEGER NULL,         --单次就诊的人次上限
  次数限制 INTEGER NULL,         --单日的次数上限
  数量限制 NUMERIC(18,2) NULL,   --单日的数量上限
  额度限制 NUMERIC(18,2) NULL,   --年度的额度上限
  疗程限制 INTEGER NULL,         --疗程最大天数
  领域标识 VARCHAR2(50) NULL);
 create index idx_gz_zlxz on 规则_诊疗限制 (诊疗编码);

--[诊疗关联表]******************************************************--
--说明：用于匹配诊疗关联项目
CREATE TABLE 规则_诊疗关联 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --首要或主要操作
  关联编码 VARCHAR2(200) NULL,
  关联名称 VARCHAR2(500) NULL,   --与主项适配的关联操作
  领域标识 VARCHAR2(50) NULL
);

--[诊疗串换表]******************************************************--
--说明：用于匹配诊疗串换项目
CREATE TABLE 规则_诊疗串换 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --串换项目
  小项编码 VARCHAR2(200) NULL,
  小项名称 VARCHAR2(500) NULL,   --实际项目
  领域标识 VARCHAR2(50) NULL
);

 --[诊疗分解表]******************************************************--
--说明：用于匹配诊疗分解项目
CREATE TABLE 规则_诊疗分解 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --首要或主要操作
  分项编码 VARCHAR2(200) NULL,
  分项名称 VARCHAR2(500) NULL,   --与主项类似的操作
  领域标识 VARCHAR2(50) NULL
);

--[诊疗过度表]******************************************************--
--说明：用于匹配诊疗过度项目
--过度限制：['每周','每月']
CREATE TABLE 规则_诊疗过度 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,
  过度周期 VARCHAR2(50) NULL,
  过度限制 VARCHAR2(200) NULL,   --在过度周期内的限定次数
  领域标识 VARCHAR2(50) NULL
);

--[诊疗虚记表]******************************************************--
--说明：用于匹配诊疗虚记项目
CREATE TABLE 规则_诊疗虚记 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,
  排查机构 VARCHAR2(100) NULL,
  排查部门 VARCHAR2(200) NULL,  
  领域标识 VARCHAR2(50) NULL
);

 --[诊疗分解表]******************************************************--
--说明：用于匹配诊疗加收项目
CREATE TABLE 规则_诊疗加收 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --首要或主要操作
  从项编码 VARCHAR2(200) NULL,
  从项名称 VARCHAR2(500) NULL,   --与主项适配的加收操作
  加收限制 INTEGER,
  领域标识 VARCHAR2(50) NULL
);

--[诊疗重复表]******************************************************--
--说明：用于匹配诊疗重复项目
CREATE TABLE 规则_诊疗重复 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --首要、主要或套餐操作
  子项编码 VARCHAR2(500) NULL,
  子项名称 VARCHAR2(1000) NULL,   --属于主项操作的小类、部分或子项操作
  领域标识 VARCHAR2(50) NULL
);

--[材料关联表]******************************************************--
--说明：用于匹配诊疗关联项目
CREATE TABLE 规则_材料关联 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --首要或主要操作
  关联编码 VARCHAR2(200) NULL,
  关联名称 VARCHAR2(500) NULL,   --与主项适配的关联操作
  领域标识 VARCHAR2(50) NULL
);

--[材料串换表]******************************************************--
--说明：用于匹配材料串换项目
CREATE TABLE 规则_材料串换 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --串换项目
  小项编码 VARCHAR2(200) NULL,
  小项名称 VARCHAR2(500) NULL,   --实际项目
  领域标识 VARCHAR2(50) NULL
);

 --[材料分解表]******************************************************--
--说明：用于匹配材料分解项目
CREATE TABLE 规则_材料分解 (
  主项编码 VARCHAR2(50) NULL,
	主项名称 VARCHAR2(200) NULL,   --首要或主要操作
  分项编码 VARCHAR2(200) NULL,
  分项名称 VARCHAR2(500) NULL,   --与主项类似的操作
  领域标识 VARCHAR2(50) NULL
);

/********************************************************************************************/


/***********************************（二）负荷类表*********************************************/
--[机构摘要表]******************************************************--
--说明：用于获取机构基本执业信息
--机构性质：['公立','民营']
--机构等级：['三级','二级','一级','社区','诊所','药店'] 
--机构类型：['综合','妇幼','儿童','精神','口腔','眼科','肿瘤','中医','康复','护理','连锁药店','单体药店'] 
CREATE TABLE 负荷_机构摘要 (
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  机构性质 VARCHAR2(50) NULL,
  机构等级 VARCHAR2(50) NULL,
  机构类型 VARCHAR2(50) NULL,
  核定床位 INTEGER NULL,
  定点开始日期 DATE NULL,
  定点停止日期 DATE NULL
);
CREATE INDEX idx_fh_jgzy ON 负荷_机构摘要 (机构编码);

--[门诊就医表]******************************************************--
--说明：用于加载门诊就医数据
--险种类别：['城镇职工','城乡居民']
--结算类别：['普通门诊','规定病种','普通住院']
CREATE TABLE 负荷_门诊就医 (
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
  门诊日期 DATE NULL,
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
CREATE INDEX idx_fh_mzjy ON 负荷_门诊就医 (机构编码, 门诊号);

--[门诊结算表]******************************************************--
--说明：用于加载门诊结算数据
--收费项目类别：['挂号费','诊查费','一般诊疗费',...]
--收费项目等级：['甲','乙','丙']
CREATE TABLE 负荷_门诊结算 (
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
CREATE INDEX idx_fh_mzjs ON 负荷_门诊结算 (机构编码, 门诊号);
CREATE INDEX idx_fh_mzjs_gbdm ON 负荷_门诊结算 (国标代码);

--[门诊处方表]******************************************************--
--说明：用于加载门诊处方记录（包括诊疗处置单）
--处置类型：['西成药方','草药方','儿童处方','精麻处方','处置单',...]
CREATE TABLE 负荷_门诊处方 (
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
CREATE INDEX idx_fh_mzcf ON 负荷_门诊处方 (机构编码, 门诊号);
  
--[门诊手术表]******************************************************--
--说明：用于加载门诊手术记录
--手术等级：['一类手术','二类手术','三类手术','四类手术']
--切口类型：['一类切口','二类切口','三类切口']
--愈合类型：['甲级愈合','乙级愈合','丙级愈合']
CREATE TABLE 负荷_门诊手术 (
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
CREATE INDEX idx_fh_mzss ON 负荷_门诊手术 (机构编码, 门诊号);

--[门诊麻醉表]******************************************************--
--用途说明：用于加载门诊麻醉记录
--麻醉等级：['ASA一级','ASA二级','ASA三级']
CREATE TABLE 负荷_门诊麻醉 (
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
CREATE INDEX idx_fh_mzmz ON 负荷_门诊麻醉 (机构编码, 门诊号);

--[住院就医表]******************************************************--
--说明：用于加载住院就医数据
--险种类别：['城镇职工','城乡居民']
--结算类别：['普通门诊','规定病种','普通住院']
CREATE TABLE 负荷_住院就医 (
  机构等级 VARCHAR2(50) NULL,
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
CREATE INDEX idx_fh_zyjy ON 负荷_住院就医 (机构编码, 住院号);

--[住院结算表]******************************************************--
--说明：用于加载住院结算数据
--收费项目类别：['床位费','诊查费','一般诊疗费',...]
--收费项目等级：['甲','乙','丙']
CREATE TABLE 负荷_住院结算 (
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
CREATE INDEX idx_fh_zyjs ON 负荷_住院结算 (机构编码, 住院号);
CREATE INDEX idx_fh_zyjs_gbdm ON 负荷_住院结算 (国标代码);

--[住院医嘱表]******************************************************--
--说明：用于加载住院医嘱记录
--医嘱类型：['药品医嘱','诊疗医嘱','其他医嘱']
CREATE TABLE 负荷_住院医嘱 (
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
CREATE INDEX idx_fh_zyyz ON 负荷_住院医嘱 (机构编码, 住院号);

--[住院手术表]******************************************************--
--说明：用于加载住院手术记录
--手术等级：['一类手术','二类手术','三类手术','四类手术']
--切口类型：['一类切口','二类切口','三类切口']
--愈合类型：['甲级愈合','乙级愈合','丙级愈合']
CREATE TABLE 负荷_住院手术 (
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
CREATE INDEX idx_fh_zyss ON 负荷_住院手术 (机构编码, 住院号);

--[住院麻醉表]******************************************************--
--用途说明：用于加载院麻醉记录
--麻醉等级：['ASA一级','ASA二级','ASA三级']
CREATE TABLE 负荷_住院麻醉 (
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
CREATE INDEX idx_fh_zymz ON 负荷_住院麻醉 (机构编码, 住院号);

--[检查登记表]******************************************************--
--用途说明：用于加载检查登记记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 负荷_检查登记 (
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
CREATE INDEX idx_fh_jcdj ON 负荷_检查登记 (机构编码, 就医号);

--[检查报告表]******************************************************--
--用途说明：用于加载检查报告记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 负荷_检查报告 (
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
CREATE INDEX idx_fh_jcbg ON 负荷_检查报告 (机构编码, 就医号);

--[化验登记表]******************************************************--
--用途说明：用于加载化验登记记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 负荷_化验登记 (
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
CREATE INDEX idx_fh_hydj ON 负荷_化验登记 (机构编码, 就医号);

--[化验报告表]******************************************************--
--用途说明：用于加载化验报告记录
--就医方式：[‘门诊’，‘住院’]
CREATE TABLE 负荷_化验报告 (
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
CREATE INDEX idx_fh_hybg ON 负荷_化验报告 (机构编码, 就医号);

--[药库结转表]******************************************************--
--说明：用于加载药库结转记录
--商品类型：['西药','成药','草药','材料']
CREATE TABLE 负荷_药库结转 (
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
CREATE INDEX idx_fh_ykjz ON 负荷_药库结转 (机构编码, 项目代码);

--[药库消耗表]******************************************************--
--说明：用于加载药库消耗记录
--业务类型：['物资采购','库房调拨','科室领用','库存盘点','其他业务']
CREATE TABLE 负荷_药库消耗(
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
CREATE INDEX idx_fh_ykxh ON 负荷_药库消耗 (机构编码, 项目代码);

--[药房结转表]******************************************************--
--说明：用于加载药房结转记录
--商品类型：['西药','成药','草药','材料']
CREATE TABLE 负荷_药房结转 (
  年月 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  药房名称 VARCHAR2(100) NULL,
  项目代码 VARCHAR2(50) NULL,
  国标代码 VARCHAR2(50) NULL,
  商品类型 VARCHAR2(50) NULL,
  商品名称 VARCHAR2(100) NULL,
  商品规格 VARCHAR2(100) NULL,
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
CREATE INDEX idx_fh_yfjz ON 负荷_药房结转 (机构编码, 项目代码);

--[药房消耗表]******************************************************--
--说明：用于加载药房消耗记录
--业务类型：['门诊销售','住院销售','库房调拨','科室领用','库存盘点','其他业务']
CREATE TABLE 负荷_药房消耗(
  机构编码 VARCHAR2(50), 
  机构名称 VARCHAR2(100), 
  药房名称 VARCHAR2(100), 
  项目代码 VARCHAR2(50), 
  国标代码 VARCHAR2(50), 
  商品类型 VARCHAR2(50), 
  商品名称 VARCHAR2(100), 
  商品规格 VARCHAR2(100),  
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
CREATE INDEX idx_fh_yfxh ON 负荷_药房消耗 (机构编码, 项目代码);
/********************************************************************************************/

/***********************************（三）统计类表*********************************************/
--[门诊诊次表]******************************************************--
--说明：用于归集诊次门诊费用总额
CREATE TABLE 统计_门诊诊次 (
  机构等级 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  身份证号 VARCHAR2(50) NULL,
  门诊日期 DATE NULL,
  门诊天数 INTEGER NULL,
  门诊科室 VARCHAR2(500) NULL,
  门诊医生 VARCHAR2(500) NULL,
  疾病诊断 VARCHAR2(1000) NULL,
  次要诊断 VARCHAR2(2000) NULL,
  医疗诊次 INTEGER NULL,
  医疗金额 NUMERIC(18,2) NULL,
  列支金额 NUMERIC(18,2) NULL,
  基金支付 NUMERIC(18,2) NULL,
  个账支付 NUMERIC(18,2) NULL,
  现金支付 NUMERIC(18,2) NULL
);
CREATE INDEX idx_tj_mzzc ON 统计_门诊诊次 (机构编码, 身份证号, 门诊日期);

--[门诊频度表]******************************************************--
--说明：用于归集诊次门诊项目费用
CREATE TABLE 统计_门诊频度(
  机构编码 VARCHAR2(50) NOT NULL,
  机构名称 VARCHAR2(100) NULL,
  人员姓名 VARCHAR2(50) NULL,
  身份证号 VARCHAR2(50) NULL,
  门诊日期 DATE NULL,
  代码 VARCHAR2(50) NULL,
  类别 VARCHAR2(50) NULL,
  属性 VARCHAR2(100) NULL,
  名称 VARCHAR2(100) NULL,
  规格 VARCHAR2(200) NULL,
  诊次 INTEGER NULL,
  人次 INTEGER NULL,
  频次 INTEGER NULL,
  天数 INTEGER NULL,
  剂量 NUMERIC(18, 2) NULL,
  数量 NUMERIC(18, 2) NULL,
  单位 VARCHAR2(50) NULL,
  单价 NUMERIC(18, 2) NULL,
  金额 NUMERIC(18, 2) NULL,
  列支 NUMERIC(18, 2) NULL,
  日期 DATE NULL
);
CREATE INDEX idx_tj_mzpd ON 统计_门诊频度 (机构编码, 身份证号, 门诊日期);
CREATE INDEX idx_tj_mzpd_lbdm ON 统计_门诊频度 (类别, 代码);

--[门诊结构表]******************************************************--
--说明：用于归集门诊费用结构
CREATE TABLE 统计_门诊结构(
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  人员姓名 VARCHAR2(50) NULL,
  身份证号 VARCHAR2(50) NULL,
  门诊日期 DATE NULL,
  门诊天数 INTEGER NULL, 
  床位金额 numeric(18, 2) NULL,
  床位列支 numeric(18, 2) NULL,
  床位数量 numeric(18, 2) NULL,
  床位项数 INTEGER NULL,
  床位次数 INTEGER NULL,
  诊查金额 numeric(18, 2) NULL,
  诊查列支 numeric(18, 2) NULL,
  诊查数量 numeric(18, 2) NULL,
  诊查项数 INTEGER NULL,
  诊查次数 INTEGER NULL,
  护理金额 numeric(18, 2) NULL,
  护理列支 numeric(18, 2) NULL,
  护理数量 numeric(18, 2) NULL,
  护理项数 INTEGER NULL,
  护理次数 INTEGER NULL,
  化验金额 numeric(18, 2) NULL,
  化验列支 numeric(18, 2) NULL,
  化验数量 numeric(18, 2) NULL,
  化验项数 INTEGER NULL,
  化验次数 INTEGER NULL,
  检查金额 numeric(18, 2) NULL,
  检查列支 numeric(18, 2) NULL,
  检查数量 numeric(18, 2) NULL,
  检查项数 INTEGER NULL,
  检查次数 INTEGER NULL,
  一般诊疗金额 numeric(18, 2) NULL,
  一般诊疗列支 numeric(18, 2) NULL,
  一般诊疗数量 numeric(18, 2) NULL,
  一般诊疗项数 INTEGER NULL,
  一般诊疗次数 INTEGER NULL,
  手术麻醉金额 numeric(18, 2) NULL,
  手术麻醉列支 numeric(18, 2) NULL,
  手术麻醉数量 numeric(18, 2) NULL,
  手术麻醉项数 INTEGER NULL,
  手术麻醉次数 INTEGER NULL,
  介入治疗金额 numeric(18, 2) NULL,
  介入治疗列支 numeric(18, 2) NULL,
  介入治疗数量 numeric(18, 2) NULL,
  介入治疗项数 INTEGER NULL,
  介入治疗次数 INTEGER NULL,
  放射治疗金额 numeric(18, 2) NULL,
  放射治疗列支 numeric(18, 2) NULL,
  放射治疗数量 numeric(18, 2) NULL,
  放射治疗项数 INTEGER NULL,
  放射治疗次数 INTEGER NULL,
  物理治疗金额 numeric(18, 2) NULL,
  物理治疗列支 numeric(18, 2) NULL,
  物理治疗数量 numeric(18, 2) NULL,
  物理治疗项数 INTEGER NULL,
  物理治疗次数 INTEGER NULL,
  中医治疗金额 numeric(18, 2) NULL,
  中医治疗列支 numeric(18, 2) NULL,
  中医治疗数量 numeric(18, 2) NULL,
  中医治疗项数 INTEGER NULL,
  中医治疗次数 INTEGER NULL,
  康复治疗金额 numeric(18, 2) NULL,
  康复治疗列支 numeric(18, 2) NULL,
  康复治疗数量 numeric(18, 2) NULL,
  康复治疗项数 INTEGER NULL,
  康复治疗次数 INTEGER NULL,
  精神治疗金额 numeric(18, 2) NULL,
  精神治疗列支 numeric(18, 2) NULL,
  精神治疗数量 numeric(18, 2) NULL,
  精神治疗项数 INTEGER NULL,
  精神治疗次数 INTEGER NULL,
  西药金额 numeric(18, 2) NULL,
  西药列支 numeric(18, 2) NULL,
  西药数量 numeric(18, 2) NULL,
  西药项数 INTEGER NULL,
  西药次数 INTEGER NULL,
  成药金额 numeric(18, 2) NULL,
  成药列支 numeric(18, 2) NULL,
  成药数量 numeric(18, 2) NULL,
  成药项数 INTEGER NULL,
  成药次数 INTEGER NULL,
  草药金额 numeric(18, 2) NULL,
  草药列支 numeric(18, 2) NULL,
  草药数量 numeric(18, 2) NULL,
  草药项数 INTEGER NULL,
  草药次数 INTEGER NULL,
  材料金额 numeric(18, 2) NULL,
  材料列支 numeric(18, 2) NULL,
  材料数量 numeric(18, 2) NULL,
  材料项数 INTEGER NULL,
  材料次数 INTEGER NULL,
  其他金额 numeric(18, 2) NULL,
  其他列支 numeric(18, 2) NULL,
  其他数量 numeric(18, 2) NULL,
  其他项数 INTEGER NULL,
  其他次数 INTEGER NULL
);
CREATE INDEX idx_tj_mzjg ON 统计_门诊结构 (机构编码, 身份证号, 门诊日期);

--[住院诊次表]******************************************************--
--说明：用于归集诊次住院费用总额
CREATE TABLE 统计_住院诊次 (
  机构等级 VARCHAR2(50) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  身份证号 VARCHAR2(50) NULL,
  住院日期 DATE NULL,
  住院天数 INTEGER NULL,
  住院科室 VARCHAR2(500) NULL,
  住院医生 VARCHAR2(500) NULL,
  疾病诊断 VARCHAR2(1000) NULL,
  次要诊断 VARCHAR2(2000) NULL,
  医疗诊次 INTEGER NULL,
  医疗金额 NUMERIC(18,2) NULL,
  列支金额 NUMERIC(18,2) NULL,
  基金支付 NUMERIC(18,2) NULL,
  个账支付 NUMERIC(18,2) NULL,
  现金支付 NUMERIC(18,2) NULL
);
CREATE INDEX idx_tj_zyzc ON 统计_住院诊次 (机构编码, 身份证号, 住院日期);

--[住院频度表]******************************************************--
--说明：用于归集住院诊次项目费用
CREATE TABLE 统计_住院频度(
  机构编码 VARCHAR2(50) NOT NULL,
  机构名称 VARCHAR2(100) NULL,
  人员姓名 VARCHAR2(50) NULL,
  身份证号 VARCHAR2(50) NULL,
  住院日期 DATE NULL,
  代码 VARCHAR2(50) NULL,
  类别 VARCHAR2(50) NULL,
  属性 VARCHAR2(100) NULL,
  名称 VARCHAR2(100) NULL,
  规格 VARCHAR2(200) NULL,
  诊次 INTEGER NULL,
  人次 INTEGER NULL,
  频次 INTEGER NULL,
  天数 INTEGER NULL,
  剂量 NUMERIC(18, 2) NULL,
  数量 NUMERIC(18, 2) NULL,
  单位 VARCHAR2(50) NULL,
  单价 NUMERIC(18, 2) NULL,
  金额 NUMERIC(18, 2) NULL,
  列支 NUMERIC(18, 2) NULL,
  日期 DATE NULL
); 
CREATE INDEX idx_tj_zypd ON 统计_住院频度 (机构编码, 身份证号, 住院日期);
CREATE INDEX idx_tj_zypd_lbdm ON 统计_住院频度 (类别, 代码);

--[住院结构表]******************************************************--
--说明：用于归集住院费用结构
CREATE TABLE 统计_住院结构(
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  人员姓名 VARCHAR2(50) NULL,
  身份证号 VARCHAR2(50) NULL,
  住院日期 DATE NULL,
  住院天数 INTEGER NULL, 
  床位金额 numeric(18, 2) NULL,
  床位列支 numeric(18, 2) NULL,
  床位数量 numeric(18, 2) NULL,
  床位项数 INTEGER NULL,
  床位次数 INTEGER NULL,
  诊查金额 numeric(18, 2) NULL,
  诊查列支 numeric(18, 2) NULL,
  诊查数量 numeric(18, 2) NULL,
  诊查项数 INTEGER NULL,
  诊查次数 INTEGER NULL,
  护理金额 numeric(18, 2) NULL,
  护理列支 numeric(18, 2) NULL,
  护理数量 numeric(18, 2) NULL,
  护理项数 INTEGER NULL,
  护理次数 INTEGER NULL,
  化验金额 numeric(18, 2) NULL,
  化验列支 numeric(18, 2) NULL,
  化验数量 numeric(18, 2) NULL,
  化验项数 INTEGER NULL,
  化验次数 INTEGER NULL,
  检查金额 numeric(18, 2) NULL,
  检查列支 numeric(18, 2) NULL,
  检查数量 numeric(18, 2) NULL,
  检查项数 INTEGER NULL,
  检查次数 INTEGER NULL,
  一般诊疗金额 numeric(18, 2) NULL,
  一般诊疗列支 numeric(18, 2) NULL,
  一般诊疗数量 numeric(18, 2) NULL,
  一般诊疗项数 INTEGER NULL,
  一般诊疗次数 INTEGER NULL,
  手术麻醉金额 numeric(18, 2) NULL,
  手术麻醉列支 numeric(18, 2) NULL,
  手术麻醉数量 numeric(18, 2) NULL,
  手术麻醉项数 INTEGER NULL,
  手术麻醉次数 INTEGER NULL,
  介入治疗金额 numeric(18, 2) NULL,
  介入治疗列支 numeric(18, 2) NULL,
  介入治疗数量 numeric(18, 2) NULL,
  介入治疗项数 INTEGER NULL,
  介入治疗次数 INTEGER NULL,
  放射治疗金额 numeric(18, 2) NULL,
  放射治疗列支 numeric(18, 2) NULL,
  放射治疗数量 numeric(18, 2) NULL,
  放射治疗项数 INTEGER NULL,
  放射治疗次数 INTEGER NULL,
  物理治疗金额 numeric(18, 2) NULL,
  物理治疗列支 numeric(18, 2) NULL,
  物理治疗数量 numeric(18, 2) NULL,
  物理治疗项数 INTEGER NULL,
  物理治疗次数 INTEGER NULL,
  中医治疗金额 numeric(18, 2) NULL,
  中医治疗列支 numeric(18, 2) NULL,
  中医治疗数量 numeric(18, 2) NULL,
  中医治疗项数 INTEGER NULL,
  中医治疗次数 INTEGER NULL,
  康复治疗金额 numeric(18, 2) NULL,
  康复治疗列支 numeric(18, 2) NULL,
  康复治疗数量 numeric(18, 2) NULL,
  康复治疗项数 INTEGER NULL,
  康复治疗次数 INTEGER NULL,
  精神治疗金额 numeric(18, 2) NULL,
  精神治疗列支 numeric(18, 2) NULL,
  精神治疗数量 numeric(18, 2) NULL,
  精神治疗项数 INTEGER NULL,
  精神治疗次数 INTEGER NULL,
  西药金额 numeric(18, 2) NULL,
  西药列支 numeric(18, 2) NULL,
  西药数量 numeric(18, 2) NULL,
  西药项数 INTEGER NULL,
  西药次数 INTEGER NULL,
  成药金额 numeric(18, 2) NULL,
  成药列支 numeric(18, 2) NULL,
  成药数量 numeric(18, 2) NULL,
  成药项数 INTEGER NULL,
  成药次数 INTEGER NULL,
  草药金额 numeric(18, 2) NULL,
  草药列支 numeric(18, 2) NULL,
  草药数量 numeric(18, 2) NULL,
  草药项数 INTEGER NULL,
  草药次数 INTEGER NULL,
  材料金额 numeric(18, 2) NULL,
  材料列支 numeric(18, 2) NULL,
  材料数量 numeric(18, 2) NULL,
  材料项数 INTEGER NULL,
  材料次数 INTEGER NULL,
  其他金额 numeric(18, 2) NULL,
  其他列支 numeric(18, 2) NULL,
  其他数量 numeric(18, 2) NULL,
  其他项数 INTEGER NULL,
  其他次数 INTEGER NULL
);
CREATE INDEX idx_tj_zyjg ON 统计_住院结构 (机构编码, 身份证号, 住院日期);

--[库房进销表]******************************************************--
--说明：用于归集药库、药房进销数据
CREATE TABLE 统计_库房进销(
  机构编码 VARCHAR2(50) NOT NULL,
  机构名称 VARCHAR2(100) NULL,
  业务期间 VARCHAR2(50) NULL,
  代码 VARCHAR2(50) NULL,
  国标 VARCHAR2(50) NULL,
  类别 VARCHAR2(50) NULL,
  名称 VARCHAR2(200) NULL,
  规格 VARCHAR2(200) NULL,
  拆零比 INTEGER NULL,
  购入数量 NUMERIC(18, 2) NULL,
  购入金额 NUMERIC(18, 2) NULL,
  购入均价 NUMERIC(18, 2) NULL,
  购入单位 VARCHAR2(50) NULL,
  销售数量 NUMERIC(18, 2) NULL,
  销售金额 NUMERIC(18, 2) NULL,
  销售均价 NUMERIC(18, 2) NULL,
  销售单位 VARCHAR2(50) NULL,
  计费人次 INTEGER NULL,
  计费数量 NUMERIC(18, 2) NULL,
  计费金额 NUMERIC(18, 2) NULL,
  计费均价 NUMERIC(18, 2) NULL,
  计费单位 VARCHAR2(50) NULL
);
CREATE INDEX idx_tj_kfjx ON 统计_库房进销 (机构编码, 代码);
CREATE INDEX idx_tj_kfjx_gb ON 统计_库房进销 (机构编码, 国标);

/********************************************************************************************/

/***********************************（四）应用类表*********************************************/
--[问题线索表]******************************************************--
--说明：用于收集规则跑测的线索数据
--就医来源：['门诊','住院',...]
--项目来源：['药品','检验',...]
--线索来源：['规则分析','***专项',...]
--问题类型：['超范围支付药品','超标准支付诊疗',...]
CREATE TABLE 应用_问题线索(
  就医来源 VARCHAR2(50) NULL,
  项目来源 VARCHAR2(50) NULL,
  线索来源 VARCHAR2(100) NULL,
  问题类型 VARCHAR2(50) NULL,
  问题情形 VARCHAR2(2000) NULL,
  问题性质 VARCHAR2(50) NULL,
  问题数量 numeric(18, 2) NULL,
  问题金额 numeric(18, 2) NULL,
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  科室名称 VARCHAR2(500) NULL,
  医生姓名 VARCHAR2(500) NULL,
  身份证号 VARCHAR2(50) NULL,
  姓名 VARCHAR2(50) NULL,
  性别 VARCHAR2(50) NULL,
  年龄 INTEGER NULL,
  就医日期 date NULL,
  就医天数 INTEGER NULL,
  疾病诊断 VARCHAR2(2000) NULL,
  分类 VARCHAR2(100) NULL,
  代码 VARCHAR2(50) NULL,
  名称 VARCHAR2(200) NULL,
  规格 VARCHAR2(200) NULL,
  单位 VARCHAR2(50) NULL,
  单价 numeric(18, 2) NULL,
  人次 INTEGER NULL,
  天数 INTEGER NULL,
  频次 INTEGER NULL,
  剂量 numeric(18, 2) NULL,
  数量 numeric(18, 2) NULL,
  医疗金额 numeric(18, 2) NULL,
  医保支付 numeric(18, 2) NULL,
  支付日期 date NULL
); 
CREATE INDEX idx_yy_wtxs ON 应用_问题线索 (机构编码, 线索来源, 问题类型);

--[病案遴选表]******************************************************--
--说明：用于遴选问题项目的病案
CREATE TABLE 应用_病案遴选(
  机构编码 VARCHAR2(50) NULL,
  机构名称 VARCHAR2(100) NULL,
  住院号 VARCHAR2(50) NULL,
  项目名称 VARCHAR2(100) NULL,
  项目数量 NUMERIC(18, 2) NULL,
  住院日期 DATE NULL
);
CREATE INDEX idx_yy_balx ON 应用_病案遴选 (机构编码);
/********************************************************************************************/
