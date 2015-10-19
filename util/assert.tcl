# https://en.wikibooks.org/wiki/Tcl_Programming/Debugging#Assertions

assert "abc" {abc} "ASSERT OLD FORM"
if {[info command assert_old] == ""} {
    rename assert assert_old
}

proc assert {condition {tag ""}} {
   set s "{$condition}"
   if {![uplevel 1 expr $s]} {
       if {$tag == ""} {
	   return -code error "assertion failed: $condition"
       } else {
	   return -code error "$tag assertion failed: $condition"
       }
   }
}

assert {3 * 5 <= 100} "ASSERT NEW FORM"

