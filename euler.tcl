#
# Given a diffusion graph with fingers
# Find an eulerian ordering to minimize number of trunks
# 

# Remember generalization: two (or more) diffusion graphs,
# Assign to "eulerian" rows, maximizing alignment, and minimizing wirelength
#

# A middle ground: two rows: PMOS/NMOS, two diffusion graphs (no assignment)
# Just re-order the "eulerian" to maximize alignment

namespace eval euler {
    proc euler netlist { create graphs from the netlist, generate eulerian }
    proc opt {} { run optimization }
    proc ~euler {} {}
    proc np netlist { netlist partitioner: one to two, or many }
    proc n2g netlist { netlist to a graph }
    proc gputs graph { print the graph } 
}

proc euler::euler netlist {
    set ns [np $netlist]
    foreach n $ns {
	gputs [set g [n2g $n]]
    }
}

proc euler::np netlist {
    partition based on 1) BODY-NODE, 2) CH-Width
    ...
    return $netlists
}

proc euler::n2g netlist {
    create diff graph
    return $g
}

proc euler::gputs g {
    
}
