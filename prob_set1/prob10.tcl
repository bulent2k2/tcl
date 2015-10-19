proc doc args {}
doc euler problem 10 {
  The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.
  Find the sum of all the primes below two million.
} answer {
    (tcl) 3 % sum 2000000
    142913828922
    (tcl) 4 % time {sum 2000000}
    13490687 microseconds per iteration
    (tcl) 5 % 
}

proc sum {bound} {
    set sum 0
    foreach prime [primes_less_than $bound] {
	incr sum $prime
    }
    set sum
}

proc primes_less_than {bound} {
    set out {}
    if {2 < $bound} {
	set out {2} 
    }
    for {set i 3} {$i < $bound} {incr i 2} {
	if {[prime? $i]} {
	    lappend out $i
	}
    }
    set out
}

#   % time { largest_prime_factor 600851475143 }
#   681449 microseconds per iteration
#   % 
proc largest_prime_factor {num} {
    set factors {}
    if {[even? $num]} { set factors {2} }
    for {set i 3} {$i <= [limit $num]} {incr i 2} {
        if {$num % $i} continue
        if {[prime? $i]} { lappend factors $i }
    }
    lindex $factors end
}
proc prime? {num} {
    #if {[even? $num]} { return 0 }
    set bound [limit $num]
    for {set i 3} {$i <= $bound} {incr i 2} {
        if {$num % $i == 0} { return 0 }
    }
    return 1
}
proc even? {num} { expr {$num % 2 == 0} }
# num has no prime factors greater than this limit
proc limit {num} { expr {sqrt($num)} }

puts [sum 10]
