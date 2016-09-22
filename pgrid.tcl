# Now in tgz file:
#   gtar -zxf /remote/helix01/user/bulent/test/maxwell/pgrid/archive/pgrid_test_for_pv.tgz
#   cd placement_grid_test/
#   cdesigner -tcl pgrid.tcl
# This: ~bbasaran/cd/tcl/pgrid_pv.tcl
# Any questions or bugs? Please email bbasaran@synopsys.com
proc sample1 {} { createPlacementGrid [gad] placeGrid1 0.2 0.25 }
proc sample2 {} { createPlacementGrid [gad] placeGrid2 1.0 0.75 }

proc createPlacementGrid {design name dx dy {ox 0.0} {oy 0.0}} {
    lassign {0 0} tox toy ; # Unused: tox/toy: track-offset
    # name: pgrid-name, dx/dy: delta (also known as pitch), ox/oy: (global region) offset
    set t1 [le::createTrack $name.h -in $design -offset $toy -visible 1 -active 1 -trackType default]
    set g1 [le::createTrackGroupDef $name.h -in $design -tracks [l2c $t1] -layer instance -direction horizontal -pitch "$dx $dy"]

    set t2 [le::createTrack $name.v -in $design -offset $tox -visible 1 -active 1 -trackType default]
    set g2 [le::createTrackGroupDef $name.v -in $design -tracks [l2c $t2] -layer instance -direction vertical   -pitch "$dx $dy"]

    set rd [le::createTrackRegionDef $name.def -in $design -groupDefs [l2c $g1 $g2] -regionDefType placement ]
    set tr [le::createGlobalTrackRegion $name.def -design $design -regionDef $rd -offset "$ox $oy"]
}

proc gad {} { ; # get active design
    set msg "Try: Design>Open"
    if {[null? [set ctx [de::getActiveContext]]]} {
        error "No active context. $msg"
    }
    if {[null? [set design [db::getAttr editDesign -of $ctx]]]} {
        error "No active design. $msg"
    }
    set design
}

proc l2c {args} { db::createCollection $args }
proc null? {str} { expr {[string length $str]==0 } }
