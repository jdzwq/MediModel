/*********************************************************************************************
脚本说明：以下脚本用于分析门诊人群密度水位指标，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/


-----------------------------------------------------------------------------------------------
--脚本：月度占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
SELECT trunc(sysdate) AS 年月 FROM DUAL
WHERE 1=0;

DECLARE
    min_day DATE;
    max_day DATE;
BEGIN
    select to_char(min(门诊日期),'YYYY-MM-DD') into min_day from 模型_门诊人群;
    select to_char(max(门诊日期),'YYYY-MM-DD') into max_day from 模型_门诊人群;
    
    insert into TMP_年月
    SELECT (min_day + LEVEL - 1) AS 年月 FROM DUAL
    CONNECT BY LEVEL <= max_day - min_day + 1;
    commit;
end;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '就医治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'就医治疗日' 特征类
    ,'' 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度性别对象占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 性别对象, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 性别对象, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.性别对象 = b.性别对象 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 性别对象, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '性别治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'性别治疗日' 特征类
    ,a.性别对象 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度年龄对象占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 年龄对象, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 年龄对象, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.年龄对象 = b.年龄对象 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 年龄对象, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '年龄治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'年龄治疗日' 特征类
    ,a.年龄对象 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度持证类别占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 持证类别, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 持证类别, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.持证类别 = b.持证类别 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 持证类别, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '持证治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'持证治疗日' 特征类
    ,a.持证类别 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度参保地域占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 参保地域, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 参保地域, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.参保地域 = b.参保地域 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 参保地域, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '地域治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'地域治疗日' 特征类
    ,a.参保地域 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度病种名称占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 病种名称, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 病种名称, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.病种名称 = b.病种名称 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 病种名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '病种治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'病种治疗日' 特征类
    ,a.病种名称 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度专业名称占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 专业名称, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 专业名称, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.专业名称 = b.专业名称 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 专业名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '专业治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'专业治疗日' 特征类
    ,a.专业名称 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度门诊科室占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 门诊科室, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 门诊科室, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.门诊科室 = b.门诊科室 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 门诊科室, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,门诊科室) AS 分位
    ,就医方式
    ,门诊科室
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.门诊科室 = t.门诊科室);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,门诊科室) AS 分位
    ,就医方式
    ,门诊科室
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊科室 = b.门诊科室 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.门诊科室 = t.门诊科室);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,门诊科室) AS 分位
    ,就医方式
    ,门诊科室
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊科室 = b.门诊科室 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.门诊科室 = t.门诊科室);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '科室治疗日';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'科室治疗日' 特征类
    ,a.门诊科室 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.门诊科室 = b.门诊科室 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度门诊医生占床日
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_水位 purge;

create table TMP_水位 nologging as
SELECT distinct 就医方式, 门诊医生, 年月, 0 床日 FROM 模型_门诊人群,TMP_年月
order by 就医方式, 门诊医生, 年月;

UPDATE TMP_水位 a set 床日 = (select count(distinct 身份证号) from 模型_门诊人群 b
where a.门诊医生 = b.门诊医生 and a.年月 between b.门诊日期 and b.门诊日期);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 门诊医生, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,门诊医生) AS 分位
    ,就医方式
    ,门诊医生
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.门诊医生 = t.门诊医生);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,门诊医生) AS 分位
    ,就医方式
    ,门诊医生
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊医生 = b.门诊医生 and a.床日 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.门诊医生 = t.门诊医生);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 床日) 
    OVER (partition by 就医方式,门诊医生) AS 分位
    ,就医方式
    ,门诊医生
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊医生 = b.门诊医生 and a.床日 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.门诊医生 = t.门诊医生);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊') and 特征类 = '医生治疗日';
commit;

insert into 线索_问题特征
select distinct 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'医生治疗日' 特征类
    ,a.门诊医生 特征名
    ,a.床日 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.门诊医生 = b.门诊医生 and a.床日 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题特征 rebuild;

drop table TMP_年月 purge;
drop table TMP_分位 purge;
drop table TMP_水位 purge;

-----------------------------------------------------------------------------------------------
--脚本：遴选门诊治疗日异常病案
--说明：
-----------------------------------------------------------------------------------------------
delete from 线索_问题病案 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊')
    and 线索来源 = '水位分析' and 问题类型 = '门诊治疗日异常';
commit;

insert into 线索_问题病案
select 就医方式 就医来源
    ,'水位分析' 线索来源
    ,'门诊治疗日异常' 问题类型
    ,'在该时段中存在此对象门诊床日异常' 问题情形
    ,'' 问题次数
    ,a.机构编码
    ,a.机构名称
    ,a.门诊科室
    ,a.门诊医生
    ,a.身份证号
    ,a.人员姓名
    ,a.性别对象
    ,a.年龄对象
    ,a.险种类别
    ,a.持证类别
    ,a.参保地域
    ,a.门诊日期 + k.校正天数 门诊日期
    ,a.门诊天数
    ,a.疾病诊断
    ,a.病种名称
    ,a.专业名称
from 模型_门诊人群 a inner join 模型_门诊日期 k on a.机构编码 = k.机构编码 and a.身份证号 = k.身份证号 and to_char(a.门诊日期,'YYYY') = k.就医年度
where a.机构编码 = 'H00000000000'
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '就医治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '性别治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.性别对象 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '年龄治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.年龄对象 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '持证治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.持证类别 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '地域治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.参保地域 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '病种治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.病种名称 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '专业治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.专业名称 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '医生治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.门诊医生 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '科室治疗日'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.门诊科室 = t.特征名 and t.特征位 between a.门诊日期 and a.门诊日期
)
order by a.门诊日期;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题病案 rebuild;
