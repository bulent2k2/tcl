proc answer {} { sum [digits [factorial 100]] }

proc sum {list} {
    set sum 0
    foreach d $list { incr sum $d }
    set sum
}

proc digits {n} {
    set out ""
    while {$n > 9} {
	lappend out [expr {$n % 10}]
	set n [expr {$n / 10}]
    }
    lappend out $n
    set out
}

proc factorial {n} {
    set val 1
    incr n
    for {set i 2} {$i < $n} {incr i} {
	set val [expr {$val * $i}]
    }
    set val
}

