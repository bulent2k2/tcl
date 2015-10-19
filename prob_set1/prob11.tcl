proc doc args {}

# takes less than 50 milliseconds
doc Sample Runs {
    (tcl) 2 % time search
    12  6  d l -> 70600674 (numbers: 89 94 97 87)
    48904 microseconds per iteration
    (tcl) 3 % search 1
     1  2    d -> 99 (numbers: 99)
    99
    (tcl) 4 % search 2
     0  3  d l -> 9603 (numbers: 97 99)
    9603
    (tcl) 5 % search 3
    12  6  d l -> 811502 (numbers: 89 94 97)
    811502
    (tcl) 6 % search 5
    11  7  d l -> 3318231678 (numbers: 47 89 94 97 87)
    3318231678
    (tcl) 7 % search 10
    17  7    r -> 2583621418281932160  (numbers: 88 34 62 99 69 82 67 59 85 74)
    2583621418281932160
    (tcl) 8 % search 20
     0  9    d -> 182479798369776159130095937843200000     (numbers: 75 87 71 24 92 75 38 63 17 45 94 58 44 73 97 46 94 62 31 92)
    182479798369776159130095937843200000
    (tcl) 9 % 
}

proc search { {how_many_numbers 4} } {
    variable how_many $how_many_numbers
    set max 1
    foreach r [range [size]] {
	foreach c [range [size]] {
	    foreach dir [search_dirs] {
		if {$max < [set prod [product [list $r $c] $dir]]} { 
		    set max $prod
		    set msg [format "%2s %2s  %3s -> %-[digits]s (numbers: %s)" $r $c $dir $max [show]] } } } }
    puts $msg
    return $max
}

proc range {n} { ... } ;                         # return python like range [0,1,..,n-1]
proc size {} { ;                                 # how big is the grid
    variable grid 
    return [llength [lindex $grid 0]]
}
proc search_dirs {} { ;                          # down, right, and two diagonals suffice:
    return {d r {d r} {d l}} ;                   # down/right, down/left
}
proc product {p dir} { ... } ;                   # product of four elements starting at point in given direction
proc word {p dir} { ... } ;                      # return four elements starting at point in given direction
proc val {p} { ... } ;                           # return value indexed by row,col
proc next {p dirs} { ... } ;                     # find the next element from point in given direction
proc how_many {} {
    variable how_many
    return $how_many
}
proc digits {} { expr [how_many] * 2 } ;         # max number of digits in the product


proc product {p dir} {
    set val 1
    foreach x [word $p $dir] {
	set val [expr {$val * [val $x]}] }
    return $val
}

proc word {p dir} { ; # group a number of elements starting at point p going in dir
    lassign $p x y
    set word {}
    foreach i [range [how_many]] {
	lappend word $p
	set p [next $p $dir] }
    variable _word $word ; # remember to dump
    return $word
}
proc show {} { ; # show the selected numbers
    variable _word
    set out ""
    foreach p $_word {
	lappend out [val $p] }
    set out
}

proc next {p d_list} {
    lassign $p r c
    # down/left diagonal := down and then left
    foreach d $d_list {
	switch $d {
	    u { incr r -1 }
	    d { incr r +1 }
	    l { incr c -1 }
	    r { incr c +1 }
	}
    }
    # check for going out of the grid.. 
    # point to the special element (row 20,col 0), so product would give 0
    if {[ expr {$r % [size]} ] != $r || 
	[ expr {$c % [size]} ] != $c} {
	set r [size]
	set c 0
    }
    return [list $r $c]
}
    
proc val {p} {
    variable grid
    set val [lindex $grid [lindex $p 0] [lindex $p 1]]
    if {[string index $val 0] == 0} { ; # this is to convert 08 to 8 (or 00 to 0)
	set val [string index $val 1]
    }
    return $val
}

proc range {n} {
    set out "" 
    for {set i 0} {$i < $n} {incr i} {
	lappend out $i
    }
    return $out
}

set grid {
    {08 02 22 97 38 15 00 40 00 75 04 05 07 78 52 12 50 77 91 08}
    {49 49 99 40 17 81 18 57 60 87 17 40 98 43 69 48 04 56 62 00}
    {81 49 31 73 55 79 14 29 93 71 40 67 53 88 30 03 49 13 36 65}
    {52 70 95 23 04 60 11 42 69 24 68 56 01 32 56 71 37 02 36 91}
    {22 31 16 71 51 67 63 89 41 92 36 54 22 40 40 28 66 33 13 80}
    {24 47 32 60 99 03 45 02 44 75 33 53 78 36 84 20 35 17 12 50}
    {32 98 81 28 64 23 67 10 26 38 40 67 59 54 70 66 18 38 64 70}
    {67 26 20 68 02 62 12 20 95 63 94 39 63 08 40 91 66 49 94 21}
    {24 55 58 05 66 73 99 26 97 17 78 78 96 83 14 88 34 89 63 72}
    {21 36 23 09 75 00 76 44 20 45 35 14 00 61 33 97 34 31 33 95}
    {78 17 53 28 22 75 31 67 15 94 03 80 04 62 16 14 09 53 56 92}
    {16 39 05 42 96 35 31 47 55 58 88 24 00 17 54 24 36 29 85 57}
    {86 56 00 48 35 71 89 07 05 44 44 37 44 60 21 58 51 54 17 58}
    {19 80 81 68 05 94 47 69 28 73 92 13 86 52 17 77 04 89 55 40}
    {04 52 08 83 97 35 99 16 07 97 57 32 16 26 26 79 33 27 98 66}
    {88 36 68 87 57 62 20 72 03 46 33 67 46 55 12 32 63 93 53 69}
    {04 42 16 73 38 25 39 11 24 94 72 18 08 46 29 32 40 62 76 36}
    {20 69 36 41 72 30 23 88 34 62 99 69 82 67 59 85 74 04 36 16}
    {20 73 35 29 78 31 90 01 74 31 49 71 48 86 81 16 23 57 05 54}
    {01 70 54 71 83 51 54 69 16 92 33 48 61 43 52 01 89 19 67 48}
    {00}
}
