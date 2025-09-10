#define DEFAULT_TIME 10 SECONDS

/// MARK: Cetrifuge
/obj/machinery/nuclear_centrifuge
	name = "Fuel Enrichment Centrifuge"
	desc = "An advanced device capable of seperating and collecting enriched materials "
	icon = 'icons/obj/fission/reactor_parts.dmi'
	icon_state = "centrifuge"
	power_state = IDLE_POWER_USE
	idle_power_consumption = 200
	active_power_consumption = 3000
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | FREEZE_PROOF
	armor = list(melee = 25, bullet = 10, laser = 30, energy = 0, bomb = 0, rad = INFINITY, fire = INFINITY, acid = 70)

	/// The time it takes for the machine to process a rod
	var/work_time
	/// The averaged amount of all stock parts
	var/average_component_rating
	/// The result when we are done operating
	var/rod_result
	/// Holds the rod object inserted into the machine
	var/obj/item/nuclear_rod/held_rod
	/// The time needed to finish enrichment
	var/time_to_completion

/obj/machinery/nuclear_centrifuge/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/nuclear_centrifuge(src)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/nuclear_centrifuge/update_overlays()
	. = ..()
	if(power_state == ACTIVE_POWER_USE)
		. += "centrifuge_spinning"
	else
		. += "centrifuge_empty"
	. += "centrifuge_glass"

/obj/machinery/nuclear_centrifuge/RefreshParts()
	average_component_rating = 0
	for(var/obj/item/stock_parts/manipulator/part in component_parts)
		average_component_rating += part.rating
	average_component_rating /= 4 //average all 4 components
	work_time = DEFAULT_TIME / average_component_rating

/obj/machinery/nuclear_centrifuge/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(istype(used, /obj/item/nuclear_rod/fuel))
		if(stat & NOPOWER)
			return
		if(panel_open)
			return
		if(power_state == ACTIVE_POWER_USE) // dont start a new cycle when on
			return
		var/obj/item/nuclear_rod/fuel/rod = used
		var/list/enrichment_to_name = list()
		var/list/radial_list = list()
		var/obj/item/nuclear_rod/fuel/rod_enrichment
		if(rod.power_enrich_progress >= rod.enrichment_cycles)
			rod_enrichment = rod.power_enrich_result
			enrichment_to_name += ("[rod.name]" = rod_enrichment)
			radial_list += ("[rod_enrichment::name]" = image(icon = rod_enrichment::icon, icon_state = rod_enrichment::icon_state))
		if(rod.heat_enrich_progress >= rod.enrichment_cycles)
			rod_enrichment = rod.heat_enrich_result
			enrichment_to_name += ("[rod.name]" = rod_enrichment)
			radial_list += ("[rod_enrichment::name]" = image(icon = rod_enrichment::icon, icon_state = rod_enrichment::icon_state))

		if(!length(radial_list))
			to_chat("<span class='warning'>This rod has no potential for enrichment!</span>")
			return ITEM_INTERACT_COMPLETE

		var/enrichment_choices = show_radial_menu(user, src, radial_list, src, radius = 40, require_near = TRUE)
		rod_result = enrichment_to_name[enrichment_choices]
		held_rod = rod
		user.transfer_item_to(rod, src)
		begin_enrichment()

/obj/machinery/nuclear_centrifuge/process()
	if(stat & NOPOWER)
		if(power_state == ACTIVE_POWER_USE)
			abort_enrichment()
		return
	if(power_state == IDLE_POWER_USE)
		return
	if(world.time < time_to_completion)
		return
	finish_enrichment()

/obj/machinery/nuclear_centrifuge/proc/begin_enrichment()
	power_state = ACTIVE_POWER_USE
	update_icon(UPDATE_OVERLAYS)
	time_to_completion = world.time + 10 SECONDS

/obj/machinery/nuclear_centrifuge/proc/abort_enrichment()
	held_rod.forceMove(loc)
	held_rod = null
	power_state = IDLE_POWER_USE
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)

/obj/machinery/nuclear_centrifuge/proc/finish_enrichment()
	held_rod = null
	power_state = IDLE_POWER_USE
	playsound(src, 'sound/machines/ping.ogg', 30, 1)
	new rod_result(loc)
	rod_result = null

/obj/item/circuitboard/nuclear_centrifuge
	board_name = "Nuclear Centrifuge"
	icon_state = "engineering"
	build_path = /obj/machinery/nuclear_centrifuge
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(/obj/item/stock_parts/manipulator = 4)

