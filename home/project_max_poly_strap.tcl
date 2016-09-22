#
# Project specific parameter settings and overrides
#

proc p_setup_tech {cellid} {
  # load alx default parameter settings
  source [alx get root]/../alx_defaults.tcl

  # input design spec
  alx set param air_od 0          ; # pdiff/ndiff are defined in layout
  # output design spec
  alx set param air_pp 0          ; # maintain existing PP/NP

  # generate od25_33
  alx set param air_od2 25
  alx set param air_gen_od25_33 1

  # set target device sizes to be same as the input layout
  alx set param fix_device_sizes 0
  alx::g poly_spacer 0

  alx set param air_dfm 0

  # device sizing by W/L signature table
  # FROM:  /remote/starc/alx/BMJul2012/cdl/resize_table3.o
#  alx set param air_resize_table [alx get root]/../resize_table3_snapped2.o
#  alx set param air_resize_table [alx get root]/../resize_table3_snapped2_fixed_res.o
  alx set param air_resize_table [alx get root]/../resize_table3_snapped2_fixed_res.o.12122012
  alx set param air_resize {}

  # device sizing on a per-device basis by coordinates
  #  alx set param air_resize {}
  # alx set param air_resize [alx get root]/../resize_file_alx.txt

  # set the number of solver iterations
  alx set param iterations "x y x y x y"
  # alx set param iterations "x y"

  # enable dummy mos device marker (user5 custom layer)
  alx::g2 pcell_dummy_poly_marker user5

  # Tcl callback proc for adding custom bonds
  alx set param custom_bond_cmd ::my_custom_bonds
  alx set param generic_rule_cmd ::my_jbonds

  # enable symmetry bonds for fingers (new mode)
#   global gate_symmetry_bonds
#   set gate_symmetry_bonds 1

  # enable active m1/m2 alignment bond
  global activem1_m2_align
  set activem1_m2_align 1

  # fix fat straps prototype
  alx::g2 smart_hook 1
  alx::g2 identify_junction 1


  # Hierarchy Setup
  # auto flatten cells without any devices
  if {[not_null? $cellid]} {
    alx set param flatten_cell_regexp [alx::find_cells_without_poly $cellid]
  } else {
    alx set param flatten_cell_regexp ""
  }
};
if {![info exists cellid] || ![db check cellId $cellid]} {
  set cellid 0
}
p_setup_tech $cellid


proc add_rail_width_bonds {molid layer tech} {
  bbt::sc
  
  set sf 0.5
  set tw 3.0
  set mw [expr $tw * $sf]
  
  set u1list [alx select layer $molid $layer -tech $tech]
  
  ###################
  # set rail width to 3.0 it was 3.0 in lay-a
  ###################
  alx loop list $u1list id {
    #    lassign [size [dbinfo $molid $id bBox]] w h
    lassign [size [$l [$e $molid $id] bBox]] w h

    if {$h == $mw} {
      tputs "adding width rail constraint layer $layer , y $id"
      alx add constraint width $molid $id -dir y -value $tw -note "rail_width_y_$id"
    } elseif {$w == $mw} {
      tputs "adding width rail constraint layer $layer , x $id"
      alx add constraint width $molid $id -dir x -value $tw -note "rail_width_x_$id"
    }
  }
}

proc add_rail_features {molid layer tech} {
  bbt::sc
  
  set sf 0.5
  set tw 3.0
  set mw [expr $tw * $sf]
  
  set u1list [alx select layer $molid $layer -tech $tech]
  
  ###################
  # 1. set rail width to 3.0 it was 3.0 in lay-a.
  # 2. edge align 3.0u m5 m6 rails to align with m3 3.0u overlapping rails
  ###################
  alx loop list $u1list id {
    #    lassign [size [dbinfo $molid $id bBox]] w h
    lassign [size [$l [$e $molid $id] bBox]] w h

    if {$h == $mw} {
      tputs "adding width rail constraint y $id"
      alx add constraint width $molid $id -dir y -value $tw -note "rail_width_y_$id"

      # find m5/m6 overlapping rail which is also 3.0 wide
      tputs "adding alignment bonds $id 1"
      add_align_bonds $molid $tech $mw $id 1 {m5 m6}

    } elseif {$w == $mw} {
      tputs "adding width rail constraint x $id"
      alx add constraint width $molid $id -dir x -value $tw -note "rail_width_x_$id"

      tputs "adding alignment bonds $id 0"
      add_align_bonds $molid $tech $mw $id 0 {m5 m6}
    }
  }
}

# for rail edge align #
proc add_align_bonds {molid tech mw id ind layers} {
  bbt::sc
  array set darr {0 x 1 y}
  set orails [alx select object overlap $molid $layers $id -tech $tech]
  alx loop list $orails oid {
    #    set ss [size [dbinfo $molid $oid bBox]]
    set ss [size [$l [$e $molid $oid] bBox]]

    if { [lindex $ss $ind] == $mw } {
      tputs "adding edge alignment $darr($ind) $oid"
      # keep_edge_ordering -keep_aligned
      alx add constraint alignment $molid [list $id $oid] -dir $darr($ind) -line both -note "align_rail_$darr($ind)"
    }
  }
}

proc size {box} {
  lassign $box ll ur
  lassign $ll x1 y1
  lassign $ur x2 y2
  set dx [expr $x2 - $x1]
  set dy [expr $y2 - $y1]
  return [list $dx $dy]
}

#
# add symmetry bonds for all fingers for devices touching the edgelayer line
# 
proc add_symmetry {molid layer tech} {
  set u1list [alx select layer $molid $layer -tech $tech]
  tputs "molid:$molid ; border: [alx get list $u1list]"
  alx loop list $u1list id {
    set allfingers {}
    set diffs [alx select object overlap $molid {ndiff pdiff} $id -tech $tech]
    tputs "$diffs : [alx get list $diffs]"
    alx loop list $diffs did {
      set fingers [alx select object overlap $molid {poly} $did -tech $tech]
      tputs "fingers for $did $fingers : [alx get list $fingers]"
      if {[alx get list $fingers -size] > 0} {
	# bin [alx get list $fingers]
	lappend allfingers $fingers
      }
    }
    if {[llength $allfingers] > 0} {
      tputs "adding symmetry bonds for lists: $allfingers"
      alx add constraint symmetry $molid $allfingers -dir x -keep_aligned -soft -force 5000 -note "my_cb_sym"
    }
  }
}

proc ::my_jbonds {args} {
  tputs "Adding JBONDS"

  #####
  # call to custom bonds for dummy devices marker layer
  #####
  user5_for_dummy_poly

  #####
  # Keep Power Rails Outside of Device regions
  #####
  jbond::set_prefix "starc_m3_rail" ; # tag bonds with prefix. GUI uses this to show bonds.
  jbond::space_min {ndiff or pdiff} m3 20
  jbond::space_min rpo m3 20
  # jbond::keep_edge_ordering {ndiff or pdiff} m3 750 ; # creates an m1 stretch due to m3 connection
  # jbond::keep_edge_ordering rpo m3 750 ; # the 750 value does not seem to do anything... why? bond has the value...

  #####
  # Maintain prBoundary and keep bondary outside of m3 rails 
  #####
  jbond::set_prefix "starc_prBoundary" ; # tag bonds with prefix. GUI uses this to show bonds.
  jbond::basic_bonds user2 500 600
  jbond::keep_edge_ordering user2 m3 20 20 20 20 1
  jbond::keep_edge_ordering user2 {ndiff or pdiff} 0 0 0 0 1 ; # this appears to work ok on BIAS
  #  jbond::keep_edge_ordering user2 {ndiff or pdiff} 200 200 200 200 1 ; # results in abstract pop-up and double width guardring on left side in aop_amp_ii_core block
  #####

  #####
  # Maintain m5/m6 co-incidence
  #####
  jbond::keep_edge_ordering m5 m6 0 0 0 0 1

  tputs "Done Adding JBONDS"
}

proc ::my_custom_bonds {molcellid} {
  tputs "Adding Custom Bonds..."
  eval mytime ::add_my_custom_bonds $molcellid
  tputs "Done adding Custom bonds"
}


proc ::add_my_custom_bonds {molcellid} {
  # clean-up all custom bonds (in case you're rerunning multiple times
  # NOTE: comment this out if adding custom bonds from the ALX GUI!
  alx delete constraint $molcellid all

  # compact most layers
  mytime add_compaction_bonds

  # symmetry bonds around the "edgeLayer" shape
  #  add_symmetry $molcellid user1 [lindex [alx::g techb] 0]

  # set m3 horizontal rails widths to 3.0 microns
  mytime add_rail_features $molcellid m3 tsmc45lp_ipdk
  mytime add_rail_width_bonds $molcellid {m2 m4} tsmc45lp_ipdk

  mytime max_poly_strap_contacts $molcellid

  # print the custom bonds (Debug)
  #  set i 0; foreach cb [alx::cbond::get all] { tputs "cb[string_pad [incr i] 4] $cb" }
  tputs "* [llength [alx::cbond::get all]] custom-bonds are created"
}

# compact resistors, mos, implants, wells, and poly (only in vertical dir)
proc add_compaction_bonds {} {
  set layers {rh ndiff pdiff nwell nplus pplus}
  foreach layer $layers {
    alx_compact_user_layer $layer 1000
  }
  alx_compact_user_layer poly 1000 y
}

proc max_poly_strap_contacts {m {force 1000}} { ; # molcell id
    bbt::sc
    bb::require {i b}
    set counter 0
    set counter2 0
    set cmd alx::cbond::add
    #set cmd mputs
    alx loop list [alx select object overlap $m m1 [alx select layer $m poly]] m1o { ; # for each m1 object that overlaps a poly
	  tputs "selected po over m1: $m $m1o"
        foreach poo [alx select connected $m $m1o -cut] {
		  tputs "found connected m1o $m $m1o $poo"
		  if {[get_tag_of_molcell_obj $poo] == "poly"} {
			  tputs "found poly connected m1o $m $m1o $poo"
                incr counter
                set bbox_po [$l [$e $m $poo] bBox]; set lo_po [lindex $bbox_po 0 0]; set hi_po [lindex $bbox_po 1 0]
                set bbox_m1 [$l [$e $m $m1o] bBox]; set lo_m1 [lindex $bbox_m1 0 0]; set hi_m1 [lindex $bbox_m1 1 0]
                if {$lo_po <= $lo_m1} {
				  tputs "adding < $m1o $poo"
                    $cmd     spacing "$m1o $poo" -edges 00 -dir x -as_is -value 0 -desc po_strap -soft -force $force
                } else { ; # order them, lest m1 is pushed inside the po strap...
				  tputs "redundant $m1o $poo"
                    # Redundant, because poly interhook connecting to m1 already has min_spacing bonds
                    #$cmd min_spacing "$m1o $poo" -edges 00 -dir x -as_is -value 0 -desc po_strap
                }
                if {$hi_po >= $hi_m1} {
				  tputs "adding > $m1o $poo"
                    $cmd     spacing "$poo $m1o" -edges 11 -dir x -as_is -value 0 -desc po_strap -soft -force $force
                } else {
                    #$cmd min_spacing "$poo $m1o" -edges 11 -dir x -as_is -value 0 -desc po_strap
                }
                comment Not needed? {
                    # if poo is not going thru diff (it's wider than the finger), we are done..
                    if {0 == [util get reflist [alx select object overlap $m $poo dev_mos] -size]} { 
                        continue
                    }
                }
                # now, max out the poly when it is not flush with the poly_gate (slow?)
                alx loop list [alx select object overlap $m poly_ext $poo] pg {
                    set bbox_pg [$l [$e $m $pg] bBox]; set lo_pg [lindex $bbox_pg 0 0]; set hi_pg [lindex $bbox_pg 1 0]
                    set lo [expr {$lo_pg >= $lo_po}] ; # if not lo, pull po towards the lo edge of gate
                    set hi [expr {$hi_po >= $hi_pg}] ; # if not hi, pull po towards the hi edge of gate
                    if {$lo && $hi} { continue }
                    alx loop list [alx select object overlap $m poly $pg] po2 { ;# find the gate mol
                        if {$po2 != $poo} {
                            incr counter2
                            if {!$lo} {
                                $cmd spacing "$po2 $poo" -edges 00 -dir x -as_is -value 0 -desc po_strap2 -soft -force [expr {5*$force}]
                            }
                            if {!$hi} {
                                $cmd spacing "$po2 $poo" -edges 11 -dir x -as_is -value 0 -desc po_strap2 -soft -force [expr {5*$force}]
                            }
                            break
                        }
                    }
                    break
                }
            }
        }
    }
    tputs "Added cbonds for $counter poly-strap(s) (to max m1). $counter2 need(s) cbonds to expand poly, too."
    return $counter
}

proc get_tag_of_molcell_obj {obj} { alx::molcell::get_layer_tag [alx::molcell::get_mid_of_objid $obj] }

# bonds needed to migrate dummy marker layer and make sure that 
# each dummy poly mol stays with poly finger mol it marks
proc ::user5_for_dummy_poly {} {
    jbond::set_prefix "dpm" ; # dummy poly marker
    jbond::basic_bonds user5 100 40
    proc jbond::iorder {l1 l2 {offset 40}} {
        keep_edge_ordering $l1 $l2 $offset $offset $offset $offset 1
    }
    jbond::iorder user5 poly
}

# 
## DFM_options DFM+Analog
#
proc ::set_various_pcell_params { pcellid tlgcellid tlgid pcells } { ; # set two custom params for gnap
  set pcells_out {}
  set params [alx get param various_pcell_params]
  foreach pcell $pcells {
    if {[null? [set name [lfetch $pcell mname]]]} { continue }
    if {[catch { eval ::alx::pcell::add_param pcell $params } msg]} { puts "-w- test error: $msg." }
    lappend pcells_out $pcell
  }
  return $pcells_out
}

alx set param various_pcell_params "{DFM_options DFM+Analog} {nwLayer 1} {impLayer 1} {drainMetalCoverage 80} {sourceMetalCoverage 80}"
alx::g pcell_pre_create_api ::set_various_pcell_params

