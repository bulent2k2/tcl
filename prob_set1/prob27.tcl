source u.tcl

Doc Quadratic Primes {
    # Problem 27
    Note:
    n(n+ 1)+41   gives primes for all n=0..40
    n(n-79)+1601 gives primes for all n=0..79

    n^2 + an + b = p
    
} Answer {
    (tcl) 92 % answer
    8149428 microseconds per iteration
    a=-61 b=971 n=71
    -59231
    (tcl) 93 % 
}

proc answer {} {
    puts [time { set answer [search 1000] }]
    lassign $answer a b n
    puts "a=$a b=$b n=$n"
    expr $a * $b
}

proc search {{bound_hi 100}} {
    set bound_lo [expr 1-1*$bound_hi]
    set max 1
    for {set a $bound_lo} {$a < $bound_hi} {incr a} {
	for {set b $bound_lo} {$b < $bound_hi} {incr b} {
	    if {[set n [quad $a $b]] > $max} {
		set max $n
		lassign "$a $b" ax bx
	    }
	}
    }
    list $ax $bx $max
}

proc quad {a b} { ; # return smallest n that gives a non-prime
    for {set n 0} {1} {incr n} {
	if {![prime? [expr {$n * ($n + $a) + $b}]]} {
	    return $n
	}
    }
}

proc unit_test {} {
    foreach {a b n} {
	  1   41   40
	-79 1601   80
	-15   97   48
	-25  197   53
	-37  383   59
	-61  971   71
    } {
	assert $n [quad $a $b] "<quad>"
    }
}
unit_test
