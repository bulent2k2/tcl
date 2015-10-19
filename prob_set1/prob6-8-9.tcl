# euler problems 6 and 8, 9

# 9: special pythagorean triplet: a + b + c = 1000

# outputs: 31875000
proc pyth1k {} {
    for {set a 5} {1} {incr a} {
	for {set b 4} {$b < $a} {incr b} {
	    for {set c 3} {$c < $b} {incr c} {
		if {[expr {$a + $b + $c == 1000}]} { 
		    if {[expr {$a * $a == $b * $b + $c * $c}]} {
			return [expr $a*$b*$c]
		    }
		}
	    }
	}
    }
    error "No such triplet!"
}
puts [pyth1k]


## The four adjacent digits in the 1000-digit number that have the greatest product are 9 × 9 × 8 × 9 = 5832.

## Find the thirteen adjacent digits in the 1000-digit number that have the greatest product. What is the value of this product?

set digits "7316717653133062491922511967442657474235534919493496983520312774506326239578318016984801869478851843858615607891129494954595017379583319528532088055111254069874715852386305071569329096329522744304355766896648950445244523161731856403098711121722383113622298934233803081353362766142828064444866452387493035890729629049156044077239071381051585930796086670172427121883998797908792274921901699720888093776657273330010533678812202354218097512545405947522435258490771167055601360483958644670632441572215539753697817977846174064955149290862569321978468622482839722413756570560574902614079729686524145351004748216637048440319989000889524345065854122758866688116427171479924442928230863465674813919123162824586178664583591245665294765456828489128831426076900422421902267105562632111110937054421750694165896040807198403850962455444362981230987879927244284909188845801561660979191338754992005240636899125607176060588611646710940507754100225698315520005593572972571636269561882670428252483600823257530420752963450"

proc d2list {digits} {
    set out {}
    for {set i 0} {$i < [string length $digits]} {incr i} {
	lappend out [string index $digits $i]
    }
    set out
}

proc find { digit_str {size 13} } {
    set digits [d2list $digit_str]
    for {set i 0} {$i < $size} {incr i} { 
	lappend digits 1
    }
    set max 1
    set bound [expr [llength $digits]-$size+1]
    for {set i 0} {$i < $bound} {incr i} {
	set prod 1
	for {set j $i} {$j < [expr {$i + $size}]} {incr j} {
	    set prod [expr {$prod * [lindex $digits $j]}]
	}
	if {$prod > $max} { 
	    set max $prod
	    puts "Starting at i=$i, found $max" 
	}
    }
}

puts [find $digits]


# problem 6:

# square of sums - sum of squares: 
# (a+b+c+d)^2 - a^2 - b^2 - c^2 = 2 * (ab + ac + ad + bc + bd + cd)
proc diff { {bound 100} } {
    incr bound
    set sum 0
    for {set i 1} { $i < $bound } { incr i } {
	for {set j [expr {1 + $i}]} { $j < $bound} { incr j} {
	    incr sum [expr {$i * $j}]
	}
    }
    expr {2 * $sum}
}
diff 100


# p5 smallest num divisible by all in [1..20]

# 
# note: 2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.


# p4 look for palindrome of products i*j where i and j are 3 digit integers

# Find: 906609 = 913 * 993
# Given: the largest for two digit numbers: 9009 = 91 * 99 

# With trick: 196605 microseconds per iteration
# Without   : 1520904 microseconds per iteration
proc large_palindrome_product { {bound 999} } {
    set lower 99
    set test_old 9009; set test_new 9009
    set hi_j 0 ; # remember the greatest factor to date
    for {set i $bound} {$i > $lower} {incr i -1} {
        if {$i < $hi_j} break ; # this trick speeds it up by about 10x
        for {set j $bound} {$j > $lower} {incr j -1} {
            set prod [expr {$i * $j}]
            if {[palindrome? $prod]} { 
                set test_new $prod
                if {$j > $hi_j} { set hi_j $j }
                break 
            }
        }
        if {$test_new > $test_old} { 
            set test_old $test_new
        }
    }
    return $test_old
}
proc palindrome? {num} {
    set list [num_to_list $num]
    while {[llength $list] > 0} {
        if {[lindex $list 0] != [lindex $list end]} {
            return 0
        }
        set list [lrange $list 1 end-1]
    }
    return 1
}
proc num_to_list {num} {
    set list {}
    while {$num > 9} {
        lappend list [expr {$num % 10}]
        set num [expr {$num / 10}]
    }
    if {$num > 0} { lappend list $num }
    set list
}

# p3

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
    if {[even? $num]} { return 0 }
    for {set i 3} {$i <= [limit $num]} {incr i 2} {
        if {$num % $i == 0} { return 0 }
    }
    return 1
}
proc even? {num} { expr {$num % 2 == 0} }
# num has no prime factors greater than this limit
proc limit {num} { expr sqrt($num) }

# find the sum of even numbers in the fibonacci series
# https://projecteuler.net/problem=2
proc fib_p2 { {limit 4000000} } {
    set sum 0; set p1 1; set p2 1
    while {1} {
        set f [expr {$p1 + $p2}]
        set p2 $p1; set p1 $f
        if { $f > $limit } break
        if { $f % 2 } continue
        incr sum $f
    }
    set sum
}
# find the sum of multiples of 3 and 5 that are less the given limit
proc sum_of_mult { {below 1000} } {
    set sum 0
    for {set i 1} {$i < $below} {incr i} { 
        if {$i % 3 == 0 || $i % 5 == 0} {
            set sum [expr {$sum + $i}]
        }
    }
    set sum
}
