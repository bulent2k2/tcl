# Instead of 'source' use 'define'
proc define {path} {
    ::use::remember_globals
    uplevel source $path
    ::use::update_globals
}
namespace eval ::use {}
proc ::use::remember_globals {} {
    variable ::tcl_cmds [namespace eval :: info commands]
}
proc ::use::update_globals {} {
    variable ::tcl_cmds
    set new {}
    foreach cmd [namespace eval :: info commands] {
	if {-1 == [lsearch $tcl_cmds $cmd]} {
	    lappend new $cmd
	}
    }
    if {[set count [llength $new]] > 0} {
	puts "There are $count new commands: <[lsort -dict $new]>"
    }
    return $count
}
define u.tcl
