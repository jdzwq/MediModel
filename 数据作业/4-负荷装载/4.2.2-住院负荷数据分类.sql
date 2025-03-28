/*********************************************************************************************
脚本说明：以下脚本用于校正、分类住院负荷数据，运行时机构编码和机构数据表名称请注意替换成为实际机构
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/

--*******************************************************************************************--
--脚本：删除负荷表中住院号和结算流水号重复的住院就医记录
--注意：删除重复记录时，保留rowid较小的记录
delete from 负荷_住院就医 a where a.机构编码 = 'H00000000000' and a.rowid > 
(select min(b.rowid) from 负荷_住院就医 b where a.机构编码 = b.机构编码 and a.住院号 = b.住院号 
and a.结算流水号 = b.结算流水号);
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：从身份证号校正年龄
update 负荷_住院就医 set 年龄 = (to_number(to_char(入院日期,'YYYY')) - to_number(substr(身份证号,7,4)))
where 机构编码 = 'H00000000000' and LENGTH(身份证号) = 18
and 年龄 <> (to_number(to_char(入院日期,'YYYY')) - to_number(substr(身份证号,7,4)));
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：从身份证号校正性别
update 负荷_住院就医 set 性别 = decode(mod(to_number(substr(身份证号,17,1)),2),0,'女',1,'男')
where 机构编码 = 'H00000000000' and LENGTH(身份证号) = 18
and 性别 <> decode(mod(to_number(substr(身份证号,17,1)),2),0,'女',1,'男');
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：身份证号为空的记录，使用姓名替代，保持个体的可标识性
UPDATE 负荷_住院就医 SET 身份证号 = 姓名 
where 机构编码 = 'H00000000000' and trim(身份证号) IS NULL;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：校正住院天数
UPDATE 负荷_住院就医 SET 住院天数 = (出院日期 - 入院日期 + 1) where 机构编码 = 'H00000000000' 
and 住院天数 <> (出院日期 - 入院日期 + 1) and 出院日期 IS NOT NULL and 入院日期 IS NOT NULL;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：默认天数为1
UPDATE 负荷_住院结算 set 天数 = 1 where 机构编码 = 'H00000000000' and 天数 is null;
COMMIT;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将冲红的费用明细的诊疗天数置为负值
UPDATE 负荷_住院结算 set 天数 = 0 - 天数 where 机构编码 = 'H00000000000' and 数量 < 0 and 天数 > 0;
COMMIT;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：从频次表中更新执行次数
begin
  for cur in (select a.rowid,b.执行频次 from 负荷_住院结算 a, 字典_医嘱频次 b where a.机构编码 = 'H00000000000' 
    and (LOWER(NVL(A.频次,'@')) = B.英文名称 OR NVL(A.频次,'@') = b.中文名称 OR NVL(A.频次,'@') LIKE '%' || B.中文别名 || '%')) loop
    update 负荷_住院结算 SET 次数 = cur.执行频次 where rowid = cur.rowid;
  end loop;
  commit;
end;

--脚本：默认次数为1
update 负荷_住院结算 set 次数 = 1 where 机构编码 = 'H00000000000' and 次数 is null;
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：保持项目名称不为空
UPDATE 负荷_住院结算 set 项目名称 = 商品名 where 机构编码 = 'H00000000000' and 项目名称 IS NULL and 商品名 IS NOT NULL;
COMMIT;

UPDATE 负荷_住院结算 set 项目名称 = 国标名称 where 机构编码 = 'H00000000000' and 项目名称 IS NULL and 国标名称 IS NOT NULL;
COMMIT;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：从费用分类表中按省标通配更新收费项目类别和医疗属性类别
begin
  for cur in (
    select distinct a.rowid, b.费用项目, b.类目名称 from 负荷_住院结算 a, 字典_诊疗分类 b 
    where a.机构编码 = 'H00000000000' and nvl(a.收费项目类别,'@') not like '%药%' and nvl(a.收费项目类别,'@') not like '%材料%'
    and upper(a.国标代码) like upper (b.省标通配) || '%' and b.目录级别 = '0' 
    ) loop
    update 负荷_住院结算 set 收费项目类别 = cur.费用项目, 医疗属性类别 = cur.类目名称 where rowid = cur.rowid;
  end loop;
  commit;
end;
--脚本：从费用分类表中按国标通配更新收费项目类别和医疗属性类别
begin
  for cur in (
    select distinct a.rowid, b.费用项目, b.类目名称 from 负荷_住院结算 a, 字典_诊疗分类 b 
    where a.机构编码 = 'H00000000000' and nvl(a.收费项目类别,'@') not like '%药%' and nvl(a.收费项目类别,'@') not like '%材料%'
    and upper(a.国标代码) like upper(b.国标通配) || '%' and b.目录级别 = '0' 
    ) loop
    update 负荷_住院结算 set 收费项目类别 = cur.费用项目, 医疗属性类别 = cur.类目名称 where rowid = cur.rowid;
  end loop;
  commit;
end;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：从药品分类表中按国标通配更新收费项目类别和医疗属性类别
begin
  for cur in (
    select distinct a.rowid, b.费用项目, b.类目名称 from 负荷_住院结算 a, 字典_药品分类 b 
    where a.机构编码 = 'H00000000000' and nvl(a.收费项目类别,'@') like '%药%'
    and upper(a.国标代码) like upper(b.类目编码) || '%' and b.目录级别 = '0' 
    ) loop
    update 负荷_住院结算 set 收费项目类别 = cur.费用项目, 医疗属性类别 = cur.类目名称 where rowid = cur.rowid;
  end loop;
  commit;
end;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：更新编码内药品和材料分类
update 负荷_住院结算 set 收费项目类别 = '草药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '草药费' and UPPER(国标代码) like 'C%' AND LENGTH(国标代码) > 12 AND LENGTH(国标代码) < 20;
update 负荷_住院结算 set 收费项目类别 = '材料费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '材料费' and UPPER(国标代码) like 'C%' AND LENGTH(国标代码) = 12;
update 负荷_住院结算 set 收费项目类别 = '材料费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '材料费' and UPPER(国标代码) like 'C%' AND LENGTH(国标代码) > 20;
update 负荷_住院结算 set 收费项目类别 = '西药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '西药费' and UPPER(国标代码) like 'X%';
update 负荷_住院结算 set 收费项目类别 = '成药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '成药费' and UPPER(国标代码) like 'Z%';
update 负荷_住院结算 set 收费项目类别 = '草药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '草药费' and UPPER(国标代码) like 'T%';
COMMIT;
--脚本：更新编码外药品和材料分类
UPDATE 负荷_住院结算 SET 收费项目类别 = '西药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '西药费' AND UPPER(国标代码) like 'LA%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '成药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '成药费' AND UPPER(国标代码) like 'LB%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '西药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '西药费' AND UPPER(国标代码) like 'SYX%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '材料费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '材料费' AND UPPER(国标代码) like 'Q%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '西药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '西药费' AND UPPER(国标代码) like '8000000000000001%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '成药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '成药费' AND UPPER(国标代码) like '8000000000000002%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '其他费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '其他费' AND UPPER(国标代码) like '8000000000000003%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '材料费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '材料费' AND UPPER(国标代码) like '8000000000000004%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '草药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '草药费' AND UPPER(国标代码) like '5000000000000002%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '西药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '西药费' AND UPPER(国标代码) like '7000000000000001%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '草药费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '草药费' AND UPPER(国标代码) like '9000000000000001%' and 数量单位 like '%g%';
UPDATE 负荷_住院结算 SET 收费项目类别 = '其他服务费' where 机构编码 = 'H00000000000' and nvl(收费项目类别,'@') <> '其他服务费' AND UPPER(国标代码) like '9000000000000001%';
COMMIT;
--*******************************************************************************************--

/***********************************************************************************************
说明：需再检查收费项目类别是否规整，以下费用项目之外的类型必须被重新归类
药品材料项目：[西药费、成药费、草药费、材料费]
检查化验项目：[化验费、病理费、检查费]
人头费用项目：[挂号费、诊查费、床位费、会诊费、巡诊费]
护理相关项目：[护理费、注射费]
一般诊疗项目：[一般诊疗费、吸氧费]
手术麻醉项目：[手术费、麻醉费]
急救治疗项目：[急救费、抢救费]
特殊治疗项目：[介入治疗费、放射治疗费、精神治疗费]
精神专科项目：[精神治疗费]
康复理疗项目：[康复治疗费、物理治疗费]
中医治疗项目：[中医论治费、中医治疗费]
其他费用项目：[体检费、疫苗费、其他服务费]
***********************************************************************************************/

--脚本：应再查看收费项目类别是否还存在以上列出的项目
--select distinct 收费项目类别 from 负荷_住院结算 where 机构编码 = 'H00000000000';

--脚本：按项目类别重新归类
--说明：仅用于示例，按实际情况修改
/*
update 负荷_住院结算 set 收费项目类别 = '诊查费' where 机构编码 = 'H00000000000' and 收费项目类别 = '诊察费';
update 负荷_住院结算 set 收费项目类别 = '成药费' where 机构编码 = 'H00000000000' and 收费项目类别 = '中成药';
commit;
*/

--脚本：应再查看属于其他费的项目是否存在归类错误的问题
--select distinct 项目名称 from 负荷_住院结算 where 机构编码 = 'H00000000000' and 收费项目类别 = '其他费'

--脚本：按项目名称重新归类
--说明：仅用于示例，按实际情况修改
/*
update 负荷_住院结算 set 收费项目类别 = '一般诊疗费' where 机构编码 = 'H00000000000' and 项目名称 in ('纤维支气管镜检查','俯卧位通气治疗(新冠中型及以上)') and 收费项目类别 <> '一般诊疗费';
update 负荷_住院结算 set 收费项目类别 = '疫苗费' where 机构编码 = 'H00000000000' and 项目名称 like '%疫苗%' and 收费项目类别 <> '疫苗费';
commit;
*/
--*******************************************************************************************--
