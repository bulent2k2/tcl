# row-oriented trunk generator
namespace eval tg {
    proc gen {pinsInsts {pins ""}} { ... }
}

proc test_inv1 {} {
    puts "Testing \"[proc_name]\":"
    set pinInsts {}
    # pinInst: {<terminal> <net>} {<row col>} [{<cost_of_misalign> [<cost_of_wirelength>]}]
    foreach pinInst {
	"{s gnd} {0 0} {0 1}" "{g in} {0 1} {10 5}" "{d out} {0 2} {15 10}"
	"{s vdd} {1 0} {0 1}" "{g in} {1 1} {10 5}" "{d out} {1 2} {15 10}"
    } {
	lappend pinInsts $pinInst
    }
    set pins {}
    # needed?
    tg::gen $pinInsts $pins
}
proc test_nand1 {} {
    puts "Testing \"[proc_name]\":"
    set pinInsts {
	"{s gnd}     {0 0} {0 1}" "{g a} {0 1} {10 5}" "{d ser1}    {0 2} {0 10}"
	"{s ser1}    {0 3} {0 1}" "{g b} {0 4} {10 5}" "{d out}     {0 5} {15 10}"
	"{s vdd}     {1 0} {0 1}" "{g a} {1 1} {10 5}" "{d out}     {1 2} {15 10}"
	"{s vdd}     {1 3} {0 1}" "{g b} {1 4} {10 5}" "{d out}     {1 5} {15 10}"
    }
    tg::gen $pinInsts
}
proc test_nor1 {} {
    puts "Testing \"[proc_name]\":"
    set pinInsts {
	"{s vdd}     {1 0} {0 1}" "{g a} {1 1} {10 5}" "{d ser1}    {1 2} {0 10}"
	"{s ser1}    {1 3} {0 1}" "{g b} {1 4} {10 5}" "{d out}     {1 5} {15 10}"
	"{s gnd}     {0 0} {0 1}" "{g a} {0 1} {10 5}" "{d out}     {0 2} {15 10}"
	"{s gnd}     {0 3} {0 1}" "{g b} {0 4} {10 5}" "{d out}     {0 5} {15 10}"
    }
    tg::gen $pinInsts
}

proc test_decoder1 {} {
    puts "Testing \"[proc_name]\":"
    tg::gen [flatten [decoder1 sw1 sw2 l1 l2 l3 l4]] ; # 2x4 decoder
}

proc inv1 {name in out} {
    nmos $name.n gnd $name.in $name.out
    pmos $name.p vdd $name.in $name.out
    # constraints: abs(cs-cd)=2 and cg=(cs+cd)/2 for both devices
    # obj: cg1=cg2 and cd1=cd2
    
    # "{s gnd} {inv1.r1 inv1.cs1} {0 1}" "{g in} {inv1.r1 inv1.cg1} {10 5}" "{d out} {inv1.r1 inv1.cd1} {15 10}"
    # "{s vdd} {inv1.r2 inv1.cs2} {0 1}" "{g in} {inv1.r2 inv1.cg2} {10 5}" "{d out} {inv1.r2 inv1.cd2} {15 10}"
}
proc nand2 {name i1 i2 o} {
    nmos $name.n1 gnd          $name.i2 $name.ser1
    nmos $name.n2 $name.ser1   $name.i1 $name.o
    pmos $name.p1 vdd          $name.i2 $name.o
    pmos $name.p2 vdd          $name.i1 $name.o
}
proc nor2 {name i1 i2 o} {
    pmos $name.n1 vdd          $name.i2 $name.ser1
    pmos $name.n2 $name.ser1   $name.i1 $name.o
    nmos $name.p1 gnd          $name.i2 $name.o
    nmos $name.p2 gnd          $name.i1 $name.o
}
# todo: DRY this!
proc nmos {name s g d} { global nmos; lappend nmos [format "%20s %20s %20s %20s" $name $s $g $d] }
proc pmos {name s g d} { global pmos; lappend pmos [format "%20s %20s %20s %20s" $name $s $g $d] }

proc decoder1 {name sw1 sw2 l1 l2 l3 l4} {
    puts "This is my simple 2x4 decoder:"
    reset_tables
    set _s1 $name._sw1
    set _s2 $name._sw2
    inv1 $name.i1 $sw1 $_s1
    inv1 $name.i2 $sw2 $_s2
    foreach x {l1 l2 l3 l4} {
	set _$x $name._$x
    }
    nand2 $name.n1 $_s1 $_s2 $_l1
    nand2 $name.n2 $sw1 $_s2 $_l2
    nand2 $name.n3 $_s1 $sw2 $_l3
    nand2 $name.n4 $sw1 $sw2 $_l4
    set c 2 ; # two inverters are instantiated above.. 
    foreach x {l1 l2 l3 l4} {
	inv1 $name.i[incr c] [set _$x] [set $x]
    }
    dump_tables
}
proc reset_tables {} { 
    global nmos pmos
    foreach dev {nmos pmos} {
	set $dev {}
    }
}
proc dump_tables {} { 
    global nmos pmos
    foreach dev {nmos pmos} {
	puts "---------"
	puts "[llength [set $dev]] [string toupper $dev]:"
	puts "---------"
	foreach d [set $dev] { puts $d }
    }
}

proc tg::gen {pinInsts {pins ""}} {
    foreach pinInst $pinInsts {
	lassign $pinInst conn coord cost
	lassign $conn term net
	lassign $coord row col
	lappend net_table($net) "$term $row $col"
    }
    parray net_table
}

test_inv1
test_nand1
test_nor1
decoder1 d i1 i2 o1 o2 o3 o4
#test_decoder1
