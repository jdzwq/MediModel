/*********************************************************************************************
脚本说明：以下脚本用于分析门诊人群密度水位指标，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

-----------------------------------------------------------------------------------------------
--脚本：筛选高水位人次比
--说明：
-----------------------------------------------------------------------------------------------
--月度就医人次比
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM')
order by 就医方式,年月;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct 就医方式, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '就医人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'就医人次比' 特征类
    ,''  特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选性别对象高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--性别对象月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,性别对象
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),性别对象
order by 机构编码,性别对象,年月;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct 就医方式, 性别对象, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '性别人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'性别人次比' 特征类
    ,a.性别对象 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选年龄对象高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--年龄对象月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,年龄对象
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),年龄对象
order by 机构编码,年龄对象,年月;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct 就医方式, 年龄对象, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '年龄人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'年龄人次比' 特征类
    ,a.年龄对象 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选持证对象高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--持证类别月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,持证类别
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),持证类别
order by 机构编码,持证类别,年月;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct 就医方式, 持证类别, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '持证人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'持证人次比' 特征类
    ,a.持证类别 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选地域对象高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--地域月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,参保地域
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),参保地域
order by 机构编码,参保地域,年月;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct 就医方式, 参保地域, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '地域人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'地域人次比' 特征类
    ,a.参保地域 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选专业对象高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--专业对象月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,专业名称
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),专业名称
order by 机构编码,专业名称,年月;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct 就医方式, 专业名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and 就医方式 in ('门诊','购药')
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '专业人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'专业人次比' 特征类
    ,a.专业名称 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选病种高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--病种对象月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,病种名称
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),病种名称
order by 机构编码,病种名称,年月;

drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 病种名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '病种人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'病种人次比' 特征类
    ,a.病种名称 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选科室高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--病种对象月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,门诊科室
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),门诊科室
order by 机构编码,门诊科室,年月;

drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 门诊科室, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,门诊科室) AS 分位
    ,就医方式
    ,门诊科室
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.门诊科室 = t.门诊科室);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,门诊科室) AS 分位
    ,就医方式
    ,门诊科室
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊科室 = b.门诊科室 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.门诊科室 = t.门诊科室);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,门诊科室) AS 分位
    ,就医方式
    ,门诊科室
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊科室 = b.门诊科室 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.门诊科室 = t.门诊科室);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '科室人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'科室人次比' 特征类
    ,a.门诊科室 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.门诊科室 = b.门诊科室 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：筛选医生高水位就医人次比
--说明：
-----------------------------------------------------------------------------------------------
--病种对象月度就医人次
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select 机构编码
    ,就医方式
    ,to_char(门诊日期,'YYYYMM') 年月
    ,门诊医生
    ,round(count(distinct 身份证号 || to_char(门诊日期,'YYYYMMDD')) / count(distinct 身份证号),2) 人次比
from 模型_门诊人群
where 机构编码 = 'H00000000000' 
group by 机构编码,就医方式,to_char(门诊日期,'YYYYMM'),门诊医生
order by 机构编码,门诊医生,年月;

drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 门诊医生, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_门诊人群;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,门诊医生) AS 分位
    ,就医方式
    ,门诊医生
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.门诊医生 = t.门诊医生);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,门诊医生) AS 分位
    ,就医方式
    ,门诊医生
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊医生 = b.门诊医生 and a.人次比 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.门诊医生 = t.门诊医生);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 人次比) 
    OVER (partition by 就医方式,门诊医生) AS 分位
    ,就医方式
    ,门诊医生
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.门诊医生 = b.门诊医生 and a.人次比 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.门诊医生 = t.门诊医生);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药') and 特征类 = '医生人次比';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'医生人次比' 特征类
    ,a.门诊医生 特征名
    ,a.人次比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.门诊医生 = b.门诊医生 and a.人次比 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题特征 rebuild;

drop table TMP_分位 purge;
drop table TMP_水位 purge;

-----------------------------------------------------------------------------------------------
--脚本：遴选就医人次比异常病案
--说明：
-----------------------------------------------------------------------------------------------
delete from 线索_问题病案 where 机构编码 = 'H00000000000' and 就医来源 in ('门诊','购药')
    and 线索来源 = '水位分析' and 问题类型 = '就医人次比异常';
commit;

insert into 线索_问题病案
select 就医方式 就医来源
    ,'水位分析' 线索来源
    ,'就医人次比异常' 问题类型
    ,'在该时段中存在此对象就医人次比异常' 问题情形
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
    select 1 from 线索_问题特征 t where 特征类 = '就医人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and to_char(门诊日期,'YYYYMM') = t.特征位
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '性别人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.性别对象 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '年龄人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.年龄对象 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '持证人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.持证类别 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '地域人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.参保地域 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '病种人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.病种名称 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '专业人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.专业名称 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '医生人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.门诊医生 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '科室人次比'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.门诊科室 = t.特征名 and to_char(门诊日期,'YYYYMM') = t.特征位 
)
order by a.门诊日期;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题病案 rebuild;

