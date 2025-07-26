/*********************************************************************************************
脚本说明：以下为导入数据、负荷数据、归档数据分别创建用户空间，脚本在sqlplus命令行中执行
**********************************************************************************************/

--脚本：数据库管理员账号登录
sqlplus / as sysdba


--创建导入数据表用户空间
sql> create tablespace users datafile '/u01/app/oracle/oradata/ORDW/user01.dbf' size 100M autoextend on next 100M;
sql> CREATE USER usr IDENTIFIED BY abc DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
sql> GRANT dba TO usr;

--创建负荷数据表用户空间
sql> create tablespace medis datafile '/u01/app/oracle/oradata/ORDW/medi01.dbf' size 100M autoextend on next 100M;
sql> CREATE USER medi IDENTIFIED BY abc DEFAULT TABLESPACE medis TEMPORARY TABLESPACE temp;
sql> GRANT dba TO medi;

--创建归档数据表用户空间
sql> create tablespace tars datafile '/u01/app/oracle/oradata/ORDW/tar01.dbf' size 100M autoextend on next 100M;
sql> CREATE USER tar IDENTIFIED BY abc DEFAULT TABLESPACE tars TEMPORARY TABLESPACE temp;
sql> GRANT dba TO tar;
