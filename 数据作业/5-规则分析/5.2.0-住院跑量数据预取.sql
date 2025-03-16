/*********************************************************************************************
脚本说明：以下脚本用于临时住院运行表以便加快规则跑测，运行时应替换实际省别、目录版本、机构代码和名称
所属省别：某省、某版本
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

--脚本：为规则跑量预先创建临时表
create table 临时_住院药品 NOLOGGING as
select a.机构编码, a.机构名称, b.住院科室, b.住院医生, b.身份证号, b.姓名, b.性别, b.年龄, b.住院日期, b.住院天数, b.疾病诊断,
    a.类别, a.代码,a.名称, a.规格, a.单位, a.单价, 
    sum(a.人次) 人次, sum(a.天数) 天数, sum(a.频次) 频次, sum(a.剂量) 剂量, sum(a.数量) 数量, sum(a.金额) 金额, sum(a.列支) 列支,
    a.日期, b.机构等级
from 统计_住院频度 a inner join 统计_住院诊次 b on a.机构编码 = b.机构编码 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and a.类别 in ('西药费','成药费')
group by a.机构编码, a.机构名称, b.住院科室, b.住院医生, b.身份证号, b.姓名, b.性别, b.年龄, b.住院日期, b.住院天数, b.疾病诊断,
    a.类别, a.代码,a.名称, a.规格, a.单位, a.单价, a.日期, b.机构等级
order by a.代码;

create index tmp_idx_zyyp_zc on 临时_住院药品 (机构编码,身份证号,日期);
create index tmp_idx_zyyp_pd on 临时_住院药品 (代码,名称);

create table 临时_住院材料 NOLOGGING as
select a.机构编码, a.机构名称, b.住院科室, b.住院医生, b.身份证号, b.姓名, b.性别, b.年龄, b.住院日期, b.住院天数, b.疾病诊断,
    a.类别, a.代码,a.名称, a.规格, a.单位, a.单价, 
    sum(a.人次) 人次, sum(a.天数) 天数, sum(a.频次) 频次, sum(a.剂量) 剂量, sum(a.数量) 数量, sum(a.金额) 金额, sum(a.列支) 列支,
    a.日期, b.机构等级
from 统计_住院频度 a inner join 统计_住院诊次 b on a.机构编码 = b.机构编码 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and a.类别 in ('材料费')
group by a.机构编码, a.机构名称, b.住院科室, b.住院医生, b.身份证号, b.姓名, b.性别, b.年龄, b.住院日期, b.住院天数, b.疾病诊断,
    a.类别, a.代码,a.名称, a.规格, a.单位, a.单价, a.日期, b.机构等级
order by a.代码;

create index tmp_idx_zycl_zc on 临时_住院材料 (机构编码,身份证号,日期);
create index tmp_idx_zycl_pd on 临时_住院材料 (代码,名称);

create table 临时_住院诊疗 NOLOGGING as
select a.机构编码, a.机构名称, b.住院科室, b.住院医生, b.身份证号, b.姓名, b.性别, b.年龄, b.住院日期, b.住院天数, b.疾病诊断,
    a.类别, a.代码,a.名称, a.规格, a.单位, a.单价,
    sum(a.人次) 人次, sum(a.天数) 天数, sum(a.频次) 频次, sum(a.剂量) 剂量, sum(a.数量) 数量, sum(a.金额) 金额, sum(a.列支) 列支,
     a.日期, b.机构等级
from 统计_住院频度 a inner join 统计_住院诊次 b on a.机构编码 = b.机构编码 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and a.类别 not in ('西药费','成药费','草药费','材料费')
group by a.机构编码, a.机构名称, b.住院科室, b.住院医生, b.身份证号, b.姓名, b.性别, b.年龄, b.住院日期, b.住院天数, b.疾病诊断,
    a.类别, a.代码,a.名称, a.规格, a.单位, a.单价, a.日期, b.机构等级
order by a.代码;

create index tmp_idx_zyzl_zc on 临时_住院诊疗 (机构编码,身份证号);
create index tmp_idx_zyzl_pd on 临时_住院诊疗 (代码,名称);

--脚本：规则跑量完成后删除临时表
drop table 临时_住院药品 purge;
drop table 临时_住院材料 purge;
drop table 临时_住院诊疗 purge;
