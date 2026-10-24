/obj/item/matter_decompiler
	name = "matter decompiler"
	desc = "Eating trash, bits of glass, or other debris will replenish your stores."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"
	new_attack_chain = TRUE
	/// Metal, glass, wood, plastic.
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0
		)

/obj/item/matter_decompiler/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	// We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/the_floor = get_turf(target)
	if(!istype(the_floor))
		return ..()

	// Used to give the right message.
	var/grabbed_something = FALSE

	for(var/atom/movable/atom in the_floor)
		if(atom.decompile_act(src, user)) // Each decompileable mob or obj needs to have this defined.
			grabbed_something = TRUE

	if(grabbed_something)
		to_chat(user, SPAN_NOTICE("You deploy your decompiler and clear out the contents of [the_floor]."))
	else
		to_chat(user, SPAN_WARNING("Nothing on [the_floor] is useful to you."))
	return ITEM_INTERACT_COMPLETE

// Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()
	..()
	if(low_power_mode || !decompiler)
		return

	// The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] <= 0)
			continue
		var/obj/item/stack/sheet/stack
		switch(type)
			if("metal")
				if(!stack_metal)
					stack_metal = new /obj/item/stack/sheet/metal/cyborg(src.module)
					stack_metal.amount = 1
				stack = stack_metal
			if("glass")
				if(!stack_glass)
					stack_glass = new /obj/item/stack/sheet/glass/cyborg(src.module)
					stack_glass.amount = 1
				stack = stack_glass
			if("wood")
				if(!stack_wood)
					stack_wood = new /obj/item/stack/sheet/wood/cyborg(src.module)
					stack_wood.amount = 1
				stack = stack_wood
		stack.amount++
		decompiler.stored_comms[type]--
