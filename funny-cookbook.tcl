proc Doc args {}
Doc Use as {
    ? {0 1}
    ? {True False}
    ? {Heads Tails}
    ? {1 2 3 4 5 6}
}

proc ? L {lindex $L [expr {int(rand()*[llength $L])}]}


proc recipe {} {
  set a {
    {3 eggs} {an apple} {a pound of garlic}
    {a pumpkin} {20 marshmallows}
  }
  set b {
    {Cut in small pieces} {Dissolve in lemonade}
    {Bury in the ground for 3 months}
    {Bake at 300 degrees} {Cook until tender}
  }
  set c {parsley snow nutmeg curry raisins cinnamon}
  set d {
     ice-cream {chocolate cake} spinach {fried potatoes} rice {soy sprouts}
  }
  return "  Take [? $a].
  [? $b].
  Top with [? $c].
  Serve with [? $d].
  Enjoy!"
}

if {1 || [file tail [info script]]==[file tail $argv0]} {
  package require Tk
  pack [text .t -width 40 -height 5]
  bind .t <1> {showRecipe %W; break}
  proc showRecipe w {
    $w delete 1.0 end
    $w insert end [recipe]
  }
  showRecipe .t
}
