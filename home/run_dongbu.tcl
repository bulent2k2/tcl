# Re: /remote/us01home36/rdevmore/idt_dongbu/chg_core_with_jbonds/run.tcl
source ./.titanprocs.tcl ; # /remote/us01home36/rdevmore/idt_dongbu/chg_core_with_jbonds/.titanprocs.tcl

alx::boot
alx::new_airdb 1

alx::msource /slowfs/titan1/alx/test/dongbu/src/jbonds.tcl

source /remote/us01home36/sabbas/alxutils/change_object_layer_datatype.tcl
source /remote/us01home36/sabbas/alxutils/flatten_insts.tcl

# set the cell list being migrated
lassign {testlib chg_core} lib cname
set view layout

set libid [db open lib $lib r]

#set cname DPDM_AnaTop_C
#set topid [db open cell $libid $cname $view -mode r]
set cellid [db open cell $libid $cname $view -mode r]
tputs ">working on cell [dbutil::get_cell_name $cellid]"

# set the root area where all process/tech related files are kept
alx set root ./project/root ; # /remote/us01home36/rdevmore/idt_dongbu/chg_core_with_jbonds/project/root

# setup migration from idt90 to tsmc45gs (sf == scalefactor)
alx setup -techa tsmc250g -techb [set techb dongbu180x] -sf 1.0 ;# -sf 0.72 ; # BB: 1.0
# load this project related settings
variable ::_no_gate_ 0
source ./project/project.tcl ; # /remote/us01home36/rdevmore/idt_dongbu/chg_core_with_jbonds/project/project.tcl

alx set param custom_bond_cmd ::my_custom_bonds
proc ::my_custom_bonds {molcellid} {
    alx_compact_user_layer rh
    alx_compact_user_layer user6
    alx_compact_dev_diff
}

alx set param fix_device_sizes 1

# flatten the pcells as selected by the g param below (new flow does not do this automatically yet):
# alx::g air_cell_flatten_api ::flattenCell (in project.tcl)
alx::hinfo $cellid [set open_with_write_access 1]; # opens all cells to write...
mytime bbt::flatten::flatten_pcells $cellid ; # TODO: do the once for the top-cell, save and re-use for reg

set resultid [mytime alx migrate -cellId $cellid]

# generate pcells
#alx::msource ~bbasaran/hotfix/20120222/extract_dev.tcl
#source /remote/us01home36/sabbas/alxutils/setup_pdk_dongbu180.tcl
#!! Pcell gen disabled
#set pcellid [mytime alx run pcell -cellId $resultid -debug]
#alx report pcell

#######################
# BEGIN post-processing
#######################
#foreach libName [list $lib@alxh_$techb $lib@alxh_pcell_$techb] {}
set libName $lib@alxh_$techb
  
db copy library [set rlib $libName] [pwd] [pwd] [set clib ${rlib}_edit]
set new [db open cell [db open lib $clib] $cname $view]

# move hvnw (dnw tag, layer 22) to nwell layer 2
change_object_layer_datatype $new 22 252 2 252 ; # dnw to nw

alx::delete_alx_property $new
set contr [alx generate implant layers $new]

# generate deep nwell, sdnw, sdpw layers
m_gen_dnw_layers $new $contr 200

# delete od shapes from the container cell (these were temporary shapes)
delete_objects_on_layer $contr 3
# copy dnw shapes to nbl layer in implant container
copy_objects_on_layer $contr 22 96
# delete the old nwell shapes (since sdnw has been created on the sdnw layer now)
delete_objects_on_layer $new 2

# change ndiff/pdiff to od
change_object_layer_datatype $new 100 252  3 252 ; # pdiff to diff
change_object_layer_datatype $new 101 252  3 252 ; # ndiff to diff

# fill gaps in HRI (90S6a :   hri-hri gaps 2.0 (hri to poly spacing at least 2.0) (layer 90))
fill_holes user7 $new $contr 1000
# fill gaps in SAB
fill_holes user6 $new $contr 300
# fill gaps in RESIST
fill_holes rpo $new $contr 710
# fill gaps in HRID
fill_holes user5 $new $contr 1000
# fill gaps in TGOX50
fill_holes od2 $new $contr 225

saveall
tputs ">done with cell $cname"
 return
# copy and flatten the design for DRC (bug with QuarzDRC does not work well when not flat)
db copy library [set rlib $clib] [pwd] [pwd] [set drclib x_DRC]
set drcId [db open cell [db open lib $drclib] $cname $view]
win open cellId $drcId
flatten_insts
cd drc_gary
source exportGDS.tcl
source run_calibre2quartz_DRC.tcl
tputs ">done running DRC on cell $cname"
