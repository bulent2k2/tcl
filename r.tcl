# See ~/fp/right-triangle.hs

proc f x { expr {9.0 * $x / 50} }

foreach {x y} {
    20         3
    50         8
   100        18
   200        35
   250        43
   500        90
  1000       180
} {
    puts "$x $y e=[expr { abs($y - [f $x]) }]"
}
