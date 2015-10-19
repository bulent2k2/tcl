source u.tcl

Doc Digit fifth powers {
    # Problem 30
    
}

proc answer {} { search 5 [bound 5] }

Doc Answer {
    (tcl) 137 % time { puts [answer] }
    443839
    3721023 microseconds per iteration
    (tcl) 138 %     
}

proc search {power {bound 10000}} {
    set list {}
    for {set n 11} {$n < $bound} {incr n} {
	if {[sum_digit_power $n $power]} {
	    lappend list $n
	}
    }
    sum $list
}

proc bound {power} {
    set one [pow 9 $power] ; # one digit can have at most this value
    set num_digits 2
    while {1} {
	set max_sum [expr {$num_digits * $one}]
	set min_num [pow 10 [expr {$num_digits - 1}]]
	if {$min_num <= $max_sum} {
	    set bound $max_sum
	    incr num_digits
	} else break
    }
    set bound
}

proc unit_test {} {
    foreach {number power} {
	1634 4
	8208 4
	9474 4
    } {
	assert 1 [sum_digit_power $number $power] "<sum_digit_power> $number $power"
    }
    foreach {number sum_digit_power_sum} {
	2 0
	3 1301
	4 19316
    } {
	assert $sum_digit_power_sum [search $number [bound $power]] "<search> $number"
    }
}

proc sum_digit_power {n p} {
    set sum 0
    foreach d [digits $n] {
	incr sum [pow $d $p]
    }
    expr {$sum == $n}
}

unit_test
