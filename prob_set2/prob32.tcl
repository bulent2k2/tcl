# Duplicated (but also rinsed) ~/tcl/prob_set1/prob32.tcl

# Prob 32 Pandigital products 
Doc {
    We shall say that an n-digit number is pandigital if it makes use of all the digits 1 to n exactly once;
    for example, the 5-digit number, 15234, is 1 through 5 pandigital.

    The product 7254 is unusual, as the identity, 39 × 186 = 7254, containing multiplicand, multiplier, and product is 1 through 9 pandigital.

    Find the sum of all products whose multiplicand/multiplier/product identity can be written as a 1 through 9 pandigital.

    HINT: Some products can be obtained in more than one way so be sure to only include it once in your sum.
} Answer {
    45228
    (tcl) 52 % 
}
proc answer {} { time { puts [search] } }

#
# First note that there are only two possibilities:
# 
#   a * bcde = xyze
#   ab * cde = xyze
#   
Doc Sample output with inlining {
    # See ~/tcl/prob_set1/prob32.tcl
    (tcl) 74 % answer
    4 * 1738 = 6952
    4 * 1963 = 7852
    12 * 483 = 5796
    18 * 297 = 5346
    28 * 157 = 4396
    39 * 186 = 7254
    48 * 159 = 7632
    45228
    637 miliseconds per iteration
    (tcl) 75 % 
} without inlining -- what we have below {
    (tcl) 58 % answer
    4 * 1738 = 6952
    4 * 1963 = 7852
    12 * 483 = 5796
    18 * 297 = 5346
    28 * 157 = 4396
    39 * 186 = 7254
    48 * 159 = 7632
    45228
    256718 microseconds per iteration
    (tcl) 59 %     
}
proc search {} {
    for {set m1 1} {$m1 < 6} {incr m1} {
	for {set m2 1000} {$m2 < 2000} {incr m2} {
	    _check_pdp
	}
    }
    for {set m1 11} {$m1 < 100} {incr m1} {
	for {set m2 100} {$m2 < 500} {incr m2} {
	    _check_pdp
	}
    }	    
    sum [array names products]
}
proc isPDP? {m1 m2 p} { expr {[lsort -int [concat [digits $m1] [digits $m2] [digits $p]]] == "1 2 3 4 5 6 7 8 9"} }
proc _check_pdp {} {
    uplevel 1 {
	set p [expr {$m1 * $m2}]
	if {[isPDP? $m1 $m2 $p]} {
	    if {![info exists [set elem products($p)]]} {
		set $elem 1
		puts "$m1 * $m2 = $p"
	    }
	}		
    }
}

