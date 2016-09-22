source u.tcl
Doc Coin sums {
    we have as many coins as we want, but they come in only
    >> $2 $1 25c 10c 5c 1c
    How many different ways can we collect $2??
    In Britain, the coins are different:
    >> 200, 100, 50, 20, 10, 5, 2, 1
}
# The key is to ask the recursive question!
# Given the coin with max value (e.g., 200) and a target, enumerate the options
# assuming that we know the answer for the next coin (100) and any given target..

# A{<target> <max-coin>} : answer for given target and max-coin
# A{200 200} = Use 200, or not: 1 + A{200 100} =
# A{200 100} = Use two, one or no 100: 1 + A{100 50} + A{200 50}
# A{100  50} = Use two, one or no 50
# A{200  50} = Use four, three, two, one or no 50
# ...
# Also note that we answer some questions many times, e.g., A{100 50} is used in A{200 50}, so, remembering our answers is very helpful

# Here is the main challenge
proc how_many_ways {max_coin target} {
    if {$max_coin == 0} { return 0 }
    if {[memo?]} {
	variable memo
	if {[info exists [set elem memo($max_coin,$target)]]} { return [set $elem] } ; # do we remember seeing this before?
    }
    set out 0
    for {set i [expr {$target / $max_coin}]} {$i >= 0} {incr i -1} {
	if {[set value [expr {$i * $max_coin}]] == $target} { incr out; continue }
	incr out [how_many_ways [next_coin $max_coin] [expr {$target - $value}]]
    }
    if {[memo?]} {
	set $elem $out ; # let's remember that we saw this before
    }
    set out
}

proc memo? {} { return 0 }

proc unit_test {} {
    proc memo? {} { return 0 }
    foreach foo {1 2} {
	# Test the basic utilities first..
	assert 50 [setup 50 "-1 10 50 100 50 20 10 -5"] "<setup> 0"
	variable next_coin
	assert [lsort -dict [array names next_coin]] "10 20 50" "<setup> 1"
	assert 0 [next_coin 10] "<next_coin> 1"
	assert 10 [next_coin 20] "<next_coin> 2"
	assert 200 [setup 201 "202 200 100 2"] "<setup> 2"
	# Test the answer
	assert 4 [answer 20 "5 20 10"] "<answer> 0"
	assert 5 [answer 20 "5 3 20 10"] "<answer> 1"
	assert 11 [the_answer 10] "<the_answer> target=10"
	assert 12 [the_answer 11] "<the_answer> target=11"
	assert 22 [the_answer 15] "<the_answer> target=15"
	assert 451 [the_answer 50] "<the_answer> target=50"
	assert 4563 [the_answer 100] "<the_answer> target=100" ; # takes about 0.1 sec w/o caching
	puts "Start to remember.."
	proc memo? {} { return 1 }
    }
}

proc the_answer {{target 200}} {  ; # This answers the question and gives us how long it took, too
    puts [time { set out [answer $target "20 50 200 100 1 2 5 10"] }]
    set out
}
proc answer {target coins} { how_many [setup $target $coins] $target } ; # this is more general, can try different sets of coins

proc how_many {max_coin target} { ; # Simple wrapper (a level of indirection) if we are remembering...
    if {[memo?]} {  ; # This is to set up our memo(ry) to speed things up...
	variable memo
	array unset memo
	array set memo {}
    }
    how_many_ways $max_coin $target
}

proc next_coin {coin} { ; # This should give us the coin with the next highest value
    variable next_coin
    return $next_coin($coin)
}

variable next_coin
# Just in case setup is not run..
array set next_coin {200 100    100 50    50 20    20 10    10 5    5 2    2 1    1 0}
# The following is a generalization so we can run with any set of coins..
proc setup {target coins} {
    puts "setup for Target=$target Coins=<$coins>"
    variable next_coin
    array unset next_coin
    array set next_coin {}
    lappend coins 0
    set sorted [lsort -unique -decreasing -int $coins]
    set max 0
    for {set i 0} {$i < [llength $sorted]} {} {
	set this [lindex $sorted $i]
	if {$this > $target} { incr i; continue }
	if {$this <= 0} break
	if {$this > $max} { set max $this }
	set next [lindex $sorted [incr i]]
	if {$next < 0} { set next 0 }
	set next_coin($this) $next
    }
    set max
}

unit_test

Doc Runtime optimization using "caching" (Memoization) {
    Before {
	% source now.tcl
	208 microseconds per iteration
	304 microseconds per iteration
	520 microseconds per iteration
	19173 microseconds per iteration
	123496 microseconds per iteration
	# > 2min for target=400
	(tcl) 81 % the_answer 400
	136104399 microseconds per iteration
	1960497
    }
    After {
	(tcl) % source now.tcl
	237 microseconds per iteration
	337 microseconds per iteration
	477 microseconds per iteration
	4539 microseconds per iteration
	18490 microseconds per iteration
	(tcl) 54 % the_answer
	83411 microseconds per iteration
	73682
	# < 2sec for target=400 (:-)
	# almost 2 million ways for four bucks
	(tcl) 55 % the_answer 400
	300556 microseconds per iteration
	1960497
	# > 300M ways for ten bucks!
	(tcl) 57 % the_answer 1000
	1637564 microseconds per iteration
	321335886
	(tcl) 57 % 
    }
}

Doc Answer {
    # No memoization (i.e., no caching)
    (tcl) 95 % time {puts [how_many_ways 200 200]}
    73682
    2900462 microseconds per iteration
    (tcl) 96 % 
    # with memo, radical speed up!
    (tcl) 54 % the_answer
    83411 microseconds per iteration
    73682
}

# Also see ~/cpp/prob31.cpp
