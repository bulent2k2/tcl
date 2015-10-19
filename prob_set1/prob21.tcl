# prob 21 - amicable nums

source u.tcl

Doc {
    Let d(n) be defined as the sum of proper divisors of n (numbers less than n which divide evenly into n).
    If d(a) = b and d(b) = a, where a ≠ b, then a and b are an amicable pair and each of a and b are called amicable numbers.

    For example, the proper divisors of 220 are 1, 2, 4, 5, 10, 11, 20, 22, 44, 55 and 110; therefore d(220) = 284. The proper divisors of 284 are 1, 2, 4, 71 and 142; so d(284) = 220.

    Evaluate the sum of all the amicable numbers under 10000.
} 

proc answer {{bound 10000}} { sum_amicable [amicable $bound] }

proc sum_amicable {table} {
    array set d $table
    set sum 0
    foreach n [array names d] { incr sum $d($n) }
    set sum
}
proc amicable {bound} {
    array set d {}
    foreach n [range_natural_open $bound] {
	if {[info exists d($n)]} continue
	set sum [sum [divisors $n]]
	if {$sum != $n && $sum < $bound} {
	    set sum2 [sum [divisors $sum]]
	    if {$sum2 == $n} {
		set d($n) $sum
		set d($sum) $n
	    }
	}
    }
    array get d
}

proc divisors {n} {
    set out {1}
    for {set d 2} {$d < int(sqrt($n))+1} {incr d} {
	if {$n % $d == 0} {
	    lappend out $d [expr {$n / $d}]
	}
    }
    set out
}

proc divisors_recursive {n} {
    set out {1}
    for {set d 2} {$d < int(sqrt($n))+1} {incr d} {
	if {$n % $d == 0} {
	    set n [expr {$n / $d}]
	    foreach d2 [divisors_recursive $n] {
		lappend out $d2 [expr $d2 * $d]
	    }
	    eval lappend out $n $d 
	}
    }
    lsort -u -int $out
}

proc unit_test {} {
    foreach {n d} {220 284  284 220} {
	assert [set out [sum [divisors $n]]] $d "<divisors> $out"
    }
}

unit_test

Doc Answer in < 13 sec {
    (tcl) 371 % array set d [time {puts [amicable 10000]}]
    5564 5020 1210 1184 220 284 6232 6368 2924 2620 2620 2924 1184 1210 284 220 6368 6232 5020 5564
    12802074 microseconds per iteration
    (tcl) 370 % sum_amicable [array get d]
    31626
} About 5 sec after improving divisors proc by using sqrt as bound {
    (tcl) 376 % time {puts [amicable 10000]}
    5564 5020 1210 1184 220 284 6232 6368 2924 2620 2620 2924 1184 1210 284 220 6368 6232 5020 5564
    5426172 microseconds per iteration
    (tcl) 377 % 
} Without recursion {
    (tcl) 405 % time {puts [sum_amicable [amicable 10000]]}
    31626
    1556875 microseconds per iteration
}
