/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1.0
	input_dir = WEST
	output_dir = EAST
	needs_item_input = TRUE
	use_machinery_signals = TRUE

/obj/machinery/mineral/unloading_machine/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	if(istype(target, /obj/structure/ore_box))
		for(var/ore in target)
			addtimer(CALLBACK(src, .proc/unload_mineral, ore), 2)
	else if(istype(target, /obj/item/stack/ore))
		addtimer(CALLBACK(src, .proc/unload_mineral, target), 2)
