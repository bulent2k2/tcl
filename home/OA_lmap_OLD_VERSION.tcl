# from /tmp/bulent/test/alx/OA/lmap/main.tcl

# OLD VERSION!

#return
source init.tcl
t::wait
t::boot

if {0} {
    alx::msource ~/ct/tech/lmap2.tcl
    alx::g2 noa_use_alx_ext_dt 1 ; # so we can see alx internal layers: bound, cell_bbox, dev_mos, etc.. Used to create ~/alxh.cfg. Not needed anymore??
}
alx::msource ~/ct/n.tcl

proc main {} {
    msetup
    return
    set layb [alx migrate -cellId [mload]]
    mcheck $layb [alx::m]
    alx run pcell -cellId $layb
    bb::dump "All is well." test.nlog
    #tclExit
}
proc mload {} { db open cell [db open lib OATEST r] Top layout -mode r }
proc msetup {} {
    set tech tsmc45lp
    alx::new_airdb 1
    # root/techb/tsmc45lp/titan.cfg
    # file cp ~/alxh.cfg root/techb/$tech/titan.cfg
    alx setup -techa $tech -techb $tech -sf 0.2 -root ./root
    alx set param iterations "x y"

    # use user's alxh to create lay-b (so we can use the oaTech)
    # use internal alxh to create molcell (can also use lay-b for this now?)
    
    alx::g2 libb_id [mcreate_lib_ref [set libb_name "libb"] [set pdk tsmcN45]]

    # for pcell:
    alx set pdk params $tech -titan_libname [set pdk_name tsmcN45] \
        -titan_libpath [set pdk_path /slowfs/titan_scm/data/reg_data/PDKs/tsmcN45/OA] \
        -cds_libfile [set lib_def_file lib_new.defs] \
        -cache ./cache -cds_path [set cds_install_path _empty_] ; # not used (for skill pdk's only)

    alx::g2 libe_id [mcreate_lib_cfg "libe" [set libb_cfg ./cfg/alxh.cfg]]
    alx::g2 libt_id [mcreate_lib_cfg "libt" $libb_cfg]
    alx::g2 libp_id [mcreate_lib_ref "libp" $pdk]
}

proc mcreate_lib_cfg {name cfg} {
    file delete -force $name
    db create lib $name $cfg
    db open lib $name w
}
proc mcreate_lib_ref {name pdk} {
    file delete -force $name
    set id [db create lib $name $pdk]
    db set lib refLibs $id $pdk
    edbWriteCfgToDisk $id
    db open lib $name w
}

proc mcheck {layb molcell} {} 

main
#set cfgfile1 [alx::lmap::get_cfgfile tsmc45lp -ext -color]
