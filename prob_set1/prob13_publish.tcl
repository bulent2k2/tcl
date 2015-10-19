proc _sum {many} {
    set carry 0
    for {set bit 0} {$bit < [bits]} {incr bit} {
	set sum $carry
	for {set n 0} {$n < [nums]} {incr n} {
	    incr sum [digit $n $bit]
	}
	set carry [expr {$sum / 10}]
	set bits($bit) [expr {$sum % 10}]
    }
    set bits([incr bit]) $carry
    set sum {}
    foreach bit [lsort -int -decreasing [array names bits]] { ; # BUG: need -int!
	append sum $bits($bit)
    }
    set tmp $many; incr many -1
    puts "First $tmp digits: [string range $sum 0 $many]"
    puts "Last  $tmp digits: [string range $sum end-$many end]"
    return $sum
}

proc sum {} {
    variable x_org
    variable x $x_org
    _sum 10
}
proc sum_test2 {} { ; # this test helped me find the bug in an earlier version!
    variable x_org
    variable x [lrange $x_org 0 1]
    _sum 10
}
proc sum_test {} {
    variable x_test
    variable x $x_test
    _sum 3
}

proc bits {} { ; # how many digits in each num
    variable x
    string length [lindex $x 0]
}

proc nums {} { ; # how many numbers? 100
    variable x
    llength $x
}
proc digit {n bit} { ; # the value of the digit of the given number at the given bit
    variable x
    string index [lindex $x $n] [expr {[bits]-$bit-1}]
}

set x_test {
8991
8991
8991
8991
8991
8991
8991
8991
8991
8991
8991
}

set x_org {
37107287533902102798797998220837590246510135740250
46376937677490009712648124896970078050417018260538
74324986199524741059474233309513058123726617309629
... omitted ...
53503534226472524250874054075591789781264330331690
}

set why_not_smile "Why not smile Now?"
