## Copyright (c) 2004-2016 Synopsys, Inc. This Galaxy Custom Compiler software
## and the associated documentation are confidential and proprietary to
## Synopsys, Inc. Your use or disclosure of this Galaxy Custom Compiler software
## is subject to the terms and conditions of a written license agreement between
## you, or your company, and Synopsys, Inc.


## Project:      helix
## File:         grouping.tcl
## Description:  Basic grouping for devices and std cells. Creates UCM placement constraints.
##               Defines a new pref: lpStandardCellsLibList <list of lib-names>
#                Instances from each lib in the list will get a new Std-Cell constraint.
#                Also does device (pcell) grouping based on type/bulk-node

namespace eval lp {
    proc groupStdCellPrefName {} { return "lpStandardCellsLibList" }
    proc createGroupingPreferences {} {
        set name [groupStdCellPrefName]
        if { [db::isEmpty [db::getPrefs $name]] } {
            db::createPref $name -defaultScope user -value [list ]
        }
    }
    proc createGroupingCommands {} {
        # create two commands: lpGroupDevices and lpGroupStdCells
        # de::createCommand lp::groupDevices
        # de::createCommand lp::groupStdCells
        foreach name {
            "group Devices" "group Std Cells"
        } info {
            "devices" "standard cells"
        } {
            set arg [de::createArgument -types {deContext dmCellView oaDesign} -description "Design context in which to search for $info"]
            de::createCommand lp::[join $name ""] -category placement -description "Create constraints by grouping $info in design" -arguments $arg
        }
    }

    if {0} { ; # in menus.tcl now
        proc addGroupingActions {} {
            set action [gi::createAction lpGroupDevices -autoDisable true -command {
                -history true -prompt "Group Devices" -toolTip "Group Devices" -title "Group Devices" -icon create_figure_group \
                lp::groupDevices [de::getContexts -window [gi::getWindows %w]]
            }]
            set m [gi::getMenus lpPlacementMenuLayout]
            gi::addActions $action -to $m -after [gi::getActions lpShowPlacerOptions]
        }
    }

    namespace eval groupStdCells {
        proc execute { argName context } {
            if {0 == [llength [db::getPrefValue [::lp::groupStdCellPrefName]]]} {
                de::sendMessage "Please add std-cell lib names to preference [::lp::groupStdCellPrefName] before running 'Group Std Cells' command." -severity warning
                return
            }
            set design [db::getAttr context.editDesign]
            set trans [de::startTransaction "Group Std Cells" -design $design]
            set lxSession [lx::getSessions -filter {%physicalCellview.cellName == [db::getAttr topFile.container.cellName -of $context]}]
            set lxNetlist [db::getAttr logicalNetlist -of $lxSession]
            set count [lp::groupDevices::doGroup $design $lxNetlist [set isStd 1]]
            de::endTransaction $trans
            de::sendMessage "Created $count std cell grouping constraints in [db::getAttr design.libName]/[db::getAttr design.cellName]/[db::getAttr design.viewName]"
         }
    }

    #Create deCommand lp::groupDevices
    namespace eval groupDevices {
        proc execute { argName context } {
            set design [db::getAttr context.editDesign]
            set trans [de::startTransaction "Group Devices" -design $design]
            set lxSession [lx::getSessions -filter {%physicalCellview.cellName == [db::getAttr topFile.container.cellName -of $context]}]
            set lxNetlist [db::getAttr logicalNetlist -of $lxSession]
            set count [doGroup $design $lxNetlist [set isStd 0]]
            de::endTransaction $trans
            de::sendMessage "Created $count device grouping constraints in [db::getAttr design.libName]/[db::getAttr design.cellName]/[db::getAttr design.viewName]"
        }
        proc doGroup {design lxNetlist isStd} {
            array set instArray [::lp::_impl::getStdCells [getUnGroupedInstances $design [db::getAttr insts -of $lxNetlist]]]
            set count 0
            foreach val [array names instArray] {
                if { $val != "NonStdCell" } {
                    if {$isStd == 1} {
                        set instNameList [list]
                        foreach inst $instArray($val) {
                            lappend instNameList [db::getAttr inst.name]
                        }
                        set consName "s$val"
                        if { [getGroupByName $consName $design] != "" } {
                            set consName [getUniqueConsName $consName $design]
                        }
                        cm::createStandardCells $consName -insts $instNameList -in $design
                        incr count
                    }
                } else {
                    set instList $instArray($val) ; # devices
                }
            }
            if {$isStd == 1} {
                return $count
            }
            if { [info exists instList] } {
                array set instArray1 [::lp::_impl::getSameClass $instList]
                foreach val1 [array names instArray1] {
                    array unset instArray2
                    if { $val1 == "NoBulk" } {
                        groupByMultiplier $instArray1($val1) $design count
                    } else {
                        array set instArray2 [::lp::_impl::getSameBulkNodes $instArray1($val1) [lindex [split $val1 ,] 1]]
                        set clusterList [list]
                        foreach val2 [array names instArray2] {
                            set rowsList [groupByMultiplier $instArray2($val2) $design count]
                            if { $rowsList == "" } {
                                continue
                            } elseif { [llength $rowsList] == 1 } {
                                lappend clusterList [lindex $rowsList 0]
                            } else {
                                set consName "c$val2"
                                if { [getGroupByName $consName $design] != "" } {
                                    set consName [getUniqueConsName $consName $design]
                                }
                                cm::createCluster $consName -insts $rowsList -in $design
                                incr count
                                lappend clusterList [list group "c$val2"]
                            }

                        }
                        if { [llength $clusterList] > 1 } {
                            set consName "c[lindex [split $val1 ,] 0]"
                            if { [getGroupByName $consName $design] != "" } {
                                set consName [getUniqueConsName $consName $design]
                            }
                            cm::createCluster $consName -insts $clusterList -in $design
                            incr count
                        }
                    }
                }
            }
            return $count
        }
        proc getUnGroupedInstances { design instCollection } {
            set instList [list]
            db::foreach inst $instCollection {
		set instName [db::getAttr name -of $inst]
		set part 0
		while {$instName != {}} {
		    if {[isPartOfPlacementGroup $design $instName]} {
			set part 1
		    }
		    if {[regexp {^(.*)\..+} $instName matched parent]} {
			set instName $parent
		    } else  {
			set instName {}
		    }
		}

                if {$part == 0} {
                    lappend instList $inst
                }
            }
            return $instList
        }
        proc getGroupByName { grpName design } {
            if { ![db::isEmpty [set grp [db::getGroups $grpName -of $design]]] } {
                return [db::getNext $grp]
            } else {
                return ""
            }
        }
        proc isPartOfPlacementGroup { design instName } {
            set grp [db::getGroups $instName -of $design]
            if { [db::isEmpty $grp] } {
                return 0
            }
            db::foreach parentGrp [db::getAttr groupsOwnedBy -of $grp] {
                if { [isLePlacementGroup $parentGrp] && [findIndexInGroup $parentGrp $instName] != -1 } {
                    return 1
                }
            }
            return 0
        }
        proc isLePlacementGroup { grp } {
            if { ![db::isObject $grp] } { return 0 }
            if { [catch {set type [db::getAttr grp.type]} ] } { return 0 }
            if { $type == "Group" } {
                if { [getPlacementIntentForGroup $grp] != "" } {
                    return 1
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
        proc findIndexInGroup { group element } {
            return [lsearch [db::createList [db::getAttr group.members.object.name]] $element]
        }
        proc getPlacementIntentForGroup { grp } {
            return [db::getNext [cm::getConstraints -filter {%owner.name == [db::getAttr grp.name] && [db::getAttr owner.def.name -of %this] =~ /cmInst$/} -of $grp]]
        }
        proc groupByMultiplier { instList design count_ } {
            upvar $count_ count
            if { [llength $instList] == 0 } {
                return ""
            } elseif { [llength $instList] == 1 } {
                return [db::getAttr name -of [lindex $instList 0]]
            }
            array set instArray [::lp::_impl::getMultiplierInsts $instList]
            set rowsList [list]
            foreach val [array names instArray] {
                set nInsts [llength $instArray($val)]
                if { $nInsts > 1 } {
                    set consName "r$val"
                    set instNameList [list]
                    foreach inst $instArray($val) {
                        lappend instNameList [db::getAttr inst.name]
                    }
                    set nRows [expr int(sqrt($nInsts))]
                    if { [getGroupByName $consName $design] != "" } {
                        set consName [getUniqueConsName $consName $design]
                    }
                    cm::createRows $consName -insts $instNameList -in $design -separation abut -sizePolicy [cm::getSizePolicy rows -target $nRows]
                    incr count
                    lappend rowsList [list group $consName]
                } else {
                    lappend rowsList [db::getAttr name -of $instArray($val)]
                }
            }
            return $rowsList
        }
        proc getUniqueConsName { consName design } {
            set idx 1
            while { [getGroupByName $consName$idx $design] != "" } {
                incr idx
            }
            return $consName$idx
        }
    } ; # ns groupDevices

    namespace eval _impl {
        array set components {}
        proc getBaseName { name } {
            if { [string first . $name] != -1 } {
                return [string range $name 0 [expr [string first . $name]-1] ]
            } else {
                return $name
            }
        }
        proc getMultiplierInsts { instList } {
            array set instArray {}
            foreach inst $instList {
                #set xyPair [list [db::getAttr x -of $inst] [db::getAttr y -of $inst]]
                #lappend instArray($xyPair) $inst
                set baseName [getBaseName [db::getAttr inst.name]]
                lappend instArray($baseName) $inst
            }
            return [array get instArray]
        }
        proc getStdCells { instList } { ; # also gets non-std cells (devices)
            array set instArray {}
            foreach inst $instList {
                set libName [db::getAttr libName -of $inst]
                if { [lsearch [db::getPrefValue [::lp::groupStdCellPrefName]] $libName] != -1 } {
                    lappend instArray($libName) $inst
                } else {
                    lappend instArray(NonStdCell) $inst
                }
            }
            return [array get instArray]
        }
        proc getSameBulkNodes { instList bulkNode } {
            array set instArray {}
            foreach inst $instList {
                db::foreach instTerm [db::getAttr instTerms -of $inst] {
                    if { [db::getAttr termName -of $instTerm] == $bulkNode } {
                        lappend instArray([db::getAttr netName -of $instTerm]) $inst
                    }
                }
            }
            return [array get instArray]
        }
        proc getSameClass { instList } {
            array set instArray {}
            variable components
            foreach inst $instList {
                set cellName [db::getAttr cellName -of $inst]
                set libName [db::getAttr libName -of $inst]
                if { ! [info exists components($libName)] } {
                    set components($libName) [db::getComponents -of [dm::getLibs $libName]]
                }
                set component [findComponent $components($libName) $cellName]
                if { $component != "" } {
                    set termMap [db::getAttr termMap -of $component]
                    set componentType [db::getAttr type -of $component]
                    switch $componentType {
                        "dbMosfetComponent" {
                            set mosType [db::getAttr mosType -of $component]
                            if { $termMap == "" } {
                                set bulkNode B
                            } else {
                                set bulkNode [lindex $termMap [lsearch -index 1 $termMap bulk] 0]
                            }
                            if { $mosType == "nmos"  || $mosType == "pmos" } {
                                set class [db::getAttr class -of $component]
                                lappend instArray($class,$bulkNode) $inst
                            } else {
                                de::sendMessage "Invalid mosType $mosType for instance [db::getAttr name -of $inst].. Ignoring" -severity warning
                            }

                        }
                        default {
                            lappend instArray(NoBulk) $inst
                        }
                    }
                } else {
                    lappend instArray(NoBulk) $inst
                }
            }
            return [array get instArray]
        }
        proc findComponent { components cellName } {
            db::foreach component $components {
                if { [lsearch [db::getAttr cellNames -of $component] $cellName] != -1 } {
                    return $component
                }
            }
            return ""
        }
    } ; # ns _impl

    createGroupingPreferences
    createGroupingCommands
}
