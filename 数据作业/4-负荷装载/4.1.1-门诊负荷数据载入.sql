/*********************************************************************************************
脚本说明：以下脚本从机构原始数据中载入门诊负荷数据，运行时机构编码和机构数据表名称请注意替换成为实际机构
机构编码：H00000000000
机构名称：测试医院
导入表名：测试医院_<导入表名>
**********************************************************************************************/

--*******************************************************************************************--
--脚本：将机构导入表中的机构摘要加载至负荷表
--注意：
delete from 负荷_机构摘要 where 机构编码 = 'H00000000000';
commit;

INSERT INTO 负荷_机构摘要 (机构编码, 机构名称, 机构性质, 机构等级, 机构类型, 核定床位, 定点开始日期, 定点停止日期) 
select trim(机构编码), 机构名称, 机构性质, 机构等级, 机构类型, 核定床位, 定点开始日期, 定点停止日期
from 测试医院_机构摘要@USR_LINK;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：收集结算金额为零的就医记录
--注意：临时表在使用完毕后即时剔除
create table 临时_无效结算 AS 
SELECT trim(结算流水号) 流水号,sum(医疗金额) 医疗金额 from 测试医院_门诊就医@USR_LINK
group by trim(结算流水号) having sum(医疗金额) = 0;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊就医记录加载至负荷表
--注意：无效的结算记录不会被载入
delete from 负荷_门诊就医 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_门诊就医 (机构等级, 机构编码, 机构名称, 险种类别, 参保区划, 姓名, 性别, 年龄, 身份证号, 
       门诊号, 门诊日期, 门诊科室, 门诊医生, 疾病编码, 疾病诊断, 次要诊断, 结算流水号, 
       结算类别, 结算日期, 医疗金额, 列支金额, 基金支付, 个账支付, 现金支付)
select distinct 机构等级, trim(机构编码), 机构名称, 险种类别, 参保地区划, 人员姓名, 人员性别, 人员年龄, trim(身份证号), 
       trim(门诊号), 门诊日期, 门诊科室名称, 首诊医生姓名, 疾病编码icd, 疾病诊断名称, 次要诊断组合, trim(结算流水号), 
       结算类别, 结算日期, 医疗金额, 医保范围金额, 基金支付, 个账支付, 现金支付
from 测试医院_门诊就医@USR_LINK a
where not exists (select 1 from 临时_无效结算 b where trim(a.结算流水号) = b.流水号);
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊结算记录加载至负荷表
--注意：无效的结算记录不会被载入
delete from 负荷_门诊结算 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_门诊结算 (机构编码, 机构名称, 险种类别, 身份证号, 人员姓名, 门诊号, 处方号, 处方组号, 
            项目代码, 项目名称, 国标代码, 国标名称, 商品名, 规格, 产地厂家, 用法, 剂量, 
            剂量单位, 频次, 天数, 收费项目类别, 收费项目等级, 数量, 数量单位, 单价, 金额, 限价, 
            自付比例, 全自费金额, 超限价金额, 先行自付金额, 费用发生日期, 费用科室名称, 结算流水号)
select trim(机构编码), 机构名称, 险种类别, trim(身份证号),人员姓名, trim(门诊号), 处方号, 处方组号, 
       trim(项目代码), 项目名称, trim(国标代码), 国标名称, 商品名, 规格, 产地厂家, 用法, 剂量, 
       剂量单位, trim(频次), 天数, 收费项目类别, 收费项目等级, 数量, 数量单位, 单价, 金额, 限价, 
       自付比例, 全自费金额, 超限价金额, 先行自付金额, 费用发生日期, 费用科室名称, trim(结算流水号) 
from 测试医院_门诊结算@USR_LINK a
where not exists (select 1 from 临时_无效结算 b where trim(a.结算流水号) = b.流水号);
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：在门诊就医、门诊结算负荷表加载完成后删除临时表
DROP TABLE 临时_无效结算 purge;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊处方记录加载至负荷表
delete from 负荷_门诊处方 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_门诊处方 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 门诊号, 处置类型, 处方号, 
            处方组号, 药品代码, 药品名称, 药品规格, 处方用法, 处方剂量, 剂量单位, 处方频次, 处方天数, 
            数量, 数量单位, 单价, 金额, 处方开具日期, 处方科室名称)
select trim(机构编码), 机构名称, 身份证号, 姓名, 性别, 年龄, trim(门诊号), 处置类型, 处方号, 
      处方组号, trim(药品代码), 药品名称, 药品规格, 处方用法, 处方剂量, 剂量单位, trim(处方频次), 处方天数, 
      数量, 数量单位, 单价, 金额, 处方开具日期, 处方科室名称
from 测试医院_门诊处方@USR_LINK;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊手术记录加载至负荷表
delete from 负荷_门诊手术 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_门诊手术 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 门诊号, 门诊科室名称, 
            疾病诊断名称, 手术日期, 手术开始时间, 手术结束时间, 手术科室名称, 手术者姓名, 手术操作编码, 手术操作名称, 
            主要手术, 手术等级, 切口类型, 愈合类型)
select trim(机构编码), 机构名称, trim(身份证号), 姓名, 性别, 年龄, trim(门诊号), 门诊科室名称, 
            疾病诊断名称, 手术日期, 手术开始时间, 手术结束时间, 手术科室名称, 手术者姓名, 手术操作编码, 手术操作名称, 
            主要手术, 手术等级, 切口类型, 愈合类型
from 测试医院_门诊手术@USR_LINK;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊麻醉记录加载至负荷表
delete from 负荷_门诊麻醉 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_门诊麻醉 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 门诊号, 门诊科室名称, 
            疾病诊断名称, 麻醉日期, 麻醉开始时间, 麻醉结束时间, 麻醉科室名称, 麻醉者姓名, 麻醉方式编码, 麻醉方式名称, 
            麻醉等级, 术后镇痛方式)
select trim(机构编码), 机构名称, trim(身份证号), 姓名, 性别, 年龄, trim(门诊号), 门诊科室名称, 
            疾病诊断名称, 麻醉日期, 麻醉开始时间, 麻醉结束时间, 麻醉科室名称, 麻醉者姓名, 麻醉方式编码, 麻醉方式名称, 
            麻醉等级, 术后镇痛方式
from 测试医院_门诊麻醉@USR_LINK;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊检查登记记录加载至负荷表
delete from 负荷_检查登记 where 机构编码 = 'H00000000000' and 就医方式 = '门诊';
commit;

insert into 负荷_检查登记 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 就医号, 就医科室名称, 
            疾病诊断名称, 检查登记日期, 检查科室名称, 检查者姓名, 检查项目编码, 检查项目名称, 是否外送)
select trim(机构编码), 机构名称, trim(身份证号), 姓名, 性别, 年龄, trim(就医号), 就医科室名称, 
            疾病诊断名称, 检查登记日期, 检查科室名称, 检查者姓名, 检查项目编码, 检查项目名称, 是否外送
from 测试医院_检查登记@USR_LINK
where 就医方式 = '门诊';
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊检查报告记录加载至负荷表
delete from 负荷_检查报告 where 机构编码 = 'H00000000000' and 就医方式 = '门诊';
commit;

insert into 负荷_检查报告 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 就医号, 就医科室名称, 疾病诊断名称, 
            检查报告时间, 检查科室名称, 检查者姓名, 检查部位, 检查方法, 检查报告诊断, 影像编号, 检查报告单位)
select trim(机构编码), 机构名称, trim(身份证号), 姓名, 性别, 年龄, trim(就医号), 就医科室名称, 疾病诊断名称, 
            检查报告时间, 检查科室名称, 检查者姓名, 检查部位, 检查方法, 检查报告诊断, 影像编号, 检查报告单位
from 测试医院_检查报告@USR_LINK
where 就医方式 = '门诊';
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊检验登记记录加载至负荷表
delete from 负荷_化验登记 where 机构编码 = 'H00000000000' and 就医方式 = '门诊';
commit;

insert into 负荷_化验登记 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 就医号, 就医科室名称, 
            疾病诊断名称, 检验登记日期, 检验科室名称, 检验者姓名, 检验项目编码, 检验项目名称, 是否外送)
select trim(机构编码), 机构名称, trim(身份证号), 姓名, 性别, 年龄, trim(就医号), 就医科室名称, 
            疾病诊断名称, 检验登记日期, 检验科室名称, 检验者姓名, 检验项目编码, 检验项目名称, 是否外送
from 测试医院_化验登记@USR_LINK
where 就医方式 = '门诊';
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的门诊检验报告记录加载至负荷表
delete from 负荷_化验报告 where 机构编码 = 'H00000000000' and 就医方式 = '门诊';
commit;

insert into 负荷_化验报告 (机构编码, 机构名称, 身份证号, 姓名, 性别, 年龄, 就医号, 就医科室名称, 疾病诊断名称, 
            检验报告时间, 检验科室名称, 检验者姓名, 检验样本, 检验方法, 检验值名称, 检验值描述, 检验值范围, 样本编号, 检验报告单位)
select trim(机构编码), 机构名称, trim(身份证号), 姓名, 性别, 年龄, trim(就医号), 就医科室名称, 疾病诊断名称, 
            检验报告时间, 检验科室名称, 检验者姓名, 检验样本, 检验方法, 检验值名称, 检验值描述, 检验值范围, 样本编号, 检验报告单位
from 测试医院_化验报告@USR_LINK
where 就医方式 = '门诊';
commit;
--*******************************************************************************************--

