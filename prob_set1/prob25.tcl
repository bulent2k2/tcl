source u.tcl

Doc 1000-digit Fibonacci number {
    Problem 25
    
    The Fibonacci sequence is defined by the recurrence relation:
    Fn = Fn-1 + Fn-2, where F1 = 1 and F2 = 1.

    What is the index of the first term in the Fibonacci sequence to contain 1000 digits?
}

Doc Smart Answer {
    fibonacci series converges to golden ratio!!

    Fibonacci terms converge to (n)*Phi=(n+1), where Phi is the
      Golden Ratio (1+sqrt5)/2.

    I reasoned that there is an nth term that is smaller than 10^999
    with the corresponding nth+1 term bigger than 10^999.

    So, using the binary splitting method for searching, I used
    the MS calculator and found Phi^4780<10^999 and Phi^4781>10^999.

    Since the two initial terms of the series have the same value
    by definition, you have to add one to the exponents found.
    No code necessary.
    Rudy.
}

Doc Manual Answer {
    (tcl) 84 % llength [digits [fibonacci_nth 4782]]
    1000
    (tcl) 85 % llength [digits [fibonacci_nth 4781]]
    999
    (tcl) 76 % llength [digits [fibonacci_nth 93]]
    20
    (tcl) 77 % llength [digits [fibonacci_nth 92]]
    19
}

Doc Auto Answer {
    (tcl) 79 % time answer
    min/max: 2/8192 try=4097 what=1
    min/max: 4097/8192 try=6144 what=-1
    min/max: 4097/6144 try=5120 what=-1
    min/max: 4097/5120 try=4608 what=1
    min/max: 4608/5120 try=4864 what=-1
    min/max: 4608/4864 try=4736 what=1
    min/max: 4736/4864 try=4800 what=-1
    min/max: 4736/4800 try=4768 what=1
    min/max: 4768/4800 try=4784 what=0
    found: 4784
    still high: 4783
    still high: 4782
    660631 microseconds per iteration
    (tcl) 80 % 
    (tcl) 82 % time {answer 2000}
    min/max: 2/16384 try=8193 what=1
    min/max: 8193/16384 try=12288 what=-1
    min/max: 8193/12288 try=10240 what=-1
    min/max: 8193/10240 try=9216 what=1
    min/max: 9216/10240 try=9728 what=-1
    min/max: 9216/9728 try=9472 what=1
    min/max: 9472/9728 try=9600 what=-1
    min/max: 9472/9600 try=9536 what=1
    min/max: 9536/9600 try=9568 what=0
    found: 9568
    still high: 9567
    3055464 microseconds per iteration
    (tcl) 83 % 
} Even 10x scaling is handled! {
    # 2000 -> 3 seconds
    # 10k  -> ~4 min
    (tcl) 85 % time {answer 10000}
    min/max: 2/65536 try=32769 what=1
    min/max: 32769/65536 try=49152 what=-1
    min/max: 32769/49152 try=40960 what=1
    min/max: 40960/49152 try=45056 what=1
    min/max: 45056/49152 try=47104 what=1
    min/max: 47104/49152 try=48128 what=-1
    min/max: 47104/48128 try=47616 what=1
    min/max: 47616/48128 try=47872 what=-1
    min/max: 47616/47872 try=47744 what=1
    min/max: 47744/47872 try=47808 what=1
    min/max: 47808/47872 try=47840 what=1
    min/max: 47840/47872 try=47856 what=-1
    min/max: 47840/47856 try=47848 what=0
    found: 47848
    still high: 47847
    Answer=47847
    230591296 microseconds per iteration
    (tcl) 86 % 
}

proc answer { {digit_count 1000} } { binary_search $digit_count }

proc binary_search {digit_count} {
    set max [upper_bound $digit_count]
    set min 2
    set count 1
    while {1} {
	set try [expr {($max+$min)/2}]
	set what [compare $try $digit_count]
	puts "min/max: $min/$max try=$try what=$what"
	if {$what == 0} break
	if {$what > 0} {
	    if {$try > $min} {
		set min $try
	    } else { incr min }
	} else {
	    if {$try < $max} {
		set max $try
	    } else { incr max -1 }
	}
	if {[incr count] > 100} { error "Buggy!" }
    }
    # still may be higher than needed, 
    puts "found: $try"
    while {1} {
	incr try -1
	if {[compare $try $digit_count]!=0} {
	    incr try
	    break
	}
	puts "still high: $try"
    }
    puts "Answer=$try"
    return $try
}

proc upper_bound {digit_count} {
    set index 2
    while {1} {
	if {[compare $index $digit_count] < 1} {
	    return $index
	}
	incr index $index
    }
}    

# 1  => index too small
# 0  => just right
# -1 => index too big
proc compare {index digit_count} {
    set num_digits [llength [digits [fibonacci_nth $index]]]
    if {$num_digits < $digit_count} {
	return 1 ; # index need to be increased
    } elseif {$num_digits > $digit_count} {
	return -1; # index need to be decreased
    } 
    return 0 ; # found it
}

proc unit_test {} {
    set cmd "<binary_search>"
    if {[binary_search 20] != 93}  { error "$cmd failed on 20" }
    if {[binary_search 30] != 141} { error "$cmd failed on 30" }
    if {[answer] != 4782} { error "answer is wrong!" }
}
unit_test
