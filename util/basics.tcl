# What is this? Keep reading!

proc Doc args {}
proc doc args {}
proc comment args {}

Doc utilities, foundational building blocks, etc. I.e., basics missing in tcl.


# https://en.wikibooks.org/wiki/Tcl_Programming/Debugging#Assertions
proc assert {condition {tag ""}} {
   set s "{$condition}"
   if {![uplevel 1 expr $s]} {
       if {$tag == ""} {
	   return -code error "assertion failed: $condition"
       } else {
	   return -code error "$tag assertion failed: $condition"
       }
   }
}


# show the declaration and optionally the definition of a proc
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
proc is_or_are? count { expr {$count > 1||$count==0?"are":"is"} }
proc it_or_they? {count {capital ""}} {  
    set word [expr {$count > 1||$count==0?"they":"it"}]
    if {$capital != ""} { 
	set word [string totitle $word]
    }
    set word
}

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

proc sei {} {
    global errorInfo
    set errorInfo
}
proc stack {} { puts [sei] }

proc unused_proc_name {name} {
    set cnt 0
    while {1} {
	set cmd [join "$name [incr cnt]" _]
	if {[info command $cmd] == ""} {
	    break
	}
    }
    set cmd
}

# if the key exists, incr value,
# otherwise, set value
proc array_incr {name key value} {
    upvar $name a
    [expr {[info exists [set elem a($key)]]==1?"incr":"set"}] $elem $value
}

proc string_trim {str {chars " "}} { ; # 'string trim' only trims prefix and suffix. We want to trim all interior chars, too
    regsub -all $chars $str ""
}




proc unit_test {} {
    # test: proc assert
    proc [set cmd [unused_proc_name "mult"]] {} { return 16 }
    lassign {3 5} x y
    assert {$x * $y < [$cmd] && [$cmd] / $x == $y} "ASSERT"
    rename $cmd ""

    # test: proc unused_proc_name
    proc test {} {}
    assert {[unused_proc_name test] == "test_1"} unused_proc_name1
    proc test_1 {} {}
    assert {[unused_proc_name test] == "test_2"} unused_proc_name2
    foreach p {test test_1} {
	rename $p ""
    }

    # test: so on and so forth..
}
unit_test
rename unit_test ""
