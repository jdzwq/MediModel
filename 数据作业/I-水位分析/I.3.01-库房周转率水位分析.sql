/*********************************************************************************************
脚本说明：以下脚本用于分析库房周转率水位指标，运行时应替换实际机构代码和代码
机构编码：H00000000000
机构代码：测试医院
**********************************************************************************************/


-----------------------------------------------------------------------------------------------
--脚本：季度物资周转率
--说明：周转率 = 销售金额 / 库存金额
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码, 代码, 业务期间 季度, round(sum(销售金额) / sum(库存金额),2) 周转率
from(
select a.机构编码
    ,a.代码
    ,case
        when substr(业务期间,5,2) in ('01','02','03') then substr(业务期间,1,4) || '-1'
        when substr(业务期间,5,2) in ('04','05','06') then substr(业务期间,1,4) || '-2'
        when substr(业务期间,5,2) in ('07','08','09') then substr(业务期间,1,4) || '-3'
        when substr(业务期间,5,2) in ('10','11','12') then substr(业务期间,1,4) || '-4'
    end 业务期间
    ,a.销售金额
    ,a.库存金额
from 模型_库房进销 a 
where a.机构编码 = 'H00000000000'
)
group by 机构编码, 代码, 业务期间
having sum(库存金额) > 0
order by 代码,季度;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.代码, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_库房进销 a 
where a.机构编码 = 'H00000000000' 
order by 代码;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 周转率) 
    OVER (partition by 代码) AS 分位
    ,代码
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.代码 = t.代码);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 周转率) 
    OVER (partition by 代码) AS 分位
    ,代码
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.代码 = b.代码 and a.周转率 <= b.中分位)
)t where s.代码 = t.代码);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 周转率) 
    OVER (partition by 代码) AS 分位
    ,代码
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.代码 = b.代码 and a.周转率 >= b.中分位)
)t where s.代码 = t.代码);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('库房') and 特征类 = '库房周转率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,'库房' 就医来源
    ,'' 对象来源 
    ,'库房周转率' 特征类
    ,a.代码  特征名
    ,a.周转率 特征值
    ,季度 特征位 ,'低水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.代码 = b.代码 and a.周转率 < b.高分位 - b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：季度物资消耗率
--说明：消耗率 = 销售金额 / （库存金额 - 购入金额 + 销售金额)
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码, 代码, 业务期间 季度, round(sum(销售金额) / (sum(库存金额) - sum(购入金额) + sum(销售金额)),2) 消耗率
from(
select a.机构编码
    ,a.代码
    ,case
        when substr(业务期间,5,2) in ('01','02','03') then substr(业务期间,1,4) || '-1'
        when substr(业务期间,5,2) in ('04','05','06') then substr(业务期间,1,4) || '-2'
        when substr(业务期间,5,2) in ('07','08','09') then substr(业务期间,1,4) || '-3'
        when substr(业务期间,5,2) in ('10','11','12') then substr(业务期间,1,4) || '-4'
    end 业务期间
    ,a.购入金额
    ,a.销售金额
    ,a.库存金额
from 模型_库房进销 a 
where a.机构编码 = 'H00000000000'
)
group by 机构编码, 代码, 业务期间
having (sum(库存金额) - sum(购入金额) + sum(销售金额)) > 0
order by 代码,季度;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.代码, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_库房进销 a 
where a.机构编码 = 'H00000000000' 
order by 代码;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 消耗率) 
    OVER (partition by 代码) AS 分位
    ,代码
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.代码 = t.代码);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 消耗率) 
    OVER (partition by 代码) AS 分位
    ,代码
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.代码 = b.代码 and a.消耗率 <= b.中分位)
)t where s.代码 = t.代码);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 消耗率) 
    OVER (partition by 代码) AS 分位
    ,代码
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.代码 = b.代码 and a.消耗率 >= b.中分位)
)t where s.代码 = t.代码);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('库房') and 特征类 = '库房消耗率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,'库房' 就医来源
    ,'' 对象来源 
    ,'库房消耗率' 特征类
    ,a.代码  特征名
    ,a.消耗率 特征值
    ,季度 特征位 ,'低水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.代码 = b.代码 and a.消耗率 < b.高分位 - b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题特征 rebuild;

drop table TMP_分位 purge;
drop table TMP_水位 purge;

--*******************************************************************************************--
--脚本：用于险种限定诊疗的超范围支付的线索跑量
delete from 线索_问题项目 where 机构编码 = 'H00000000000' and 就医来源 = '库房' and 项目来源 = '物资' 
    and 线索来源 = '水位分析' and 问题类型 = '库房周转率';
commit;

insert into 线索_问题项目 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select 就医来源,
    '物资' 项目来源,
    '水位分析' 线索来源,
    '库房周转率' 问题类型,
    '该物资项目周转率偏低' 问题情形,
    '运营异常' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称, 部门科室, 
    '' 医生姓名, 身份证号, 人员姓名, '' 性别, '' 年龄, '' 就医日期, '' 就医天数, '' 疾病诊断,
    类别, 代码, 名称, 规格, 单位, 单价, '' 人次, '' 天数, '' 频次, '' 剂量, 数量, 金额, 列支, 日期
from 模型_库房频度 a where 1=1
and exists(
    select 1 from 线索_问题特征 t where t.特征类 = '库房周转率' 
    and a.机构编码 = t.机构编码 and a.代码 = t.特征名 and a.业务期间 = t.特征位
)
order by 机构名称,名称,日期;
commit;
-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题项目 rebuild;
