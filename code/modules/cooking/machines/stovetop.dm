/datum/cooking_surface/stovetop_burner
	surface_name = "burner"
	cooker_id = COOKER_SURFACE_STOVE

/obj/machinery/cooking/stovetop
	name = "stovetop"
	desc = "An electric stovetop with four burners."
	icon_state = "stove"
	density = FALSE
	pass_flags = PASSTABLE
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/pot,
		/obj/item/reagent_containers/cooking/pan,
	)

/obj/machinery/cooking/stovetop/Initialize(mapload)
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/stove(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)

	for(var/i in 1 to 4)
		surfaces += new/datum/cooking_surface/stovetop_burner(src)

	RefreshParts()

/obj/machinery/cooking/stovetop/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> on a burner to set its timer, temperature, and toggle it on or off.</span>"

#define ICON_SPLIT_X 16
#define ICON_SPLIT_Y 21

/obj/machinery/cooking/stovetop/clickpos_to_surface(modifiers)
	var/icon_x = text2num(modifiers["icon-x"])
	var/icon_y = text2num(modifiers["icon-y"])
	if(icon_x <= ICON_SPLIT_X && icon_y <= ICON_SPLIT_Y)
		return 1
	else if(icon_x > ICON_SPLIT_X && icon_y <= ICON_SPLIT_Y)
		return 2
	else if(icon_x <= ICON_SPLIT_X && icon_y > ICON_SPLIT_Y)
		return 3
	else if(icon_x > ICON_SPLIT_X && icon_y > ICON_SPLIT_Y)
		return 4

#undef ICON_SPLIT_X
#undef ICON_SPLIT_Y

/obj/machinery/cooking/stovetop/attack_hand(mob/user, params)
	var/input = clickpos_to_surface(params2list(params))
	if(!input)
		return

	var/datum/cooking_surface/burner = surfaces[input]
	if(burner && burner.container)
		if(burner.on)
			SEND_SIGNAL(burner.container, COMSIG_COOK_MACHINE_STEP_INTERRUPTED, burner)
			var/mob/living/carbon/human/burn_victim = user
			if(istype(burn_victim) && !burn_victim.gloves)
				var/which_hand = "l_hand"
				if(!burn_victim.hand)
					which_hand = "r_hand"
				switch(burner.temperature)
					if(J_HI)
						burn_victim.adjustFireLossByPart(5, which_hand)
					if(J_MED)
						burn_victim.adjustFireLossByPart(2, which_hand)
					if(J_LO)
						burn_victim.adjustFireLossByPart(1, which_hand)

				to_chat(burn_victim, "<span class='danger'>You burn your hand a little taking [burner.container] off of the stove.</span>")
		user.put_in_hands(burner.container)
		burner.UnregisterSignal(burner.container, COMSIG_PARENT_EXAMINE)
		burner.container = null
		update_appearance(UPDATE_ICON)

/obj/machinery/cooking/stovetop/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[surface_idx]

	if(!surface.container)
		return
	switch(surface_idx)
		if(1)
			surface.container.pixel_x = -7
			surface.container.pixel_y = 1
		if(2)
			surface.container.pixel_x = 7
			surface.container.pixel_y = 1
		if(3)
			surface.container.pixel_x = -7
			surface.container.pixel_y = 12
		if(4)
			surface.container.pixel_x = 7
			surface.container.pixel_y = 12
	add_to_visible(surface.container, surface_idx)

/obj/machinery/cooking/stovetop/update_overlays()
	. = ..()

	if(cooking)
		. += image(icon, icon_state = "indicator")

	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		if(surface.on)
			. += image(icon, icon_state = "burner_[i]")
			if(surface.container)
				. += image(icon, icon_state="steam_[i]", layer = ABOVE_OBJ_LAYER)

/obj/machinery/cooking/stovetop/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	container.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	container.make_mini()
	vis_contents += container
	if(surface_idx == 2 || surface_idx == 4)
		var/matrix/M = matrix()
		M.Scale(-1, 1)
		container.transform = M

/obj/item/circuitboard/cooking/stove
	board_name = "Stovetop"
	build_path = /obj/machinery/cooking/stovetop
	board_type = "machine"
	icon_state = "service"
	origin_tech = "biotech=1"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/machinery/cooking/stovetop/loaded/Initialize(mapload)
	. = ..()
	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		if(i % 2 == 0)
			surface.container = new /obj/item/reagent_containers/cooking/pot(src)
		else
			surface.container = new /obj/item/reagent_containers/cooking/pan(src)
	update_appearance()
