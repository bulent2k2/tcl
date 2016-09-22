# this -> /u/bbasaran/pgrid_for_prashant.tcl
# Sources build blocks from:
#     bb.tcl  for gad (get active design), l2c (list to collection), etc..
# bb.tcl sources (from TCLROOT if set):
#     /u/bbasaran/cd/tcl/objTable.tcl ; # for g <obj>, e.g., g [gad]

source /u/bbasaran/cd/tcl/bb.tcl
define_sm

proc createOnePGrid {design name dx dy {ox 0.0} {oy 0.0} {tox 0.0} {toy 0.0}} { ; # name: pgrid-name, d: delta, o: (global region) offset, to: track-offset
    set t1 [le::createTrack $name.h -in $design -offset $toy -visible 1 -active 1 -trackType default]
    set g1 [le::createTrackGroupDef $name.h -in $design -tracks [l2c $t1] -layer instance -direction horizontal -pitch "$dx $dy"]

    set t2 [le::createTrack $name.v -in $design -offset $tox -visible 1 -active 1 -trackType default]
    set g2 [le::createTrackGroupDef $name.v -in $design -tracks [l2c $t2] -layer instance -direction vertical   -pitch "$dx $dy"]

    set rd [le::createTrackRegionDef $name.def -in $design -groupDefs [l2c $g1 $g2]]
    set gr [le::createGlobalTrackRegion $name.def -design $design -regionDef $rd -offset "$ox $oy"]
}

set name pg1
set pggr [createOnePGrid [gad] $name 0.5 1.0  0.1 0.2]
dumpVar pggr
g $pggr
