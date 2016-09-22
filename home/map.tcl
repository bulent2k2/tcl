# How to identify the source shapes (in lay-a) that a target shape (in lay-b) originate from...

alx::boot

ediDefineKey 9 {puts "Running map b2a on selection"  ; alx::map_obj_b2a -show -win -verbose}
ediDefineKey 8 {puts "Running map mol2a on selection"; alx::get_laya_coords_of_selected_mol -win}
ediDefineKey 7 {puts "Running map mol2a on selection" ; alx::get_laya_objs_of_selected_mol }

alx setup ...
alx run ... -hflow or -flat

# 1- Map from lay-b to lay-a
# Select an object from lay-b (please no vias, contacts, for now!). Can also select an object from a sub-cell of lay-b. (;-)
# Press 9
# This should open up a new window with a copy of original lay-a shapes that map to the selected object. If you check the coordinates of the object in this new window, they will show you exactly where the lay-a object is. 

# If there is an error, it may help to type the command (alx::map_obj_* ...) above to see the stack trace

# 2- Map from molcell to lay-a
win open cellid [alx::m]
# Select an object from the molcell
# Press 8
# Same idea as above..

