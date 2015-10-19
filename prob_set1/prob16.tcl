# prob 16 Power Digit Sum

proc answer {} { power_digit_sum 1000 }

proc see {{to_power 20}} {
    foreach x [range $to_power] {
	puts [format "%2s %10s" $x [power_digit_sum $x]]
    }
}

proc power_digit_sum {n} { sum [bits [pow $n]] }

proc pow {n} {
    set pow 1
    for {set i 0} {$i < $n} {incr i} {
	set pow [expr {2 * $pow}]
    }
    set pow
}

proc bits {n} {
    assert [expr {$n >= 0}] 1 "Negative n: $n"
    set bits {}
    set bound [string length $n]
    for {set i 0} {$i < $bound} {incr i} {
	lappend bits [string index $n $i]
    }
    set bits
}

proc sum {bits} {
    set sum 0
    foreach bit $bits { incr sum $bit }
    set sum
}

proc unit_tests {} {
    foreach {string total} { 12345 15    999 27     90909 27 } {
	assert [sum [bits $string]] $total "string: $string"
    }
    foreach {x pow} { 0 1  1 2  10 1024 } {
	assert [expr {[pow $x] == $pow}] 1 "x=$x pow=$pow"
    }
    foreach {x pds} { 0 1    2 4    3 8    4 7    10 7    13 20    14 22} {
	assert [power_digit_sum $x] $pds "x=$x" 
    }
}

proc assert {a b info} { if {$a != $b} { error "Failed: $a $b $info" } }
proc range n { set o {0}; for {set i 1} {$i < $n} {incr i} { lappend o $i }; return $o }
unit_tests

