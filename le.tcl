# left-edge..

namespace eval le {
    proc le nets { Input horizontal trunks: List("<left-edge> <right-edge> [<netname>]") }
    proc findMin {{cb ""}} { How many trunks do we need? Optionally, call the call back as [cb $netname $track_id $left $right] }
    proc vputs str  { variable v; if {$v>0} { puts $str } } ; # for viz..
    variable v 0
    proc ~le {} { Deconstruct here }
}

proc le::le {nets_} {
    ~le
    variable numbers ; # populate with the left edge coordinates
    variable nets    ; # table to get left and right edges from netname
    foreach net $nets_ {
	lassign $net a b netname
	if {$a > $b} { swap a b }
	if {$netname == ""} { set netname "\[$a,$b\]" }
	lappend numbers($a) $netname
	set nets($netname) "$a $b"
    }
}
proc le::findMin {{get_assignment ""}} {
    variable numbers
    variable nets
    set tracks [list] ; # element i has the max b of the nets assigned to track i
    foreach le [lsort -dict [array names numbers]] {
	vputs "le=$le tracks: $tracks"
	foreach netname $numbers($le) {
	    lassign $nets($netname) a b
	    assert {$a == $le} "net:$netname a=$a le=$le"
	    set track [_assignToTrack $netname $a $tracks]
	    if {"" != [info command $get_assignment]} { $get_assignment $netname $track $a $b }
	    lset tracks $track $b
	}
    }
    return [llength $tracks]
}

proc le::_compare {o1 o2} { expr {[lindex $o1 0] > [lindex $o2 0]} } ; # ascending sort 

proc le::_assignToTrack {netname a tracks} {
    set options [list]
    set i -1
    foreach b $tracks {
	lappend options "[expr {$a - $b}] [incr i]"
    }
    lsort -command _compare $options
    foreach o $options {
	lassign $o gap track
	if {$gap > 0} {
	    return $track
	}
    }
    return [llength $tracks]
}

# To see the callback working, do:
if (0) {
    set le::v 1
    le::test0
}
proc le::test0 {} {
    le::le {
	"0 1 n1" "2 3 n2"
	"1 2 n3"
	"0 1 n4" "2 3 n5" }
    le::findMin _lambda_
}
proc _lambda_ {args} { lassign $args net track a b; ::le::vputs "$net \[$a,$b\] -> track=$track" }

proc le::run_unit_tests {} {
    foreach {name golden} {
	test0 3
	test1 3
	test2 4
	test3 5
	test4 5} {
	vputs "Running $name"
	set val [$name]
	assert {$golden == $val} "$name expecting < $golden > got < $val >"
    }
}

proc le::test1 {} {
    le::le {
	"0 2 n1" "3 5 n2" "6 7 n3"
	"1 4 n4" "5 8 n5"
	"-1 10 n6"
    }
    le::findMin
}

proc le::~le {} {
    foreach a {numbers nets} {
	variable $a
	array unset $a
	array set $a {}
    }
    if 0 { ; # no need
	foreach l {tracks} {
	    variable $l
	    set $l [list]
	}
    }
}

proc le::test2 {} {
    le::le {
	"0 2 o1" "3 5 o2" "6 7 o3"
	"1 4 o4" "5 8 o5"
	"-1 10 o6"
	"0.1 1.9 o7" "1.91 1.99 08"
    }
    le::findMin
}
proc le::test3 {} {
    le::le {
	"1 1 x1" "2 2 x2" "0 1 x3"
	"1 2 x3b" "0 1 x4" "-1 1 x5" "2 3 x6"
    }
    le::findMin
}
proc le::test4 {} {
    le::le {
	"0 1" "2 5"
	"1 2" "3 4" "5 6"
	"1 3" "4 6"
	"0 1" "2 4" "5 6"
	"0 1" "2 3" "4 5" }
    assert {5 == [findMin]} [proc_name]
    return 5
}

le::run_unit_tests

puts "All is well."
