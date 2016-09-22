error "Now in bb.tcl"

alx::boot
namespace eval bb::state {
    proc test {} {
        namespace eval ::test_state {
            variable x {}
            variable y "a b c"
            variable z {a {b c}}
            variable a1
            variable a2
            array set a1 {}
            array set a2 {a 0 b 1 c {1 2 3} z {}}
            namespace eval ::test_state_sub {
                variable x {}
                variable y "a b c"
                variable z {a {b c}}
                variable a1
                variable a2
                array set a1 {}
                array set a2 {a 0 b 1 c {1 2 3} z {}}
            }
        }
        foreach sample {test_state tk bb alx} {
            set sns [i::get_children_ns $sample]
            i::fputs "[llength $sns] namespace(s) in $sample: $sns"
        }
        save ::test_state test_state.tcl
        save ::bb test_bb_state.tcl
    }
    proc save {top_namespace filename} {
        i::fopen $filename
        bb::defer i::fclose
        puts "saving state in [file normalize $filename].."
        i::dump $top_namespace
    }
    proc load {filename} {
        uplevel \#0 source $filename
    }
    namespace eval i {
        proc fopen {filename} {
            variable file [open $filename w]
        }
        proc fclose {} { 
            variable file
            close $file
            unset file
        }
        proc fputs {string} {
            variable file
            if {![info exists file]} {
                set file stdout
            }
            puts $file $string
        }
        proc cc {} { return \# }
        proc ob {} { return \{ }
        proc cb {} { return \} }
        proc dump {top_ns} {
            dump_vars $top_ns
            foreach cns [get_children_ns $top_ns] {
                dump_vars $cns
            }
        }
        proc get_children_ns {ns} {
            set out [list]
            foreach sns [namespace eval :: namespace children $ns] {
                lappend out $sns 
                foreach ss [get_children_ns $sns] {
                    lappend out $ss
                }
            }
            return $out
        }
        proc dump_procs {ns} {
            set cntp 0; set cnts 0
            foreach p [info procs [set ns]::*] {
                if {[catch {fputs [pp $p]}]} {
                    fputs "[cc] SKIPPED proc $p."
                    incr cnts
                } { incr cntp }
            }
            fputs "[cc] num-procs=$cntp num-skipped-procs=$cnts"
        }
        proc dump_vars {ns} {
            fputs "[cc] ---ns $ns---"
            set cntv 0; set cnta 0; set cnts 0
            foreach v [info vars [set ns]::*] {
                if {[array exists $v]} {
                    set val [array get $v]
                    set ll [llength $val]
                    if {$ll == 0} {
                        set val {}
                    }
                    if {$ll > 1000} {
                        fputs "[cc] SKIPPED LONG ARRAY $v"
                        incr cnts
                    } else {
                        if {$ll==0 || $ll > 1} {
                            set val "[ob]$val[cb]"
                        }
                        fputs "array set $v $val"
                        incr cnta
                    }
                } { 
                    if {[info exists $v]} {
                        set val [set $v]
                        if {0 == [string length $val]} {
                            set val {}
                            set ll 0
                        } else {
                            set ll [llength $val]
                        }
                        if {$ll > 1000} {
                            fputs "[cc] SKIPPED LONG VAR $v"
                            incr cnts
                        } else {
                            if {$ll==0 || $ll > 1} {
                                set val "[ob]$val[cb]"
                            }
                            fputs "set $v $val"
                            incr cntv
                        }
                    } ; # else it is not initialized
                }
            }
            fputs "[cc] num-arrays=$cnta num-vars=$cntv num-skipped=$cnts"
            #dump_procs $ns
        }
    } ; # ns i
} ; # ns bb::state
