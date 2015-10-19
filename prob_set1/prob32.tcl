source useme.tcl

# Prob 32 Pandigital products 
Doc {
    We shall say that an n-digit number is pandigital
    if it makes use of all the digits 1 to n exactly once;
    for example, the 5-digit number, 15234, is 1 through 5 pandigital.

    The product 7254 is unusual, as the identity, 39 × 186 = 7254,
    containing multiplicand, multiplier, and product is 1 through 9 pandigital.

    Find the sum of all products whose multiplicand/multiplier/product 
    identity can be written as a 1 through 9 pandigital.

    HINT: Some products can be obtained in more than one way so be sure to
    only include it once in your sum.
} Answer {
    45228
    (tcl) 52 % 
}
proc answer {} { time { puts [search2] } }

#
# proc search below does it but there is a better way!
# First note that there are only two possibilities:
# 
#   a * bcde = xyze
#   ab * cde = xyze
#   
Doc Better Method {
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
}
proc search2 {} {
    for {set a 1} {$a < 6} {incr a} {
	for {set bcde 1000} {$bcde < 2000} {incr bcde} {
	    set p [expr {$a * $bcde}]
	    if {[isPDP? $a $bcde $p]} {
		if {![info exists [set elem products($p)]]} {
		    set $elem 1
		    puts "$a * $bcde = $p"
		}
	    }		
	}
    }
    for {set a 11} {$a < 100} {incr a} {
	for {set bcd 100} {$bcd < 500} {incr bcd} {
	    # TODO: duplicate!
	    set p [expr {$a * $bcd}]
	    if {[isPDP? $a $bcd $p]} {
		if {![info exists [set elem products($p)]]} {
		    set $elem 1
		    puts "$a * $bcd = $p"
		}
	    }		
	}
    }	    
    sum [array names products]
}

proc isPDP? {m1 m2 p} { expr {[lsort -int [concat [digits $m1] [digits $m2] [digits $p]]] == "1 2 3 4 5 6 7 8 9"} }

Doc First Try {
    #
    #
    #

    # n-perm: a permutation that starts with digit n.
    proc search {} {
	foreach perm [permute [digits 23456789]] {
	    set perm [concat 1 $perm] ; # it is sufficient to consider 1-perms (Proof?)
	    for {set i 1} {$i < 4} {incr i} { ; # check 2,3 or 4 digit m1's only
		set m1 [digits2number [lrange $perm 0 $i] 1]
		set next [expr {$i+1}]
		for {set j $next} {$j < 5} {incr j} {
		    set m2 [digits2number [lrange $perm $next $j] 1]
		    set p  [expr {$m1 * $m2}]
		    if {[lsort [digits $p]] == [lsort [lrange $perm [expr {$j+1}] end]]} {
			if {![info exists [set elem products($p)]]} {
			    set $elem 1
			    puts "$p = $m1 * $m2"
			}
		    }
		}
	    }
	}
	set sum 0
	foreach p [array names products] {
	    incr sum $p
	}
	set sum
    }

    # There are only seven pandigital products! :-)
    proc all {} { set list "4396 5346 5796 6952 7254 7632 7852" }
    proc prob32 {} { sum [all] }

    # Note: 362k permutations for 9 digits..

    # For completeness, we need i to sweep [0,7) and j to sweep [i+1,8), but
    # it seems that the product has to have 4 digits. 
    # So, we can reduce the bounds
    Doc Sample {
	# very slow, despite the trick to reduce the upper bound of i and j loops by 1 each:
	# i sweeping [0,6) and j sweeping [i+1,7)
	(tcl) 61 % time search
	This is it! Add: 7632 (48 * 159)
	This is it! Add: 5796 (483 * 12)
	This is it! Add: 7852 (4 * 1963)
	This is it! Add: 6952 (4 * 1738)
	This is it! Add: 5346 (18 * 297)
	This is it! Add: 7254 (186 * 39)
	This is it! Add: 4396 (157 * 28)
	267750787 microseconds per iteration
	(tcl) 62 % 
    } Much smaller ranges {
	# i: [0,3)
	# j: [i+1,5)
	(tcl) 52 % time search
	This is it! Add: 7632 (48 * 159)
	This is it! Add: 5796 (483 * 12)
	This is it! Add: 7852 (4 * 1963)
	This is it! Add: 6952 (4 * 1738)
	This is it! Add: 5346 (18 * 297)
	This is it! Add: 7254 (186 * 39)
	This is it! Add: 4396 (157 * 28)
	103621403 microseconds per iteration
	(tcl) 53 % 
    } Cheat by skipping permutations that do not start with 1 or 4 {
	# Still half a minute!
	(tcl) 54 % time search
	This is it! Add: 7632 (48 * 159)
	This is it! Add: 5796 (483 * 12)
	This is it! Add: 7852 (4 * 1963)
	This is it! Add: 6952 (4 * 1738)
	This is it! Add: 5346 (18 * 297)
	This is it! Add: 7254 (186 * 39)
	This is it! Add: 4396 (157 * 28)
	29931821 microseconds per iteration
	(tcl) 55 % 
    } Optimize by not even generating permutations that do NOT start with 1 or 4 {
	(tcl) 54 % answer
	This is it! Add: 5346 (18 * 297)
	This is it! Add: 7254 (186 * 39)
	This is it! Add: 7632 (159 * 48)
	This is it! Add: 4396 (157 * 28)
	This is it! Add: 5796 (12 * 483)
	This is it! Add: 7852 (4 * 1963)
	This is it! Add: 6952 (4 * 1738)
	45228
	22734027 microseconds per iteration
	(tcl) 55 % 
    } After the last one, notice that checking only the permutations that start with 1 is enough! {
	% answer
	This is it! Add: 5346 (18 * 297)
	This is it! Add: 7254 (186 * 39)
	This is it! Add: 7852 (1963 * 4)
	This is it! Add: 7632 (159 * 48)
	This is it! Add: 4396 (157 * 28)
	This is it! Add: 5796 (12 * 483)
	This is it! Add: 6952 (1738 * 4)
	45228
	13414220 microseconds per iteration
	%
    } Also notice that no need to check m1 = 1 {
	# < 10 sec, finally :-)
	(tcl) 61 % answer
	7254 = 186 * 39
	5346 = 18 * 297
	7632 = 159 * 48
	4396 = 157 * 28
	7852 = 1963 * 4
	5796 = 12 * 483
	6952 = 1738 * 4
	45228
	8723315 microseconds per iteration
	(tcl) 62 % 
    } Reorder per m1 {
	5796 = 12 * 483
	5346 = 18 * 297
	4396 = 157 * 28
	7632 = 159 * 48
	7254 = 186 * 39
	6952 = 1738 * 4
	7852 = 1963 * 4
    }

} ; # FIRST TRY..
