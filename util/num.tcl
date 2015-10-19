
# Interesting.. 3 prime factor pairs for "me":
# > set me 492947237
# > set f [prime_factors $me]
# > 89 139 12371 39847 3546383 5538733
proc prime_factors n { lrange [lsort -int [divisors $n]] 1 end } ; # drop 1
proc largest_prime_factor n { lindex [prime_factors $n] end }
# prob 21
proc divisors {n} { ; # all divisors of a number
    set out {1}
    for {set d 2} {$d < int(sqrt($n))+1} {incr d} {
	if {$n % $d == 0} {
	    if {$d != [set d2 [expr {$n / $d}]]} {
		lappend out $d $d2
	    } else {
		lappend out $d
	    }
	}
    }
    set out
}

proc digits {n} { ; # digits starting with least significant
    set out ""
    while {$n > 9} {
	lappend out [expr {$n % 10}]
	set n [expr {$n / 10}]
    }
    lappend out $n
    set out
}

proc factorial {n} { ; # tcl 8.6 has infinite precision ints
    set val 1
    incr n
    for {set i 2} {$i < $n} {incr i} {
	set val [expr {$val * $i}]
    }
    set val
}

# prob 25
proc fibonacci_nth {n} {
    if {$n < 4} {
	return [lindex "x 1 1 2" $n]
    }
    set parent 1
    set fib 2
    for {set i 3} {$i < $n} {incr i} {
	set this $fib
	incr fib $parent
	set parent $this
    }
    set fib
}
proc fibonacci_seq {{bound 15}} {
    set fibs {1 1}
    set parent 1 ; # f2
    set fib 2    ; # f3
    for {set i 3} {$i < $bound} {incr i} {
	lappend fibs $fib
	set this $fib
	incr fib $parent
	set parent $this
    }
    set fibs
}    

proc unit_test {} {
    set seq [fibonacci_seq 20]
    foreach {index fib} {
	1    1   2 1   3 2    4 3
	5    5   6 8   7 13   8 21
	9   34
	10  55
	11  89
	12 144
	13 233
    } {
	assert [fibonacci_nth $index] $fib "<fibonacci_nth> $index"
	incr index -1
	assert [lindex $seq $index] $fib "<fibonacci_seq> $index"
    }
}
unit_test

# prob 29
proc pow {a b} {
    set prod 1
    incr b
    while {[incr b -1] > 0} {
	set prod [expr {$prod * $a}]
    }
    set prod
}
assert 1    [pow 1000 0] "<pow> 1"
assert 1000 [pow 1000 1] "<pow> 2"
assert 129110040087761027839616029934664535539337183380513 [pow 33 33] "<pow> 3"


# for prob 32 pandigital products

proc digits2number {digits {reverse 0}} {
    set prod 1
    set number 0
    if {$reverse == 1} {
	set digits [lreverse $digits]
    }
    foreach d $digits {
	incr number [expr $d * $prod]
	set prod [expr {10 * $prod}]
    }
    set number
}
assert "0 1" [digits 10] 1
assert "0 1 2 3" [digits 3210] 2
assert 3210 [digits2number [digits 3210]] 3
assert 10 [digits2number [digits 10]] 4
foreach num [range 100] {
    assert $num [digits2number [digits $num]] "<num2digit2num> $num"
    assert $num [digits2number [lreverse [digits $num]] 1] "<num2digit_reverse2num> $num"
}
unset num
