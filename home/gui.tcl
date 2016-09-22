proc alx::update_bbond_db_for_iteration {iteration_count {dont 1}} {
    if {$dont == 1} { puts "Skipped [lrange [bb::stack] 0 3]"; return }
    puts "[bb::stack]"
    # do this first, before taking seriously the conflicting/relaxed bonds displayed in the GUI!
    set f1 [file join [set path [file join [dir] molcell]] [g bbond_filename]] ; # fullpath to molcell/bbonds.tcl
    set f1 "$f1-$iteration_count" ; # fullpath to molcell/bbonds.tcl-2, e.g.
    if {![file readable $path]} { dputs "No path=$path";  return }
    if {![file exists $f1]} { ; # it is generally zipped
        set f2 "$f1.gz"
        if {![file exists $f2]} {
            iputs "Can't read bbond file for iter $iteration_count. Path $path has:\n[join [exec ls $path]]"
            return
        }
        set f1 $f2
    }
    alx::bbond::load_with_duplicates $f1
}
