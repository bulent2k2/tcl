# number letter counts

proc answer {} { count_seq 1000 } ; # 21124

proc unit_tests {} {
    foreach {n words count trimmed} {
	5 "five" 4 "five"
	23 "twenty three" 11 "twentythree"
	342 "three hundred and forty two" 23 "threehundredandfortytwo"
	100 "one hundred" 10 "onehundred"
	115 "one hundred and fifteen" 20     "onehundredandfifteen"
    } {
	assert 1 [string equal $trimmed [string_trim $words]] "<string_trim> $words"
	lassign [count $n] count2 words2
	assert [string equal $words $words2] 1 "<count><words> 1='$words' 2='$words2'"
	assert $count $count2 "<count><count> words=$words"
    }
    foreach {n count} [subst {
	5  [string length "onetwothreefourfive"]
	6  [string length "onetwothreefourfivesix"]
	10 [string length "onetwothreefourfivesixseveneightnineten"]
	11 [string length "onetwothreefourfivesixseveneightnineteneleven"]
	12 [string length "onetwothreefourfivesixseveneightnineteneleventwelve"]
	99 854
	100 864
	200 3015
	1000 21124
    }] {
	assert [set new [count_seq $n]] $count "<count_seq> n=$n new=$new"
    }
}

proc count_seq {n} {
    set sum 0
    foreach i [range_natural $n] {
	incr sum [lindex [count $i] 0]
    }
    set sum
}
proc count {n} {
    set w [n2words $n]
    set c [string length [string_trim $w]]
    list $c $w
}
proc n2words {n} {
    if {$n < 20} { return [words $n] }
    if {$n < 100} {
	set hi [expr {$n / 10}]
	set out [tens2n $hi]
	if {[set lo [expr {$n % 10}]]} {
	    lappend out [n2words $lo]
	}
	return $out
    }
    if {$n < 1000} {
	set hi [expr {$n / 100}]
	set out "[n2words $hi] hundred"
	if {[expr {0 < [set rest [expr {$n - $hi * 100}]]}]} {
	    eval lappend out [concat "and" [n2words $rest]]
	}
	return $out
    }
    if {$n == 1000} {
	return "one thousand"
    }
    error "only upto 1000 yet (:-). Got: '$n'"
}
proc words {n} { ; # 0 to 19
    assert 1 [expr {0 <= $n && $n < 20}] "<words> $n"
    set words { "" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten" "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen" "seventeen" "eighteen" "nineteen" }
    lindex $words $n
}
proc tens2n {n} {
    assert 1 [expr {1 < $n && $n <= 9}] "tens: n='$n'"
    set words {"" "" "twenty" "thirty" "forty" "fifty" "sixty" "seventy" "eighty" "ninety"}
    lindex $words $n
}

proc string_trim {str {chars " "}} { ; # 'string trim' only trims prefix and suffix. We want to trim all interior chars, too
    regsub -all $chars $str ""
}
proc assert {a b info} { if {$a != $b} { error "Failed: $a $b $info" } } ; # info should say what new cmd this assert call wants to test..
# [1,2,..,n-1,n]
proc range_natural n { set o {}; for {set i 1} {$i <= $n} {incr i} { lappend o $i }; return $o }
# [0,1,...,n-2,n-1]
proc range n { set o {0}; for {set i 1} {$i < $n} {incr i} { lappend o $i }; return $o }
unit_tests
