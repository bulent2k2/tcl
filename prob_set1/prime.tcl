proc primes {bound {min 2}} {
    set out ""
    if {$min <= 2} { set out "2" }; # 1 is not a prime. It is primer than prime (:-)
    if {[even? $min]} { incr min }
    for {set i $min} {$i < $bound} {incr i 2} {
	if {[prime? $i]} { lappend out $i }
    }
    return $out
}
proc prime? {num} {
    if {$num < 2} { return 0 }
    if {$num == 2} { return 1 }
    if {[even? $num]} { return 0 }
    set bound [limit $num]
    for {set i 3} {$i <= $bound} {incr i 2} {
        if {$num % $i == 0} { return 0 }
    }
    return 1
}
proc even? {num} { expr {$num % 2 == 0} }
# num has no prime factors greater than this limit
proc limit {num} { expr {sqrt($num)} }
