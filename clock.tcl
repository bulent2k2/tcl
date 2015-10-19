#!/usr/bin/env tclsh
package require Tk

proc every {ms body} {eval $body; after $ms [info level 0]}

proc drawhands w {
    $w delete hands
    set secSinceMidnight [expr {[clock sec]-[clock scan 00:00:00]}]
    foreach divisor {60 3600 43200} length {45 40 30} width {1 3 7} {
       set angle [expr {$secSinceMidnight * 6.283185 / $divisor}]
       set x [expr {50 + $length * sin($angle)}]
       set y [expr {50 - $length * cos($angle)}]
       $w create line 50 50 $x $y -width $width -tags hands
    }
}
proc toggle {w1 w2} {
    if [winfo ismapped $w2] {
        foreach {w2 w1} [list $w1 $w2] break ;# swap
    }
    pack forget $w1
    pack $w2
}
#-- Creating the analog clock:
canvas .analog -width 100 -height 100 -bg white
every 1000 {drawhands .analog}
pack .analog

#-- Creating the digital clock:
label .digital -textvar ::time -font {Courier 24}
every 1000 {set ::time [clock format [clock sec] -format %H:%M:%S]}

bind . <1> {toggle .analog .digital}
