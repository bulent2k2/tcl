# left-edge..

namespace eval le {
    proc le nets { a net is simply a list of numbers -- double, i.e. real, instead of int, or natural, to make it more flexible }
    proc findMin {} { how many trunks do we need? }
    proc vputs str  { variable v; if {$v>0} { puts $str } } ; # for viz..
    variable v 0
    proc ~le {} { deconstruct here }
}

proc le::le nets {
    variable numbers
    ~le
    foreach net $nets {
	lassign $net a b
	if {$a > $b} { swap a b }
	lappend numbers($a) "a.$net"
	lappend numbers($b) "b.$net"
    }
}
proc le::findMin {} {
    variable numbers
    set num_trunks 0
    set max 0
    foreach number [lsort -dict [array names numbers]] {
	set num_start 0 ; # in case of aligned pins, need to first add to find the max...
	set num_end 0   ; # ... and then subtract..
	foreach end_points $numbers($number) {
	    lassign [split $end_points .] which net
	    switch $which {
		a { vputs "Start $net.."; incr num_start }
		b { vputs "End $net.."; incr num_end -1 }
		default { error "Switch expects a or b. Got: < $which >." }
	    }
	}
	incr num_trunks $num_start
	if {$max < $num_trunks} {
	    set max $num_trunks
	}
	incr num_trunks $num_end
    }
    return $max
}
proc le::test1 {} {
    le::le {
	"0 2" "3 5" "6 7"
	"1 4" "5 8"
	"-1 10"
    }
    le::findMin
}
proc le::~le {} {
    variable numbers
    array unset numbers
    array set numbers {}
}

proc le::test2 {} {
    le::le {
	"0 2" "3 5" "6 7"
	"1 4" "5 8"
	"-1 10"
	"0.1 1.9" "1.91 1.99"
    }
    le::findMin
}
proc le::test3 {} {
    le::le {
	"1 1" "2 2" "0 1"
	"1 2" "0 1" "-1 1" "2 3"
    }
    le::findMin
}


assert {3==[le::test1]} "Test1"
assert {4==[le::test2]} "Test2"
assert {5==[le::test3]} "Test3"

puts "All is well."
