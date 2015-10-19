# What is this? Keep reading!

proc Doc args {}
proc doc args {}
proc comment args {}
Doc utilities, foundational building blocks, etc. 

set dir [file dirname [file normalize [info script]]]
source [file join $dir prime.tcl]
unset dir

# Use as 'assert 1 [set x 1] "Cmd <set> is tested (:-)"
proc assert {a b info} { if {$a != $b} { error "Failed: <$a> <$b> <$info>" } } ; # info should say what new cmd this assert call wants to test..

# Ranges!
# {0 1 2 ... $n-1}:
proc range n { set o {0}; for {set i 1} {$i < $n} {incr i} { lappend o $i }; return $o }
# {1 2 3 ... n}:
proc range_natural n { set o {}; for {set i 1} {$i <= $n} {incr i} { lappend o $i }; return $o }
# {1 2 3 ... n-1}:
proc range_natural_open n { set o {}; for {set i 1} {$i < $n} {incr i} { lappend o $i}; return $o}
proc string_trim {str {chars " "}} { ; # 'string trim' only trims prefix and suffix. We want to trim all interior chars, too
    regsub -all $chars $str ""
}

# list utilities
proc lhas? {list elem} { expr {[lsearch $list $elem] > -1} }
proc lhas_all? {list args} { 
    foreach a $args {
	if {![lhas? $list $a]} { return 0 }
    }
    return 1
}
proc ldiff {l1 l2} { ; # only report distinct elements, ignore duplicates
    foreach l $l1 {
	set t1($l) 1
    }
    foreach l $l2 {
	set t2($l) 1
    }
    set only_in_l1 ""
    foreach n [array names t1] {
	if {![info exists t2($n)]} {
	    lappend only_in_l1 $n
	}
    }
    set only_in_l2 ""
    foreach n [array names t2] {
	if {![info exists t1($n)]} {
	    lappend only_in_l2 $n
	}
    }
    set out ""
    if {[llength $only_in_l1] > 0} {
	lappend out "Only in first:" [lsort -dict $only_in_l1]
    } 
    if {[llength $only_in_l2] > 0} {
	lappend out "Only in second:" [lsort -dict $only_in_l2]
    }
    set out
}
proc unit_test {} {
    set list "a b c {d e}"
    foreach e $list {
	assert 1 [lhas? $list $e] "<lhas?> $e"
    }
    foreach e "x y z d e" {
	assert 0 [lhas? $list $e] "<lhas?> $e"
    }
    assert 1 [lhas_all? $list a b {d e}]   "<lhas_all?> 1"
    assert 0 [lhas_all? $list a b {d e} x] "<lhas_all?> 2"
    assert 0 [lhas_all? $list a b c x {d e}] "<lhas_all?> 2"
    assert "" [ldiff "a b" "a b a b"] "<ldiff> 1"
    set out [ldiff "x y common" "a b common"]
    assert "Only in first:"  [lindex $out 0] "<ldiff 2a>"
    assert "x y"             [lindex $out 1] "<ldiff> 2"
    assert "Only in second:" [lindex $out 2] "<ldiff 3a>"
    assert "a b"             [lindex $out 3] "<ldiff> 3"
}
unit_test

# 
proc max {list} { compare $list > max }
proc min {list} { compare $list < min }
proc compare {list op tag} {
    if {[set bound [llength $list]] < 1} { error "<$tag> Empty list" }
    set select [lindex $list 0]
    for {set i 1} {$i < $bound} {incr i} {
	if [list [set val [lindex $list $i]] $op $select] {
	    set select $val
	}
    }
    set select
}


# prob 21
proc divisors {n} { ; # all divisors of a number
    set out {1}
    for {set d 2} {$d < int(sqrt($n))+1} {incr d} {
	if {$n % $d == 0} {
	    if {$d != [set d2 [expr {$n / $d}]]} {
		lappend out $d $d2
	    } else {
		lappend out $d
	    }
	}
    }
    set out
}

# prob 20
proc sum {list} {
    set sum 0
    foreach d $list { incr sum $d }
    set sum
}

proc digits {n} { ; # digits starting with least significant
    set out ""
    while {$n > 9} {
	lappend out [expr {$n % 10}]
	set n [expr {$n / 10}]
    }
    lappend out $n
    set out
}

proc factorial {n} { ; # tcl 8.6 has infinite precision ints
    set val 1
    incr n
    for {set i 2} {$i < $n} {incr i} {
	set val [expr {$val * $i}]
    }
    set val
}

# prob 25
proc fibonacci_nth {n} {
    if {$n < 4} {
	return [lindex "x 1 1 2" $n]
    }
    set parent 1
    set fib 2
    for {set i 3} {$i < $n} {incr i} {
	set this $fib
	incr fib $parent
	set parent $this
    }
    set fib
}
proc fibonacci_seq {{bound 15}} {
    set fibs {1 1}
    set parent 1 ; # f2
    set fib 2    ; # f3
    for {set i 3} {$i < $bound} {incr i} {
	lappend fibs $fib
	set this $fib
	incr fib $parent
	set parent $this
    }
    set fibs
}    

proc unit_test {} {
    set seq [fibonacci_seq 20]
    foreach {index fib} {
	1    1   2 1   3 2    4 3
	5    5   6 8   7 13   8 21
	9   34
	10  55
	11  89
	12 144
	13 233
    } {
	assert [fibonacci_nth $index] $fib "<fibonacci_nth> $index"
	incr index -1
	assert [lindex $seq $index] $fib "<fibonacci_seq> $index"
    }
}
unit_test

# prob 29
proc pow {a b} {
    set prod 1
    incr b
    while {[incr b -1] > 0} {
	set prod [expr {$prod * $a}]
    }
    set prod
}
assert 1    [pow 1000 0] "<pow> 1"
assert 1000 [pow 1000 1] "<pow> 2"
assert 129110040087761027839616029934664535539337183380513 [pow 33 33] "<pow> 3"


# show the declaration of a proc 
proc s {procname {show_definition_too 0}} {
    set body [info body $procname]
    set args ""
    foreach arg [info args $procname] {
	if {[info default $procname $arg default]} {
	    lappend args "$arg $default"
	} else {
	    lappend args $arg
	}
    }
    set header "proc $procname {$args}"
    if {$show_definition_too == 0} {
	puts "$header {...}"
    } else {
	puts "$header {"
	puts $body
	puts "} ; \# proc $procname {$args}"
    }
}


# for prob 32 pandigital products

proc digits2number {digits {reverse 0}} {
    set prod 1
    set number 0
    if {$reverse == 1} {
	set digits [lreverse $digits]
    }
    foreach d $digits {
	incr number [expr $d * $prod]
	set prod [expr {10 * $prod}]
    }
    set number
}
assert "0 1" [digits 10] 1
assert "0 1 2 3" [digits 3210] 2
assert 3210 [digits2number [digits 3210]] 3
assert 10 [digits2number [digits 10]] 4
foreach num [range 100] {
    assert $num [digits2number [digits $num]] "<num2digit2num> $num"
    assert $num [digits2number [lreverse [digits $num]] 1] "<num2digit_reverse2num> $num"
}
unset num

proc permute {list} {
    if {[llength $list] == 1} {
	return [lindex $list 0]
    }
    set perms {}
    foreach elem $list { set table($elem) "" } ; # init table
    foreach elem [array names table] {
	set reminder "" ; # find list of all but this elem
	foreach e2 [array names table] {
	    if {$e2 != $elem} { lappend reminder $e2 }
	}
	foreach sub [permute $reminder] {
	    lappend perms [concat $elem $sub]
	}
    }
    set perms
}
assert "x" [permute "x"] "<permute> 0"
assert {{0 1} {1 0}} [permute "0 1"] "<permute> 1"
assert [lindex [permute [range 3]] 3] "1 2 0" "<permute> 2"
assert "{a b c} {a c b} {b a c} {b c a} {c a b} {c b a}" [permute "a b c"] "<permute> 3"

