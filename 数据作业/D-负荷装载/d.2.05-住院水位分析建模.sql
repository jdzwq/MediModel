/*********************************************************************************************
脚本说明：以下脚本用于生成住院人群水位分析模型数据，运行时机构编码、机构名称、机构区划请注意替换成为实际机构
机构编码：H00000000000
机构名称：测试医院
机构区划: 000000
**********************************************************************************************/

--*******************************************************************************************--
--脚本：建立住院日期校正基准表
delete from 模型_住院日期 where 机构编码 = 'H00000000000';
commit;

insert into 模型_住院日期 (机构编码,身份证号,就医年度,校正天数)
select distinct t.机构编码,t.身份证号,t.住院年度,to_number(to_char(t.住院日期,'DD')) - 1 校正天数 from 负荷_住院就医 e, 
(select 机构编码,身份证号,to_char(入院日期,'YYYY') 住院年度,min(入院日期) 住院日期 from 负荷_住院就医 group by 机构编码，身份证号, to_char(入院日期,'YYYY')) t
where e.机构编码 = t.机构编码 and e.身份证号 = t.身份证号 and to_char(e.入院日期,'YYYY') = t.住院年度
order by t.机构编码,t.身份证号,t.住院年度;
commit;

alter index 索引_模型_住院日期 rebuild;

--*******************************************************************************************--
--脚本：从住院负荷表中归集住院人群
delete from 模型_住院人群 where 机构编码 = 'H00000000000' and 就医方式 in ('住院');
commit;

--select to_char(入院日期,'YYYYMM') 年月, count(*) 人次 from 负荷_住院就医 group by to_char(入院日期,'YYYYMM') order by 年月;

INSERT INTO 模型_住院人群 (机构编码, 机构名称, 人员姓名, 性别对象, 年龄对象, 身份证号, 险种类别, 持证类别, 参保地域, 就医方式, 住院日期, 
    住院天数, 住院科室, 住院医生, 疾病编码, 疾病诊断, 医疗金额) 
select 机构编码, 机构名称, 人员姓名, 性别对象, 年龄对象, 身份证号, 险种类别, 持证类别, 参保地域, 就医方式, 住院日期,
    sum(住院天数) 住院天数, 住院科室, 住院医生, 疾病编码, 疾病诊断, sum(医疗金额) 医疗金额
from(
select e.机构编码
    ,e.机构名称
    ,姓名 人员姓名
    ,性别 性别对象
    ,case when 年龄 < 7 then '婴幼儿' when 年龄 < 15 then '少年儿童' when 年龄 < 65 then '劳动人口' else '老年人口' end 年龄对象
    ,e.身份证号
    ,险种类别
    ,case when 持证类别 in ('特困供养人员','特困,低保') then '特困'
        when 持证类别 in ('低保边缘家庭人员','低保边缘家庭成员','低边,低保') then '低边'
        when 持证类别 in ('最低生活保障对象','低保,特困','低保,低边') then '低保'
    end 持证类别
    ,case 参保区划 when '000000' then '本地' when '' then '本地' else '异地' end 参保地域
    ,'住院' 就医方式
    ,trunc(入院日期) - t.校正天数 住院日期
    ,住院天数
    ,住院科室
    ,住院医生
    ,疾病编码
    ,疾病诊断
    ,医疗金额
from 负荷_住院就医 e inner join 模型_住院日期 t on e.机构编码 = t.机构编码 and e.身份证号 = t.身份证号 and to_char(e.入院日期,'YYYY') = t.就医年度
where e.机构编码 = 'H00000000000'
and to_char(入院日期,'YYYYMM')  between '202301' and '202504' 
) a
group by 机构编码, 机构名称, 人员姓名, 性别对象, 年龄对象, 身份证号, 险种类别, 持证类别, 参保地域, 就医方式, 住院日期, 住院科室, 住院医生, 疾病编码, 疾病诊断
having sum(医疗金额) <> 0;
commit;

alter index 索引_模型_住院人群 rebuild;

--*******************************************************************************************--
--脚本：更新住院人群疾病分类

update 模型_住院人群 set 病种编码 = substr(疾病编码,1,7) where 机构编码 = 'H00000000000' and 病种编码 is null;
commit;

--更新肿瘤分型
begin
    for cur in (
    select a.rowid,b.病种名称,b.专业名称 from 模型_住院人群 a inner join 字典_疾病分类 b on upper(substr(a.病种编码,1,4)) = b.病种编码 and b.病种类型 = '肿瘤诊断'
    where instr(a.病种编码,'.') = 0 and upper(substr(a.病种编码,1,1)) = 'M'
    )loop
    update 模型_住院人群 set 病种名称 = cur.病种名称, 专业名称 = cur.专业名称 where rowid = cur.rowid;
    end loop;
    commit;

--更新规定病种
    for cur in (
    select a.rowid,b.病种名称,b.专业名称 from 模型_住院人群 a inner join 字典_疾病分类 b on upper(substr(a.病种编码,1,4)) = b.病种编码 and b.病种类型 = '规定病种'
    where instr(a.病种编码,'.') = 0 and upper(substr(a.病种编码,1,1)) = 'M'
    )loop
    update 模型_住院人群 set 病种名称 = cur.病种名称, 专业名称 = cur.专业名称 where rowid = cur.rowid;
    end loop;
    commit;

--更新中医诊断
    for cur in (
    select a.rowid,b.病种名称,b.专业名称 from 模型_住院人群 a inner join 字典_疾病分类 b on upper(substr(a.病种编码,1,4)) = b.病种编码 and b.病种类型 = '中医诊断'
    where substr(a.病种编码,7,1) = '.' and upper(substr(a.病种编码,1,1)) in ('A')
    )loop
    update 模型_住院人群 set 病种名称 = cur.病种名称, 专业名称 = cur.专业名称 where rowid = cur.rowid;
    end loop;
    commit;

--更新中医诊断
    for cur in (
    select a.rowid,b.病种名称,b.专业名称 from 模型_住院人群 a inner join 字典_疾病分类 b on upper(substr(a.病种编码,1,4)) = b.病种编码 and b.病种类型 = '中医诊断'
    where instr(a.病种编码,'.') = 0 and upper(substr(a.病种编码,1,1)) in ('B','Z')
    )loop
    update 模型_住院人群 set 病种名称 = cur.病种名称, 专业名称 = cur.专业名称 where rowid = cur.rowid;
    end loop;
    commit;

--更新西医诊断
    for cur in (
    select a.rowid,b.病种名称,b.专业名称 from 模型_住院人群 a inner join 字典_疾病分类 b on upper(substr(a.病种编码,1,4)) = b.病种编码 and b.病种类型 = '西医诊断'
    where instr(a.病种编码,'.') > 0 and substr(a.病种编码,7,1) <> '.'
    )loop
    update 模型_住院人群 set 病种名称 = cur.病种名称, 专业名称 = cur.专业名称 where rowid = cur.rowid;
    end loop;
    commit;
end;

--*******************************************************************************************--
--脚本：从住院负荷表中归集住院项目
delete from 模型_住院项目 where 机构编码 = 'H00000000000' and 就医方式 in ('住院');
commit;

INSERT INTO 模型_住院项目 (机构编码, 身份证号, 就医方式, 住院日期, 费用日期, 
    项目编码, 项目名称, 项目类别, 项目属性, 项目次数, 项目数量, 项目金额) 
select 机构编码, 身份证号, 就医方式, 住院日期, 费用日期,
    项目编码, 项目名称, 项目类别, 项目属性, sum(项目次数) 项目次数, sum(项目数量) 项目数量, sum(项目金额) 项目金额
from(
select e.机构编码
    ,e.身份证号
    ,decode(e.结算类别,'住院','住院','日间手术','住院','家庭病床','住院','住院') 就医方式
    ,trunc(e.入院日期) - t.校正天数 住院日期
    ,trunc(g.费用发生日期) 费用日期
    ,upper(substr(g.国标代码,1,15)) 项目编码
    ,g.国标名称 项目名称
    ,g.收费项目类别 项目类别
    ,g.医疗属性类别 项目属性
    ,g.次数 项目次数
    ,g.数量 项目数量
    ,g.金额 项目金额
from 负荷_住院就医 e inner join 模型_住院日期 t on e.机构编码 = t.机构编码 and e.身份证号 = t.身份证号 and to_char(e.入院日期,'YYYY') = t.就医年度
    inner join 负荷_住院结算 g on e.机构编码 = g.机构编码 and e.住院号 = g.住院号 and e.结算流水号 = g.结算流水号
where e.机构编码 = 'H00000000000'
and to_char(入院日期,'YYYYMM')  between '202301' and '202504' 
) a
group by 机构编码, 身份证号, 就医方式, 住院日期, 费用日期, 项目编码, 项目名称, 项目类别, 项目属性
having sum(项目数量) <> 0;
commit;

alter index 索引_模型_住院项目 rebuild;
