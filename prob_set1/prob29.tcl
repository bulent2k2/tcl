source u.tcl

# prob 29
Doc Fast {
    (tcl) 87 % answer
    9183
    623901 microseconds per iteration
    (tcl) 88 % 
}
proc answer {} { time { puts [llength [distinct_powers 2 100]] } }

proc distinct_powers {lo hi} {
    incr hi
    for {set a $lo} {$a < $hi} {incr a} {
	for {set b $lo} {$b < $hi} {incr b} {
	    set table([pow $a $b]) 1
	}
    }
    array names table
}

proc unit_test {} {
    assert 15 [llength [distinct_powers 2 5]] "<answer>"
}
unit_test
