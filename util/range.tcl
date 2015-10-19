# Ranges!

# {0 1 2 ... $n-1}:
proc range n { set o {0}; for {set i 1} {$i < $n} {incr i} { lappend o $i }; return $o }
# {1 2 3 ... n}:
proc range_natural n { set o {}; for {set i 1} {$i <= $n} {incr i} { lappend o $i }; return $o }
# {1 2 3 ... n-1}:
proc range_natural_open n { set o {}; for {set i 1} {$i < $n} {incr i} { lappend o $i}; return $o}
