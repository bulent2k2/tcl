# Instead of 'source' use 'define'
catch {namespace delete use}
catch {rename define ""}
proc define {path} {
    #puts "-define- [info level [info level]]"
    ::use::remember_globals
    if {![file exists $path]} {
	if {![file exists [set path2 $path.tcl]]} {
	    error "No such file: $path\[.tcl\]"
	} else { set path $path2 }
    }
    uplevel source $path
    ::use::update_globals $path
}
namespace eval ::use {}
proc ::use::remember_globals {} {
    variable tcl_nss [namespace children ::]
    variable tcl_cmds [namespace eval :: info commands]
    variable tcl_vars [namespace eval :: info vars]
    return $tcl_vars
}
proc ::use::update_globals {path} {
    set out {}
    # TODO: refactor!
    variable tcl_vars

    variable tcl_cmds
    set new {}
    foreach cmd [namespace eval :: info commands] {
	if {-1 == [lsearch $tcl_cmds $cmd]} {
	    lappend new $cmd
	}
    }
    if {[set count [llength $new]] > 0} {
	puts "[file tail $path] defined $count new commands: <[lsort -dict $new]>"
    }
    lappend out $count

    variable tcl_nss
    set new {}
    foreach ns [namespace children ::] {
	if {-1 == [lsearch $tcl_nss $ns]} {
	    lappend new $ns
	}
    }
    if {[set count [llength $new]] > 0} {
	puts "$path defined $count new namespace[plural? $count]: <[set nss [lsort -dict $new]]>"
	foreach ns $nss {
	    set c2 [llength [set cmds [get_commands $ns]]]
	    puts "[llength $cmds] command[plural? $c2] in $ns: <$cmds>"
	    if {[llength [set sub [namespace children $ns]]] > 0} {
		puts "-- $ns has sub-namespace[plural? [llength $sub]]: < $sub >"
		foreach ss $sub {
		    set c2 [llength [set cmds [get_commands $ss]]]
		    puts "-- [llength $cmds] command[plural? $c2] in $ss: <$cmds>"
		}
		# TODO: what if there are more nested namespaces??
	    }
	}
    }
    lappend out $count
    return $out
}

proc ::use::get_commands {nsn} {
    # this works properly only if the NameSpaceName is given properly:
    #   get_commands ::use
    #   get_commands ::ckt::i
    regsub -all "[set nsn]::" [lsort -dict [info commands [set nsn]::*]] "" out
    set out
}

set ::use::tcl_vars2 [use::remember_globals]
set dir [file dirname [file normalize [info script]]]
set count 0
set count2 0

######################
# This is where we source the utility procs
######################
set kind_msg "Please keep the namespace tidy!"
foreach file {
    func basics defer list num
} {
    lassign [define [file join $dir $file.tcl]] c1 c2
    incr count $c1
    incr count2 $c2
}
if {$count == 0} {
    puts "Defined one new command. Name: < define >"
} else {
    puts "Defined $count new command[plural? $count]. $kind_msg"
}
if {$count == 0} {
    puts "Defined one new namespace. Name: < ::use >"
}
if {$count2 > 0} {
    puts "Defined $count2 new namespace[plural? $count2]! $kind_msg"
}
unset file count dir count2 c1 c2 kind_msg

set ::use::tcl_vars3 [use::remember_globals]

set new {}
foreach var $::use::tcl_vars3 {
    if {-1 == [lsearch $::use::tcl_vars2 $var]} {
	lappend new $var
    }
}
if {[set diff [llength $new]] > 0} {
    puts "There [is_or_are? $diff] $diff new var[plural? $diff]!"
    puts "[it_or_they? $diff capital] [is_or_are? $diff]: [lsort -dict $new]"
} else {
    puts "No new vars (:-)"
}
unset diff var new
