# diffusion sharing
#   use: find the minimum possible
#

if {""==[info command struct::graph]} {
    define c:/tcllib/tcllib-1.17/modules/struct/graph.tcl
}

namespace eval ds {
    proc ds edges   { enter the edges }
    proc findMin {} { find the minimum number of chains possible }
    proc ~ds {}     { variable g; if {""!=[info command $g]} { $g destroy } }
    proc vputs str  { variable v; if {$v>0} { puts $str } } ; # for viz..
    variable v 0
}

proc ds::ds edges {
    variable g "diffusion_graph"
    ~ds
    struct::graph $g
    foreach edge $edges {
	vputs "Edge: $edge"
	lassign $edge dev_name terminals
	lassign $terminals source gate drain body
	# Do we have "s d" (two term only), or "s g d b"??
	# Support both! (:-)
	if {""==$body} { ; # terminals has at most 3 entries..
	    set drain $gate ; # drain is second terminal
	    set gate g ; # gate and body are ignored below..
	    set body b
	}
	set index -1
	foreach term "$source $gate $drain $body" {
	    switch [incr index] {
		0 {set source $term}
		2 {set drain  $term}
		default continue
	    }
	    # default above to skip gate and body terms
	    if {![$g node exists $term]} {
		vputs "Adding node: $term"
		$g node insert $term
	    }
	}
	foreach arc [list "$dev_name.s2d" "$dev_name.d2s"] \
	    from "$source $drain" \
	    to "$drain $source" {
		if {![$g arc exists $arc]} {
		    vputs "Adding arc: $arc $from -> $to"
		    $g arc insert $from $to $arc
		}
	    }
    }
}

proc ds::test1 {} {
    puts "Draw a home with one stroke?"
    ds {
	"A {5 3}"    "B {5 4}"
	"C {3 4}"    "D {1 3}"
	"E {2 4}"    "F {2 3}"
	"G {1 4}"    "H {1 2}"
    }
    if {[ds::findMin] < 2} {
	puts "Sure. Just make sure to start on a node with an odd degree!"
    }
}
proc ds::test2 {} {
    puts "Walk over Bridges of Konigsberg?"
    ds {
	"1 {N S}"    "2 {N I}"
	"3 {N P}"    "4 {I P}"
	"5 {I S}"    "6 {P S}"
    }
    if {[ds::findMin]>1} {
	puts "To walk over all the bridges, one has to walk one at least twice!"
    }
}

proc ds::findMin {} {
    variable g 
    foreach n [$g nodes] {
	lappend deg2nodes([$g node degree -in $n]) $n
    }
    set count 0
    foreach degree [array names deg2nodes] {
	set deg2nodes($degree) [lsort $deg2nodes($degree)]
	if {$degree % 2} {
	    incr count [llength $deg2nodes($degree)]
	}
    }
    parray deg2nodes
    vputs "Number of trails: [set out [expr $count/2]]"
    # number of edge-disjoint trails needed to cover the graph
    # this also gives us the number of diffusion chains (== diffusion gaps+1)
    return $out
}
