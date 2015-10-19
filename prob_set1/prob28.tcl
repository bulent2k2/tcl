source u.tcl

Doc Number spiral diagonals {
    # Problem 28
    Starting with the number 1 and moving to the right in a clockwise direction a 5 by 5 spiral is formed as follows:

   (21)22 23 24(25)
    20 (7) 8 (9)10
    19  6 (1) 2 11
    18 (5) 4 (3)12
   (17)16 15 14(13)

    It can be verified that the sum of the numbers on the diagonals is 101.

    What is the sum of the numbers on the diagonals in a 1001 by 1001 spiral formed in the same way?
}  Answer {
    (tcl) 55 % answer 1001
    669171001
    (tcl) 56 % 
}

proc answer {size} {
    set total 1
    set last  1
    set step  2
    while {$step < $size} {
	incr total [expr 4 * $last + 10 * $step]
	incr last [expr 4 * $step]
	incr step 2
    }
    set total
}

proc unit_test {} {
    foreach {size total} {
	1    1
	3    25
	5    101
	7    261
	9    537
	11   961
	101  692101
	1001 669171001
    } {
	assert $total [answer $size] "<answer> $size"
    }
}
unit_test
