options(skip=1,direct=true,parallel=true)
load data
characterset UTF8
infile '/u01/app/oracle/oraldr/loaddata.csv' "str '\r\n'"
append into table "SETL_LIST_OPRN_D"
fields terminated by '|'
OPTIONALLY ENCLOSED BY '@|' AND '|@'
trailing nullcols
( setl_list_oprn_id FILLER,
setl_id,
psn_no,
mdtrt_id,
main_oprn_flag,
oprn_oprt_name,
oprn_oprt_code,
oprn_oprt_date,
anst_way,
oper_dr_name,
oper_dr_code FILLER,
anst_dr_name,
anst_dr_code FILLER,
vali_flag FILLER,
rid FILLER,
updt_time FILLER,
oprn_oprt_begntime,
oprn_oprt_endtime,
anst_begntime
)