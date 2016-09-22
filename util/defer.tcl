proc defer {args} {
    while {[llength $args] == 1} {
	set args2 [lindex $args 0]
	if {[string match $args2 $args]} break
	set args $args2
    }
    set cmd [uplevel 1 [list namespace code $args]]
    set create_trace [list trace variable DEFER_VAR_ u [list ::defer::callback $cmd]]
    uplevel 1 $create_trace
}

namespace eval ::defer {
    proc callback {cmd name1 name2 op} {
	eval $cmd
    }
}

#
# That's it!
# 
# The rest is sample usage and unit tests..
# 
namespace eval bb {
    proc tmpdir {} {
	set name .bb_defer_test_dir
	if {[file isdirectory /tmp]} {
	    set dir /tmp/$name ; # unix only
	} else { 
	    set dir [file join . $name]
	}
	file mkdir $dir
	set dir [file normalize $dir]
    }

    proc defer_samples {} {
	# save and auto-restore the state of a variable
	namespace eval _defer_ {
	    variable x -1
	    proc ex0 {val} {
		variable x
		defer set x $x
		set x $val
		# ...
		# use the tmp val of x until the the end of proc
		# afterwards, it will revert to -1
	    }
	}
	# execute something at the end (or upon throwing out) of a proc
	proc ex1 {args} {
	    set msg "ex1"
	    # defer puts "Finished $msg"
	    # puts "Started $msg"
	    # ...
	    # any return path will first print the finish message
	}
	# can unset env vars
	proc ex2 {} {
	    global env
	    set vars {_S_ _S_ _A_}
	    foreach x $vars {
		set env($x) 1
		defer unset env($x)
	    }
	    # use these env vars until end of proc
	    # ...
	}
	# preserve current dir after changing to a tmp dir
	proc ex3 {} {
	    defer cd [pwd]
	    cd [bb::tmpdir]
	    # do something in this dir
	    # ...
	}
	# can also use quotes, if needed. Use {} to suppress substitution as normal
	proc ex3b {} {
	    defer "cd [pwd]"
	    cd [bb::tmpdir]
	    # do something in this dir
	    # ...
	}
	# can defer execution of any complex command, e.g., proc
	proc ex4 {} {
	    defer proc bb::_ex4_ {} { return 0 }
	    proc bb::_ex4_ {} { return 1 }
	    # use _ex4_ 
	    # ...
	}
    }
} ; # ns bb for defer

proc [set test_cmd bb_test_defer] {info} {
    #puts "UNIT TESTING DEFER: $info"
    namespace eval _defer_ {
	variable x -1
	proc ex0 {{val 0}} {
	    variable x
	    defer set x $x
	    set x $val
	    assert {$x == $val} ex0_1
	}
	assert {$x == -1} ex0_0
	ex0
	assert {$x == -1} ex0_2
    }
    _defer_::ex0 99
    assert {$_defer_::x == -1} ex0_3

    global a; set a 0
    proc ex1 {args} {
	set msg "ex1"
	global a
	#defer puts "Finished $msg a=<$a>"
	#puts "Started $msg a=<$a>"
	defer incr a
	return $a
    }
    assert {[ex1] == 0} ex1
    assert {$a == 1} ex1
    unset a

    global env
    catch {unset env(_TMP_DEFER_)}
    assert {[info exists env(_TMP_DEFER_)] == 0} ex2

    proc ex2 {} {
	global env
	set env(_TMP_DEFER_) 1
	set vars {_S_ _S_ _A_}
	foreach x $vars {
	    set env($x) 1
	    assert {[info exists env($x)] == 1} ex2
	    defer unset env($x)
	}
    }
    ex2
    assert {[info exists env(_TMP_DEFER_)] == 1} ex2
    unset env(_TMP_DEFER_); # clean-up
    foreach var {S S A} {
	assert {[info exists ::env(_${var}_)] == 0} ex2
    }
    foreach p {1 2} {
	rename ex${p} ""; # clean-up
    }

    proc ex3 {} {
	defer cd [pwd]
	cd [bb::tmpdir]
    }
    set dir [pwd]
    ex3
    assert {[pwd] == $dir} ex3
    unset dir

    proc ex3b {} {
	defer "cd [pwd]"
	cd [bb::tmpdir]
    }
    set dir [pwd]
    assert {[pwd] == $dir} ex3b0
    ex3b
    assert {[pwd] == $dir} ex3b1
    unset dir

    proc ex3c {} {
	defer [list [list "cd [pwd]"]]
    }
    set dir [pwd]
    assert {[pwd] == $dir} ex3c0
    ex3c
    assert {[pwd] == $dir} ex3c1
    unset dir

    proc [set p bb::_ex4_] {} { return -1 }
    proc ex4 {} {
	defer proc bb::_ex4_ {} { return 0 }
	proc bb::_ex4_ {} { return 1 }
	assert {[bb::_ex4_] == 1} ex4
    }
    assert {[$p] == -1} ex4
    ex4
    assert {[$p] == 0} ex4
}
proc cmd {} "return $test_cmd"
#puts "cmd: [cmd]"
[cmd] local
namespace eval :: [cmd] under_global
namespace eval bb [cmd] under_bb
namespace eval test_bb {
    [cmd] under_test_bb
    proc test {} {
	[cmd] under_test_bb_proc_test
    }
}

# clean up namespaces
foreach ns {test_bb _defer_ bb} {
    namespace delete $ns
}
# clean up commands
rename [cmd] ""
foreach cmd {cmd ex3 ex3b ex3c ex4} {
    rename $cmd ""
}
if {0} { ; # no longer needed as bb ns is now deleted
    foreach cmd {_ex4_ defer_samples tmpdir} {
	rename ::bb::$cmd ""
    }    
}

# clean up vars
unset cmd ns test_cmd
