/datum/cooking_surface/grill_surface
	cooker_id = COOKER_SURFACE_GRILL

/datum/cooking_surface/grill_surface/handle_switch(mob/user)
	var/obj/machinery/cooking/grill/grill = parent
	if(!istype(grill))
		return

	if(!on)
		if(grill.stored_wood <= 0)
			to_chat(user, "<span class='notice'>There is no wood in the grill. Insert some planks first.</span>")
			return

	return ..()

/obj/effect/grill_hopper
	icon = 'icons/obj/cooking/machines.dmi'
	icon_state = "blank"
	vis_flags = VIS_INHERIT_ID
	mouse_opacity = 0
	invisibility = 0

// TODO: add back special attack for grill for v2
// Yes, that's a v2 thing, I'm not doing it right now
/obj/machinery/cooking/grill
	name = "grill"
	desc = "A deep pit of charcoal for cooking food. A slot on the side of the machine takes wood and converts it into charcoal."
	icon_state = "grill"
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	pass_flags = PASSTABLE
	interact_offline = TRUE
	active_power_consumption = 50 // uses more wood than power
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/grill_grate,
	)

	var/stored_wood = 0
	var/wood_maximum = 30
	var/obj/effect/grill_hopper/hopper_overlay

/obj/machinery/cooking/grill/Initialize(mapload)
	. = ..()

	hopper_overlay = new
	vis_contents += hopper_overlay
	InitializeParts()

	for(var/i in 1 to 2)
		surfaces += new /datum/cooking_surface/grill_surface(src)
	update_appearance()

/obj/machinery/cooking/grill/proc/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/cooking/grill/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It contains [stored_wood]/[wood_maximum] units of charcoal.</span>"
	. += "<span class='notice'><b>Alt-Shift-Click</b> on a grate to set its temperature.</span>"
	. += "<span class='notice'><b>Ctrl-Click</b> on a grate to set its timer.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> on a grate to toggle it on or off.</span>"

/obj/machinery/cooking/grill/process()
	. = ..()

	for(var/datum/cooking_surface/surface in surfaces)
		if(surface.on)
			if(!stored_wood)
				surface.turn_off()
			else
				stored_wood = max(0, stored_wood - 0.025)

/obj/machinery/cooking/grill/RefreshParts()
	. = ..()

	var/las_rating = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		las_rating += M.rating
	quality_mod = round(las_rating/2)

	var/bin_rating = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		bin_rating += M.rating
	wood_maximum = 15 * bin_rating

#define ICON_SPLIT_X 16

//Retrieve which half of the baking pan is being used.
/obj/machinery/cooking/grill/clickpos_to_surface(modifiers)
	var/icon_x = text2num(modifiers["icon-x"])
	if(icon_x <= ICON_SPLIT_X)
		return 1
	else if(icon_x > ICON_SPLIT_X)
		return 2

#undef ICON_SPLIT_X

/obj/machinery/cooking/grill/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/stack = used
		var/used_sheets = min(stack.get_amount(), (wood_maximum - stored_wood))
		if(!used_sheets)
			to_chat(user, "<span class='notice'>The grill's hopper is full.</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You add [used_sheets] wood plank\s into [src]'s hopper.</span>")
		if(!stack.use(used_sheets))
			qdel(stack)	// Protects against weirdness
		stored_wood += used_sheets

		flick("wood_load", hopper_overlay)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/cooking/grill/attack_hand(mob/user, params)
	var/input = clickpos_to_surface(params2list(params))
	var/datum/cooking_surface/surface = surfaces[input]
	if(surface.placed_item)
		if(surface.on)
			surface.handle_cooking(user)
			var/mob/living/carbon/human/burn_victim = user
			if(istype(burn_victim) && !burn_victim.gloves)
				var/which_hand = "l_hand"
				if(!burn_victim.hand)
					which_hand = "r_hand"

				switch(surface.temperature)
					if(J_HI)
						burn_victim.adjustFireLossByPart(5, which_hand)
					if(J_MED)
						burn_victim.adjustFireLossByPart(2, which_hand)
					if(J_LO)
						burn_victim.adjustFireLossByPart(1, which_hand)

				to_chat(burn_victim, "<span class='danger'>You burn your hand a little taking the [surface.placed_item] off of [src].</span>")

		user.put_in_hands(surface.placed_item)
		surface.placed_item = null
		update_appearance(UPDATE_ICON)

/obj/machinery/cooking/grill/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[surface_idx]
	if(surface.on)
		add_overlay(image(icon, icon_state = "fire_[surface_idx]"))

	if(!(surface.placed_item))
		return

	var/obj/item/our_item = surface.placed_item
	switch(surface_idx)
		if(1)
			our_item.pixel_x = -7
			our_item.pixel_y = 4
		if(2)
			our_item.pixel_x = 7
			our_item.pixel_y = 4

	add_to_visible(our_item, surface_idx)

/obj/machinery/cooking/grill/add_to_visible(obj/item/our_item, surface_idx)
	our_item.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	vis_contents += our_item
	if(surface_idx == 2 || surface_idx == 4)
		var/matrix/M = matrix()
		M.Scale(-1,1)
		our_item.transform = M
	our_item.transform *= 0.8

/obj/machinery/cooking/grill/upgraded/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	RefreshParts()

/obj/item/circuitboard/grill
	board_name = "Charcoal Grill"
	build_path = /obj/machinery/cooking/grill
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)
