/*********************************************************************************************
脚本说明：以下脚本用于跑测门诊操作限制规则，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
操作限制：医疗支付定义的操作限制和临床专业操作相关
**********************************************************************************************/

--脚本：先创建一个操作项目的临时表
create  table 临时_计费项目 NOLOGGING as
select distinct a.机构编码, a.身份证号, a.门诊日期, a.名称, a.日期, t.药品编码 from 统计_门诊频度 a 
inner join 规则_药品限制 t on t.操作限制 is not null and regexp_instr(nvl(a.名称,'@'), t.操作限制) > 0
where a.机构编码 = 'H00000000000' and a.类别 not in ('西药费','成药费','草药费','材料费');

create index temp_jfxm on 临时_计费项目 (机构编码,身份证号,药品编码);

--*******************************************************************************************--
--脚本：用于操作限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '规则分析' and 问题类型 = '超操作限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '规则分析' 线索来源,
    '超操作限定用药' 问题类型,
    '该药品材料使用未找到' || t.操作限制 || '相关操作' 问题情形,
    '关联缺失' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' and t.操作限制 is not null
    where not exists (select 1 from 临时_计费项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号
    and upper(g.代码) like s.药品编码 || '%')
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--脚本：删除临时表
drop table 临时_计费项目 purge;

