/*********************************************************************************************
脚本说明：以下脚本用于生成门诊结构、频度数据，运行时机构编码和机构数据表名称请注意替换成为实际机构
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

--*******************************************************************************************--
--脚本：从门诊负荷表中归集门诊诊次
delete from 统计_门诊诊次 where 机构编码 = 'H00000000000';
commit;

INSERT INTO 统计_门诊诊次 (机构等级, 机构编码, 机构名称, 姓名, 性别, 年龄, 身份证号, 门诊日期, 门诊天数,
    门诊科室, 门诊医生, 疾病诊断, 次要诊断, 医疗诊次, 医疗金额, 列支金额, 基金支付, 个账支付, 现金支付) 
SELECT 机构等级，机构编码, 机构名称, 姓名, 性别, 年龄, 身份证号, trunc(门诊日期), 1 门诊天数,
    listagg(a.门诊科室,'、') within group(order by a.门诊日期) 门诊科室, 
    listagg(a.门诊医生,'、') within group(order by a.门诊日期) 门诊医生,
    listagg(a.疾病诊断,'、') within group(order by a.门诊日期) 疾病诊断,
    listagg(a.次要诊断,'、') within group(order by a.门诊日期) 次要诊断,
    count(distinct a.门诊号) 医疗诊次,
    sum(医疗金额) 医疗金额,
    sum(列支金额) 列支金额,
    sum(基金支付) 基金支付,
    sum(个账支付) 个账支付,
    sum(现金支付) 现金支付
FROM 负荷_门诊就医 a
group by 机构等级, 机构编码, 机构名称, 姓名, 性别, 年龄, 身份证号, trunc(门诊日期)
having sum(医疗金额) <> 0;
commit;

--*******************************************************************************************--
--脚本：从门诊负荷表中归集门诊项目频度
delete from 统计_门诊频度 where 机构编码 = 'H00000000000';
commit;

insert into 统计_门诊频度(机构编码, 机构名称, 人员姓名, 身份证号, 门诊日期, 代码, 类别, 属性, 
    名称, 规格, 诊次, 人次, 频次, 天数, 剂量, 数量, 单位, 单价, 金额, 列支, 日期)
select b.机构编码,b.机构名称,b.姓名,b.身份证号,trunc(b.门诊日期),
    a.国标代码,a.收费项目类别,a.医疗属性类别,a.国标名称,a.规格,
    count(distinct a.门诊号) as 诊次,
    count(distinct a.身份证号 || to_char(a.费用发生日期,'YYYYMMDD')) as 人次,
    round(avg(a.次数),0) 频次,
    sum(a.天数) 天数,
    sum(regexp_substr(a.剂量,'[0-9]+(\.\[0-9]+)?')) as 剂量,
    sum(a.数量) as 数量,
    a.数量单位 as 单位,
    a.单价,
    sum(nvl(a.金额,0.0)) as 金额,
    sum(NVL(a.金额,0.0)-NVL(a.全自费金额,0.0)-NVL(a.超限价金额,0.0)-NVL(a.先行自付金额,0.0)) as 列支,
    trunc(a.费用发生日期) as 日期
from 负荷_门诊结算 a inner join 负荷_门诊就医 b on a.机构编码 = b.机构编码 and a.门诊号 = b.门诊号 and a.结算流水号 = b.结算流水号
where b.机构编码 = 'H00000000000' and nvl(a.数量,0) <> 0
group by b.机构编码, b.机构名称, b.姓名, b.身份证号, trunc(b.门诊日期),a.国标代码, a.收费项目类别, a.医疗属性类别,
    a.国标名称,a.规格,a.数量单位,a.单价,trunc(a.费用发生日期)
having sum(a.数量) <> 0;
commit;

--*******************************************************************************************--
--脚本：从门诊负荷表中归集门诊结构
delete from 统计_门诊结构 where 机构编码 = 'H00000000000';
commit;

INSERT INTO 统计_门诊结构 (机构编码, 机构名称, 身份证号, 人员姓名, 门诊日期, 门诊天数)
SELECT 机构编码, 机构名称, 身份证号, 姓名, 门诊日期, 门诊天数
FROM 统计_门诊诊次 WHERE 机构编码 = 'H00000000000';
COMMIT;
--*******************************************************************************************--

--更新项目费用分量
begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('床位费') group by a.rowid)loop
     UPDATE 统计_门诊结构 SET 床位金额 = cur.金额,床位列支 = cur.列支,床位数量 = cur.数量,床位项数 = cur.项数,床位次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('诊查费','挂号费','会诊费','巡诊费') group by a.rowid)loop
     UPDATE 统计_门诊结构 SET 诊查金额 = cur.金额,诊查列支 = cur.列支,诊查数量 = cur.数量,诊查项数 = cur.项数,诊查次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('护理费','注射费') group by a.rowid)loop
     UPDATE 统计_门诊结构 SET 护理金额 = cur.金额,护理列支 = cur.列支,护理数量 = cur.数量,护理项数 = cur.项数,护理次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('化验费','病理费') group by a.rowid)loop
     UPDATE 统计_门诊结构 SET 化验金额 = cur.金额,化验列支 = cur.列支,化验数量 = cur.数量,化验项数 = cur.项数,化验次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('检查费') group by a.rowid)loop
     UPDATE 统计_门诊结构 SET 检查金额 = cur.金额,检查列支 = cur.列支,检查数量 = cur.数量,检查项数 = cur.项数,检查次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('吸氧费','抢救费','急救费','一般诊疗费') group by a.rowid)loop
     UPDATE 统计_门诊结构 SET 一般诊疗金额 = cur.金额,一般诊疗列支 = cur.列支,一般诊疗数量 = cur.数量,一般诊疗项数 = cur.项数,一般诊疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期   
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('手术费','麻醉费')group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 手术麻醉金额 = cur.金额,手术麻醉列支 = cur.列支,手术麻醉数量 = cur.数量,手术麻醉项数 = cur.项数,手术麻醉次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('介入治疗费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 介入治疗金额 = cur.金额,介入治疗列支 = cur.列支,介入治疗数量 = cur.数量,介入治疗项数 = cur.项数,介入治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('放射治疗费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 放射治疗金额 = cur.金额,放射治疗列支 = cur.列支,放射治疗数量 = cur.数量,放射治疗项数 = cur.项数,放射治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('物理治疗费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 物理治疗金额 = cur.金额,物理治疗列支 = cur.列支,物理治疗数量 = cur.数量,物理治疗项数 = cur.项数,物理治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('中医治疗费','中医论治费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 中医治疗金额 = cur.金额,中医治疗列支 = cur.列支,中医治疗数量 = cur.数量,中医治疗项数 = cur.项数,中医治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('康复治疗费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 康复治疗金额 = cur.金额,康复治疗列支 = cur.列支,康复治疗数量 = cur.数量,康复治疗项数 = cur.项数,康复治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('精神治疗费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 精神治疗金额 = cur.金额,精神治疗列支 = cur.列支,精神治疗数量 = cur.数量,精神治疗项数 = cur.项数,精神治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('西药费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 西药金额 = cur.金额,西药列支 = cur.列支,西药数量 = cur.数量,西药项数 = cur.项数,西药次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('成药费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 成药金额 = cur.金额,成药列支 = cur.列支,成药数量 = cur.数量,成药项数 = cur.项数,成药次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('草药费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 草药金额 = cur.金额,草药列支 = cur.列支,草药数量 = cur.数量,草药项数 = cur.项数,草药次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('材料费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 材料金额 = cur.金额,材料列支 = cur.列支,材料数量 = cur.数量,材料项数 = cur.项数,材料次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;

begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 统计_门诊结构 A inner join 统计_门诊频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.门诊日期 = B.门诊日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('其他服务费','体检费','疫苗费') group by a.rowid )loop
     UPDATE 统计_门诊结构 SET 其他金额 = cur.金额,其他列支 = cur.列支,其他数量 = cur.数量,其他项数 = cur.项数,其他次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;
