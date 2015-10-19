source u.tcl

# problem 24 
# lexicographic permutations

Doc Lexicographic permutations {
    Problem 24
    
    A permutation is an ordered arrangement of objects. For example, 3124 is one possible permutation of the digits 1, 2, 3 and 4. If all of the permutations are listed numerically or alphabetically, we call it lexicographic order. The lexicographic permutations of 0, 1 and 2 are:

    012   021   102   120   201   210

    What is the millionth lexicographic permutation of the digits 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9?

}

proc answer  {} { time { puts [lindex [permute "2347658901"] 999999]} }
proc answer2 {} { time { puts [lindex [permute "xyzabc0123"] 999999]} }
proc count {n} { factorial $n } ; # this many permutations for n elements

proc unit_test {} {
    foreach {input output} {
	012 "012 021 102 120 201 210"
	ab  "ab ba"
	x   x
	xyz "xyz xzy yxz yzx zxy zyx"
	abba "aabb aabb abab abba abab abba aabb aabb abab abba abab abba baab baba baab baba bbaa bbaa baab baba baab baba bbaa bbaa"
    } {
	assert 1 [expr {[permute $input] == $output}] "<permute> $input"
    }
}

proc permute {{str "abcxyz"}} {
    set ordered [lsort -dict [split $str ""]]
    set n [llength $ordered]
    if {$n < 4} {
	if {$n == 3} {
	    lassign $ordered f s t
	    return [list [join "$f $s $t" ""] [join "$f $t $s" ""] \
			[join "$s $f $t" ""] [join "$s $t $f" ""] \
			[join "$t $f $s" ""] [join "$t $s $f" ""]]
	} elseif {$n == 2} {
	    lassign $ordered first second
	    return [list $first[set second] $second[set first]]
	} else {
	    # This it the only base needed for recursion to work,
	    # but, the previous two cases speed things up quite a bit..
	    return [list $str]
	}
    }
    set perms {}
    for {set i 0} {$i < $n} {incr i} {
	set first [lindex $ordered $i]
	set rest [lremove $ordered $first]
	foreach sub [permute [join $rest ""]] {
	    set new "$first[set sub]"
	    lappend perms $new
	}
    }
    return $perms
}
#permute

unit_test


Doc Answer in 13 seconds {
# Note: 
#  - Without the base case for 3 elements it goes up to 22 seconds!
#  - Without the base case for 2 elements it goes up to 30 seconds!
    (tcl) 94 % answer
    2783915460
    13304321 microseconds per iteration
    (tcl) 135 % answer2
    2xy3z1bac0
    15037059 microseconds per iteration
    (tcl) 136 % 
} Smart counting would be a lot faster for larger n {
    9! is about 300k (check [count 9])
    0,1,2 -> gets us to 900k
    3 would overshoot..
    2<first> -> 
    (tcl) 136 % count 10
    3628800
    (tcl) 137 % count 9
    362880
    (tcl) 138 % count 8
    40320
    (tcl) 140 % expr 2 * [count 9]
    725760
    (tcl) 141 % expr 3 * [count 9]
    1088640
    # now we know the first digit is the second in the string (2)
    (tcl) 143 % expr 2 * [count 9] + 6 * [count 8]
    967680
    (tcl) 144 % expr 2 * [count 9] + 7 * [count 8]
    1008000
    # now we know the second digit it the 6th in the remainder of the string
    # "013456789" -> so that gives us (7)
    (tcl) 149 % expr 2 * [count 9] + 6 * [count 8] + 6 * [count 7]
    997920
    (tcl) 148 % expr 2 * [count 9] + 6 * [count 8] + 7 * [count 7]
    1002960
    # now we know the third digit is the 6th in the remainder:
    # "01345689" -> so that gives us (8)
    (tcl) 150 % 
    Now, this gives us a much faster algorithm by just using the 
    factorial and doing binary search to find the bounding [n]s
} See haskell solution in ../fp/euler/prob24. Runs very fast!

Doc Good feedback (\;-) {
    Congratulations, the answer you gave to problem 24 is correct.

    You are the 68077th person to have solved this problem.

    Nice work, bulent2k2, you've just advanced to Level 1 . 
    72900 members (14.68%) have made it this far.

    You have earned 1 new award:

    The Journey Begins: Progress to Level 1 by solving twenty-five problems
}
