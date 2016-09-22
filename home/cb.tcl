# source ~/cb.tcl
alx::boot
alx::msource ~/ct/g2.tcl
alx::g2 use_better_defaults 1
alx set param custom_bond_cmd ::my_custom_bonds
proc ::my_custom_bonds {molcellid} {
    alx delete constraint $molcellid all
    #source /remote/us01home36/sabbas/.titanprocs.tcl
    source ~/sabbas/.titanprocs.tcl
    foreach layer {rh ndiff pdiff} { alx_compact_user_layer $layer }
    #...
    set i 0; foreach cb [alx::cbond::get all] { puts "cb[string_pad [incr i] 4] $cb" }
}      
alx migrate -cellId $input ; # from ~/bulent/u.tcl
