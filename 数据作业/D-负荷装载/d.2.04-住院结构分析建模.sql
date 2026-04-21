/*********************************************************************************************
脚本说明：以下脚本用于生成住院水位分析模型数据，运行时机构编码和机构数据表名称请注意替换成为实际机构
机构编码：H00000000000
机构名称：测试医院
结算年度: 2023
**********************************************************************************************/

--*******************************************************************************************--
--脚本：从住院负荷表中归集住院结构
delete from 模型_住院结构 where 机构编码 = 'H00000000000';
commit;

INSERT INTO 模型_住院结构 (机构编码, 机构名称, 身份证号, 人员姓名, 住院日期, 住院天数, 住院人次)
SELECT 机构编码, 机构名称, 身份证号, 姓名, 住院日期, 住院天数, 医疗人次
FROM 模型_住院诊次 WHERE 机构编码 = 'H00000000000';
COMMIT;

alter index 索引_模型_住院结构 rebuild;
--*******************************************************************************************--

--更新项目费用分量
begin
  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('床位费') group by a.rowid)loop
     UPDATE 模型_住院结构 SET 床位金额 = cur.金额,床位列支 = cur.列支,床位数量 = cur.数量,床位项数 = cur.项数,床位次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('诊查费','挂号费','会诊费','巡诊费') group by a.rowid)loop
     UPDATE 模型_住院结构 SET 诊查金额 = cur.金额,诊查列支 = cur.列支,诊查数量 = cur.数量,诊查项数 = cur.项数,诊查次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('护理费','注射费') group by a.rowid)loop
     UPDATE 模型_住院结构 SET 护理金额 = cur.金额,护理列支 = cur.列支,护理数量 = cur.数量,护理项数 = cur.项数,护理次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('化验费','病理费') group by a.rowid)loop
     UPDATE 模型_住院结构 SET 化验金额 = cur.金额,化验列支 = cur.列支,化验数量 = cur.数量,化验项数 = cur.项数,化验次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('检查费') group by a.rowid)loop
     UPDATE 模型_住院结构 SET 检查金额 = cur.金额,检查列支 = cur.列支,检查数量 = cur.数量,检查项数 = cur.项数,检查次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('吸氧费','抢救费','急救费','一般诊疗费') group by a.rowid)loop
     UPDATE 模型_住院结构 SET 一般诊疗金额 = cur.金额,一般诊疗列支 = cur.列支,一般诊疗数量 = cur.数量,一般诊疗项数 = cur.项数,一般诊疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期 
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('手术费','麻醉费')group by a.rowid )loop
     UPDATE 模型_住院结构 SET 手术麻醉金额 = cur.金额,手术麻醉列支 = cur.列支,手术麻醉数量 = cur.数量,手术麻醉项数 = cur.项数,手术麻醉次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('介入治疗费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 介入治疗金额 = cur.金额,介入治疗列支 = cur.列支,介入治疗数量 = cur.数量,介入治疗项数 = cur.项数,介入治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('放射治疗费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 放射治疗金额 = cur.金额,放射治疗列支 = cur.列支,放射治疗数量 = cur.数量,放射治疗项数 = cur.项数,放射治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('物理治疗费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 物理治疗金额 = cur.金额,物理治疗列支 = cur.列支,物理治疗数量 = cur.数量,物理治疗项数 = cur.项数,物理治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('中医治疗费','中医论治费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 中医治疗金额 = cur.金额,中医治疗列支 = cur.列支,中医治疗数量 = cur.数量,中医治疗项数 = cur.项数,中医治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('康复治疗费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 康复治疗金额 = cur.金额,康复治疗列支 = cur.列支,康复治疗数量 = cur.数量,康复治疗项数 = cur.项数,康复治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('精神治疗费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 精神治疗金额 = cur.金额,精神治疗列支 = cur.列支,精神治疗数量 = cur.数量,精神治疗项数 = cur.项数,精神治疗次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('西药费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 西药金额 = cur.金额,西药列支 = cur.列支,西药数量 = cur.数量,西药项数 = cur.项数,西药次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('成药费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 成药金额 = cur.金额,成药列支 = cur.列支,成药数量 = cur.数量,成药项数 = cur.项数,成药次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('草药费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 草药金额 = cur.金额,草药列支 = cur.列支,草药数量 = cur.数量,草药项数 = cur.项数,草药次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('材料费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 材料金额 = cur.金额,材料列支 = cur.列支,材料数量 = cur.数量,材料项数 = cur.项数,材料次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;

  for cur in (select a.rowid, sum(b.金额) 金额,sum(b.列支) 列支,SUM(b.数量) 数量,count(distinct 名称) 项数,sum(频次) 次数
     from 模型_住院结构 A inner join 模型_住院频度 B on A.机构编码 = B.机构编码 AND A.身份证号 = B.身份证号 and A.住院日期 = B.住院日期
     WHERE a.机构编码 = 'H00000000000' AND b.类别 IN ('其他服务费','体检费','疫苗费','其他费') group by a.rowid )loop
     UPDATE 模型_住院结构 SET 其他金额 = cur.金额,其他列支 = cur.列支,其他数量 = cur.数量,其他项数 = cur.项数,其他次数 = cur.次数 
     where rowid = cur.rowid;
    end loop;
  commit;
end;
