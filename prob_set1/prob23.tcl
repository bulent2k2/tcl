source u.tcl

# prob 23

doc Non-abundant Sums {
    A perfect number is a number for which the sum of its proper divisors is exactly equal to the number. For example, the sum of the proper divisors of 28 would be 1 + 2 + 4 + 7 + 14 = 28, which means that 28 is a perfect number. 

    A number n is called deficient if the sum of its proper divisors is less than n and it is called abundant if this sum exceeds n.

    As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16, the smallest number that can be written as the sum of two abundant numbers is 24. By mathematical analysis, it can be shown that all integers greater than 28123 can be written as the sum of two abundant numbers. However, this upper limit cannot be reduced any further by analysis even though it is known that the greatest number that cannot be expressed as the sum of two abundant numbers is less than this limit.

    Find the sum of all the positive integers which cannot be written as the sum of two abundant numbers.

}

doc Answer {
    (tcl) 60 % time { puts [sum [get_nonabundant_sums_less_than [bound]]] }
    4179871
    118197325 microseconds per iteration
    (tcl) 61 % 
}

proc get_nonabundant_sums_less_than {bound} {
    set out {}
    set last 1 ; # last non-abundant we summed is less than this
    foreach abundant [get_abundant_sums_less_than $bound] {
	if {$abundant > $bound} break
	for {set i $last} {$i < $abundant} {incr i} {
	    lappend out $i
	}
	set last [incr i]
    }
    set out
}

proc get_abundant_sums_less_than {bound} {
    set range [abundants_less_than $bound]
    foreach num $range {
	foreach num2 $range {
	    set table([expr $num+$num2]) 1
	}
    }
    lsort -int [array names table]
}

proc answer {} { sum_until_old [bound] }
proc sum_until_old {bound} {
    set sum 0
    foreach a [get_nonabundant_sums $bound] {
	incr sum $a
    }
    set sum
}

proc get_nonabundant_sums {bound} {
    variable range [abundants_less_than $bound]
    set out [range_natural 23] 
    for {set i 25} {$i < $bound} {incr i} {
	if {![sum_of_two_abundants? $i]} {
	    lappend out $i
	}
    }
    set out
}

proc sum_of_two_abundants? {num} {
    variable range
    foreach a $range {
	if {$a > $num} break
	foreach b $range {
	    set sum [expr {$a + $b}]
	    if {$sum == $num} { 
		return 1
	    } else {
		if {$sum > $num} break
	    }
	}
    }
    return 0
}

proc abundants_less_than {num} {
    set out ""
    for {set i 12} {$i < $num} {incr i} {
	if {[abundant? $i]==1} {
	    lappend out $i
	}
    }
    set out
}

proc bound {} { set smallest_by_math_proof 28124 }
proc perfect?   num { expr {$num == [sum [divisors $num]]} }
proc deficient? num { expr {$num  > [sum [divisors $num]]} }
proc abundant?  num { expr {$num  < [sum [divisors $num]]} }
proc which?     num {
    set sum [sum [divisors $num]]
    if {$sum > $num} {
	return 1 ; # abundant
    } else {
	if {$sum < $num} {
	    return -1 ; # deficient
	}
    }
    return 0 ; # perfect
}

	
# use as: [show 30 "a p"]
proc show {{bound 200} {what "x"}} { ; # x (any), p, a or d or any combo
    foreach n [range_natural $bound] {
	set which [which? $n]
	set msg "$n -> [name $which]"
	if {[lhas? $what x]} {
	    puts $msg
	} else {
	    if {[lhas? $what p] && $which == 0}  { puts $msg }
	    if {[lhas? $what a] && $which == 1}  { puts $msg }
	    if {[lhas? $what d] && $which == -1} { puts $msg }
	}
    }
}

proc name {flag} {
    if {$flag < 0} { return "d" } else {
	if {$flag > 0} { return "a" } else {
	    return "p"
	}
    }
}

proc unit_test {} {
    # #6: 8589869056 and the seventh perfect numbers 137438691328
    foreach p {1 6 28 496 8128 33550336 8589869056 137438691328} {
	puts "$p -> [lsort -int [divisors $p]]\n"
	assert 1 [perfect? $p] "<perfect> $p"
    }
    foreach n {123124189080 10 100 1000 999} {
	assert 0 [perfect? $n] "<perfect> $n"
    }
}

unit_test
