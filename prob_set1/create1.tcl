# Number 1023456789 is the smallest number which has each one digit number once.
# Find the smallest factorial which has each digit at least once!

source u.tcl

proc has_each_digit? {number} {
    set digits [digits $number]
    if {[llength $digits] < 10} { return 0 }
    foreach d "0 1 2 3 4 5 6 7 8 9" {
	if {[lsearch $digits $d] < 0} { return 0 }
    }
    return 1
}

proc unit_test {} {
    foreach n {0 1 2 3 4 5 6 7 8 9 10 123456780 987643210} {
	assert 0 [has_each_digit? $n] "<has_each_digit> $n"
    }
    foreach n {1023456789 9876543210} {
	assert 1 [has_each_digit? $n] "<has_each_digit> $n"
    }
}
unit_test

proc answer {} {
    for {set n 1} {[has_each_digit? [set f [factorial $n]]] == 0} {incr n} { }
    return $n
}   

# 23! (:-) That was fast.
# what about with at least two each?

proc answer2 {{bound 2}} {
    for {set n 1} {[get_count_of_digit_with_min_occurrence [set f [factorial $n]]] < $bound} {incr n} { }
    return $n
}

proc get_count_of_digits {number} {
    set digits [digits $number]
    foreach d "0 1 2 3 4 5 6 7 8 9" { set num($d) 0 }
    foreach d $digits {
	incr num($d)
    }
    # sort and filter out digits that don't appear
    set out {}
    foreach d [lsort [array names num]] {
	if {$num($d) > 0} {
	    lappend out $d:$num($d)
	}
    }
    set out
}
proc get_count_of_digit_with_min_occurrence {number} { ; # 
    if {![has_each_digit? $number]} { return 0 }
    set digits [lsort [digits $number]]
    set min [llength $digits]
    set digit [lindex $digits 0]
    set which $digit
    set count 1
    lappend digits 10 ; # to count 9s, too!
    foreach d [lrange $digits 1 end] {
	if {$d > $digit} {
	    if {$count < $min} { 
		set min $count
		set which $digit
		#puts "$digit appears $min times"
	    }
	    set digit $d
	    set count 1
	} else {
	    incr count
	}
    }
    set min
}
proc get_count_of_digit_with_max_occurrence {number} {
    set digits [lsort [digits $number]]
    set digit [lindex $digits 0]
    set max 0; set which $digit
    set count 1
    lappend digits 10 ; # to count 9s, too!
    foreach d [lrange $digits 1 end] {
	if {$d > $digit} {
	    if {$count > $max} { 
		set max $count
		set which $digit
		#puts "$which appears $count times" 
	    }
	    set digit $d
	    set count 1
	} else {
	    incr count
	}
    }
    set max
}

proc unit_test2 {} {
    puts "test get_count_*min* and max:"
    foreach {n min max} {
	1122344556677899000 1 3
	111333222445556667778999000 1 3
	1113332822445556667778999000 2 3
    } {
	assert [get_count_of_digit_with_min_occurrence $n] $min "<get_count..min..> $n [lsort [digits $n]]"
	assert [get_count_of_digit_with_max_occurrence $n] $max "<get_count..max..> $n [lsort [digits $n]]"
    }
    
}
unit_test2

proc unit_test3 {} {
    assert [set n 23] [answer] "<answer> $n! is the first factorial which has all digits"
    assert [set n 34] [answer2 2] "<answer> $n! is the first factorial which has each digit at least twice"
}

# 529! is the first factorial which has each digit at least 100 times
# It has only 1213 digits, which is very close to 1000, the minimum number..

Doc Beautiful {
    # 529!
    (tcl) 453 % llength [digits [factorial 529]]
    1213
    (tcl) 454 % time {puts [answer2 100]}
    529
    ~22 seconds
    (tcl) 455 % 
    (tcl) 484 % get_count_of_digit_with_min_occurrence [factorial 529]
    103
    (tcl) 485 % get_count_of_digit_with_max_occurrence [factorial 529]
    227
    (tcl) 496 % get_count_of_digits [factorial 529]
    0:227 1:109 2:114 3:105 4:110 5:109 6:107 7:103 8:120 9:109
    (tcl) 497 % 
}

Doc Tougher -- About 3 minutes to get to min 200 occurrences {
    # 914!
    # Again, it is seven with the least. But, two and five are very close, too!
    (tcl) 50 % time {puts [answer2 200]}
    914
    194547994 microseconds per iteration
    (tcl) 51 % get_count_of_digits [factorial 914]
    0:412 1:224 2:207 3:210 4:210 5:207 6:210 7:204 8:215 9:213
    (tcl) 52 % llength [digits [factorial 914]]
    2312
    (tcl) 53 % 
    # Is there some randomization here??
    # Eliminate 0s and see the average:
    (tcl) 53 % expr (1213 - 227)/9.0
    109.55555555555556
    (tcl) 54 % expr (2312 - 412)/9.0
    211.11111111111111
    (tcl) 55 % 
}

Doc Even tougher -- About 8 minutes to get to min 300 occurrences {
    # 1271
    (tcl) 55 % time {puts [answer2 300]}
    1271
    487528251 microseconds per iteration
    (tcl) 56 % 
    (tcl) 56 % get_count_of_digits [factorial 1271]
    0:587 1:325 2:308 3:301 4:306 5:318 6:324 7:305 8:313 9:309
    (tcl) 57 % llength [digits [factorial 1271]]
    3396
    (tcl) 58 % expr (3396 - 587)/9.0
    312.1111111111111
    (tcl) 59 % 
}
