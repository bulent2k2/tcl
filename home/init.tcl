# This is ~/.cdesigner.tcl <- ~/cd/tcl/init.tcl
puts "bbx: In [set me [info script]]."

#puts "skipping all of $me. [unset me]"; return; puts "not here!"

proc setupHelixMenu {} {
    global env
    set var env(CNI_HELIX_ENV)
    if {[info exists $var]} {
        puts "Helix CC menu is sourced."
        source [set $var]/pylib/DesFlow/HelixCDMenu.tcl
    } else {
        puts "CNI_HELIX_ENV is not set. Helix CC menu is not sourced."
    }
}
if 1 {
    setupHelixMenu
} else {
    puts "Did not source HEI setup! Do: 'setupHelixMenu'"
}

global bb_skip_definitions 1
if {[source /u/bbasaran/cd/tcl/bb.tcl]} {
    puts "got bb. skipping the rest of $me. [unset me]"; return; puts "not here!"
} else {
    define_sm
}

# From: ~/p/star/sdl/instance/SNPS40NE/.cdesigner.tcl
# For setup, see: ~/p/star/sdl/README

##source $env(CNI_ROOT)/pylib/DesFlow/HelixCDMenu.tcl
# /u/girishv/regression/p4/custom/helix/ae/Plugins/pylib/DesFlow/HelixCDMenu.tcl

proc doc args {}

doc tcl unknown {
    Warning: TCL error encountered while sourcing startup file '/remote/us01home36/bbasaran/.cdesigner.tcl':
    invalid command name "echo"
    while executing
    "tcl_unknown echo {Did not source HEI setup!}"
    invoked from within
    "_base_tcl_unknown echo {Did not source HEI setup!}"
    ("uplevel" body line 1)
    invoked from within
    "uplevel 2 [linsert $arg 0 _base_tcl_unknown]"
    (procedure "_utility::eval_base_unknown" line 2)
    invoked from within
    "_utility::eval_base_unknown $args"
    (procedure "::unknown" line 30)
    invoked from within
    "echo "Did not source HEI setup!""
    invoked from within
    "if 0 {
    source $env(CNI_HELIX_ENV)/pylib/DesFlow/HelixCDMenu.tcl
} else {
    echo "Did not source HEI setup!"
}"
    (file "/remote/us01home36/bbasaran/.cdesigner.tcl" line 7)
    invoked from within
    "source /remote/us01home36/bbasaran/.cdesigner.tcl"
    ("uplevel" body line 1)
    invoked from within
    "uplevel #0 source $file"
} {
    Designer> info body tcl_unknown 
} proc tcl_unknown {...} {
    variable ::tcl::UnknownPending
    global auto_noexec auto_noload env tcl_interactive

    # If the command word has the form "namespace inscope ns cmd"
    # then concatenate its arguments onto the end and evaluate it.

    set cmd [lindex $args 0]
    if {[regexp "^:*namespace\[ \t\n\]+inscope" $cmd] && [llength $cmd] == 4} {
        #return -code error "You need an {*}"
        set arglist [lrange $args 1 end]
        set ret [catch {uplevel 1 ::$cmd $arglist} result opts]
        dict unset opts -errorinfo
        dict incr opts -level
        return -options $opts $result
    }

    catch {set savedErrorInfo $::errorInfo}
    catch {set savedErrorCode $::errorCode}
    set name $cmd
    if {![info exists auto_noload]} {
        #
        # Make sure we're not trying to load the same proc twice.
        #
        if {[info exists UnknownPending($name)]} {
            return -code error "self-referential recursion in \"unknown\" for command \"$name\"";
        }
        set UnknownPending($name) pending;
        set ret [catch {
            auto_load $name [uplevel 1 {::namespace current}]
        } msg opts]
        unset UnknownPending($name);
        if {$ret != 0} {
            dict append opts -errorinfo "\n    (autoloading \"$name\")"
            return -options $opts $msg
        }
        if {![array size UnknownPending]} {
            unset UnknownPending
        }
        if {$msg} {
            if {[info exists savedErrorCode]} {
                set ::errorCode $savedErrorCode
            } else {
                unset -nocomplain ::errorCode
            }
            if {[info exists savedErrorInfo]} {
                set ::errorInfo $savedErrorInfo
            } else {
                unset -nocomplain ::errorInfo
            }
            set code [catch {uplevel 1 $args} msg opts]
            if {$code ==  1} {
                #
                # Compute stack trace contribution from the [uplevel].
                # Note the dependence on how Tcl_AddErrorInfo, etc. 
                # construct the stack trace.
                #
                set errorInfo [dict get $opts -errorinfo]
                set errorCode [dict get $opts -errorcode]
                set cinfo $args
                if {[string bytelength $cinfo] > 150} {
                    set cinfo [string range $cinfo 0 150]
                    while {[string bytelength $cinfo] > 150} {
                        set cinfo [string range $cinfo 0 end-1]
                    }
                    append cinfo ...
                }
                append cinfo "\"\n    (\"uplevel\" body line 1)"
                append cinfo "\n    invoked from within"
                append cinfo "\n\"uplevel 1 \$args\""
                #
                # Try each possible form of the stack trace
                # and trim the extra contribution from the matching case
                #
                set expect "$msg\n    while executing\n\"$cinfo"
                if {$errorInfo eq $expect} {
                    #
                    # The stack has only the eval from the expanded command
                    # Do not generate any stack trace here.
                    #
                    dict unset opts -errorinfo
                    dict incr opts -level
                    return -options $opts $msg
                }
                #
                # Stack trace is nested, trim off just the contribution
                # from the extra "eval" of $args due to the "catch" above.
                #
                set expect "\n    invoked from within\n\"$cinfo"
                set exlen [string length $expect]
                set eilen [string length $errorInfo]
                set i [expr {$eilen - $exlen - 1}]
                set einfo [string range $errorInfo 0 $i]
                #
                # For now verify that $errorInfo consists of what we are about
                # to return plus what we expected to trim off.
                #
                if {$errorInfo ne "$einfo$expect"} {
                    error "Tcl bug: unexpected stack trace in \"unknown\"" {}  [list CORE UNKNOWN BADTRACE $einfo $expect $errorInfo]
                }
                return -code error -errorcode $errorCode  -errorinfo $einfo $msg
            } else {
                dict incr opts -level
                return -options $opts $msg
            }
        }
    }

    if {([info level] == 1) && ([info script] eq "")  && [info exists tcl_interactive] && $tcl_interactive} {
        if {![info exists auto_noexec]} {
            set new [auto_execok $name]
            if {$new ne ""} {
                set redir ""
                if {[namespace which -command console] eq ""} {
                    set redir ">&@stdout <@stdin"
                }
                uplevel 1 [list ::catch  [concat exec $redir $new [lrange $args 1 end]]  ::tcl::UnknownResult ::tcl::UnknownOptions]
                dict incr ::tcl::UnknownOptions -level
                return -options $::tcl::UnknownOptions $::tcl::UnknownResult
            }
        }
        if {$name eq "!!"} {
            set newcmd [history event]
        } elseif {[regexp {^!(.+)$} $name -> event]} {
            set newcmd [history event $event]
        } elseif {[regexp {^\^([^^]*)\^([^^]*)\^?$} $name -> old new]} {
            set newcmd [history event -1]
            catch {regsub -all -- $old $newcmd $new newcmd}
        }
        if {[info exists newcmd]} {
            tclLog $newcmd
            history change $newcmd 0
            uplevel 1 [list ::catch $newcmd  ::tcl::UnknownResult ::tcl::UnknownOptions]
            dict incr ::tcl::UnknownOptions -level
            return -options $::tcl::UnknownOptions $::tcl::UnknownResult
        }

        set ret [catch {set candidates [info commands $name*]} msg]
        if {$name eq "::"} {
            set name ""
        }
        if {$ret != 0} {
            dict append opts -errorinfo  "\n    (expanding command prefix \"$name\" in unknown)"
            return -options $opts $msg
        }
        # Filter out bogus matches when $name contained
        # a glob-special char [Bug 946952]
        if {$name eq ""} {
            # Handle empty $name separately due to strangeness
            # in [string first] (See RFE 1243354)
            set cmds $candidates
        } else {
            set cmds [list]
            foreach x $candidates {
                if {[string first $name $x] == 0} {
                    lappend cmds $x
                }
            }
        }
        if {[llength $cmds] == 1} {
            uplevel 1 [list ::catch [lreplace $args 0 0 [lindex $cmds 0]]  ::tcl::UnknownResult ::tcl::UnknownOptions]
            dict incr ::tcl::UnknownOptions -level
            return -options $::tcl::UnknownOptions $::tcl::UnknownResult
        }
        if {[llength $cmds]} {
            return -code error "ambiguous command name \"$name\": [lsort $cmds]"
        }
    }
    return -code error "invalid command name \"$name\""
} ; doc


source ~bbasaran/tcl/max.tcl

proc bbx_remember0 {} [format {
    set doc {
        This is from proc: bbax_remember0
        Defined in %s
        To re-source, just do: [source $me],
        Or, better: sm
    }
    db::setPrefValue lxCreatePins -value false
} [set me [info script]]]
proc sm {} "source $me"

puts [info body bbx_remember0]
puts [info body sm]

set cmd "db::getPrefValue lxCreatePins"
puts "<$cmd>: [eval $cmd]"
bbx_remember0
puts "<$cmd>: [eval $cmd]"

msource pgrid
useMcp

# from girish:
# ~/p/test/maxwell/hfl/autoGrouping/.cdesigner.tcl
proc from_Girish {} {
    db::setAttr shown -of [gi::getAssistants heDesignNavigator] -value 1
    db::setAttr shown -of [gi::getAssistants cmConstraintEditor] -value 1
    db::setPrefValue cmConstraintEditorZoom -value 1
    db::setPrefValue cmConstraintEditorHighlight -value 1
    db::setPrefValue leAutoAbutment -value true
    db::setPrefValue lxSplit -value false
    db::setPrefValue dmShowCellCategories -value false
    #source /u/girishv/objTable.tcl
    gi::createBinding -event Ctrl-x -command "ide::descendIntoGroup %w"
    db::setPrefValue dbPlacementGroupSync -value true
    db::setAttr selectable -value true -of [de::getObjectFilters leFigGroupMember]

    # new:
    db::setAttr selectable -value true -of [de::getObjectFilters leBoundaryPR]
}
if {[catch from_Girish msg]} {
    puts "-Warning- Got exception: $msg. Are we running an old version of CC,  maybe CDesigner?"
}
proc hfl {} { ; # would work only after Placement menu is brought up..
    #msource hfl
    # for: /u/stars/testcases/9001010253/test/snapOrigin
    # for: ~/p/test/maxwell/stdpart/placer_test
    db::setPrefValue lpStandardCellsLibList -value "openCellLibrary"

    # for: ~/p/test/maxwell/hfl/autoGrouping/ DemoPLL chargepump
    #db::setPrefValue lpStandardCellsLibList -value "stdCellLib"
    puts "lpStandardCellsLibList: [db::getPrefValue lpStandardCellsLibList]"
}

puts "bbx: Finished [info script]."
