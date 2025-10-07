/datum/cooking_surface/oven
	cooker_id = COOKER_SURFACE_OVEN

// TODO: add back special attack for oven for v2
// Yes, that's a v2 thing, I'm not doing it right now
/obj/machinery/cooking/oven
	name = "oven"
	desc = "A cozy oven for baking food."
	icon_state = "oven"
	layer = LOW_ITEM_LAYER  // horrible hackiness to deal with layering vis_contents (tray),
							// overlays (door/light) and emptying container contents on top
							// of the oven, see below

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

/obj/machinery/cooking/oven/attack_hand(mob/user as mob, params)
	var/input = clickpos_to_surface(params2list(params))

	var/datum/cooking_surface/surface = surfaces[input]
	if(surface && surface.container)
		user.put_in_hands(surface.container)
		surface.UnregisterSignal(surface.container, COMSIG_PARENT_EXAMINE)
		surface.container = null
		update_appearance(UPDATE_ICON)

/obj/machinery/cooking/oven/clickpos_to_surface(modifiers)
	return 1

/obj/machinery/cooking/oven/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[1]
	if(surface.container)
		surface.container.pixel_x = 0
		surface.container.pixel_y = -2
		add_to_visible(surface.container)

/obj/machinery/cooking/oven/update_overlays()
	. = ..()

	var/datum/cooking_surface/surface = surfaces[1]
	if(surface.on)
		. += image(icon, icon_state = "oven_on", layer = LOW_ITEM_LAYER + 0.02)
	if(surface.container)
		. += image(icon, icon_state = "oven_closed", layer = LOW_ITEM_LAYER + 0.04)
	else
		. += image(icon, icon_state = "oven_open", layer = LOW_ITEM_LAYER + 0.04)

/obj/machinery/cooking/oven/remove_from_visible(obj/item/reagent_containers/cooking/container, input)
	. = ..()
	container.layer = initial(container.layer)

/obj/machinery/cooking/oven/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	container.vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_ID
	container.layer = LOW_ITEM_LAYER + 0.01
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
	icon_state = "service"
	origin_tech = "biotech=1"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/machinery/cooking/oven/loaded/Initialize(mapload)
	. = ..()
	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		surface.container = new /obj/item/reagent_containers/cooking/oven(src)
	update_appearance()
