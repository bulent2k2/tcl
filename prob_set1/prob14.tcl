# collatz (3x+1) 

proc doc args {}

doc Sample run. Takes about half a second only {
    (tcl) :-) time {puts [search_longest_chain 1000000]}
    winner 837799 length 196
    5462856 microseconds per iteration
    (tcl) :-) % 
}

# Note: inlining call to chain_length only improves run time by 2% (for bound=1e6)
# So, do use procs to make code more readable and modular
proc search_longest_chain {{bound 1000}} {
    set max 0; set winner {}
    set start 3
    while {[incr start 4] < $bound} {
	if {[set new [chain_length $start]] > $max} {
	    set max $new
	    set winner $start
	}
    }
    list "winner" $winner "length" $max
}
proc chain_length {num} {
    set length 1
    while {1} {
	while {[expr {$num % 2 == 0}]} { set num [expr {$num / 2}] }
	if {$num == 1} break
	incr length
	set num [expr { (3 * $num + 1) / 2 }]
    }
    return $length
}

# Remembering the chain costs 50% of the runtime..
proc chain {num} {
    set chain {}
    while {1} {
	while {[expr {$num % 2 == 0}]} { set num [expr {$num / 2}] }
	if {$num == 1} break
	lappend chain $num
	set num [expr { (3 * $num + 1 ) /2 }]
    }
    return $chain
}

# This proc in the inner loop would be costly..
proc even? {num} { expr {$num % 2 == 0} }

set why_not "smile Now?"
