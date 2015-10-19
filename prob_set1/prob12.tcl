# see prob12_old.tcl for some more data..

source prime.tcl
source array.tcl

proc search {bound} {
    set n 1
    while {1} {
	# slower: set num [num_divisors [tri [incr n]]]
	set num [num_divisors_of_tri [incr n]]
	if {$num > $bound} {
	    return [list "n $n" "triangle-number [tri $n]" "num-divisors $num"]
	}
    }
    error "num=$num bound=$bound"
}

proc doc args {}
doc After speeding up prime_factors {
    (tcl) % time {puts [search 500]}
    {n 12375} {triangle-number 76576500} {num-divisors 576}
    1395183 microseconds per iteration
    (tcl) % time {puts [num_divisors_of_tri 12375]}
    576
    6011 microseconds per iteration
    (tcl) % time {puts [num_divisors 76576500]}
    576
    3426 microseconds per iteration
    (tcl) % 

} Sample run times {
    (tcl) % time {puts [search 300]}
    {n 2079} {triangle-number 2162160} num-divisors 320
    540259 microseconds per iteration
    (tcl) % time {puts [search 500]}
    {n 12375} {triangle-number 76576500} num-divisors 576
    9423768 microseconds per iteration
    (tcl) % 
} Also note {
    (tcl) % time {puts [num_divisors_of_tri 12375]}
    576
    10042 microseconds per iteration
    (tcl) % time {puts [num_divisors 76576500]}
    576
    5002002 microseconds per iteration
    (tcl) % 
}

# tri(n) = 1 + 2 + 3 + ... + n = n(n+1)/2

# Factor n into primes = p(2) * p(3) * p(5) * p(7) * p(11) * ...
# where p(i) is i to the power pi =>
# num_divisors = Product (pi + 1)

proc num_divisors_of_tri {n} {
    array set pfact [pfact $n]
    foreach {prime power} [pfact [incr n]] {
	array_incr pfact $prime $power
    }
    incr pfact(2) -1
    num_divisors_from_table [array get pfact]
}

proc tri {n} { expr {$n*($n+1)/2} }

proc num_divisors {n} { num_divisors_from_table [pfact $n] }
proc num_divisors_from_table {table} {
    set num 1
    foreach {prime power} $table {
	set num [expr {$num * ($power+1)}]
    }
    return $num
}

# return a table for prime factorization
#   i -> pi
# 60 = {2->2 3->1 5->1}
proc pfact {n} {
    array set out {}
    if {[prime? $n]} { return [list $n 1] }
    foreach prime [prime_factors $n] {
	set out($prime) 1
	set n [expr {$n/$prime}]
    }
    if {$n > 1} {
	foreach {i pi} [pfact $n] {
	    if {[info exists [set elem out($i)]]} {
		incr $elem $pi
	    } else {
		set $elem $pi
	    }
	}
    }
    return [array get out]
}

# prime factors of n
proc prime_factors {n} {
    if {$n < 2} { error "n is $n" }
    set out [list]
    if {[even? $n]} { lappend out 2 }
    set bound $n
    for {set i 3} {$i <= $bound} {incr i 2} {
	if {[expr {$n % $i}]} { continue }
	if {[prime? $i]} { 
	    lappend out $i
	    set bound [expr $bound / $i]
	}
    }
    if {[llength $out] == 0} { 
	return [list $n]
    }
    return $out
}
