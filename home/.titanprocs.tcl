proc stp {} "source [info script]"
tool set configuration -autoRedraw yes
tool set configuration -justDesignLayers yes

source /remote/us01home36/sabbas/.titanprocs.tcl
puts "finished: /remote/us01home36/sabbas/.titanprocs.tcl"
source /remote/us01home36/bbasaran/bulent/.titanprocs.tcl
source ~/t/alx/init.tcl
if {![namespace exists alx]} {
    puts "Sourcing test/alx/init.tcl and booting alx.."
    t::boot!
}
t::load_samples

foreach x {pin text} {
    proc get_${x}s {{cellid 0} {bin_them 1}} [format {
        set x %s
        set out [${x}::get_${x}s [set cell [bbt::cell $cellid]]]
        if {[null? $out]} {
            puts "No $x found in cell [get_cell_name $cell] (id=$cell)."
        } else {
            if {$bin_them == 1} {
                bin $out
                puts "Added [llength $out] $x objects to the bin."
            }
        }
        set out
    } $x]
}
#bbt::remove_ldp
proc get_tlgs {{cellid 0} {bin_them 1}} {
    set out [list]
    db loop object x [set cell [bbt::cell $cellid]] lineHeader {
        lappend out $x
    }
    if {[null? $out]} {
        puts "No TLG found in cell [get_cell_name $cell] (id=$cell)."
    } else {
        if {$bin_them == 1} {
            bin $out
            puts "Added [llength $out] TLGs to the bin."
        }
    }
    set out
}
proc get_via_arrays {cellid {regexp ""}} {
    set out {}
    bbt::sc
    db loop object x $cellid viaarray {
        if {[not_null? $regexp]} {
            set name [$l [$e $cellid $x] viaName]
            if {![regexp $regexp $name]} { continue }
        } 
        lappend out $x
    }
    set out
}
proc get_via_array_net_ids {cellid} {
    set count 0
    set bad 0
    db loop object x $cellid viaarray {
        incr count
        if {![set netid [lAssocFetch [edbFetchObject $cellid $x] netId]]} {
            incr bad
            puts "netid=$netid: $x"
        }
    }
    puts "Visited $count via arrays. $bad has no net."
}
proc m2o m { alx::molcell::get_objid_of_mid $m }
proc o2m o { alx::molcell::get_mid_of_objid $o }
proc ac {} bbt::cell
proc bin { ids } { foreach id $ids { win add object to bin [win get window active] $id } }
proc clear_bin {} { win clear bin [win get window active] }

proc rect2poly {} { ; # see doc for {lay eval shape}
    set rects [list]
    edbSeq r [bbt::cell] rectangle {
        lappend rects $r
    }
    bbt::sel_objs $rects
    layBoolOr -delete1 -win [win get window active] -operand1 default
    redraw
}

proc get_layer_no {cellid layer_name} { ; # use bbt::get_layer_number instead
    set layer_no [lAssocFetch [tf get layer info [edbGetCellIdLibId $cellid] $layer_name] layerNumber]
}

proc comment args {}
comment SPEC {
func {alx generate polygons} {cellId:i -noHier:b} {
    if {[db check cellId $cellId]==0} { error "cellID is not valid." }
    catch { eval alx gen polygons $cellId }
    if { ![info exists noHier] } {
        foreach cid [alx::get_libb_cells $cellId] {
            catch { eval alx gen polygons $cid }
        }
    }
    return 0
}

in {alx migrate} {
    # do after {alx fix guardRing}
    if {[alx::g generate_polygons]} {
        bb::mytime alx generate polygons $out
    }
}

in g.tcl {
    generate_polygons     - 0 alx 0 1 {bool} { Generate polygons instead of rectangles in the layout }
}
} END SPEC ; # SPEC

puts "finished: ~/.titanprocs.tcl"
