/datum/cooking_surface/ice_cream_mixer
	cooker_id = COOKER_SURFACE_ICE_CREAM_MIXER

/datum/cooking_surface/ice_cream_mixer/turn_on(mob/user)
	. = ..()
	parent.icon_state = "cereal_on"
	parent.update_appearance()

/datum/cooking_surface/ice_cream_mixer/turn_off(mob/user)
	. = ..()
	parent.icon_state = "cereal_off"
	parent.update_appearance()

/obj/machinery/cooking/ice_cream_mixer
	name = "ice cream mixer"
	desc = "An industrial mixing device for desserts of all kinds."
	icon_state = "cereal_off"
	active_power_consumption = 200
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/icecream_bowl,
		/obj/item/reagent_containers/cooking/mould,
	)

/obj/machinery/cooking/ice_cream_mixer/Initialize(mapload)
	. = ..()
	InitializeParts()
	surfaces += new /datum/cooking_surface/ice_cream_mixer(src)

/obj/machinery/cooking/ice_cream_mixer/proc/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/ice_cream_mixer(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/cooking/ice_cream_mixer/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> to set its timer.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> to toggle it on or off.</span>"

/obj/machinery/cooking/ice_cream_mixer/clickpos_to_surface(modifiers)
	return 1

/obj/machinery/cooking/ice_cream_mixer/attack_hand(mob/user)
	var/datum/cooking_surface/surface = surfaces[1]
	if(!surface.placed_item)
		return

	if(surface.on)
		to_chat(user, "<span class='notice'>\The [src] must be off to retrieve its contents.</span>")
		return

	user.put_in_hands(surface.placed_item)
	surface.placed_item = null

/obj/machinery/cooking/ice_cream_mixer/AltShiftClick(mob/user, modifiers)
	// No temperature changing on the ice cream mixer.
	return

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
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
	)
