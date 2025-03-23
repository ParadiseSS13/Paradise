/datum/cooking_surface/oven
	cooker_id = COOKER_SURFACE_OVEN

/datum/cooking_surface/oven/handle_switch(mob/user)
	var/obj/machinery/cooking/oven/oven = parent
	if(istype(oven))
		if(!on && oven.opened)
			to_chat(user, "<span class='notice'>The oven must be closed in order to turn it on.</span>")
			return

	return ..()

// TODO: add back special attack for oven for v2
// Yes, that's a v2 thing, I'm not doing it right now
/obj/machinery/cooking/oven
	name = "oven"
	desc = "A cozy oven for baking food."
	icon_state = "oven"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	cooking = FALSE
	var/opened = FALSE

	var/on_fire = FALSE //if the oven has caught fire or not.
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/oven
	)

/obj/machinery/cooking/oven/Initialize(mapload)
	. = ..()

	InitializeParts()
	surfaces += new /datum/cooking_surface/oven(src)
	update_appearance()

/obj/machinery/cooking/oven/proc/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/oven(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)

	RefreshParts()

/obj/machinery/cooking/oven/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> to set its timer, temperature, and toggle it on or off.</span>"

/obj/machinery/cooking/oven/RefreshParts()
	..()

	var/las_rating = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		las_rating += M.rating

/obj/machinery/cooking/oven/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer) || istype(used, /obj/item/autochef_remote))
		return ..()

	if(!opened)
		handle_open(user)
		update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/cooking/oven/attack_hand(mob/user as mob, params)
	var/input = clickpos_to_surface(params2list(params))

	// If we didn't click on the door, toggle it.
	if(!input)
		handle_open(user)
		return

	var/datum/cooking_surface/surface = surfaces[input]
	if(surface && surface.container && opened)
		user.put_in_hands(surface.container)
		surface.UnregisterSignal(surface.container, COMSIG_PARENT_EXAMINE)
		surface.container = null
		update_appearance(UPDATE_ICON)
	else
		handle_open(user)

/obj/machinery/cooking/oven/AltClick(mob/user, params)
	if(user.stat || user.restrained() || (!in_range(src, user)))
		return

	if(!opened)
		to_chat(user, "<span class='notice'>The oven must be open to retrieve the food.</span>")
		return

	return ..()

/obj/machinery/cooking/oven/proc/handle_open(mob/user)
	if(opened)
		opened = FALSE
	else
		opened = TRUE
		var/datum/cooking_surface/surface = surfaces[1]
		if(surface.on)
			surface.handle_switch(user)
			makeNormalProcess()

	update_appearance()

#define ICON_SPLIT_X_1 5
#define ICON_SPLIT_X_2 28
#define ICON_SPLIT_Y_1 5
#define ICON_SPLIT_Y_2 20

/obj/machinery/cooking/oven/clickpos_to_surface(modifiers)
	var/icon_x = text2num(modifiers["icon-x"])
	var/icon_y = text2num(modifiers["icon-y"])
	if(icon_x >= ICON_SPLIT_X_1 && icon_x <= ICON_SPLIT_X_2 && icon_y >= ICON_SPLIT_Y_1 && icon_y <= ICON_SPLIT_Y_2)
		return 1

#undef ICON_SPLIT_X_1
#undef ICON_SPLIT_X_2
#undef ICON_SPLIT_Y_1
#undef ICON_SPLIT_Y_2

/obj/machinery/cooking/oven/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[1]
	if(surface.container)
		surface.container.pixel_x = 0
		surface.container.pixel_y = -2
		add_to_visible(surface.container)

/obj/machinery/cooking/oven/update_overlays()
	. = ..()
	if(opened)
		. += image(icon, icon_state = "oven_hatch_open", layer = ABOVE_OBJ_LAYER)
	else
		var/datum/cooking_surface/surface = surfaces[1]
		. += image(icon, icon_state = "oven_hatch[surface.on ? "_on" : ""]", layer = ABOVE_OBJ_LAYER)

/obj/machinery/cooking/oven/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	container.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	container.make_mini()
	vis_contents += container

/obj/machinery/cooking/oven/upgraded/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/oven(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)

	RefreshParts()

/obj/item/circuitboard/cooking/oven
	board_name = "Convection Oven"
	build_path = /obj/machinery/cooking/oven
	board_type = "machine"
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 2,
	)
