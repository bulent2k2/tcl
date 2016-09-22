# Now in ~/cd/tcl/pgrid.tcl
# see: /u/bbasaran/pgrid_for_prashant.tcl

done {
set pggr1 [createOnePGrid [gad] ga 1.0 1.0   0.0 0.0   0.0 0.0]
#dumpVar pggr1; g $pggr1
set pggr2 [createOnePGrid [gad] gb 1.0 1.0   0.5 0.0   0.0 0.0]
dumpVar pggr1
g $pggr1
}
puts "Use as: createOnePGrid \[gad\] <name> 0.1 0.1"
