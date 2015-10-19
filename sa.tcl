define c:/tcllib/tcllib-1.17/modules/simulation/annealing.tcl

namespace eval sa {}
proc sa::findMin {} {
    puts [::simulation::annealing::findMinimum \
	      -trials 300 \
	      -verbose 1 \
	      -parameters {x -5.0 5.0 y -5.0 5.0} \
	      -function {$x*$x+$y*$y+sin(10.0*$x)+4.0*cos(20.0*$y)}]

}

proc sa::findMinConstrained {} {
    puts "Constrained:"
    puts [::simulation::annealing::findMinimum \
	      -trials 3000 \
	      -verbose 1 \
	      -reduce 0.98 \
	      -parameters {x -5.0 5.0 y -5.0 5.0} \
	      -code {
		  if { hypot($x-5.0,$y-5.0) < 4.0 } {
		      set result [expr {$x*$x+$y*$y+sin(10.0*$x)+4.0*cos(20.0*$y)}]
		  } else {
		      set result 1.0e100
		  }
	      }]
}

proc sa::findMinCombinatorial {} {
    foreach n {100 1000 10000} {
	puts "Problem size: $n"
	puts [::simulation::annealing::findCombinatorialMinimum \
		  -trials 300 \
		  -verbose 1 \
		  -number-params $n \
		  -code [format {set result [%s $params]} [namespace which cost]]]
	break
    }
}

# bbx: help view the annealing process..
# 1- Sample in time! Otherwise, printing to the console takes too long
# 2- Sample in space: only the first 80 params or so fits my screen
proc sa::init {{sample 1000} {show 75}} {
    reset
    sample $sample
    show $show
    return
}
variable counter
variable wavelength
proc sa::sample {{val 20}} {
    variable wavelength $val
    puts "Will sample the state once every $wavelength. (Change with [namespace which sample])"
}
proc sa::reset {} {
    variable counter 0
    puts "Reset the counter. (To reset again after a run, do: [namespace which reset])"
}
proc sa::show {{howmany -1}} {
    variable show
    if {$howmany == -1} { return $show }
    set show $howmany
    puts "Set the number of params to show: $show. (Change with [namespace which show])"
    incr show -1
    return $show
}
proc sa::print? {params_name} {
    variable counter
    variable wavelength
    variable show
    if {[incr counter] % $wavelength == 0} { ; # (1)
	upvar $params_name params
	#set showme $params
	set showme [lrange $params 0 $show] ; # (2)
	puts [format "%5s: $showme ..." $counter]
    }
}

#
# A simple combinatorial problem:
# We have 100 items and the function is optimal if the first 10
# values are 1 and the result is 0. Can we find this solution?
#
# What if we have 1000 items? Or 10000 items?
#
# WARNING:
# 10000 items take a very long time!
#
proc sa::cost {params} {
    print? params
    set cost 0
    foreach p [lrange $params 0 9] {
	if { $p == 0 } {
	    incr cost
	}
    }
    foreach p [lrange $params 10 end] {
	if { $p == 1 } {
	    incr cost
	}
    }
    return $cost
}

#
# Second problem:
#     Only the values of the first 10 items are important -
#     they should be 1
#
proc sa::cost2 {params} {
    print? params
    set cost 0
    foreach p [lrange $params 0 9] {
	if { $p == 0 } {
	    incr cost
	}
    }
    return $cost
}

proc sa::findMinCombinatorial2 {} {
    foreach n {100 1000 10000} {
	puts "Problem size: $n"
	puts [::simulation::annealing::findCombinatorialMinimum \
		  -trials 300 \
		  -verbose 1 \
		  -number-params $n \
		  -code [format {set result [%s $params]} [namespace which cost2]]]
	break
    }
}

sa::init
