/*********************************************************************************************
脚本说明：以下脚本用于跑测领域专项，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
药店专项：药品、材料销售
**********************************************************************************************/

--*******************************************************************************************--
--脚本：用于险种限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超险种限定范围用药';
commit;

--险种：工伤
insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超险种限定范围用药' 问题类型,
    '该药品属于工伤保险目录，不属于医保支付范围' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g
where exists (select 1 from 规则_药品限制 t where upper(g.代码) like t.药品编码 || '%' and t.险种限制 in ('工伤'))
order by 机构名称,身份证号,门诊日期,名称;
commit;

--险种：生育
insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超险种限定范围用药' 问题类型,
    '该药品属于生育保险目录，不属于医保支付范围' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g
where exists (select 1 from 规则_药品限制 t where upper(g.代码) like t.药品编码 || '%' and t.险种限制 in ('生育'))
order by 机构名称,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于机构等级限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超机构等级限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超机构等级限定用药' 问题类型,
    '该药品适用' || t.机构限制 || '机构，与当前机构等级不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' and t.机构限制 is not null 
    and decode(g.机构等级,'三级',3,'二级',2,'一级',1,0) < decode(t.机构限制,'三级',3,'二级',2,'一级',1,0)
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于就医方式限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超就医方式限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超就医方式限定用药' 问题类型,
    '该药品适用于住院治疗，不属于门诊支付范围' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g
where exists (select 1 from 规则_药品限制 t where upper(g.代码) like t.药品编码 || '%' and t.就医限制 in ('住院'))
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于专科限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超专科范围限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项'线索来源,
    '超专科范围限定用药' 问题类型,
    '该药品适用' || t.专科限制 || '，专科范围与当前科室不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' 
    and t.专科限制 is not null and regexp_instr(nvl(g.门诊科室,'@'), t.专科限制) = 0
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于性别限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超性别对象限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超性别对象限定用药' 问题类型,
    '该药品适用于女性对象与患者性别不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g where g.性别 <> '女'
and exists (select 1 from 规则_药品限制 t where upper(g.代码) like t.药品编码 || '%' and t.性别限制 in ('女性'))
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于年龄限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超年龄对象限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超年龄对象限定用药' 问题类型,
    '该药品适用于新生儿对象与患者年龄不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g where g.年龄 > 1
    and exists (select 1 from 规则_药品限制 t where upper(g.代码) like t.药品编码 || '%' and t.年龄限制 in ('新生儿'))
order by 门诊科室,身份证号,门诊日期,名称;
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超年龄对象限定用药' 问题类型,
    '该药品适用于小儿对象与患者年龄不符' 问题情形,
    '超支付范围' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g  where g.年龄 > 14
    and exists (select 1 from 规则_药品限制 t where upper(g.代码) like t.药品编码 || '%' and t.年龄限制 in ('小儿'))
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--脚本：用于适应症限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超适应症限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超适应症限定用药' 问题类型,
    '该药品适用于' || t.疾病限制 || '，与患者诊断不符' 问题情形,
    '超适应症' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' 
    and t.疾病限制 is not null and regexp_instr(nvl(g.疾病诊断,'@'), t.疾病限制) = 0
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于阶梯限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超阶梯限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超阶梯限定用药' 问题类型,
    '该药品属于' || t.阶梯限制 || '，门诊使用需核实适应症' 问题情形,
    '超适应症' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' and t.阶梯限制 in ('二线','三线')
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于用量限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超用量限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超用量限定用药' 问题类型,
    '该药品当日开具剂量' || g.剂量 || '，超过' || t.用量限制 || '日限剂量' 问题情形,
    '过度诊疗' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' 
    and t.用量限制 is not null and g.剂量 > t.用量限制
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于额度限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超额度限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超额度限定用药' 问题类型,
    '该药品总额' || g.金额 || '元，超过额度限定' || t.额度限制 || '元' 问题情形,
    '超标准支付' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' 
    and t.额度限制 is not null  and g.金额 > t.额度限制
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于疗程限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超疗程限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超疗程限定用药' 问题类型,
    '该药品开具' || g.天数 || '天，超过疗程限定' || t.疗程限制 || '天' 问题情形,
    '过度诊疗' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,门诊科室, 门诊医生, 身份证号, 姓名, 性别, 年龄, 门诊日期, 门诊天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_门诊药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' and t.疗程限制 is not null  and g.天数 > t.疗程限制
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于药品的超支付价格的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '门诊' and 项目来源 = '药品' 
    and 线索来源 = '药店专项' and 问题类型 = '超加价标准药品';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 分类, 代码,
    名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '门诊' 就医来源,
    '药品' 项目来源,
    '药店专项' 线索来源,
    '超加价标准药品' 问题类型,
    '该药品购入价' || t.购入均价 || '，销售价' || g.单价 || '加成比超过1.5倍' 问题情形,
    '超标准支付' 问题性质,
    g.数量 问题数量, 
    g.列支 问题金额,
    g.机构编码, g.机构名称, g.门诊科室, g.门诊医生, g.身份证号, g.姓名, g.性别, g.年龄, g.门诊日期, g.门诊天数, g.疾病诊断,
    g.类别, g.代码, g.名称, g.规格, g.单位, g.单价, g.人次, g.天数, g.频次, g.剂量, g.数量, g.金额, g.列支, g.日期
from 临时_门诊药品 g  inner join 统计_库房进销 t on g.机构编码 = t.机构编码 and g.代码 = t.国标 and g.单价 > t.购入均价 * 1.5
order by 门诊科室,身份证号,门诊日期,名称;
commit;
--*******************************************************************************************--

