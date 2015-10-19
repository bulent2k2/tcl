# prob15 - lattice paths -- non-maze routing

proc doc args {}

doc Combinatorial Formula = (2n)! / (n!)^2

doc Scales by >3^n and <4^n. {
    See How it increases:
    2   (- 6         (+ (* 3 2)               0))  (- 6         (- (* 4 2)                     2))
    3   (- 20        (+ (* 3 6)               2))  (- 20        (- (* 4 6)                     4))
    4   (- 70        (+ (* 3 20)             10))  (- 70        (- (* 4 20)                   10))
    5   (- 252       (+ (* 3 70)             42))  (- 252       (- (* 4 70)                   28))
    6   (- 924       (+ (* 3 252)           168))  (- 924       (- (* 4 252)                  84))
    7   (- 3432      (+ (* 3 924)           660))  (- 3432      (- (* 4 924)                 264))
    8   (- 12870     (+ (* 3 3432)         2574))  (- 12870     (- (* 4 3432)                858))
    9   (- 48620     (+ (* 3 12870)       10010))  (- 48620     (- (* 4 12870)              2860))
    10  (- 184756    (+ (* 3 48620)       38896))  (- 184756    (- (* 4 48620)              9724))
    11  (- 705432    (+ (* 3 184756)     151164))  (- 705432    (- (* 4 184756)            33592))
    12  (- 2704156   (+ (* 3 705432)     587860))  (- 2704156   (- (* 4 705432)           117572))
    13  (- 10400600  (+ (* 3 2704156)   2288132))  (- 10400600  (- (* 4 2704156)          416024))
    14  (- 40116600  (+ (* 3 10400600)  8914800))  (- 40116600  (- (* 4 10400600)        1485800))
    15  (- 155117520 (+ (* 3 40116600) 34767720))  (- 155117520 (- (* 4 40116600)        5348880))
    16  (- 601080390 )
    17  (- 2333606220)
    18  (- 9075135300)
    19  (- 35345263800)
    20  (- 137846528820)
}

doc Memoized recursion is very fast in practice even though it is O(n^2). {
    (tcl) 101 % time {puts [count_fast 20]}
    137846528820
    12665 microseconds per iteration
    (tcl) 102 % time {puts [count 20]}
    137846528820
    11522 microseconds per iteration
    (tcl) 103 % 
    # Only 10x increase in problem size starts to make a difference for small problems.. But for bigger problems.. n*n is much worse than n (:-)
    (tcl) 107 % time {puts [count_fast 200]}
    102952500135414432972975880320401986757210925381077648234849059575923332372651958598336595518976492951564048597506774120
    323654 microseconds per iteration
    (tcl) 108 % time {puts [count 200]}
    102952500135414432972975880320401986757210925381077648234849059575923332372651958598336595518976492951564048597506774120
    35096 microseconds per iteration
    (tcl) 109 % 
}


proc test_bounds {n} {
    foreach i [range $n] {
	if {[more? $n] && [less? $n]} { continue }
	puts "$i is either not more than 3^n or not less than 4^n!"
	return 0
    }
    return 1
}
proc more? {n} { expr {[count $n] > pow(3,$n)} }
proc less? {n} { expr {[count $n] < pow(4,$n)} }
proc range n { set o {0}; for {set i 1} {$i < $n} {incr i} { lappend o $i }; return $o }
assert [test_bounds 100] 1 "How beautiful!"

proc count {n} { 
    set f [fact $n]
    incr n $n
    set f2 [fact $n]
    expr {$f2 / ($f * $f)}
}

proc fact {n} {
    set f 1
    incr n
    for {set i 2} {$i < $n} {incr i} { set f [expr {$f * $i}] }
    return $f
}

proc count_fast {n} { reset; path3 $n $n}

#proc count_slower {n} { path $n $n } ; # n=2 2x2 grid
proc count_slow {n} { path2 $n } ; # n=2 2x2 grid

proc path3 {x y} { ; # memoized recursion..
    if {$x == 0 || $y == 0} { return 1 }
    if {[set val [known? $x $y]]>0} {
	return $val
    } else {
	set elem cache("$x,$y")
	incr x -1
	set left [path3 $x $y]
	incr x 1; incr y -1
	set up   [path3 $x $y]
	variable cache
	return [set $elem [expr {$up + $left}]]
    }
}
proc reset {} { variable cache; array unset cache; array set cache {} }
proc known? {x y} {
    variable cache
    if {[info exists [set elem cache("$x,$y")]]} { return [set $elem] }
    return 0
}

proc path2 {n} {
    if {$n == 0} { return 1 }
    set sum 0
    set prev [expr {$n - 1}]
    for {set i 0} {$i < $n} {incr i} {
	incr sum [path $i $prev]
    }
    return [expr {2 * $sum}]
}

proc path {x y} { ; # slow
    if {$x > 3} {
	set left [path [expr {$x - 1}] $y]
	if {$x == $y} { return [expr {2 * $left}] }
	# No need for this slow check: if {$x > $y} { error "x=$x y=$y" }
	set up [path $x [expr {$y - 1}]]
	return [expr {$up + $left}]
    }
    if {$x == 3} { ; # s(1) + s(2) + ... + s(n) = ??
	set sum 0; set bound [incr y 2]
	for {set i 1} {$i < $bound} {incr i} {
	    incr sum [expr {$i * ($i + 1) / 2}]
	}
	return $sum
    }
    if {$x == 2} { ; # s(n) = 1 + 2 + ... + n = n * (n+1) / 2
	incr y
	#return [s [incr y]]
	return [expr {$y * ($y + 1) / 2}]
    }
    if {$x == 1} { 
	return [expr {$y + 1}]
    }
    if {[expr {$x == 0 || $y == 0}]} {
	return 1
    }
}

proc assert {a b info} { if {$a != $b} { error "Failed: $a $b $info" } }
proc run_tests_with_cmd {{cmd count}} {
    foreach {size count} {0 1    1 2    2 6    3 20    4 70    6 924} {
	assert [count $size] $count "size=$size"
    }
}
run_tests_with_cmd
proc s {y} { expr {$y * ($y + 1) / 2} }

doc faster with path2 {
    17 -> 7sec
    18 -> 26sec
    19 -> ?1min?
    20 -> 376.7sec
}

doc faster with x==3 {
    14 -> 0.3sec
    15 -> 0.9sec
    19 -> 1933sec!
}
doc fasterNow {
    (tcl) 62 % time {puts [count 18]}
    9075135300
    45.691 sec
    (tcl) 63 % 
}
doc sample Run {
    source prob15.tcl
    (tcl) 50 % time {puts [count 9]}
    48620
    19023 microseconds per iteration
    (tcl) 51 % time {puts [count 14]}
    40116600
    2850516 microseconds per iteration
    (tcl) 52 % time {puts [count 19]}
    35345263800
    1933533567 microseconds per iteration
    (tcl) 53 % 
}

#
# no need for routing (:-)
#
if {0} {
    proc search {{n 2}} {
	proc n "" "return $n"
	reset
	set count 0; set touched 0
	set que [src]
	while {[llength $que] > 0} {
	    set this [lindex $que 0]; set que [lrange $que 1 end]
	    touch $this
	    if {[touched? [tgt]]} { break
		foreach next [next $this] {
		    if {[touched? $next]} { incr touched }
		    incr count
		    lappend que $next
		}
	    }
	}
	return "$count $touched"
    }

    # 0,0 is top-left. n,n is one off bottom-right
    # Going right is increasing column (x),
    # going down  is increasing row (y)
    proc next here {
	lassign [split $here ,] x y
	set next {}
	if {[set tmp [incr x]] < [n]} { lappend next "$tmp,$y" }
	if {[set tmp [incr y]] < [n]} { lappend next "$x,$tmp" }
	return $next
    }

    proc src {} { return "0,0" }
    proc tgt {} { 
	set tmp [n]
	incr tmp -1
	return "$tmp,$tmp"
    }
    proc reset {} {
	variable grid
	array unset grid
	array set grid {}
    }
    proc touched? here {
	variable grid
	info exists grid($here)
    }
    proc touch here {
	variable grid
	set grid($here) 1
    }
} ; # if 0
