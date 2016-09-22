# Instead of {dummy_poly_on_off 1}
# encap:
#   {dummy_poly_left leftDummyPoly {off on}}
#   {dummy_poly_right rightDummyPoly {off on}}
# default: {dummyp_poly_left leftDummyPoly} defaults to:
#   {dummy_poly_left leftDummyPoly {0 1}}
# Can test with:
#  1- tsmcN45: ~/t/alx/OA/abs
#  2- starc ipdk: ~/share/bz/sb1/noa_crash/working_dir_for_alx/run.tcl
# 

#
# into ~/ct/mcell/tlg2pcell.tcl
#

namespace eval alx::pcell {
    proc _get_pcell_mos {tech params {mos_cont 1}} {
        variable _PCELLVAR
        if {[setv debug]==1} { pout >_get_pcell_mos tech params mos_cont}
        foreach param $params {
            set [lindex $param 0] [lindex $param 1]
        }
        lassign $origin cx cy

        set tlgcellid [lfetch $tlg cellId]
        set tlgid [lfetch $tlg tlgId]

        #BUG in (tsmc) PDK
        set bugadd 0;
        set rp [_get_base $tech -mos round_posp];#for bug!
        if {$rp!=0} {
            #if posp!=n*0.01, rounding problem!  - worked w/ Samir!
            if {[expr {int($posp*1000-10*int($posp*100))==5}]} {;#posp=0.005
                set bugadd 0.005;
            }
            #TODO: use [expr {int(floor(1000*$posp))==5}]
        }
        
        set minwf_base [_get_base $tech $dev minwf]
        if {$wfg<$minwf_base} { 
            lappend _PCELLVAR(nosupport_tlgid2err) "$tlgid {minwf:$wfg<$minwf_base}"
            return "" 
        };#do not create device

        ### CHANNEL LENGTH OFFSET (In global foundries, we don't get what we ask for but an offset)
        # e.g., ~/t/alx/OA/lmap/root/techb/tsmc45lp/pcell.tcl
        # Given:
        #   {npdnwod18 nch_18_dnw}
        # Add:
        #   {{dev nch_18_dnw} {posp 0.22} {pocosp 0.08} {poex 0.09} {odex 0.15} {ch_l_offset 0.03}}
        set chl [_get_base $tech $dev ch_l_offset]
        set lfg [expr {$lfg - $chl}]

        set w [expr {$fng*$wfg}]
        set ng [_get_base $tech -mos n_gates]
        set gl [_get_base $tech -mos gate_length]
        set gw [_get_base $tech -mos gate_width]
        set fparams "{$ng $fng} {$gl ${lfg}u}"
        set tgw [_get_base $tech -mos total_gate_width]
        if {$tgw!="0"} { lmerge fparams "{$tgw ${w}u}" }
        if {$gw!="0"} { lmerge fparams "{$gw ${wfg}u}" }

        #poly spacing
        set ferr 0.0000001
        if {[expr {$fng>1 && abs($posp)>$ferr}]} {
            set spn [_get_base $tech $dev posp $posp];#distance between two poly
            if {[expr {$spn<0}]} {
                alx::plog "_get_pcell_mos; error(spn:$spn<0) tlgid:c${tlgcellid}:$tlgid"
                lappend _PCELLVAR(nosupport_tlgid2err) "$tlgid {spn:$spn<0}"
                return ""
            } elseif {$spn>0} { ;#???
                set fsp [_get_base $tech -mos finger_spacing];#{finger_spacing fingers_SP_INC}
                if {$fsp!="0"} {
                    lmerge fparams "{$fsp ${spn}u}"
                } else {;#fix poly spacing
                    set fparams "{$ng 1} {$gl ${lfg}u} {$tgw ${wfg}u}";#just consider one finger!
                    if {$gw!="0"} { lmerge fparams "{$gw ${wfg}u}" }
                    set fix_posp 1
                }
            }
        }

        set params ""
        set pr [_get_base $tech -mos poly_route];#connecting polys
        set mr [_get_base $tech -mos m1_route];#connecting m1s
        if {$pr!="0"} { lmerge params "{$pr 0}" }
        if {$mr!="0"} { lmerge params "{$mr 0}" }
        
        #contacts
        set odex_dueto_cont 0
        set ci 0; set cl 0; set cr 0;
        set cow_base [_get_base $tech $dev cow];#cont size
        set eval_cocosp [_get_base $tech -mos eval_cocosp];#from pcell eval!
        if {[setv mos_cocosp]==1} { set eval_cocosp 1 };#if user wants it!

        #    pout xxx-4  eval_cocosp wfg odco cow_base [expr {$wfg-$odco*2-$cow_base}]

        if {[expr {$wfg-$odco*2-$cow_base>=-$ferr}]} {;#$odm1>0
            #        pout xxx-3 cocosp cocosp2 odco odco2 odm1 m1co m1co2
            set pocosp_base [_get_base $tech $dev pocosp];#cont-po on sides
            set pocosp_base [expr {$pocosp_base+$bugadd}];#???
            set pocospl [expr {$pocospl-$pocosp_base}];#co-po spacing
            set pocospr [expr {$pocospr-$pocosp_base}]

            if {[expr {$fng>1 && $pocospi>0}]} {
                set cosp [expr {($posp-$cow_base)/2}]
                if {[expr {abs($pocospi-$cosp)<$ferr}]} { set ci 1 }
            }
            
            #### CONTACT
            if {$pocospl>=0} { set cl 1 }
            if {$pocospr>=0} { set cr 1 }
            if {[expr {$ci+$cl+$cr>0}]} {;#at least one contact row
                if {$eval_cocosp} {
                    set cocosp2 [_get_base $tech -mos cocosp $cocosp]
                    if {$cocosp2>0} {;#let find max. possible cont in row!
                        set ccsp [_get_base $tech -mos co_co_spacing];# {co_co_spacing DCO_CO_SP_INC}
                        if {$ccsp!="0"} { lmerge params "{$ccsp ${cocosp2}u}" }
                    }
                }
                set odco2 [_get_base $tech -mos odcoenc $odco];#od2co gate direction
                #in tsmc65 CO_EN_1_1_INC is absolute value! ???
                if {$odco2>0} {
                    set odcoenc [_get_base $tech -mos od_co_enc];# {od_co_enc DOD_CO_EN_INC}
                    if {$odcoenc!="0"} { lmerge params "{$odcoenc ${odco2}u}" }
                    set odex_dueto_cont [_get_base $tech -mos odex_dueto_cont]
                    if {$odex_dueto_cont!="0"} {
                        set odex_dueto_cont $odco2;#od extends in x&y direction
                    }
                }
                set m1co [expr {$odco-$odm1}];#from gate direction
                set m1co2 [_get_base $tech $dev m1coen $m1co]
                if {$m1co2>0} {
                    set m1coenc [_get_base $tech -mos m1_co_enc];# {m1_co_enc DM1_CO_EN_INC}
                    if {$m1coenc!="0"} { lmerge params "{$m1coenc ${m1co2}u}" }
                }
            }
        }

        if {!$mos_cont} {;#put no contact
            set cl 0; set cr 0; set ci 0
        }

        if {$mos_cont==3} {
            set ci 0; #no mid cont
            if {$cl && $cr} {
                if {$pocospl!=$pocospr} { set cr 0 };#just keep left cont
            }
        }
        
        set ncnt [_get_base $tech -mos contact];;# {contact cnt}
        if {$ncnt!="0"} {
            set ncntblr [_get_base $tech -mos cont_blr];#{cont_blr cntBLR}
            if {$ncntblr!="0"} {
                if {$cr && $ci && $cl} {
                    lmerge params "{$ncnt 1} {$ncntblr Both}"
                } else {
                    if {$cl && $ci} {
                        lmerge params "{$ncnt 1} {$ncntblr Left}"
                    } elseif {$cr && $ci} {
                        lmerge params "{$ncnt 1} {$ncntblr Right}"
                    } else {
                        lmerge params "{$ncnt 0}"
                    }
                }
            } else {
                lmerge params "{$ncnt 0}";#default no contact
            }
        }

        set nci  [_get_base $tech -mos inter_cont];#{inter_cont interCnt}
        set ncl  [_get_base $tech -mos left_cont];#{left_cont leftCnt}
        set ncr  [_get_base $tech -mos right_cont];#{right_cont rightCnt}
        if {$nci!="0"} { lmerge params "{$nci $ci}" }
        if {$ncl!="0"} { 
            if {"" == [set value_enum [lindex $ncl 1]]} { 
                set val $cl
            } else {
                set val [lindex $value_enum $cl]
            }
            lmerge params "{$ncl $val}"
            if {$cl} {
                set lgacosp  [_get_base $tech -mos left_gate_co_sp];#{left_gate_co_sp LGA_CO_SP_INC}
                if {$lgacosp!="0"} { lmerge params "{$lgacosp  ${pocospl}u}" }
            }
        }
        if {$ncr!="0"} { 
            if {$cr == 1} { set val True } { set val False }
            lmerge params "{$ncr $val}"
            if {$cr} {
                set rgacosp  [_get_base $tech -mos right_gate_co_sp];#{right_gate_co_sp RGA_CO_SP_INC}
                if {$rgacosp!="0"} { lmerge params "{$rgacosp ${pocospr}u}" }
            }
        }

        #### POLY FINGER EXTENTION
        set poex_base [_get_base $tech $dev poex];#poly cap    
        set poexb [expr {$poexb-$poex_base}];#poly cap bottom
        set poext [expr {$poext-$poex_base}]
        if {$poexb>0} {
            set npoexl  [_get_base $tech -mos poly_ext_lower];#{poly_ext_lower DLower_PO_EX_INC}
            if {$npoexl!="0"} { lmerge params "{$npoexl ${poexb}u}" }
        }    
        if {$poext>0} {
            set npoexu  [_get_base $tech -mos poly_ext_upper];#{poly_ext_upper DUpper_PO_EX_INC}
            if {$npoexu!="0"} { lmerge params "{$npoexu  ${poext}u}" }
        }
        
        #### DIFF EXTENTION
        #consider pocosp for odex, it it is default
        set odex_base [_get_base $tech $dev odex];#diff ext. from poly
        set odex_base [expr {$odex_base+$odex_dueto_cont+$bugadd}];#???
        if {[expr {abs($odexl)<$ferr}]} { 
            set odexl $pocospl 
        } else { 
            set odexl [expr {$odexl-$odex_base}] 
        }
        if {[expr {abs($odexr)<$ferr}]} { 
            set odexr $pocospr 
        } else {
            set odexr [expr {$odexr-$odex_base}]
        }

        #setting od extention, if negative ...!
        if {$odexl>[expr {-$odex_base}]} {
            set nodexl  [_get_base $tech -mos od_ext_left];#{od_ext_left LdiffExt}
            if {$nodexl!="0"} { lmerge params "{$nodexl ${odexl}u}" }
        }
        if {$odexr>[expr {-$odex_base}]} {
            set nodexr  [_get_base $tech -mos od_ext_right];#{od_ext_right RdiffExt}
            if {$nodexr!="0"} { lmerge params "{$nodexr ${odexr}u}" }
        }
        
        #### POLY DUMMY
        if {[setv dummypoly]!=1} { set dmpol 0; set dmpor 0 }
        set ndmpol [_get_base $tech -mos dummy_poly_left];#{dummy_poly_left leftDummyPoly}
        set ndmpor [_get_base $tech -mos dummy_poly_right];#{dummy_poly_right rightDummyPoly}
        set ndmpo_onoff [_get_base $tech -mos dummy_poly_on_off];#{dummy_poly_on_off 1}
        if {$ndmpol!="0"} {
            if {$ndmpo_onoff==1} {
                lmerge params "{$ndmpol OFF} {$ndmpor OFF}"
            } else {
                lmerge params "{$ndmpol $dmpol} {$ndmpor $dmpor}"
            }
        }
        
        #### NP & PP
        if {[setv impLayer]!=1} {;#turn off np&pp for fixing DRCs!
            set nimpl [_get_base $tech -mos imp_layer];#{imp_layer impLayer}
            if {$nimpl!="0"} { lmerge params "{$nimpl 0}" }
        }
        #### NWELL
        if {[setv nwLayer]!=1} {;#turn off nw for fixing DRCs!
            set nwl [_get_base $tech -mos nw_layer];#{nw_layer nwLayer}
            if {$nwl!="0"} { lmerge params "{$nwl 0}" }
        }

        set params "$fparams $params"

        if {[setv debug]==1} {
            pout dev odex_base odex_dueto_cont bugadd odexl odexr nodexl 
            pout params
        }

        #### Shift the origin based on cell definiation
        #- when origin is LL of diff not LL of first gate
        set dx 0
        if {[_get_base $tech -mos origin_od_ll]=="1"} {
            set dx [expr -$odexl]
        } elseif {[_get_base $tech -mos origin_m1_ll]=="1"} {
            set dx [expr -$odexl]
        }
        if {$dx} {
            if {$ang=="90"} {
                set cy [expr {$cy+$dx}]
            } else {
                set cx [expr {$cy+$dx}]
            }
        }

        if {[setv debug]==1} { pout 2222 Name }

        if {[info exists fix_posp] && $fix_posp} {
            for {set i 0} {$i<$fng} {incr i} {
                if {$ang=="90"} {
                    set cy [expr {$cy+$i*($posp+$lfg)}]
                } else {
                    if {$ang!="0"} { puts "WRN. In TLG $tlgid Angle is $ang. pcell origin may not be right!" }
                    set cx [expr {$cx+$i*($posp+$lfg)}]
                }
                lappend rs "{mname $dev} {Origin {$cx $cy}} {Angle $ang} {Reflection $flip} {Name $Name} {params {$params}}"
            }
        } else {
            set rs "{{mname $dev} {Origin {$cx $cy}} {Angle $ang} {Reflection $flip} {Name $Name} {params {$params}}}"
        }
        if {[setv debug]==1} { pout rs }
        return $rs
    }

}
