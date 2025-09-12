/*********************************************************************************************
脚本说明：以下脚本用于将负荷数据归档，运行时请替换实际的机构编码、机构名称和行政区划
执行位置：脚本应在‘medi’用户空间执行
机构编码：H00000000000
机构名称：测试医院
**********************************************************************************************/


--脚本：清除应用表
delete from 应用_问题线索 where 机构编码 = 'H00000000000';
commit;

delete from 应用_病案遴选 where 机构编码 = 'H00000000000';
commit;
--*******************************************************************************************--

--脚本：清除统计表
delete from 统计_门诊结构 where 机构编码 = 'H00000000000';
commit;

delete from 统计_门诊诊次 where 机构编码 = 'H00000000000';
commit;

delete from 统计_门诊频度 where 机构编码 = 'H00000000000';
commit;

delete from 统计_住院结构 where 机构编码 = 'H00000000000';
commit;

delete from 统计_住院诊次 where 机构编码 = 'H00000000000';
commit;

delete from 统计_住院频度 where 机构编码 = 'H00000000000';
commit;

delete from 统计_库房进销 where 机构编码 = 'H00000000000';
commit;
--*******************************************************************************************--

--脚本：清除负荷表
delete from 负荷_机构摘要 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_门诊就医 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_门诊结算 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_门诊处方 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_门诊手术 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_门诊麻醉 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_住院就医 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_住院结算 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_住院医嘱 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_住院手术 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_住院麻醉 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_检查登记 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_检查报告 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_化验登记 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_化验报告 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_药库结转 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_药库消耗 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_药房结转 where 机构编码 = 'H00000000000';
commit;

delete from 负荷_药房消耗 where 机构编码 = 'H00000000000';
commit;
--*******************************************************************************************--

