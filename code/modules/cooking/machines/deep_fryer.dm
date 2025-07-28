/datum/cooking_surface/deepfryer_basin
	cooker_id = COOKER_SURFACE_DEEPFRYER
	allow_temp_change = FALSE

// TODO: add back special attack for deep fryer for v2
// Yes, that's a v2 thing, I'm not doing it right now
/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "A deep fryer that can hold two baskets."
	icon_state = "deep_fryer"
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/deep_basket,
	)

/obj/machinery/cooking/deepfryer/Initialize(mapload)
	. = ..()

	InitializeParts()

	for(var/i in 1 to 2)
		surfaces += new/datum/cooking_surface/deepfryer_basin(src)

/obj/machinery/cooking/deepfryer/proc/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/deep_fryer(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/cooking/deepfryer/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> on a basin to set its timer and toggle it on or off.</span>"

#define ICON_SPLIT_X 16
#define ICON_SPLIT_Y 16

/obj/machinery/cooking/deepfryer/clickpos_to_surface(modifiers)
	var/icon_x = text2num(modifiers["icon-x"])
	var/icon_y = text2num(modifiers["icon-y"])
	if(icon_y <= ICON_SPLIT_Y)
		return

	if(icon_x <= ICON_SPLIT_X)
		return 1
	else if(icon_x > ICON_SPLIT_X)
		return 2

#undef ICON_SPLIT_X
#undef ICON_SPLIT_Y

/obj/machinery/cooking/deepfryer/attack_hand(mob/user, params)
	var/input = clickpos_to_surface(params2list(params))
	if(!input)
		return

	var/datum/cooking_surface/surface = surfaces[input]
	if(surface && surface.container)
		if(surface.on)
			surface.handle_cooking(user)
			var/mob/living/carbon/human/burn_victim = user
			if(istype(burn_victim) && !burn_victim.gloves)
				var/which_hand = "l_hand"
				if(!burn_victim.hand)
					which_hand = "r_hand"

				burn_victim.adjustFireLossByPart(20, which_hand)
				to_chat(burn_victim, "<span class='danger'>You burn your hand a little taking [surface.container] off of [src].</span>")

		user.put_in_hands(surface.container)
		surface.UnregisterSignal(surface.container, COMSIG_PARENT_EXAMINE)
		surface.container = null
		update_appearance(UPDATE_ICON)

/obj/machinery/cooking/deepfryer/update_overlays()
	. = ..()

	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		if(!surface.container)
			continue

/obj/machinery/cooking/deepfryer/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[surface_idx]

	if(!surface.container)
		return
	var/obj/item/reagent_containers/cooking/deep_basket/basket = surface.container
	if(surface.on)
		basket.frying = TRUE
		basket.update_icon()
	else
		basket.frying = FALSE
		basket.update_icon()
	switch(surface_idx)
		if(1)
			basket.pixel_x = -6
			basket.pixel_y = 4
		if(2)
			basket.pixel_x = 7
			basket.pixel_y = 4

	add_to_visible(basket, surface_idx)

/obj/machinery/cooking/deepfryer/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	container.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	container.make_mini()
	vis_contents += container

/obj/machinery/cooking/deepfryer/upgraded/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/deep_fryer(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/item/circuitboard/cooking/deep_fryer
	board_name = "Deep Fryer"
	build_path = /obj/machinery/cooking/deepfryer
	icon_state = "service"
	board_type = "machine"
	origin_tech = "biotech=1"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/machinery/cooking/deepfryer/loaded/Initialize(mapload)
	. = ..()
	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		surface.container = new /obj/item/reagent_containers/cooking/deep_basket(src)
	update_appearance()
