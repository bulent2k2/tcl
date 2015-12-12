# Parse a basic spice netlist.
# Flatten it down to devices..
# 

# /berry/secure18/m1118/bulent/helix/reg/archive/basic_ckts/top1_parse.tcl

proc Doc args {}

proc test_ckt {} {
    global input
    ckt::parse [lindex $input 1]
    #parray ckt::i::table
    ckt::flatten [set topName [lindex $input 0]]; # [set prefix $topName]
    ckt::output
}

namespace eval ckt {}
namespace eval ckt::i {}
proc ckt::i::dputs {str} { puts $str }
proc ckt::parse {list} { 
    namespace eval i::ckt {
	variable table
	array unset table
	array set table {}
    }
    i::parse $list
}
proc ckt::flatten {ckt {prefix ""} {map ""}} { 
    namespace eval i::ckt {
	variable transistors {}
    }
    i::flatten $ckt $prefix $map
}
proc ckt::output {}  { ; # print it out nicely
    i::output 
}

proc ckt::i::parse {list} {
    set circuit ""
    foreach line $list {
	dputs [format "%-30s -- line: $line" "circuit: < $circuit >"]
        set words [split [string trim $line "\n"]]
        if {[llength $words] < 2} { continue }
        set cmd [lindex $words 0]
        switch $cmd {
            ".subckt"  { addCircuit [set circuit [lindex $words 1]] [lrange $words 2 end] }
            ".ends"    { set circuit "" }
            default    { addInst $circuit $words }
        }
    }
}
proc ckt::i::addCircuit {name interface} {
    variable table
    set table("i,$name") $interface
    set table("c,$name") "" ; # init just in case there are no sub-comps!
    return ""
}
proc ckt::i::addInst {name comp} {
    set out {}
    foreach word [split $comp] { ;     # remove whitespace!
	if {[set word [lindex $word 0]] != ""} { lappend out $word }
    }
    if {$name == ""} { error "No circuit name given for inst: < $out > (original line: < $comp >)." }
    variable table
    lappend table("c,$name") $out
}

proc ckt::i::flatten {ckt prefix map} {
    # prefix is the unique occurrence name (<top>.<inst1>.<inst2>...)
    # map is to map net names from local names to global/unique occurrence names
    variable table
    if {![info exists [set elem table("c,$ckt")]]} {
	error "Circuit <$ckt> is not found in netlist"
    }
    foreach comp [set $elem] {
	set oiname [set iname [string range [lindex $comp 0] 1 end]]
	if {$prefix != ""} { set iname $prefix.$oiname }
	switch [string index [lindex $comp 0] 0] {
	    "M" { mapTransistor $comp $iname $map}
	    "X" {
		set master [lindex $comp end]
		checkInst $iname $master [set elem2 table("i,$master")]
		set terms [set $elem2]
		set nets [mapNets $map [lrange $comp 1 end-1]]
		if {[catch {set map [zip $terms $nets]} msg]} {
		    error "Incorrect I/O for occurrence < $iname > with master < $master >.  $msg."
		}
		flatten $master $iname $map
	    }
	    default { error "ckt:$ckt" }
	}
    }
}
proc ckt::i::checkInst {iname master elem} {
    variable table
    if {![info exists $elem]} {
	error "Master < $master > for occurrence < $iname > was not found in the netlist."
    }
}

proc ckt::i::mapTransistor {comp name map} {
    set out $name
    lappend out [mapNets $map [lrange $comp 1 4]]
    foreach rest [lrange $comp 5 end] {
	lappend out $rest
    }
    variable transistors
    lappend transistors $out
    return $out
}

proc ckt::i::mapNets {map nets} {
    if {$map == ""} {
	return $nets
    }
    array set a $map
    set out {}
    foreach net $nets {
	if {[info exists [set elem a($net)]]} {
	    lappend out [set $elem]
	} else {
	    lappend out $net; # local net
	}
    }
    return $out
}

proc ckt::i::zip {list1 list2} {
    if {[llength $list1] != [llength $list2]} {
	error "Nets and terms do not match: < $list1 > vs < $list2 >"
    }
    set out {}
    foreach a $list1 b $list2 {
	lappend out $a $b
    }
    set out
}

#     {Xgx  foo1 foo2 foo3 foo4 foo5                inv_fbn}

set input { top3 {
    {.subckt top3}
    {Xt0  top}
    {Xt1  foo1 foo2 foo3 foo4 foo5                inv_fbn}
    {Xt2  top2}
    {.ends}
    {.subckt top2}
    {Xt1  foo1 foo2 foo3 foo4 foo5                inv_fbn}
    {Xt2  top}
    {Xt3  top}
    {.ends}
    {.subckt top}
    {Xg38 ck ina0 ina1 ina2 net53 vdd vss_1 vddp  na4_fbn}
    {Xg2  net53 r3 vdd vss_1 vddp                 inv_fbn}
    {Xg3 net52 r4 vdd vss_1 vddp                  inv_fbn}
    {Xg37 ck inb0 inb1 inb2 net52 vdd vss_1 vddp  na4_fbn}
    {.ends top}
    {.subckt inv_fbn a o vccl vssl vcclp}
    {MN0 o a vssl vssl n m=6}
    {MP0 o a vccl vcclp p m=6}
    {.ends inv_fbn}
    {.subckt na4_fbn a b c d o vccl vssl vcclp}
    {MP0 o d vccl vcclp p m=2 nf=1}
    {MP3 o b vccl vcclp p m=2 nf=1}
    {MP2 o a vccl vcclp p m=2 nf=1}
    {MP1 o c vccl vcclp p m=2 nf=1}
    {MN3 net22 d vssl vssl n m=2 nf=2}
    {MN2 net23 c net22 vssl n m=2 nf=2}
    {MN1 net24 b net23 vssl n m=2 nf=2}
    {MN0 o a net24 vssl n m=2 nf=2}
    {Xg10 xfoo yfoo  top4}
    {.ends na4_fbn}
    {.subckt top4 foo1 foo2}
    {.ends}
} }

Doc OtherPair {
    {Xg3 net52 r4 vdd vss_1 vddp                  inv_fbn}
    {Xg37 ck inb0 inb1 inb2 net52 vdd vss_1 vddp  na4_fbn}
}

Doc Original {
    {Xg38 ck_enb in_bb<0> in_bb<1> in_b<2> net53 vdd vss_1 vddp na4_fbn}
    {Xg37 ck_enb in_b<0> in_b<1> in_bb<2> net052 vdd vss_1 vddp na4_fbn}
    {Xg2 net53 rdec<3> vdd vss_1 vddp inv_fbn}
    {Xg3 net052 rdec<4> vdd vss_1 vddp inv_fbn}
}

proc ckt::i::output {} {
    variable transistors
    puts "[llength $transistors] transistors.."
    foreach t $transistors {
	set type [lindex $t 2]
	set types($type) 1
	lappend $type $t
    }
    foreach t [array names types] {
	puts "Count of $t FETs: [llength [set $t]]"
	foreach v [set $t] {
	    lassign [lindex $v 1] t0 t1 t2 t3
	    puts [format "%30s     d:%-10s g:%-10s s:%-10s b:%-10s   %s" [lindex $v 0] $t0 $t1 $t2 $t3 [lrange $v 2 end]]
	}
    }
}

proc sm {} "define [info script]"
