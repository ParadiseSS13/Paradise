RESTRICT_TYPE(/obj/machinery/cooking)

/obj/machinery/cooking
	name = "Default Cooking Appliance"
	desc = "You shouldn't be seeing this. Please report this as an issue on GitHub."
	icon = 'icons/obj/cooking/machines.dmi'
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 100

	var/cooking = FALSE
	var/quality_mod = 1
	var/list/allowed_containers
	var/list/surfaces = list()

/obj/machinery/cooking/Destroy()
	QDEL_LIST_CONTENTS(surfaces)

	return ..()

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

// No AI or robot interactions with these, as that has all sorts of awful
// implications for how the containers and machines are interacted with.
/obj/machinery/cooking/attack_ai()
	return

/obj/machinery/cooking/attack_robot(mob/living/user)
	return

/obj/machinery/cooking/ShiftClick(mob/user, modifiers)
	var/surface_idx = clickpos_to_surface(modifiers)
	if(!surface_idx)
		return ..()

	var/datum/cooking_surface/surface = surfaces[surface_idx]
	if(surface.container)
		return surface.container.ShiftClick(user, modifiers)

	return ..()

/obj/machinery/cooking/RefreshParts()
	. = ..()
	var/man_rating = 0
	var/part_count = 0
	for(var/obj/item/stock_parts/stock_part in component_parts)
		man_rating += stock_part.rating
		part_count++
	quality_mod = floor(man_rating / part_count)

/// Retrieve which burning surface on the machine is being accessed.
/obj/machinery/cooking/proc/clickpos_to_surface(modifiers)
	return

/obj/machinery/cooking/wrench_act(mob/living/user, obj/item/used)
	return default_unfasten_wrench(user, used, time = 4 SECONDS)

/obj/machinery/cooking/crowbar_act(mob/living/user, obj/item/used)
	return default_deconstruction_crowbar(user, used)

/obj/machinery/cooking/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(user.a_intent == INTENT_HELP)
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You screw [src]'s panel [panel_open ? "open" : "closed"].</span>")
		update_appearance()
		if(panel_open)
			machine_state_change()
		return
	if(!I.use_tool(src, user, 2.5 SECONDS, volume = I.tool_volume))
		return

/obj/machinery/cooking/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer) || istype(used, /obj/item/autochef_remote))
		return ..()

	var/input = clickpos_to_surface(modifiers)
	if(input)
		var/datum/cooking_surface/surface = surfaces[input]
		return surface_item_interaction(user, used, surface)

	return ..()

/obj/machinery/cooking/CtrlClick(mob/user, modifiers)
	if(user.stat || user.restrained() || (!in_range(src, user)) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(!anchored)
		return ..()

	var/surface_idx = clickpos_to_surface(modifiers)
	if(!surface_idx)
		return
	var/datum/cooking_surface/surface = surfaces[surface_idx]

	var/list/surface_options = list(
		RADIAL_ACTION_SET_ALARM = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_setalarm"),
		RADIAL_ACTION_ON_OFF = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_onoff"),
	)
	if(surface.allow_temp_change)
		surface_options[RADIAL_ACTION_SET_TEMPERATURE] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_settemp")
	var/option_choice = show_radial_menu(user, src, surface_options, require_near = TRUE)

	switch(option_choice)
		if(RADIAL_ACTION_SET_ALARM)
			surface.handle_timer(user)
		if(RADIAL_ACTION_SET_TEMPERATURE)
			surface.handle_temperature(user)
		if(RADIAL_ACTION_ON_OFF)
			if(surface.handle_switch(user))
				makeSpeedProcess()
			update_appearance()

/obj/machinery/cooking/proc/surface_item_interaction(mob/living/user, obj/item/used, datum/cooking_surface/surface)
	if(surface.container)
		surface.container.item_interaction(user, used)
		return ITEM_INTERACT_COMPLETE

	for(var/allowed_container_type in allowed_containers)
		if(istype(used, allowed_container_type))
			if(ismob(user))
				to_chat(user, "<span class='notice'>You put [used] on [src].</span>")
				if(user.drop_item())
					used.forceMove(src)
			else
				used.forceMove(src)

			surface.container = used
			surface.prob_quality_decrease = 0
			surface.RegisterSignal(used, COMSIG_PARENT_EXAMINE, TYPE_PROC_REF(/datum/cooking_surface, container_examine), override = TRUE)
			if(surface.on)
				surface.reset_cooktime()

	update_icon()
	return ITEM_INTERACT_COMPLETE

/// Empty the container on the surface if it exists.
/obj/machinery/cooking/AltClick(mob/user, modifiers)
	if(user.stat || user.restrained() || (!in_range(src, user)) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/input = clickpos_to_surface(modifiers)
	var/datum/cooking_surface/burner = surfaces[input]
	if(!burner)
		return

	var/obj/item/reagent_containers/cooking/container = burner.container
	if(!(istype(container)))
		return

	container.do_empty(user)
	burner.unset_callbacks()

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

/obj/machinery/cooking/proc/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/machinery/cooking/proc/remove_from_visible(obj/item/reagent_containers/cooking/container, input)
	container.vis_flags = 0
	container.blend_mode = 0
	container.transform =  null
	container.appearance_flags &= PIXEL_SCALE
	container.unmake_mini()
	vis_contents.Remove(container)

/obj/machinery/cooking/update_icon(updates)
	cooking = FALSE
	for(var/datum/cooking_surface/surface in surfaces)
		if(surface.on)
			cooking = TRUE

	. = ..()
	for(var/obj/item/our_item in vis_contents)
		remove_from_visible(our_item)

	for(var/i in 1 to length(surfaces))
		update_surface_icon(i)

/obj/machinery/cooking/update_overlays()
	. = ..()
	if(panel_open)
		. += image(icon = icon, icon_state = "[icon_state]_openpanel")

/obj/machinery/cooking/proc/update_surface_icon(surface_idx)
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/machinery/cooking/power_change()
	. = ..()
	if(stat & NOPOWER)
		machine_state_change()

/obj/machinery/cooking/proc/machine_state_change()
	for(var/datum/cooking_surface/surface in surfaces)
		if(surface.on)
			surface.turn_off()
			var/obj/item/reagent_containers/cooking/container = surface.container
			if(istype(container) && container.tracker)
				SEND_SIGNAL(container, COMSIG_COOK_MACHINE_STEP_INTERRUPTED, surface)
