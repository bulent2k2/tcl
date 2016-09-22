alx::boot
bb::error_good
alx::g pcell_pdk_path /remote/titan_testcases01/pdk
source [alx::ui::ui_dir testCases.tcl]
source [alx::ui::ui_dir testProcs.tcl]

set libid [db open lib sap_txrx2 r /remote/gemini2/alx/reg/lib ]
set cellid [db open cell $libid SAP_TXRX_BIAS lay -mode r]
alxReg::get_proj_info sap_txrx2 -setup tsmc45gs -root /remote/gemini/test/alx/20120901
alx::g2 hier_run 1
#bb::mytime alx run solver -cellId $cellid -flat

db close cell $cellid
db close lib $libid

set libid [db open lib sap_txrx2@alx_tsmc45gs w .]
set cellid [db open cell $libid SAP_TXRX_BIAS lay -mode w]

set ::pcCDSFile /remote/gemini2/alx_regression/linux26_x86_64/weekly/reg_09012012/Unit/ALX_WEEK/tsmc45gs/sap_txrx2__SAP_TXRX_BIAS/cds_tsmc45gs.lib
set ::pcExecPath /home/mojave/tools/cadence/CDS_61_INSTALL/CDS_INST_DIR
set ::pcIsCDBExec 0
set ::pcCDSAutoLaunch 0
set ::pcCDSInitFiles ""
set ::pcCDSCommandArgs ""
set ::pcUseCDFParams 1
#cp -r /remote/gemini2/alx_regression/linux26_x86_64/weekly/reg_09012012/Unit/ALX_WEEK/tsmc45gs/sap_txrx2__SAP_TXRX_BIAS/pcell_cache /remote/gemini2/alx_regression/linux26_x86_64/weekly/reg_09012012/Unit/ALX_WEEK/tsmc45gs/sap_txrx2__SAP_TXRX_BIAS/tsmc45gs_Hier0/sap_txrx2.SAP_TXRX_BIAS/pcell_cache
tool set configuration -pCellCacheDir /remote/gemini2/alx_regression/linux26_x86_64/weekly/reg_09012012/Unit/ALX_WEEK/tsmc45gs/sap_txrx2__SAP_TXRX_BIAS/tsmc45gs_Hier0/sap_txrx2.SAP_TXRX_BIAS/pcell_cache
unless [bbt::gtcl?] { if {![info exists ::REG_START]} { vwait ::REG_START } }
#bb::mytime alx run pcell -debug -cellId $cellid
