options(skip=1,direct=true,parallel=true)
load data
characterset UTF8
infile '/u01/app/oracle/oraldr/loaddata.csv' "str '\r\n'"
append into table "SETL_LIST_DIAG_D"
fields terminated by '|'
OPTIONALLY ENCLOSED BY '@|' AND '|@'
trailing nullcols
( setl_list_diag_id FILLER,
setl_id,
mdtrt_id,
psn_no,
diag_type,
maindiag_flag,
diag_code,
diag_name,
adm_cond_type,
vali_flag FILLER,
rid FILLER,
updt_time FILLER
)