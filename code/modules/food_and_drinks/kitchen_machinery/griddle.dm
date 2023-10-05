/obj/machinery/griddle
	name = "griddle"
	desc = "Because using pans is for pansies."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE| LETPASSTHROW // It's roughly the height of a table.
	layer = BELOW_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	idle_power_consumption = 2
	active_power_consumption = 500

	///Things that are being griddled right now
	var/list/griddled_objects = list()
	///Looping sound for the grill
	var/datum/looping_sound/griddle/grill_loop
	///Whether or not the machine is turned on right now
	var/on = FALSE
	///What variant of griddle is this?
	var/variant = 1
	///How many shit fits on the griddle?
	var/max_items = 8

/obj/machinery/griddle/Initialize(mapload)
	. = ..()
	add_overlay("grinder_jam")
	component_parts = list()
	component_parts += new /obj/item/circuitboard/griddle(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	grill_loop = new(src, FALSE)
	if(isnum(variant))
		variant = rand(1,3)
	RegisterSignal(src, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose_reagents))
//	RegisterSignal(src, COMSIG_TRY_STORAGE_QUICK_EMPTY, PROC_REF(storage_quick_empty))

/obj/machinery/griddle/Destroy()
	QDEL_NULL(grill_loop)
	return ..()

/obj/machinery/griddle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
//	if(flags_1 & NODECONSTRUCT_1)
	//	return
	if(default_deconstruction_crowbar(I, ignore_panel = TRUE))
		return
	variant = rand(1,3)

/obj/machinery/griddle/proc/on_expose_reagents(atom/parent_atom, datum/reagent/exposing_reagent, reac_volume)
	SIGNAL_HANDLER
	//commented out because we don't have pancake batter but probly cool to keep function
//	if(griddled_objects.len >= max_items || !istype(exposing_reagent, /datum/reagent/consumable/pancakebatter) || reac_volume < 5)
	//	return NONE //make sure you have space... it's actually batter... and a proper amount of it.

//	for(var/pancakes in 1 to FLOOR(reac_volume, 5) step 5) //this adds as many pancakes as you possibly could make, with 5u needed per pancake
	//	var/obj/item/food/pancakes/raw/new_pancake = new(src)
	//	new_pancake.pixel_x = rand(16,-16)
	//	new_pancake.pixel_y = rand(16,-16)
	//	AddToGrill(new_pancake)
	//	if(griddled_objects.len >= max_items)
	//		break
//	visible_message(span_notice("[exposing_reagent] begins to cook on [src]."))
	return NONE

/obj/machinery/griddle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return default_deconstruction_crowbar(I, ignore_panel = TRUE)


/obj/machinery/griddle/attackby(obj/item/I, mob/user, params)
	if(isrobot(user))
		return
	if(anchored)
		if(user.a_intent == INTENT_HELP && !(I.flags & ABSTRACT))
			if(griddled_objects.len < max_items)
				if(user.drop_item())
					I.forceMove(get_turf(src))
					if(istype(I, /obj/item/reagent_containers/food/snacks/egg))
						qdel(I)
						I = new /obj/item/reagent_containers/food/snacks/raw_egg
					var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
					if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
						return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
					I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
					I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
				AddToGrill(I, user)
			else
				to_chat(user, "Too many items on the griddle!")
	else
		to_chat(user, "The griddle must be secured before you can use it!")
		return..()

/obj/machinery/griddle/attack_hand(mob/user, list/modifiers)
	. = ..()
	toggle_mode()

/obj/machinery/griddle/attack_robot(mob/user)
	. = ..()
	toggle_mode()

/obj/machinery/griddle/proc/toggle_mode()
	on = !on
	if(on)
		begin_processing()
	else
		end_processing()
	update_appearance()
	update_grill_audio()

/obj/machinery/griddle/proc/begin_processing()
	for(var/obj/item/item_to_grill as anything in griddled_objects)
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_ON)

/obj/machinery/griddle/proc/end_processing()
	for(var/obj/item/item_to_grill as anything in griddled_objects)
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_OFF)

/obj/machinery/griddle/proc/AddToGrill(obj/item/item_to_grill, mob/user)
	vis_contents += item_to_grill
	griddled_objects += item_to_grill
	//item_to_grill.flags_1 |= IS_ONTOP_1
	item_to_grill.vis_flags |= VIS_INHERIT_PLANE
	SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_PLACED, user)
	if(on)
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_ON)
	RegisterSignal(item_to_grill, COMSIG_MOVABLE_MOVED, PROC_REF(ItemMoved))
	RegisterSignal(item_to_grill, COMSIG_ITEM_GRILLED, PROC_REF(GrillCompleted))
	RegisterSignal(item_to_grill, COMSIG_PARENT_QDELETING, PROC_REF(ItemRemovedFromGrill))
	update_grill_audio()
	update_appearance()

/obj/machinery/griddle/proc/ItemRemovedFromGrill(obj/item/ungrill)
	SIGNAL_HANDLER
//	ungrill.flags_1 &= ~IS_ONTOP_1
	ungrill.vis_flags &= ~VIS_INHERIT_PLANE
	griddled_objects -= ungrill
	vis_contents -= ungrill
	UnregisterSignal(ungrill, list(COMSIG_ITEM_GRILLED, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	update_grill_audio()

/obj/machinery/griddle/proc/ItemMoved(obj/item/I, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	ItemRemovedFromGrill(I)

/obj/machinery/griddle/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	AddToGrill(grilled_result)

/obj/machinery/griddle/proc/update_grill_audio()
	if(on && griddled_objects.len)
		grill_loop.start()
	else
		grill_loop.stop()

/obj/machinery/griddle/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool, time = 2 SECONDS)
	if(!anchored)
		for(var/obj/item/I in griddled_objects)
			I.forceMove(get_turf(src))
	return TRUE

/obj/machinery/griddle/process(seconds_per_tick)
	for(var/obj/item/griddled_item as anything in griddled_objects)
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILL_PROCESS, src, seconds_per_tick) & COMPONENT_HANDLED_GRILLING)
			continue
		griddled_item.fire_act(1000) //Hot hot hot!
		if(prob(10))
			visible_message("<span class='danger'>[griddled_item] doesn't seem to be doing too great on the [src]!</span>")

		use_power(active_power_consumption)
	var/turf/griddle_loc = loc
	if(isturf(griddle_loc))
		griddle_loc.hotspot_expose(800, 100)

/obj/machinery/griddle/update_icon_state()
	icon_state = "griddle[variant]_[on ? "on" : "off"]"
	return ..()
