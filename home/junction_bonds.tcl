# Run this for both x and y:
for each pair of interacting atoms in a given layer {
    # "interact" := they overlap; or touch (on a side or corner)
    two atoms -> 4 edges (for x iter, 4 vertical edges)
    Let's populate an array of four Edge objects: e(i), i=0,1,2,3
    Edge has four methods {
        0- coord (e.g., current x coord for vertical edges)
        1- id (id of its atom)
        2- side (the edge of the atom it is from: lo or hi)
        3- var (lp variable that will solve for the coord of this edge)
    }
    sort edges according to coord low to high
    for i = 0; i < 3 { # for one of the first three edges
        j = i+1 ; # pick the next edge
        if e(i).id == e(j).id {
            continue ; # same atom, no bond is needed
        }
        if e(i).coord != e(j).coord {
            add bond (e(i).var <= e(j).var) ; # keep the same order
        } else { ; # e(i).coord == e(j).coord 
            if e(i).side != e(j).side() {; # opposing sides
                # add reverse ordering bond such that the lo edge stays on the low side of the hi edge
                if e(i).side = lo {
                    add bond (e(i).var <= e(j).var)
                } else {
                    add bond (e(j).var <= e(i).var)
                }
            } else { ; # both lo or both hi -- air hook takes care of this. o.w., we can do:
                # add bond (e(i).var = e(j).var)
            }
        }
    }
}

