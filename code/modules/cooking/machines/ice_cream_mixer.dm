/datum/cooking_surface/ice_cream_mixer
	cooker_id = COOKER_SURFACE_ICE_CREAM_MIXER
	allow_temp_change = FALSE

/obj/machinery/cooking/ice_cream_mixer
	name = "ice cream mixer"
	desc = "An industrial mixing device for desserts of all kinds."
	icon_state = "ice_cream_mixer"
	active_power_consumption = 200
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/icecream_bowl,
		/obj/item/reagent_containers/cooking/mould,
	)

/obj/machinery/cooking/ice_cream_mixer/Initialize(mapload)
	. = ..()
	InitializeParts()
	surfaces += new /datum/cooking_surface/ice_cream_mixer(src)
	update_icon()

/obj/machinery/cooking/ice_cream_mixer/proc/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/ice_cream_mixer(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/cooking/ice_cream_mixer/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> to set its timer and toggle it on or off.</span>"

/obj/machinery/cooking/ice_cream_mixer/clickpos_to_surface(modifiers)
	return 1

/obj/machinery/cooking/ice_cream_mixer/attack_hand(mob/user)
	var/datum/cooking_surface/surface = surfaces[1]
	if(!surface.container)
		return

	if(surface.on)
		to_chat(user, "<span class='notice'>\The [src] must be off to retrieve its contents.</span>")
		return

	user.put_in_hands(surface.container)
	surface.UnregisterSignal(surface.container, COMSIG_PARENT_EXAMINE)
	surface.container = null
	update_appearance(UPDATE_ICON)

/obj/machinery/cooking/ice_cream_mixer/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	container.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	container.make_mini()
	vis_contents += container

/obj/machinery/cooking/ice_cream_mixer/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[1]
	if(surface.container)
		surface.container.pixel_x = 0
		surface.container.pixel_y = 2
		add_to_visible(surface.container, surface_idx)

/obj/machinery/cooking/ice_cream_mixer/update_overlays()
	. = ..()
	var/datum/cooking_surface/surface = surfaces[1]
	if(surface.on)
		. += image(icon = icon, icon_state = "ice_cream_mixer_door", layer = ABOVE_OBJ_LAYER)
		. += image(icon = icon, icon_state = "ice_cream_mixer_on")
	else
		. += image(icon = icon, icon_state = "ice_cream_mixer_door_open", layer = ABOVE_OBJ_LAYER)

/obj/machinery/cooking/ice_cream_mixer/upgraded/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/ice_cream_mixer(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	RefreshParts()

/obj/item/circuitboard/cooking/ice_cream_mixer
	board_name = "Ice Cream Mixer"
	build_path = /obj/machinery/cooking/ice_cream_mixer
	board_type = "machine"
	icon_state = "service"
	origin_tech = "biotech=1"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
	)
