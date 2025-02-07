RESTRICT_TYPE(/obj/machinery/cooking)

/obj/machinery/cooking
	name = "Default Cooking Appliance"
	desc = "You shouldn't be seeing this. Please report this as an issue on GitHub."
	icon = 'icons/obj/cooking/machines.dmi'
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/cooking = FALSE
	var/quality_mod = 1
	idle_power_consumption = 5
	active_power_consumption = 100

	var/list/allowed_containers
	var/list/surfaces = list()

/obj/machinery/cooking/process()
	if(any_surface_active())
		makeSpeedProcess()
	else
		makeNormalProcess()
		return

	for(var/datum/cooking_surface/surface in surfaces)
		if(surface.on)
			surface.handle_cooking(null)

	use_power(active_power_consumption)

/obj/machinery/cooking/proc/any_surface_active()
	for(var/datum/cooking_surface/surface in surfaces)
		if(surface.on)
			return TRUE

/obj/machinery/cooking/RefreshParts()
	..()
	var/man_rating = 0
	for(var/obj/item/stock_parts/stock_part in component_parts)
		man_rating += stock_part.rating
	quality_mod = round(man_rating / 2)

/// Retrieve which burning surface on the machine is being accessed.
/obj/machinery/cooking/proc/clickpos_to_surface(modifiers)
	return

/obj/machinery/cooking/wrench_act(mob/living/user, obj/item/I)
	if(default_unfasten_wrench(user, I, time = 4 SECONDS))
		return TRUE

/obj/machinery/cooking/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(user.a_intent == INTENT_HELP)
		return FALSE
	if(!I.use_tool(src, user, 2.5 SECONDS, volume = I.tool_volume))
		return

	to_chat(user, "<span class='notice'>You disassemble [src].</span>")
	deconstruct()

/obj/machinery/cooking/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/input = clickpos_to_surface(modifiers)
	if(input)
		var/datum/cooking_surface/surface = surfaces[input]
		return surface_item_interaction(user, used, surface)

	return ..()

/obj/machinery/cooking/proc/surface_item_interaction(mob/living/user, obj/item/used, datum/cooking_surface/surface)
	if(surface.placed_item)
		surface.placed_item.item_interaction(user, used)
		return ITEM_INTERACT_COMPLETE

	for(var/allowed_container_type in allowed_containers)
		if(istype(used, allowed_container_type))
			if(ismob(user))
				to_chat(user, "<span class='notice'>You put [used] on \the [src].</span>")
				if(user.drop_item())
					used.forceMove(src)
			else
				used.forceMove(src)

			surface.placed_item = used
			surface.prob_quality_decrease = 0
			if(surface.on)
				surface.reset_cooktime()

	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_COMPLETE

/// Ask the user to set the a cooking surfaces's temperature.
/obj/machinery/cooking/AltShiftClick(mob/user, modifiers)
	if(user.stat || user.restrained() || (!in_range(src, user)))
		return

	if(!anchored)
		to_chat(user, "<span class='notice'>The [src] must be secured before using it.</span>")
		return

	var/surface_idx = clickpos_to_surface(modifiers)
	if(!surface_idx)
		return

	var/datum/cooking_surface/burner = surfaces[surface_idx]
	burner.handle_temperature(user)

/// Ask the user to set a cooking surface's timer.
/obj/machinery/cooking/CtrlClick(mob/user, modifiers)
	if(user.stat || user.restrained() || (!in_range(src, user)))
		return

	if(!anchored)
		return ..()

	var/surface_idx = clickpos_to_surface(modifiers)
	if(!surface_idx)
		return

	var/datum/cooking_surface/burner = surfaces[surface_idx]
	burner.handle_timer(user)

/// Switch the cooking surface on or off.
/obj/machinery/cooking/CtrlShiftClick(mob/user, modifiers)
	if(user.stat || user.restrained() || (!in_range(src, user)))
		return

	if(!anchored)
		to_chat(user, "<span class='notice'>The [src] must be secured before using it.</span>")
		return

	var/surface_idx = clickpos_to_surface(modifiers)
	if(!surface_idx)
		return

	var/datum/cooking_surface/burner = surfaces[surface_idx]
	if(burner.handle_switch(user))
		// swap us over to SSfastprocess to have any hope
		// of properly syncing up timing between surface
		// and container cook times
		makeSpeedProcess()

/// Empty the container on the surface if it exists.
/obj/machinery/cooking/AltClick(mob/user, modifiers)
	if(user.stat || user.restrained() || (!in_range(src, user)))
		return

	var/input = clickpos_to_surface(modifiers)
	var/datum/cooking_surface/burner = surfaces[input]
	if(!burner)
		return

	var/obj/item/reagent_containers/cooking/container = burner.placed_item
	if(!(istype(container)))
		return

	container.do_empty(user)
	burner.kill_timers()

/obj/machinery/cooking/proc/ignite()
	new /obj/effect/fire(loc, T0C + 300, (roll("2d10+15") SECONDS), 1)

	// Chance of spreading
	var/spread_count = rand(1, 3)
	if(prob(30))
		var/list/dirs = GLOB.alldirs.Copy()
		while(spread_count && length(dirs))
			var/direction = pick_n_take(dirs)
			var/turf/T = get_step(src, direction)
			if(T.density)
				continue
			new /obj/effect/fire(T, T0C + 300, (roll("2d10+15") SECONDS), 1)
			spread_count--

	for(var/datum/cooking_surface/surface in surfaces)
		if(surface.on)
			surface.handle_switch()

	makeNormalProcess()
