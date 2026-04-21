/*********************************************************************************************
脚本说明：以下脚本用于分析库房品规置换水位指标，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

-----------------------------------------------------------------------------------------------
--脚本：月度库房置换率
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 属性, 业务期间 年月
from 模型_库房进销
where 机构编码 = 'H00000000000' 
order by 属性, 年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 属性, 业务期间 年月, count(distinct 代码) 品规数, 0 增量, 0 减量, 0.0 置换率
from 模型_库房进销
where 机构编码 = 'H00000000000' 
group by 属性, 业务期间
order by 属性, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 属性, 年月 FROM TMP_年月 order by 属性, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 增量 = (select count(distinct 代码) from 模型_库房进销 a 
        where 属性 = rec.属性 and 业务期间 = rec.年月
        and not exists (select 1 from 模型_库房进销 b where a.属性 = b.属性 and b.业务期间 < rec.年月 and a.代码 = b.代码))
    where 属性 = rec.属性 and 年月 = rec.年月;
    commit;
   
    update TMP_水位 set 减量 = (select count(distinct 代码) from 模型_库房进销 a 
        where 属性 = rec.属性 and 业务期间 < rec.年月
        and not exists (select 1 from 模型_库房进销 b where a.属性 = b.属性 and b.业务期间 = rec.年月 and a.代码 = b.代码))
    where 属性 = rec.属性 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 置换率 = round(增量 / (品规数 + 减量),2) * 月数;
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 属性, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 置换率) 
    OVER (partition by 属性) AS 分位
    ,属性
FROM TMP_水位 a where 1=1
)t
where s.属性 = t.属性);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 置换率) 
    OVER (partition by 属性) AS 分位
    ,属性
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.属性 = b.属性 and a.置换率 <= b.中分位)
)t
where s.属性 = t.属性);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 置换率) 
    OVER (partition by 属性) AS 分位
    ,属性
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.属性 = b.属性 and a.置换率 >= b.中分位)
)t
where s.属性 = t.属性);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('库房') and 特征类 = '库房置换率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,'库房' 就医来源 
    ,'' 对象来源 
    ,'库房置换率' 特征类
    ,a.属性 特征名
    ,a.置换率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where 1=1
and a.属性 = b.属性 and a.置换率 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征位;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题特征 rebuild;

drop table TMP_分位 purge;
drop table TMP_水位 purge;

-----------------------------------------------------------------------------------------------
--脚本：用于遴选库房置换率异常业务记录
--说明：
-----------------------------------------------------------------------------------------------
delete from 线索_问题项目 where 机构编码 = 'H00000000000' and 就医来源 = '库房' and 项目来源 = '物资' 
    and 线索来源 = '水位分析' and 问题类型 = '库房置换率';
commit;

insert into 线索_问题项目 (就医来源, 项目来源, 线索来源, 问题类型, 问题情形, 问题性质, 问题数量, 问题金额,
    机构编码, 机构名称, 科室名称, 医生姓名, 身份证号, 姓名, 性别, 年龄, 就医日期, 就医天数, 疾病诊断, 
    分类, 代码, 名称, 规格, 单位, 单价, 人次, 天数, 频次, 剂量, 数量, 医疗金额, 医保支付, 支付日期)
select 就医来源,
    '物资' 项目来源,
    '水位分析' 线索来源,
    '库房置换率' 问题类型,
    '该物资项目置换率偏高' 问题情形,
    '运营异常' 问题性质,
    数量 问题数量, 
    列支 问题金额,
    机构编码, 机构名称, 部门科室, 
    '' 医生姓名, 身份证号, 人员姓名, '' 性别, '' 年龄, '' 就医日期, '' 就医天数, '' 疾病诊断,
    属性, 代码, 名称, 规格, 单位, 单价, '' 人次, '' 天数, '' 频次, '' 剂量, 数量, 金额, 列支, 日期
from 模型_库房频度 a where 1=1
and exists(
    select * from 线索_问题特征 t where t.特征类 = '库房置换率' 
    and a.机构编码 = t.机构编码 and a.属性 = t.特征名 and a.业务期间 = t.特征位
)
order by 机构名称,名称,日期;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题病案 rebuild;

