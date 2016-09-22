# Try without echo, and Titan (not gtcl) aborts with:
#   invalid command name "tcl_findLibrary"
# if this file (or any other file with the name init.tcl) is in the run dir.
echo "in alx (t) init.tcl"
namespace eval t {}

proc me? {} { return 0 } ; # turn this on for personal debugging code (OBSOLETE?)
namespace eval t {
    proc use_bootme? {} {
        # set to 1 to boot with ~/bootme (for any test which uses t::boot without any args). Default (=0) to use "eval alx::boot [list]"
        variable bootme
        global ::env
        if {[set bootme [expr {[info exists env(USE_BOOTME)] && $env(USE_BOOTME) == 1}]]} {
            puts "USING ~/bootme"
        }
        # check the run dir for BOOT_DIR soft-link. It will have info as to what it booted with..
        set bootme
    }
}

proc t::boot!  {args} { eval boot[if {[debug?]} { format _debug } { format ""  }] $args }
# The next two are for make's debug target (so titan stays up):
# Use boot_debug to turn on debug messages for either target (debug or test.log)
proc t::debug! {{yes 1}} { if {$yes} { exec touch .DO_NOT_EXIT } else { file delete -force .DO_NOT_EXIT } }
proc t::debug? {} { file readable .DO_NOT_EXIT }
proc t::exit?  {} { if {![debug?]} { tclExit } }
proc t::run?   {} { expr {0 == [file readable .DO_NOT_EXIT]} }
proc t::root   {} { 
    set install [ssInstallDir]
    if {[regexp local/eda $install]} {
        # e.g., /remote/titan_scm/tmp/sunilk/linux26_x86_64.hbonds_fix/gemini/R1.0.0/local/eda
        return /remote/titan_builds02/test/alx/latest
    }
    #set root /remote/titan_builds02/test/alx/20121113
    set alx  [file normalize $install/../../alx]
    set date [lindex [file split $alx] end-1]
    if {![regexp ^201 $date]} {
        set date latest
        #e.g., a release build: /remote/titan_builds02/fix/REL201210/unstable/alx
    }
    _check_root $alx $date
}
proc t::_check_root {alx date} {
    #/remote/titan_builds02/test/alx/20121113/
    # if the latest build failed, pick up the most recent..
    set root [file join $alx $date]
    set counter 0
    while {![file readable [set test [file join $root techb/umc130/rule.tcl]]]} {
        if {$counter == 0} {
            puts "-WARNING- Latest ALX ROOT is not looking good. Could not read: $test."
        }
        set msg "Can't find a good alx root under [file normalize $alx]"
        if {![null? $date] && [string is int $date]} {
            set root [file normalize $alx/[incr date -1]]
            if {[incr counter] > 30} { 
                error $msg
            }
        } else {
            error $msg
        }
    }
    if {0 < [llength [info command ::bb::defer]]} {
        bb::defer cd [pwd]
    } else { 
        error "Please boot alx first."
    }
    cd $root
    set root [pwd]
    puts "-INFO- Set ALX ROOT to $root."
    return $root
    # E.g., /remote/titan_builds02/test/alx/20121103
    # or, /remote/titan_builds02/fix/REL201210/unstable/alx/20121103
}

proc t::boot_debug {args} {
    variable ::_alx_boot_debug_ 1
    eval boot $args
    debug
}
proc t::debug {} {
    bb::debug ; # toggles on/off
    bb::mytime_on
    alx::g2 n_debug 1                                  ; # new air_db
    alx::g f_debug 1;                                  ; # debug flag alx tcl flow code
    alx::g2 aflow_debug 1                              ; # abs flow debug
    alx::g air_debug 2                                 ; # debug flag for mol and drc bond generation
    alx::g cbond_debug 1                               ; # alx set param cbond_debug 1
    alx::g plog 1                                      ; # For pcell flow. To see the log, do: alx::plog -print
    alx::g pcell_debug 1
    alx::g pcell_verify_params 1
    alx::g pcell_verify_params_file pcell_param_verification.log
    variable ::h::debug 2
    air h set int debug 10
    alx::g2 mdb_history 1
    alx::g keep_lp_input 1
    alx::g2 chem_b_files_to_keep "diff*.txt poly*.txt jbond*" ; # a few samples..
    alx::g2 lp_debug 1 ; # lp engine debug flag
    alx::g2 save_custom_bonds 1
}
proc t::reset_debug {} {
    proc ::bb::dputs args {} ; # bb::debug
    bb::mytime_off
    alx::g n_debug -
    alx::g f_debug 0
    alx::g aflow_debug -
    alx::g air_debug 0
    alx::g cbond_debug 0
    alx::g plog 0
    alx::g pcell_debug 0
    alx::g pcell_verify_params 0
    variable ::h::debug 0
    air h set int debug 0
    alx::g mdb_history -
    alx::g keep_lp_input 0
    alx::g chem_b_files_to_keep -
    alx::g lp_debug -
}
# Instead of t::boot, can also do something like: 
#  set mybuild ""
#  if {$env(USER) == "bulent"} { set mybuild /home/bulent/public/ibuild/20110624/alx } else { set mybuild "" }
#  eval alx::boot $mybuild
#
proc t::boot {{option 0}} {
    global ::env ::_alx_boot_debug_
    if {![info exist _alx_boot_debug_]} { set debug 0 } { set debug 1 }
    set home $env(HOME)
    if { [string is int $option] && $option == -1 } { set option $home/bootme ; set link_bootme 0 } else { set link_bootme 1 }
    if { ![string is int $option] } { ; # if "option" is an ibuild, boot with it
	if { ![file readable $option] } { error "Can not boot from < $option > .. " }

 	if {![info exists env(USER)]} { set env(USER) noone }
 	set me $env(USER) ; # if me==bulent, do NOT turn on debugging!
        if {$debug == 0} { set env(USER) noone }
	if {[ eval _boot $option]} { set env(USER) $me; error "Boot error." }
 	if {$debug} { set env(USER) debugger }
 	set env(USER) $me

	if {$link_bootme && [file readable $home] && "bootme" != [file tail $option] } {
	    file delete $home/bootme
	    exec ln -s [file normalize $option] $home/bootme
	}
	return
    }
    set env(USER) noone
    if {$debug} { set env(USER) debugger }
    if {$option == -2} { ; # update ~/bootme to point to the latest ibuild
	file delete /home/bulent/bootme
	exec ln -s [exec cat /home/bulent/ct/.last_ibuild]/alx /home/bulent/bootme
    }
    # 0: default        -- test old/official code
    # 1: local          -- local source from sandbox/air/src/tcl
    # 2: build          -- after magmaBuild in local tcl 
    # 3: release        -- after copy to a public/release area
    set root_index $option
    set tcl ~/air_root                                        ; # option 1: <cvs>/gemini/R1.0.0/local/src/modules/air
    set build ~/air_build/gemini/R1.0.0/local/eda/lib/alx     ; # option 2: <cvs>/gemini/R1.0.0/local/eda/lib/alx
    set release ~/air_release                                 ; # option 3: ~/public/ibuild/latest
    set roots [list {} $tcl $build $release]                  ; # option 0: see the first elem in list
    set root [lindex $roots $root_index]
    # can also do tmp overrides here:
    #set root ~/branch/air; puts "INFO:GLOBAL-TMP-TEST from branch sandbox"
    #set root ~/branch/alx; puts "INFO:GLOBAL-TMP-TEST from branch build"
    #set root ~/c;          puts "INFO:GLOBAL-TMP-TEST from tot sandbox"
    #set root $build;       puts "INFO:GLOBAL-TMP-TEST from tot build"
    #set root ~/bootme;     puts "INFO:GLOBAL-TMP-TEST from ~/bootme"
    if {[ eval _boot $root]} { error "Boot error." }
}
proc t::_boot { {arg ""} } {
    puts "INFO: arg='$arg'."
    if {"" == $arg && [use_bootme?]} {
        set arg ~/bootme
    }
    puts "INFO: booting with '$arg'.."
    if {[file readable $arg]} {
        set dir [pwd]; cd $arg; puts "INFO: boot path: [set tmp [file normalize .]]"; cd $dir 
        file delete -force BOOT_DIR
        exec ln -s $tmp BOOT_DIR
    } else {
        file delete -force BOOT_DIR
        exec ln -s alx_boot_default BOOT_DIR
    }
    namespace eval ::bb0 { proc cb_after {args} { puts "alx_version: [::alx::version]" } }
    if {[catch { eval alx::boot $arg } msg]} { ; # BOOT!
        puts "-ALX-Error- Failed to boot: '$msg'"
        return 1
    }
    return 0
}

proc t::run {{option 0}} {
    # 0: default -- exit titan
    # 1: do NOT exit titan
    set val _INIT_
    if {[bb::mytime catch { set val [bb::source&run ./main.tcl main]} msg]} {
	puts "caught error: $msg"
    }
    puts "val= < $val >"
    if {$option == 0} {
        exit?
    }
    return ; # keep Titan up to use the test run further
}

proc t::sample_input {{path "/slowfs/titan1/alx/reg/lib/gto_rx_ctle/gto_rx_ctle_stg1-lay-1"}} { bbt::load_from_fullpath $path r r }
proc t::sample_setup {{techa fujitsu65} {techb tsmc45gs}} { alx setup -techa $techa -techb $techb -root [root] }

proc t::new_lib {name} { edbCreateLibrary $name [sample_cfg] . }
proc t::new_cell {libid name {view layout}} { edbCreateCell $libid $name $view }
proc t::sample_cfg {} { file join [ssInstallDir] userdefaults tsmcN45_LDP.cfg }
proc t::new_rect {cellid layerid point w h {ref_type center} {datatype 252} {netid 0}} { ; # lower-left point,  width and height are in microns
    switch $ref_type {
        center {
            set box  "{[expr {[lindex $point 0]-$w/2.0}] [expr {[lindex $point 1]-$h/2.0}]} {[expr {[lindex $point 0]+$w/2.0}] [expr {[lindex $point 1]+$h/2.0}]}"
        }
        ll { set box "{$point}                                                              {[expr {[lindex $point 0]+$w    }] [expr {[lindex $point 1]+$h    }]}" }
        ur { set box "{[expr {[lindex $point 0]-$w    }] [expr {[lindex $point 1]-$h    }]} {$point}" }
        lr { set box "{[expr {[lindex $point 0]-$w    }]        [lindex $point 1]         }        {[lindex $point 0]          [expr {[lindex $point 1]+$h    }]}" }
        ul { set box "{       [lindex $point 0]          [expr {[lindex $point 1]-$h    }]} {[expr {[lindex $point 0]+$w}]            [lindex $point 1]         }" }
    }
    edbCreateRectangle $cellid $layerid $datatype $netid $box
}
proc t::sample_z {cellid layerid} { ; # up -> left -> up
    foreach {point w h ref_type} {
        {-5 -5} 1 4 ur
        {-5 -5} 3 1 ur 
        {-8 -6} 1 4 ll
    } { new_rect $cellid $layerid $point $w $h $ref_type }
}
proc t::sample_sym_z {cellid layerid} {
    sample_z $cellid $layerid
    foreach {point w h ref_type} {
        {5 -5} 1 4 ul
        {5 -5} 3 1 ul
        {8 -6} 1 4 lr
    } { new_rect $cellid $layerid $point $w $h $ref_type }
}
