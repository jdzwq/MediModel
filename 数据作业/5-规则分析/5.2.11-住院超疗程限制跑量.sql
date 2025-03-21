/*********************************************************************************************
脚本说明：以下脚本用于跑测住院疗程限制规则，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
疗程限制：疗程限制指的是一次疗程的最长天数，例如注射剂3天、口服剂1周、慢性疾病1月，中医治疗、康复类20天
**********************************************************************************************/
 
--*******************************************************************************************--
--脚本：用于疗程限定药品的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '住院' and 项目来源 = '药品' 
    and 线索来源 = '规则分析' and 问题类型 = '超疗程限定用药';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '住院' 就医来源,
    '药品' 项目来源,
    '规则分析' 线索来源,
    '超疗程限定用药' 问题类型,
    '该药品开具' || g.天数 || '天，超过疗程限定' || t.疗程限制 || '天' 问题情形,
    '过度诊疗' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称,住院科室, 住院医生, 身份证号, 姓名, 性别, 年龄, 住院日期, 住院天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_住院药品 g inner join 规则_药品限制 t on upper(g.代码) like t.药品编码 || '%' and t.疗程限制 is not null  and g.天数 > t.疗程限制
order by 住院科室,身份证号,住院日期,名称;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：用于疗程限定诊疗的超范围支付的线索跑量
delete from 应用_问题线索 where 机构编码 = 'H00000000000' and 就医来源 = '住院' and 项目来源 = '诊疗' 
    and 线索来源 = '规则分析' and 问题类型 = '超疗程限定诊疗';
commit;

insert into 应用_问题线索 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select '住院' 就医来源,
    '诊疗' 项目来源,
    '规则分析' 线索来源,
    '超疗程限定用药' 问题类型,
    '该诊疗开具' || g.天数 || '天，超过疗程限定' || t.疗程限制 || '天' 问题情形,
    '过度诊疗' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称, 住院科室, 住院医生, 身份证号, 姓名, 性别, 年龄, 住院日期, 住院天数, 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 金额, 列支, 日期
from 临时_住院诊疗 g inner join 规则_诊疗限制 t on upper(g.代码) like t.诊疗编码 || '%' 
    and t.疗程限制 is not null  and g.天数 > t.疗程限制
order by 住院科室,身份证号,住院日期,名称;
commit;
--*******************************************************************************************--

