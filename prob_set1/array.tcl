# if the key exists, incr value,
# otherwise, set value
proc array_incr {name key value} {
    upvar $name a
    [expr {[info exists [set elem a($key)]]==1?"incr":"set"}] $elem $value
}
