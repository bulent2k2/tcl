proc alx::implant::get_data {args} { return "0 0.18" }

return

proc get_via_arrays {cellid {regexp ""}} {
    set out {}
    bbt::sc
    db loop object x $cellid viaarray {
        if {[not_null? $regexp]} {
            set name [$l [$e $cellid $x] viaName]
            if {![regexp $regexp $name]} { continue }
        } 
        lappend out $x
    }
    set out
}

return

if {[namespace exists alx]} { set alx::booted 0 }
alx::boot ~/alx_build
