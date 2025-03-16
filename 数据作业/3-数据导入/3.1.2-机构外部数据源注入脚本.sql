/*********************************************************************************************
脚本说明：以下脚本仅用于演示如何从外部数据源中检出机构导入表数据，运行时请替换实际的机构编码和机构名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

--脚本：编录一条机构摘要数据
--说明：以下脚本仅用于演示，需根据实际情况修改
DELETE FROM 测试医院_机构摘要;
COMMIT;

INSERT INTO 测试医院_机构摘要 (机构编码,机构名称,机构性质,机构等级,机构类型,核定床位,定点开始日期,定点停止日期)
VALUES ('H00000000000','测试医院','综合医院','三级','公立',1000,'2024-01-01 00:00:00','2024-12-31 23:59:59');
COMMIT;

--脚本：创建外部数据链接
--说明：以下链接仅适用于Oracle数据库，可能存在多个外部数据源，以下演示了医疗、影像、检验三个外部数据源
--注意：请将<user>、<password>、<dbname>替换为实际的用户名、密码和数据库名
CREATE DATABASE LINK HIS_LINK CONNECT TO '<user>' IDENTIFIED BY VALUES '<password>' USING '<dbname>';
CREATE DATABASE LINK RIS_LINK CONNECT TO '<user>' IDENTIFIED BY VALUES '<password>' USING '<dbname>';
CREATE DATABASE LINK LIS_LINK CONNECT TO '<user>' IDENTIFIED BY VALUES '<password>' USING '<dbname>';

--脚本：在HIS外源数据库中创建机构门诊就医视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZJY AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.jgdj 机构等级,
    a.cbxz 险种类别,
    a.cbqh 参保地区划,
    a.ryxm 人员姓名,
    a.ryxb 人员性别,
    a.rynl 人员年龄,
    a.sfzh 身份证号,
    a.mzh 门诊号,
    a.jzrq 门诊日期,
    a.ksmc 门诊科室名称,
    a.ysxm 首诊医生姓名,
    a.jbdm 疾病编码ICD,
    a.jbmc 疾病诊断名称,
    a.jbms 次要诊断组合,
    b.jsxh 结算流水号,
    b.jslb 结算类别,
    b.jsrq 结算日期,
    b.ylje 医疗金额,
    b.ybje 医保范围金额,
    b.jjzf 基金支付,
    b.zhzf 个账支付,
    b.xjzf 现金支付 
FROM mz_jz a INNER JOIN mz_js b ON a.mzh = b.mzh
--限定时间范围和有效的结算标志
WHERE b.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND b.jsbz = '1'; 

--脚本：从外源数据库中检出数据并注入到机构门诊就医表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊就医;
COMMIT;

INSERT INTO 测试医院_门诊就医
SELECT * FROM DEMO_MZJY@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构门诊结算视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZJS AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.cbxz 险种类别,
    a.cbqh 参保地区划,
    a.sfzh 身份证号,
    a.ryxm 人员姓名,
    a.mzh 门诊号,
    c.cfh 处方号,
    c.cfzh 处方组号,
    c.xmdm 项目代码,
    c.xmmc 项目名称,
    c.gbdm 国标代码,
    c.gbmc 国标名称,
    c.spmc 商品名,
    c.gg 规格,
    c.cd 产地厂家,
    c.yf 用法,
    c.jl 剂量,
    c.jldw 剂量单位,
    c.pc 频次,
    c.ts 天数,
    c.xmlb 收费项目类别,
    c.xmlv 收费项目等级,
    c.sl 数量,
    c.sldw 数量单位,
    c.dj 单价,
    c.je 金额,
    c.xj 限价,
    c.zfbl 自付比例,
    c.zzje 全自费金额,
    c.cxje 超限价金额,
    c.zfje 先行自付金额,
    c.fyrq 费用发生日期,
    c.fyks 费用科室名称,
    b.jsxh 结算流水号,
    b.jsrq 结算日期
FROM mz_jz a 
INNER JOIN mz_js b ON a.mzh = b.mzh
INNER JOIN mz_jsmx c ON b.jsxh = c.jsxh
--限定时间范围和有效的结算标志
WHERE b.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND b.jsbz = '1'; 

--脚本：从外源数据库中检出数据并注入到机构门诊结算表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊结算;
COMMIT;

INSERT INTO 测试医院_门诊结算
SELECT * FROM DEMO_MZJS@HIS_LINK;
COMMIT;

--脚本：在HIS外源数据库中创建机构门诊结算视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZCF AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.mzh 门诊号,
    b.cflx 处置类型,
    b.cfh 处方号,
    b.cfzh 处方组号,
    b.xmdm 药品代码,
    b.xmmc 药品名称,
    b.gg 药品规格,
    b.yf 处方用法,
    b.jl 处方剂量,
    b.jldw 剂量单位,
    b.pc 处方频次,
    b.ts 处方天数,
    b.sl 数量,
    b.sldw 数量单位,
    b.dj 单价,
    b.je 金额,
    b.cfrq 处方开具日期,
    b.cfks 处方科室名称,
    b.cfys 开具医生姓名 
FROM mz_jz a 
INNER JOIN mz_cf b ON a.mzh = b.mzh
--限定时间范围和有效的结算标志
WHERE EXISTS (SELECT 1 FROM mz_js c WHERE a.mzh = c.mzh
AND c.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND c.jsbz = '1'); 

--脚本：从外源数据库中检出数据并注入到机构门诊处方表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊处方;
COMMIT;

INSERT INTO 测试医院_门诊处方
SELECT * FROM DEMO_MZCF@HIS_LINK;
COMMIT;

--脚本：在HIS外源数据库中创建机构门诊结算视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZSS AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.mzh 门诊号,
    a.ksmc 门诊科室名称,
    a.jbmc 疾病诊断名称,
    b.ssrq 手术日期,
    b.sskssj 手术开始时间,
    b.sstzsj 手术结束时间,
    b.ssks 手术科室名称,
    b.ssys 手术者姓名,
    b.ssdm 手术操作编码,
    b.ssmc 手术操作名称,
    b.zyss 主要手术,
    b.ssdj 手术等级,
    b.qklx 切口类型,
    b.yhlx 愈合类型
FROM mz_jz a 
INNER JOIN mz_ss b ON a.mzh = b.mzh
--限定时间范围和有效的结算标志
WHERE EXISTS (SELECT 1 FROM mz_js c WHERE a.mzh = c.mzh
AND c.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND c.jsbz = '1'); 

--脚本：从外源数据库中检出数据并注入到机构门诊手术表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊手术;
COMMIT;

INSERT INTO 测试医院_门诊手术
SELECT * FROM DEMO_MZSS@HIS_LINK;
COMMIT;

--脚本：在HIS外源数据库中创建机构门诊麻醉视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZMZ AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.ssfz 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.mzh 门诊号,
    a.ksmc 门诊科室名称,
    a.jbmc 疾病诊断名称,
    b.mzrq 麻醉日期,
    b.mzkssj 麻醉开始时间,
    b.mztzsj 麻醉结束时间,
    b.mzks 麻醉科室名称,
    b.mzys 麻醉者姓名,
    b.mzdm 麻醉方式编码,
    b.mzmc 麻醉方式名称,
    b.mzdj 麻醉等级,
    b.ztfs 术后镇痛方式
FROM mz_jz a 
INNER JOIN mz_mz b ON a.mzh = b.mzh
--限定时间范围和有效的结算标志
WHERE EXISTS (SELECT 1 FROM mz_js c WHERE a.mzh = c.mzh
AND c.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND c.jsbz = '1'); 

--脚本：从外源数据库中检出数据并注入到机构门诊麻醉表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊麻醉;
COMMIT;

INSERT INTO 测试医院_门诊麻醉
SELECT * FROM DEMO_MZMZ@HIS_LINK;
COMMIT;

--脚本：在HIS外源数据库中创建机构住院就医视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYJY AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.jgdj 机构等级,
    a.cbxz 险种类别,
    a.cbqh 参保地区划,
    a.ryxm 人员姓名,
    a.ryxb 人员性别,
    a.rynl 人员年龄,
    a.sfzh 身份证号,
    a.zyh 住院号,
    a.ryrq 入院日期,
    a.cyrq 出院日期,
    a.zyts 住院天数
    a.ksmc 住院科室名称,
    a.ysxm 主管医生姓名,
    a.jbdm 疾病编码ICD,
    a.jbmc 疾病诊断名称,
    a.jbms 次要诊断组合,
    b.jsxh 结算流水号,
    b.jslb 结算类别,
    b.jsrq 结算日期,
    b.ylje 医疗金额,
    b.ybje 医保范围金额,
    b.jjzf 基金支付,
    b.zhzf 个账支付,
    b.xjzf 现金支付 
FROM zy_jz a INNER JOIN zy_js b ON a.zyh = b.zyh
--限定时间范围和有效的结算标志
WHERE b.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND b.jsbz = '1'; 

--脚本：从外源数据库中检出数据并注入到机构住院就医表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院就医;
COMMIT;

INSERT INTO 测试医院_住院就医
SELECT * FROM DEMO_ZYJY@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构住院结算视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYJS AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.cbxz 险种类别,
    a.cbqh 参保地区划,
    a.sfzh 身份证号,
    a.ryxm 人员姓名,
    a.zyh 住院号,
    c.yzh 医嘱号,
    c.yzzh 医嘱组号,
    c.xmdm 项目代码,
    c.xmmc 项目名称,
    c.gbdm 国标代码,
    c.gbmc 国标名称,
    c.spmc 商品名,
    c.gg 规格,
    c.cd 产地厂家,
    c.yf 用法,
    c.jl 剂量,
    c.jldw 剂量单位,
    c.pc 频次,
    c.ts 天数,
    c.xmlb 收费项目类别,
    c.xmlv 收费项目等级,
    c.sl 数量,
    c.sldw 数量单位,
    c.dj 单价,
    c.je 金额,
    c.xj 限价,
    c.zfbl 自付比例,
    c.zzje 全自费金额,
    c.cxje 超限价金额,
    c.zfje 先行自付金额,
    c.fyrq 费用发生日期,
    c.fyks 费用科室名称,
    b.jsxh 结算流水号,
    b.jsrq 结算日期
FROM mz_jz a 
INNER JOIN zy_js b ON a.zyh = b.zyh
INNER JOIN zy_jsmx c ON b.jsxh = c.jsxh
--限定时间范围和有效的结算标志
WHERE b.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND b.jsbz = '1'; 

--脚本：从外源数据库中检出数据并注入到机构住院结算表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院结算;
COMMIT;

INSERT INTO 测试医院_住院结算
SELECT * FROM DEMO_ZYJS@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构住院医嘱视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYYZ AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.zyh 住院号,
    b.yzh 医嘱号,
    b.yzzh 医嘱组号,
    b.yzdm 医嘱代码,
    b.yzmc 医嘱名称,
    b.gg 医嘱规格,
    b.yf 医嘱用法,
    b.jl 医嘱剂量,
    b.jldw 剂量单位,
    b.pc 医嘱频次,
    b.ts 医嘱天数,
    b.sl 数量,
    b.sldw 数量单位,
    b.dj 单价,
    b.je 金额,
    b.ksrq 医嘱开始日期,
    b.tzrq 医嘱停止日期,
    b.yzks 医嘱科室名称,
    b.yzys 开立医生姓名
FROM zy_jz a 
INNER JOIN zy_yz b ON a.zyh = b.zyh
--限定时间范围和有效的结算标志
WHERE EXISTS (SELECT 1 FROM zy_js c WHERE a.zyh = c.zyh
AND c.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND c.jsbz = '1'); 

--脚本：从外源数据库中检出数据并注入到机构住院医嘱表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院医嘱;
COMMIT;

INSERT INTO 测试医院_住院医嘱
SELECT * FROM DEMO_ZYYZ@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构住院医嘱视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYSS AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.zyh 住院号,
    a.ksmc 住院科室名称,
    a.jbmc 疾病诊断名称,
    b.ssrq 手术日期,
    b.sskssj 手术开始时间,
    b.sstzsj 手术结束时间,
    b.ssks 手术科室名称,
    b.ssys 手术者姓名,
    b.ssdm 手术操作编码,
    b.ssmc 手术操作名称,
    b.zyss 主要手术,
    b.ssdj 手术等级,
    b.qklx 切口类型,
    b.yhlx 愈合类型 
FROM zy_jz a 
INNER JOIN zy_ss b ON a.zyh = b.zyh
--限定时间范围和有效的结算标志
WHERE EXISTS (SELECT 1 FROM zy_js c WHERE a.zyh = c.zyh
AND c.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND c.jsbz = '1'); 

--脚本：从外源数据库中检出数据并注入到机构住院手术表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院手术;
COMMIT;

INSERT INTO 测试医院_住院手术
SELECT * FROM DEMO_ZYSS@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构住院麻醉视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYMZ AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.zyh 住院号,
    a.ksmc 住院科室名称,
    a.jbmc 疾病诊断名称,
    b.mzrq 麻醉日期,
    b.mzkssj 麻醉开始时间,
    b.mztzsj 麻醉结束时间,
    b.mzks 麻醉科室名称,
    b.mzys 麻醉者姓名,
    b.mzdm 麻醉方式编码,
    b.mzmc 麻醉方式名称,
    b.mzdj 麻醉等级,
    b.ztfs 术后镇痛方式,
    b.fhkssj 麻醉复苏开始时间,
    b.fhtzsj 麻醉复苏结束时间 
FROM zy_jz a 
INNER JOIN zy_mz b ON a.zyh = b.zyh
--限定时间范围和有效的结算标志
WHERE EXISTS (SELECT 1 FROM zy_js c WHERE a.zyh = c.zyh
AND c.jsrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
AND c.jsbz = '1'); 

--脚本：从外源数据库中检出数据并注入到机构住院麻醉表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院麻醉;
COMMIT;

INSERT INTO 测试医院_住院麻醉
SELECT * FROM DEMO_ZYMZ@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构药库结转视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_YKJZ AS
SELECT 
    a.jzxh 年月,
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.ykmc 药库名称,
    a.xmdm 项目代码,
    a.gbdm 国标代码,
    a.wzlx 商品类型,
    a.wzmc 商品名称,
    a.wzgg 商品规格,
    a.cdmc 生产厂家,
    a.gysmc 供应商名称,
    a.bzdw 包装单位,
    a.cldw 拆零单位,
    a.clbl 拆零比,
    a.kcdw 库存单位,
    a.sqjc 上期结存数,
    a.bqsr 本期收入数,
    a.bqzc 本期支出数,
    a.bqjc 本期结存数,
    a.grdj 购入价,
    a.lsdj 零售价,
    a.jzrq 结转日期 
FROM yk_jz a 
--限定时间范围
WHERE a.jzxh BETWEEN '202401' AND '202412';

--脚本：从外源数据库中检出数据并注入到机构药库结转表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_药库结转;
COMMIT;

INSERT INTO 测试医院_药库结转
SELECT * FROM DEMO_YKJZ@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构药房结转视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_YFJZ AS
SELECT 
    a.jzxh 年月,
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.ykmc 药房名称,
    a.xmdm 项目代码,
    a.gbdm 国标代码,
    a.wzlx 商品类型,
    a.wzmc 商品名称,
    a.wzgg 商品规格,
    a.cdmc 生产厂家,
    a.gysmc 供应商名称,
    a.bzdw 包装单位,
    a.cldw 拆零单位,
    a.clbl 拆零比,
    a.kcdw 库存单位,
    a.sqjc 上期结存数,
    a.bqsr 本期收入数,
    a.bqzc 本期支出数,
    a.bqjc 本期结存数,
    a.grdj 购入价,
    a.lsdj 零售价,
    a.jzrq 结转日期 
FROM yf_jz a 
--限定时间范围
WHERE a.jzxh BETWEEN '202401' AND '202412';

--脚本：从外源数据库中检出数据并注入到机构药房结转表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_药房结转;
COMMIT;

INSERT INTO 测试医院_药房结转
SELECT * FROM DEMO_YFJZ@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构药库消耗视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_YKXH AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.ykmc 药库名称,
    a.xmdm 项目代码,
    a.gbdm 国标代码,
    a.wzlx 商品类型,
    a.wzmc 商品名称,
    a.wzgg 商品规格,
    a.cdmc 生产厂家,
    a.gysmc 供应商名称,
    a.bzdw 包装单位,
    a.cldw 拆零单位,
    a.clbl 拆零比,
    a.ywlx 出入库类型,
    a.sl 出入库数量,
    a.dw 出入库单位,
    a.grdj 购入价,
    a.lsdj 零售价,
    a.ywrq 业务日期,
    a.dfbm 对方单位部门 
FROM yk_xh a 
--限定时间范围
WHERE a.ywrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

--脚本：从外源数据库中检出数据并注入到机构药库消耗表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_药库消耗;
COMMIT;

INSERT INTO 测试医院_药库消耗
SELECT * FROM DEMO_YKXH@HIS_LINK
COMMIT;

--脚本：在HIS外源数据库中创建机构药房消耗视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_YFXH AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.ykmc 药库名称,
    a.xmdm 项目代码,
    a.gbdm 国标代码,
    a.wzlx 商品类型,
    a.wzmc 商品名称,
    a.wzgg 商品规格,
    a.cdmc 生产厂家,
    a.gysmc 供应商名称,
    a.bzdw 包装单位,
    a.cldw 拆零单位,
    a.clbl 拆零比,
    a.ywlx 出入库类型,
    a.sl 出入库数量,
    a.dw 出入库单位,
    a.grdj 购入价,
    a.lsdj 零售价,
    a.ywrq 业务日期,
    a.dfbm 对方单位部门 
FROM yf_xh a 
--限定时间范围
WHERE a.ywrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

--脚本：从外源数据库中检出数据并注入到机构药房消耗表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_药房消耗;
COMMIT;

INSERT INTO 测试医院_药房消耗
SELECT * FROM DEMO_YFXH@HIS_LINK
COMMIT;

--脚本：在RIS外源数据库中创建机构门诊检查视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZJC AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.mzh 门诊号,
    a.ksmc 门诊科室名称,
    a.jbmc 疾病诊断名称,
    b.jcrq 检查日期,
    b.jcks 检查科室名称,
    b.jcry 检查者姓名,
    b.jcdm 检查项目编码,
    b.jcmc 检查项目名称,
    b.jcbw 检查部位,
    b.jcff 检查方法,
    b.yxbh 影像编号,
    b.bgrq 检查报告时间,
    b.bgzd 检查报告诊断,
    b.bgbm 报告单位部门,
    b.bgys 报告者姓名 
FROM ris_br a INNER JOIN ris_bg b ON a.mzh = b.mzh
--限定时间范围
WHERE a.jcrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

--脚本：从外源数据库中检出数据并注入到机构门诊检查表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊检查;
COMMIT;

INSERT INTO 测试医院_门诊检查
SELECT * FROM DEMO_MZJC@RIS_LINK
COMMIT;

--脚本：在RIS外源数据库中创建机构住院检查视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYJC AS
SELECT 
    a.jgdm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.zyh 住院号,
    a.ksmc 住院科室名称,
    a.jbmc 疾病诊断名称,
    b.jcrq 检查日期,
    b.jcks 检查科室名称,
    b.jcry 检查者姓名,
    b.jcdm 检查项目编码,
    b.jcmc 检查项目名称,
    b.jcbw 检查部位,
    b.jcff 检查方法,
    b.yxbh 影像编号,
    b.bgrq 检查报告时间,
    b.bgzd 检查报告诊断,
    b.bgbm 报告单位部门,
    b.bgys 报告者姓名 
FROM ris_br a INNER JOIN ris_bg b ON a.zyh = b.zyh
--限定时间范围
WHERE a.jcrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

--脚本：从外源数据库中检出数据并注入到机构住院检查表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院检查;
COMMIT;

INSERT INTO 测试医院_住院检查
SELECT * FROM DEMO_ZYJC@RIS_LINK
COMMIT;

--脚本：在LIS外源数据库中创建机构门诊检验视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_MZHY AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.mzh 门诊号,
    a.ksmc 门诊科室名称,
    a.jbmc 疾病诊断名称,
    b.jyrq 检验日期,
    b.jyks 检验科室名称,
    b.jyry 检验者姓名,
    b.xmdm 检验项目编码,
    b.xmmc 检验项目名称,
    b.jyyb 检验样本,
    b.jyff 检验方法,
    b.zbmc 检验值名称,
    b.zbms 检验值描述,
    b.zbfw 检验值范围,
    b.bgrq 检验报告时间,
    b.bgbm 报告单位部门,
    b.bgys 报告者姓名 
FROM lis_br a INNER JOIN lis_bg b ON a.mzh = b.mzh
--限定时间范围
WHERE a.jyrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

--脚本：从外源数据库中检出数据并注入到机构门诊检验表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_门诊化验;
COMMIT;

INSERT INTO 测试医院_门诊化验
SELECT * FROM DEMO_MZHY@LIS_LINK
COMMIT;

--脚本：在LIS外源数据库中创建机构住院检验视图
--说明：以下脚本仅用于演示，需拷贝至外源数据库中根据实际情况修改
CREATE VIEW DEMO_ZYJY AS
SELECT 
    a.jgbm 机构编码,
    a.jgmc 机构名称,
    a.sfzh 身份证号,
    a.ryxm 姓名,
    a.ryxb 性别,
    a.rynl 年龄,
    a.zyh 住院号,
    a.ksmc 住院科室名称,
    a.jbmc 疾病诊断名称,
    b.jyrq 检验日期,
    b.jyks 检验科室名称,
    b.jyry 检验者姓名,
    b.xmdm 检验项目编码,
    b.xmmc 检验项目名称,
    b.jyyb 检验样本,
    b.jyff 检验方法,
    b.zbmc 检验值名称,
    b.zbms 检验值描述,
    b.zbfw 检验值范围,
    b.bgrq 检验报告时间,
    b.bgbm 报告单位部门,
    b.bgys 报告者姓名 
FROM lis_br a INNER JOIN lis_bg b ON a.zyh = b.zyh
--限定时间范围
WHERE a.jyrq BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

--脚本：从外源数据库中检出数据并注入到机构住院检验表
--说明：请先确定外部数据源中视图可用后，再执行以下脚本
DELETE FROM 测试医院_住院检验;
COMMIT;

INSERT INTO 测试医院_住院检验
SELECT * FROM DEMO_ZYJY@LIS_LINK
COMMIT;