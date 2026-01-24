/*********************************************************************************************
脚本说明：以下为导入数据、负荷数据、归档数据分别创建用户空间，脚本在sqlplus命令行中执行
**********************************************************************************************/

--脚本：数据库管理员账号登录
sqlplus / as sysdba


--创建导入数据表用户空间
sql> create tablespace hosps datafile '/u01/app/oracle/oradata/ORDW/hosp1.dbf' size 100M autoextend on next 100M;
sql> alter tablespace hosps add datafile '/u01/app/oracle/oradata/ORDW/hosp2.dbf' size 100M autoextend on next 100M;
sql> CREATE USER hosp IDENTIFIED BY abc DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
sql> GRANT dba TO hosp;

--创建负荷数据表用户空间
sql> create tablespace medis datafile '/u01/app/oracle/oradata/ORDW/medi1.dbf' size 100M autoextend on next 100M;
sql> alter tablespace medis add datafile '/u01/app/oracle/oradata/ORDW/medi2.dbf' size 100M autoextend on next 100M;
sql> CREATE USER medi IDENTIFIED BY abc DEFAULT TABLESPACE medis TEMPORARY TABLESPACE temp;
sql> GRANT dba TO medi;

--创建归档数据表用户空间
sql> create tablespace archs datafile '/u01/app/oracle/oradata/ORDW/arch1.dbf' size 100M autoextend on next 100M;
sql> alter tablespace archs add datafile '/u01/app/oracle/oradata/ORDW/arch2.dbf' size 100M autoextend on next 100M;
sql> CREATE USER arch IDENTIFIED BY abc DEFAULT TABLESPACE archs TEMPORARY TABLESPACE temp;
sql> GRANT dba TO arch;
