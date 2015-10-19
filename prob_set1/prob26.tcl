source u.tcl

Doc Reciprocal cycles {
    Problem 26
    
    Find the value of d < 1000 for which 1/d contains the longest recurring cycle in its decimal fraction part.
}

proc answer {{bound 1000}} {
    set max 1
    set what 7
    foreach i [range_natural_open $bound] {
	if {[set c [cycle $i]] > $max} { 
	    puts "$i -> $c"
	    set what $i
	    set max $c
	}
    }
    list $what $max
}

proc unit_test {} {
    foreach {bound index cycle_length} {
	10   7   6
	100  97  87
	200  193 173
	400  389 350
	1000 983 884
    } {
	set a [answer $bound]
	set info "<answer> bound=$bound a=$a"
	assert $index [lindex $a 0]        $info
	assert $cycle_length [lindex $a 1] $info
    }
}

proc cycle {d} {
    set reminder [expr {[up 1 $d] % $d}]
    set index 0
    set table($reminder) [incr index]
    set has_cycle 0
    while {$reminder > 0} {
	set reminder [expr {[up $reminder $d] % $d}]
	set elem table($reminder)
	if {[info exist $elem]} {
	    set has_cycle 1
	    break
	}
	set $elem [incr index]
    }
    if {$has_cycle} { 
	return [expr {[llength [array names table]] - $table($reminder) + 1}]
    } else {
	return 0
    }
}

proc up {unit d} { ; # multiply unit by 10 while it's less than d
    while {$unit < $d} {
	set unit [expr {$unit * 10}]
    }
    set unit
}

unit_test
