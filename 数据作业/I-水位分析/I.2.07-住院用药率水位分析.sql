/*********************************************************************************************
脚本说明：以下脚本用于分析住院药品使用水位指标，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/


-----------------------------------------------------------------------------------------------
--脚本：月度就医用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.身份证号),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),b.项目名称
order by 就医方式,年月,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,项目名称) AS 分位
    ,就医方式
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,项目名称) AS 分位
    ,就医方式
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,项目名称) AS 分位
    ,就医方式
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '就医用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'就医用药率' 特征类
    ,''  特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度性别用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.性别对象
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.性别对象),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.性别对象,b.项目名称
order by 就医方式,年月,性别对象,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.性别对象, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,性别对象,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,性别对象,项目名称) AS 分位
    ,就医方式
    ,性别对象
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,性别对象,项目名称) AS 分位
    ,就医方式
    ,性别对象
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,性别对象,项目名称) AS 分位
    ,就医方式
    ,性别对象
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '性别用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'性别用药率' 特征类
    ,a.性别对象 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度年龄用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.年龄对象
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.年龄对象),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.年龄对象,b.项目名称
order by 就医方式,年月,年龄对象,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.年龄对象, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,年龄对象,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,年龄对象,项目名称) AS 分位
    ,就医方式
    ,年龄对象
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,年龄对象,项目名称) AS 分位
    ,就医方式
    ,年龄对象
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,年龄对象,项目名称) AS 分位
    ,就医方式
    ,年龄对象
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '年龄用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'年龄用药率' 特征类
    ,a.年龄对象 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度持证用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.持证类别
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.持证类别),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.持证类别,b.项目名称
having count(distinct a.持证类别) > 0
order by 就医方式,年月,持证类别,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.持证类别, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,持证类别,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,持证类别,项目名称) AS 分位
    ,就医方式
    ,持证类别
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,持证类别,项目名称) AS 分位
    ,就医方式
    ,持证类别
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,持证类别,项目名称) AS 分位
    ,就医方式
    ,持证类别
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '持证用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'持证用药率' 特征类
    ,a.持证类别 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度地域用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.参保地域
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.参保地域),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.参保地域,b.项目名称
having count(distinct a.参保地域) > 0
order by 就医方式,年月,参保地域,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.参保地域, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,参保地域,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,参保地域,项目名称) AS 分位
    ,就医方式
    ,参保地域
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,参保地域,项目名称) AS 分位
    ,就医方式
    ,参保地域
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,参保地域,项目名称) AS 分位
    ,就医方式
    ,参保地域
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '地域用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'地域用药率' 特征类
    ,a.参保地域 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度病种用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.病种名称
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.病种名称),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.病种名称,b.项目名称
having count(distinct a.病种名称) > 0
order by 就医方式,年月,病种名称,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.病种名称, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,病种名称,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,病种名称,项目名称) AS 分位
    ,就医方式
    ,病种名称
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,病种名称,项目名称) AS 分位
    ,就医方式
    ,病种名称
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,病种名称,项目名称) AS 分位
    ,就医方式
    ,病种名称
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '病种用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'病种用药率' 特征类
    ,a.病种名称 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度病种用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.专业名称
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.专业名称),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.专业名称,b.项目名称
having count(distinct a.专业名称) > 0
order by 就医方式,年月,专业名称,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.专业名称, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,专业名称,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,专业名称,项目名称) AS 分位
    ,就医方式
    ,专业名称
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,专业名称,项目名称) AS 分位
    ,就医方式
    ,专业名称
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,专业名称,项目名称) AS 分位
    ,就医方式
    ,专业名称
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '专业用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'专业用药率' 特征类
    ,a.专业名称 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度医生用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.住院医生
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.住院医生),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.住院医生,b.项目名称
having count(distinct a.住院医生) > 0
order by 就医方式,年月,住院医生,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.住院医生, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,住院医生,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,住院医生,项目名称) AS 分位
    ,就医方式
    ,住院医生
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.住院医生 = t.住院医生 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,住院医生,项目名称) AS 分位
    ,就医方式
    ,住院医生
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院医生 = b.住院医生 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.住院医生 = t.住院医生 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,住院医生,项目名称) AS 分位
    ,就医方式
    ,住院医生
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院医生 = b.住院医生 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.住院医生 = t.住院医生 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '医生用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'医生用药率' 特征类
    ,a.住院医生 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.住院医生 = b.住院医生 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度科室用药率
--说明：
-----------------------------------------------------------------------------------------------
--汇总水位值
drop table TMP_水位 purge;
create table TMP_水位 nologging as
select a.机构编码
    ,a.就医方式
    ,to_char(a.住院日期,'YYYYMM') 年月
    ,a.住院科室
    ,b.项目名称
    ,round(sum(b.项目次数) / count(distinct a.住院科室),2) 用药率
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式  and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费') 
group by a.机构编码,a.就医方式,to_char(a.住院日期,'YYYYMM'),a.住院科室,b.项目名称
having count(distinct a.住院科室) > 0
order by 就医方式,年月,住院科室,项目名称;

--计算四分位
drop table TMP_分位 purge;
create table TMP_分位 nologging as
select distinct a.就医方式, a.住院科室, b.项目名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from 模型_住院人群 a inner join 模型_住院项目 b on a.机构编码 = b.机构编码 and a.就医方式 = b.就医方式 and a.身份证号 = b.身份证号 and a.住院日期 = b.住院日期
where a.机构编码 = 'H00000000000' and b.项目类别 in ('西药费','成药费')
order by 就医方式,住院科室,项目名称;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,住院科室,项目名称) AS 分位
    ,就医方式
    ,住院科室
    ,项目名称
FROM TMP_水位 where 机构编码 = 'H00000000000'
)t where s.就医方式 = t.就医方式 and s.住院科室 = t.住院科室 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,住院科室,项目名称) AS 分位
    ,就医方式
    ,住院科室
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院科室 = b.住院科室 and a.项目名称 = b.项目名称 and a.用药率 <= b.中分位)
)t where s.就医方式 = t.就医方式 and s.住院科室 = t.住院科室 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 用药率) 
    OVER (partition by 就医方式,住院科室,项目名称) AS 分位
    ,就医方式
    ,住院科室
    ,项目名称
FROM TMP_水位 a where 机构编码 = 'H00000000000'
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院科室 = b.住院科室 and a.项目名称 = b.项目名称 and a.用药率 >= b.中分位)
)t where s.就医方式 = t.就医方式 and s.住院科室 = t.住院科室 and s.项目名称 = t.项目名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

--筛选高水位
delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '科室用药率';
commit;

insert into 线索_问题特征
select a.机构编码
    ,a.就医方式 就医来源 
    ,a.项目名称 对象来源
    ,'科室用药率' 特征类
    ,a.住院科室 特征名
    ,a.用药率 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where a.就医方式 = b.就医方式 and a.住院科室 = b.住院科室 and a.项目名称 = b.项目名称 and a.用药率 > b.低分位 + b.分位矩 * 1.5
order by 特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题特征 rebuild;

drop table TMP_分位 purge;
drop table TMP_水位 purge;

-----------------------------------------------------------------------------------------------
--脚本：遴选药品用药率异常病案
--说明：
-----------------------------------------------------------------------------------------------
delete from 线索_问题病案 where 机构编码 = 'H00000000000' and 就医来源 in ('住院')
    and 线索来源 = '水位分析' and 问题类型 = '药品用药率异常';
commit;

insert into 线索_问题病案
select 就医方式 就医来源
    ,'水位分析' 线索来源
    ,'药品用药率异常' 问题类型
    ,'在该时段中存在此药品用药率异常' 问题情形
    ,'' 问题次数
    ,a.机构编码
    ,a.机构名称
    ,a.住院科室
    ,a.住院医生
    ,a.身份证号
    ,a.人员姓名
    ,a.性别对象
    ,a.年龄对象
    ,a.险种类别
    ,a.持证类别
    ,a.参保地域
    ,a.住院日期 + k.校正天数 住院日期
    ,a.住院天数
    ,a.疾病诊断
    ,a.病种名称
    ,a.专业名称
from 模型_住院人群 a inner join 模型_住院日期 k on a.机构编码 = k.机构编码 and a.身份证号 = k.身份证号 and to_char(a.住院日期,'YYYY') = k.就医年度
where a.机构编码 = 'H00000000000'
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '就医用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and to_char(住院日期,'YYYYMM') = t.特征位
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '性别用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.性别对象 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '年龄用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.年龄对象 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '持证用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.持证类别 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '地域用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.参保地域 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '病种用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.病种名称 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '专业用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.专业名称 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '医生用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.住院医生 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '科室用药率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.住院科室 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
order by a.住院日期;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题病案 rebuild;
