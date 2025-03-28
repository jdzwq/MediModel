/*********************************************************************************************
脚本说明：以下脚本用于跑测领域专项，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
康复理疗专项：康复治疗、物理治疗
**********************************************************************************************/

-----------------------------------------------------------------------------------------------
--脚本：跑测超机构范围的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超机构等级限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超机构等级限定诊疗' 问题类型,
    '该诊疗适用' || t.机构限制 || '机构，与当前机构等级不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗限制 t on upper(g.代码) like t.诊疗编码 || '%' and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
    and t.机构限制 is not null  and decode(g.机构等级,'三级',3,'二级',2,'一级',1,0) < decode(t.机构限制,'三级',3,'二级',2,'一级',1,0)
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测超就医方式的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超就医方式限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超就医方式限定诊疗' 问题类型,
    '该诊疗适用于住院治疗，不属于门诊支付范围' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
where exists (select 1 from 规则_诊疗限制 t where upper(g.代码) like t.诊疗编码 || '%' and t.就医限制 in ('住院') 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 )
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测超性别对象的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超性别对象限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超性别对象限定诊疗' 问题类型,
    '该诊疗适用于女性对象与患者性别不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g where g.性别 <> '女' 
    and exists (select 1 from 规则_诊疗限制 t where upper(g.代码) like t.诊疗编码 || '%' 
    and t.性别限制 in ('女性') and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 )
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测超年龄对象的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超年龄对象限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超年龄对象限定诊疗' 问题类型,
    '该诊疗适用于新生儿对象与患者年龄不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g where g.年龄 > 1
    and exists (select 1 from 规则_诊疗限制 t where upper(g.代码) like t.诊疗编码 || '%' 
    and t.年龄限制 in ('新生儿') and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 )
order by 门诊科室,身份证号,门诊日期,名称;
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超年龄对象限定诊疗' 问题类型,
    '该诊疗适用于小儿对象与患者年龄不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g where g.年龄 > 14
    and exists (select 1 from 规则_诊疗限制 t where upper(g.代码) like t.诊疗编码 || '%' and t.年龄限制 in ('小儿') 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 )
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测超适应症的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超适应症限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超适应症限定诊疗' 问题类型,
    '该诊疗适用于' || t.疾病限制 || '，与患者诊断不符' 问题情形,
    '超适应症' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g 
inner join 规则_诊疗限制 t on upper(g.代码) like t.诊疗编码 || '%'  and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
    and t.疾病限制 is not null and regexp_instr(nvl(g.疾病诊断,'@'), t.疾病限制) = 0
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测超人次限定的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超人次限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超人次限定诊疗' 问题类型,
    '该诊疗总人次' || g.人次 || '，超过' || t.人次限制 || '人次限定' 问题情形,
    '超标准支付' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室,门诊医生,身份证号, 姓名, 性别, 年龄,门诊日期,门诊天数,疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支,门诊日期 支付日期
from(
    select 机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
        类别, 代码, 名称, 规格, 单位, 单价, 
        sum(人次) 人次, sum(天数) 天数, sum(频次) 频次, sum(剂量) 剂量, sum(数量) 数量, sum(金额) 金额, sum(列支) 列支
    from 临时_门诊诊疗
    group by 机构编码, 机构名称, 门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,类别, 代码,名称, 规格, 单位, 单价
) g inner join 规则_诊疗限制 t on upper(g.代码) like t.诊疗编码 || '%' and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
    and t.人次限制 is not null and g.人次 > t.人次限制
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测超频次限定的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超频次限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '超频次限定诊疗' 问题类型,
    '该诊疗当日次数' || g.频次 || '，超过' || t.次数限制 || '次数限定' 问题情形,
    '超标准支付' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗限制 t on upper(g.代码) like t.诊疗编码 || '%' and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
    and t.次数限制 is not null and g.频次 > t.次数限制
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测重复计费的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '重复计费诊疗';
commit;

--脚本：创建操作项目临时表
create  table 临时_康复理疗项目 as 
select a.机构编码,a.名称,a.身份证号,a.日期,sum(a.人次) 人次,b.子项编码,b.子项名称
from 统计_门诊频度 a inner join 规则_诊疗重复 b on regexp_instr(b.领域标识,'(康复治疗|物理治疗)') > 0 
and upper(a.代码) like b.主项编码 || '%' and a.名称 like '%' || b.主项名称 || '%'
where a.机构编码 = 'H00000000000' and a.类别 not in ('西药费','成药费','草药费','材料费')
group by a.机构编码,a.名称,a.身份证号,a.日期,b.子项编码,b.子项名称
having sum(a.人次) > 0;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '重复计费诊疗' 问题类型,
    '该项目疑似' || t.主项名称 || '的内容包含，需核实是否属于重复计费' 问题情形,
    '重复计费' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗重复 t on (regexp_instr(upper(g.代码), t.子项编码) > 0 or regexp_instr(g.名称, t.子项名称) > 0) 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
where exists (select 1 from 临时_康复理疗项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号 and g.日期 = s.日期 and g.名称 <> s.名称
    and (regexp_instr(upper(g.代码), s.子项编码) > 0 or regexp_instr(g.名称, s.子项名称) > 0))
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--删除临时表
drop table 临时_康复理疗项目 purge;
-----------------------------------------------------------------------------------------------

--脚本：跑测关联缺失的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '诊疗关联缺失';
commit;

--脚本：创建操作项目临时表
create  table 临时_康复理疗项目 as 
select distinct a.机构编码,a.身份证号,a.日期,b.主项编码 诊疗编码,b.主项名称 诊疗名称
from 统计_门诊频度 a, 规则_诊疗关联 b 
where a.类别 not in ('西药费','成药费','草药费','材料费') and regexp_instr(b.领域标识,'(康复治疗|物理治疗)') > 0
and (regexp_instr(upper(a.代码),b.关联编码) > 0 or regexp_instr(a.名称, b.关联名称) > 0);

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '诊疗关联缺失' 问题类型,
    '该诊疗计费缺失' || t.主项名称 || '主项目' 问题情形,
    '关联缺失' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗关联 t on upper(g.代码) like t.主项编码 || '%' and g.名称 like '%' || t.主项名称 || '%' 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
where not exists (select 1 from 临时_康复理疗项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号 and g.日期 = s.日期 
    and upper(g.代码) like s.诊疗编码 || '%' and regexp_instr(g.名称,s.诊疗名称) > 0)
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--删除临时表
drop table 临时_康复理疗项目 purge;

--脚本：跑测关联缺失的材料项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '材料' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '诊疗关联缺失';
commit;

--脚本：创建操作项目临时表
create  table 临时_康复理疗项目 as 
select distinct a.机构编码,a.身份证号,a.日期,b.主项编码 材料编码,b.主项名称 材料名称
from 统计_门诊频度 a, 规则_材料关联 b 
where a.类别 not in ('西药费','成药费','草药费','材料费') and regexp_instr(b.领域标识,'(康复治疗|物理治疗)') > 0
and (regexp_instr(upper(a.代码),b.关联编码) > 0 or regexp_instr(a.名称, b.关联名称) > 0);

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '材料' 项目来源,
    '康复理疗专项' 线索来源,
    '材料关联缺失' 问题类型,
    '该材料计费缺失' || t.关联名称 || '操作项目' 问题情形,
    '关联缺失' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊材料 g
inner join 规则_材料关联 t on upper(g.代码) like t.主项编码 || '%' and g.名称 like '%' || t.主项名称 || '%' 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
where not exists (select 1 from 临时_康复理疗项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号 and g.日期 = s.日期 
    and upper(g.代码) like s.材料编码 || '%' and g.名称 like '%' || s.材料名称 || '%')
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--删除临时表
drop table 临时_康复理疗项目 purge;
-----------------------------------------------------------------------------------------------

--脚本：跑测串换项目的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '串换诊疗项目';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '串换诊疗项目' 问题类型,
    '该诊疗项目疑似串换' || t.小项名称 || '，需进行核实' 问题情形,
    '串换项目' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗串换 t on upper(g.代码) like t.主项编码 || '%' and g.名称 like '%' || t.主项名称 || '%' 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--脚本：跑测串换项目的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '材料' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '串换材料项目';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '材料' 项目来源,
    '康复理疗专项' 线索来源,
    '串换材料项目' 问题类型,
    '该材料项目疑似串换' || t.小项名称 || '，需进行核实' 问题情形,
    '串换项目' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊材料 g
inner join 规则_材料串换 t on upper(g.代码) like t.主项编码 || '%' and g.名称 like '%' || t.主项名称 || '%' 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测虚记项目的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '虚记诊疗项目';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '虚记诊疗项目' 问题类型,
    '该诊疗项目疑似虚记，需进行核实' 问题情形,
    '虚记项目' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗虚记 t on upper(g.代码) like t.主项编码 || '%' and g.名称 like '%' || t.主项名称 || '%' 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
order by 门诊科室,身份证号,门诊日期,名称;
commit;
-----------------------------------------------------------------------------------------------

--脚本：跑测分解项目的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '诊疗' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '分解计费诊疗';
commit;

--脚本：创建临时表
create  table 临时_康复理疗项目 as 
select a.机构编码,a.名称,a.身份证号,a.日期,sum(a.人次) 人次,b.分项编码,b.分项名称
from 统计_门诊频度 a inner join 规则_诊疗分解 b on regexp_instr(b.领域标识,'(康复治疗|物理治疗)') > 0
and regexp_instr(upper(a.代码),b.分项编码) > 0 and regexp_instr(a.名称,b.分项名称) > 0
where a.机构编码 = 'H00000000000' and a.类别 not in ('西药费','成药费','草药费','材料费')
group by a.机构编码,a.名称,a.身份证号,a.日期,b.分项编码,b.分项名称
having sum(a.人次) > 1;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '诊疗' 项目来源,
    '康复理疗专项' 线索来源,
    '分解计费诊疗' 问题类型,
    '该项目疑似' || t.主项名称 || '的分项内容，需核实是否属于分解计费' 问题情形,
    '分解计费' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊诊疗 g
inner join 规则_诊疗分解 t on regexp_instr(g.名称, t.分项名称) > 0 and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
where exists (select 1 from 临时_康复理疗项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号 and g.日期 = s.日期 and g.名称 = s.名称)
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--删除临时表
drop table 临时_康复理疗项目 purge;

--脚本：跑测分解项目的康复理疗项目
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '材料' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '分解计费材料';
commit;

--脚本：创建临时表
create  table 临时_康复理疗项目 as 
select a.机构编码,a.名称,a.身份证号,a.日期,sum(a.人次) 人次,b.分项编码,b.分项名称
from 统计_门诊频度 a inner join 规则_材料分解 b on regexp_instr(b.领域标识,'(康复治疗|物理治疗)') > 0
and regexp_instr(upper(a.代码),b.分项编码) > 0 and regexp_instr(a.名称,b.分项名称) > 0
where a.机构编码 = 'H00000000000' and a.类别 in ('材料费')
group by a.机构编码,a.名称,a.身份证号,a.日期,b.分项编码,b.分项名称
having sum(a.人次) > 1;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '材料' 项目来源,
    '康复理疗专项' 线索来源,
    '分解计费材料' 问题类型,
    '该项目疑似' || t.主项名称 || '的分项内容，需核实是否属于分解计费' 问题情形,
    '分解计费' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊材料 g
inner join 规则_材料分解 t on regexp_instr(g.名称, t.分项名称) > 0 and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0
where exists (select 1 from 临时_康复理疗项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号 and g.日期 = s.日期 and g.名称 = s.名称)
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--删除临时表
drop table 临时_康复理疗项目 purge;
-----------------------------------------------------------------------------------------------

--*******************************************************************************************--
--脚本：跑测操作项目的康复理疗药品
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '康复理疗专项' and 问题类型 = '超操作限定用药';
commit;

--创建临时表
create  table 临时_康复理疗项目 as 
select distinct a.机构编码, a.身份证号, a.门诊日期, a.名称, a.日期, t.药品编码 from 统计_门诊频度 a 
inner join 规则_药品限制 t on regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0
    and t.操作限制 is not null and regexp_instr(nvl(a.名称,'@'), t.操作限制) > 0
where a.机构编码 = 'H00000000000' and a.类别 not in ('西药费','成药费','草药费','材料费'); 

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '康复理疗专项' 线索来源,
    '超操作限定用药' 问题类型,
    '该药品材料使用未找到' || t.操作限制 || '相关操作' 问题情形,
    '关联缺失' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g 
inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' and t.操作限制 is not null 
    and regexp_instr(t.领域标识,'(康复治疗|物理治疗)') > 0 
where not exists (select 1 from 临时_康复理疗项目 s where g.机构编码 = s.机构编码 and g.身份证号 = s.身份证号
    and upper(g.代码) like s.药品编码 || '%')
order by 门诊科室,身份证号,门诊日期,名称;
commit;

--删除临时表
drop table 临时_康复理疗项目 purge;
-----------------------------------------------------------------------------------------------
