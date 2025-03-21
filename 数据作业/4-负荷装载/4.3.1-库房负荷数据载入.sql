/*********************************************************************************************
脚本说明：以下脚本从机构原始数据中载入负荷数据，运行时机构编码和机构数据表名称请注意替换成为实际机构
机构编码：H00000000000
机构名称：测试医院
导入表名：测试医院_<导入表名>
**********************************************************************************************/

--*******************************************************************************************--
--脚本：将机构导入表中的药库结转记录加载至负荷表
delete from 负荷_药库结转 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_药库结转 (年月, 机构编码, 机构名称, 药库名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 
       生产厂家, 供应商名称, 包装单位, 拆零单位, 拆零比, 库存单位, 上期结存数, 本期收入数, 本期支出数, 
       本期结存数, 购入价, 零售价, 结转日期)
select replace(年月,'-','') 年月, 机构编码, 机构名称, 药库名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 
       生产厂家, 供应商名称, 包装单位, 拆零单位, 拆零比, 库存单位, 上期结存数, 本期收入数, 本期支出数, 
       本期结存数, 购入价, 零售价, 结转日期
from 测试医院_药库结转 where 机构编码 = 'H00000000000';
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的药库消耗记录加载至负荷表
delete from 负荷_药库消耗 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_药库消耗 (机构编码, 机构名称, 药库名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 
       包装单位, 拆零单位, 拆零比, 数量, 单位, 购入价, 零售价, 业务类型, 业务日期, 对方部门)
select 机构编码, 机构名称, 药库名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 包装单位, 拆零单位, 拆零比,
       sum(出入库数量) 数量,包装单位 单位,购入价,零售价,
       出入库类型 业务类型,trunc(业务日期),对方单位部门 对方部门
from 测试医院_药库消耗 where 机构编码 = 'H00000000000'
GROUP BY 机构编码,机构名称,药库名称,项目代码,国标代码,商品类型,商品名称,商品规格,包装单位,拆零单位,拆零比,
包装单位,购入价,零售价,出入库类型,trunc(业务日期),对方单位部门
order by trunc(业务日期);
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的药房结转记录加载至负荷表
delete from 负荷_药房结转 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_药房结转 (年月, 机构编码, 机构名称, 药房名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 
       生产厂家, 供应商名称, 包装单位, 拆零单位, 拆零比, 库存单位, 上期结存数, 本期收入数, 本期支出数, 
       本期结存数, 购入价, 零售价, 结转日期)
select replace(年月,'-','') 年月, 机构编码, 机构名称, 药房名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 
       生产厂家, 供应商名称, 包装单位, 拆零单位, 拆零比, 库存单位, 上期结存数, 本期收入数, 本期支出数, 
       本期结存数, 购入价, 零售价, 结转日期
from 测试医院_药房结转 where 机构编码 = 'H00000000000';
commit;
--*******************************************************************************************--

--*******************************************************************************************--
--脚本：将机构导入表中的药房消耗记录加载至负荷表
delete from 负荷_药房消耗 where 机构编码 = 'H00000000000';
commit;

insert into 负荷_药房消耗 (机构编码, 机构名称, 药房名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 
       包装单位, 拆零单位, 拆零比, 数量, 单位, 购入价, 零售价, 业务类型, 业务日期, 对方部门)
select 机构编码, 机构名称, 药房名称, 项目代码, 国标代码, 商品类型, 商品名称, 商品规格, 包装单位, 拆零单位, 拆零比,
       sum(出入库数量) 数量,包装单位 单位,购入价,零售价,
       出入库类型 业务类型,trunc(业务日期),对方单位部门 对方部门
from 测试医院_药房消耗 where 机构编码 = 'H00000000000'
GROUP BY 机构编码,机构名称,药房名称,项目代码,国标代码,商品类型,商品名称,商品规格,包装单位,拆零单位,拆零比,
包装单位,购入价,零售价,出入库类型,trunc(业务日期),对方单位部门
ORDER BY trunc(业务日期);
commit;
--*******************************************************************************************--
