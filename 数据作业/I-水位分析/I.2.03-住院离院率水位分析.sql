/*********************************************************************************************
脚本说明：以下脚本用于分析住院人群流动水位指标，运行时应替换实际机构代码和名称
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

-----------------------------------------------------------------------------------------------
--脚本：月度出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 就医方式,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, to_char(住院日期,'YYYYMM') 
order by 就医方式,年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 年月 FROM TMP_年月 order by 就医方式, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式) AS 分位
    ,就医方式
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '就医离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'就医离院率' 特征类
    ,'' 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度性别对象出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 性别对象, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 性别对象,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 性别对象, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 性别对象, to_char(住院日期,'YYYYMM') 
order by 就医方式, 性别对象, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 性别对象, 年月 FROM TMP_年月 order by 就医方式, 性别对象, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 性别对象 = rec.性别对象 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 性别对象 = rec.性别对象 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 性别对象, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 性别对象) AS 分位
    ,就医方式
    ,性别对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.性别对象 = t.性别对象);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '性别离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'性别离院率' 特征类
    ,a.性别对象 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.性别对象 = b.性别对象 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度年龄对象出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 年龄对象, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 年龄对象,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 年龄对象, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 年龄对象, to_char(住院日期,'YYYYMM') 
order by 就医方式, 年龄对象, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 年龄对象, 年月 FROM TMP_年月 order by 就医方式, 年龄对象, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 年龄对象 = rec.年龄对象 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 年龄对象 = rec.年龄对象 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 年龄对象, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 年龄对象) AS 分位
    ,就医方式
    ,年龄对象
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.年龄对象 = t.年龄对象);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '年龄离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'年龄离院率' 特征类
    ,a.年龄对象 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.年龄对象 = b.年龄对象 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度持证类别出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 持证类别, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 持证类别,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 持证类别, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 持证类别, to_char(住院日期,'YYYYMM') 
order by 就医方式, 持证类别, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 持证类别, 年月 FROM TMP_年月 order by 就医方式, 持证类别, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 持证类别 = rec.持证类别 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 持证类别 = rec.持证类别 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 持证类别, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 持证类别) AS 分位
    ,就医方式
    ,持证类别
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.持证类别 = t.持证类别);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '持证离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'持证离院率' 特征类
    ,a.持证类别 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.持证类别 = b.持证类别 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度参保地域出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 参保地域, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 参保地域,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 参保地域, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 参保地域, to_char(住院日期,'YYYYMM') 
order by 就医方式, 参保地域, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 参保地域, 年月 FROM TMP_年月 order by 就医方式, 参保地域, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 参保地域 = rec.参保地域 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 参保地域 = rec.参保地域 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 参保地域, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 参保地域) AS 分位
    ,就医方式
    ,参保地域
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.参保地域 = t.参保地域);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '地域离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'地域离院率' 特征类
    ,a.参保地域 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.参保地域 = b.参保地域 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度病种名称出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 病种名称, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 病种名称,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 病种名称, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 病种名称, to_char(住院日期,'YYYYMM') 
order by 就医方式, 病种名称, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 病种名称, 年月 FROM TMP_年月 order by 就医方式, 病种名称, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 病种名称 = rec.病种名称 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 病种名称 = rec.病种名称 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 病种名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 病种名称) AS 分位
    ,就医方式
    ,病种名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.病种名称 = t.病种名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '病种离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'病种离院率' 特征类
    ,a.病种名称 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.病种名称 = b.病种名称 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度专业名称出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 专业名称, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 专业名称,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 专业名称, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 专业名称, to_char(住院日期,'YYYYMM') 
order by 就医方式, 专业名称, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 专业名称, 年月 FROM TMP_年月 order by 就医方式, 专业名称, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 专业名称 = rec.专业名称 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 专业名称 = rec.专业名称 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 专业名称, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 专业名称) AS 分位
    ,就医方式
    ,专业名称
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.专业名称 = t.专业名称);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '专业离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'专业离院率' 特征类
    ,a.专业名称 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.专业名称 = b.专业名称 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;


-----------------------------------------------------------------------------------------------
--脚本：月度科室出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 住院医生, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 住院医生,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 住院医生, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 住院医生, to_char(住院日期,'YYYYMM') 
order by 就医方式, 住院医生, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 住院医生, 年月 FROM TMP_年月 order by 就医方式, 住院医生, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 住院医生 = rec.住院医生 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 住院医生 = rec.住院医生 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 住院医生, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 住院医生) AS 分位
    ,就医方式
    ,住院医生
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.住院医生 = t.住院医生);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 住院医生) AS 分位
    ,就医方式
    ,住院医生
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院医生 = b.住院医生 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.住院医生 = t.住院医生);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 住院医生) AS 分位
    ,就医方式
    ,住院医生
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院医生 = b.住院医生 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.住院医生 = t.住院医生);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '医生离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'医生离院率' 特征类
    ,a.住院医生 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.住院医生 = b.住院医生 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
--脚本：月度科室出入院人数
--说明：
-----------------------------------------------------------------------------------------------
drop table TMP_年月 purge;

create table TMP_年月 nologging as
select distinct 就医方式, 住院科室, to_char(住院日期,'YYYYMM') 年月
from 模型_住院人群
where 机构编码 = 'H00000000000' 
order by 住院科室,年月;

drop table TMP_水位 purge;

create table TMP_水位 nologging as
select t.*, rownum 月数 from
(
select distinct 就医方式, 住院科室, to_char(住院日期,'YYYYMM') 年月, count(distinct 身份证号) 入院, 0 出院, 0.0 出入比
from 模型_住院人群
where 机构编码 = 'H00000000000' 
group by 就医方式, 住院科室, to_char(住院日期,'YYYYMM') 
order by 就医方式, 住院科室, 年月
)t;

DECLARE
  CURSOR cur IS SELECT 就医方式, 住院科室, 年月 FROM TMP_年月 order by 就医方式, 住院科室, 年月;
  rec cur%ROWTYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN cur%NOTFOUND;

    update TMP_水位 set 出院 = (select count(distinct 身份证号) from 模型_住院人群 a 
        where 就医方式 = rec.就医方式 and 住院科室 = rec.住院科室 and to_char(a.住院日期 + a.住院天数,'YYYYMM') = rec.年月)
    where 就医方式 = rec.就医方式 and 住院科室 = rec.住院科室 and 年月 = rec.年月;
    commit;
  END LOOP;
  CLOSE cur;
END;

update TMP_水位 set 出入比 = round(出院 / 入院,2);
commit;

--计算四分位
drop table TMP_分位 purge;

create table TMP_分位 nologging as
select distinct 就医方式, 住院科室, 0 低分位， 0 中分位, 0 高分位, 0 分位矩 
from TMP_水位;

update TMP_分位 s set 中分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 住院科室) AS 分位
    ,就医方式
    ,住院科室
FROM TMP_水位 a where 1=1
)t
where s.就医方式 = t.就医方式 and s.住院科室 = t.住院科室);
commit;

update TMP_分位 s set 低分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 住院科室) AS 分位
    ,就医方式
    ,住院科室
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院科室 = b.住院科室 and a.出入比 <= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.住院科室 = t.住院科室);
commit;

update TMP_分位 s set 高分位 = (select 分位 from
(
SELECT distinct PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY 出入比) 
    OVER (partition by 就医方式, 住院科室) AS 分位
    ,就医方式
    ,住院科室
FROM TMP_水位 a where 1=1
and exists (select 1 from TMP_分位 b where a.就医方式 = b.就医方式 and a.住院科室 = b.住院科室 and a.出入比 >= b.中分位)
)t
where s.就医方式 = t.就医方式 and s.住院科室 = t.住院科室);
commit;

update TMP_分位 set 分位矩 = 高分位 - 低分位;
commit;

delete from 线索_问题特征 where 机构编码 = 'H00000000000' and 就医来源 in ('住院') and 特征类 = '科室离院率';
commit;

insert into 线索_问题特征
select 'H00000000000' 机构编码
    ,a.就医方式 就医来源 ,'' 对象来源 
    ,'科室离院率' 特征类
    ,a.住院科室 特征名
    ,a.出入比 特征值
    ,年月 特征位 ,'高水位' 特征区 from TMP_水位 a, TMP_分位 b
where b.分位矩 > 0
and a.就医方式 = b.就医方式 and a.住院科室 = b.住院科室 and a.出入比 > b.低分位 + b.分位矩 * 1.5
order by 就医来源,特征名,特征位;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题特征 rebuild;

drop table TMP_年月 purge;
drop table TMP_分位 purge;
drop table TMP_水位 purge;

-----------------------------------------------------------------------------------------------
--脚本：遴选住院离院率异常病案
--说明：
-----------------------------------------------------------------------------------------------
delete from 线索_问题病案 where 机构编码 = 'H00000000000' and 就医来源 in ('住院')
    and 线索来源 = '水位分析' and 问题类型 = '住院离院率异常';
commit;

insert into 线索_问题病案
select 就医方式 就医来源
    ,'水位分析' 线索来源
    ,'住院离院率异常' 问题类型
    ,'在该时段中存在此对象住院离院异常' 问题情形
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
    select 1 from 线索_问题特征 t where 特征类 = '就医离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and to_char(住院日期,'YYYYMM') = t.特征位
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '性别离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.性别对象 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '年龄离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.年龄对象 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '持证离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.持证类别 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '地域离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.参保地域 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '病种离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.病种名称 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '专业离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.专业名称 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '医生离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.住院医生 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
and exists(
    select 1 from 线索_问题特征 t where 特征类 = '科室离院率'
    and a.机构编码 = t.机构编码 and a.就医方式 = t.就医来源 and a.住院科室 = t.特征名 and to_char(住院日期,'YYYYMM') = t.特征位 
)
order by a.住院日期;
commit;

-----------------------------------------------------------------------------------------------
alter index 索引_线索_问题病案 rebuild;
