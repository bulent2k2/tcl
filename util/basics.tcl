# What is this? Keep reading!

proc Doc args {}
proc doc args {}
proc comment args {}
Doc utilities, foundational building blocks, etc. 

# This is old assert. It will be overwritten. Don't use it anymore. See: assert.tcl
# Use as 'assert 1 [set x 1] "Cmd <set> is tested (:-)"
proc assert {a b info} { if {$a != $b} { error "Failed: <$a> <$b> <$info>" } } ; # info should say what new cmd this assert call wants to test..

# show the declaration of a proc 
proc s {procname {show_definition_too 0}} {
    set body [info body $procname]
    set args ""
    foreach arg [info args $procname] {
	if {[info default $procname $arg default]} {
	    lappend args "$arg $default"
	} else {
	    lappend args $arg
	}
    }
    set header "proc $procname {$args}"
    if {$show_definition_too == 0} {
	puts "$header {...}"
    } else {
	puts "$header {"
	puts $body
	puts "} ; \# proc $procname {$args}"
    }
}

proc plural? count { expr {$count > 1||$count==0?"s":""} }

proc proc_name {} { uplevel {lindex [call_info] 0} } 
# print <proc_name args...>
proc call_info {} { uplevel {info level [info level]} }
proc caller_info {} { if {2 >= [info level]} return ; uplevel 2 {info level [info level]} }
proc caller_name {} { uplevel [lindex [caller_info] 0] }

proc swap {_a _b} {
    upvar $_a a
    upvar $_b b
    set tmp $a
    set a $b
    set b $tmp
    return 
}
