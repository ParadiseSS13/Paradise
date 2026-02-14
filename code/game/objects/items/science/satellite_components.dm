/obj/item/satellite_component
	name = "satellite component"
	new_attack_chain = TRUE
	icon = 'icons/obj/stock_parts.dmi'
	var/datum/satellite_stats/component_stats = new()

////////////////////////////////////////
// MARK: Computers
////////////////////////////////////////

/obj/item/satellite_component/computer/basic
	name = "basic on-board computer"
	icon_state = "nano_mani"
	desc = "A standard satellite computer that doesn't specialize in anything."
	component_stats = new /datum/satellite_stats/computer/basic()

/obj/item/satellite_component/computer/science
	name = "scientific on-board computer"
	icon_state = "pico_mani"
	desc = "A satelite computer that focuses on processing more data at the cost of more power usage. "
	component_stats = new /datum/satellite_stats/computer/science()


/obj/item/satellite_component/computer/efficient
	name = "efficient on-board computer"
	icon_state = "femto_mani"
	desc = "A computer that focuses on powersaving at the cost of data processing."
	component_stats = new /datum/satellite_stats/computer/efficient()


////////////////////////////////////////
// MARK: Engines
////////////////////////////////////////

/obj/item/satellite_component/engine/basic_engine
	name = "basic engine"
	icon_state = "advanced_matter_bin"
	desc = "A basic engine that doesn't specialize in anything."
	component_stats = new /datum/satellite_stats/engine/basic_engine()


/obj/item/satellite_component/engine/small_engine
	name = "basic engine"
	icon_state = "super_matter_bin"
	desc = "A small engine that has a lower weight, but also lower fuel efficiency."
	component_stats = new /datum/satellite_stats/engine/small_engine()


/obj/item/satellite_component/engine/ion_engine
	name = "basic engine"
	icon_state = "bluespace_matter_bin"
	desc = "An ion engine that uses ionized gass as a propellant. Extremely high fuel efficiency, buy uses power."
	component_stats = new /datum/satellite_stats/engine/ion_engine()


////////////////////////////////////////
// MARK: Science instruments
////////////////////////////////////////

/obj/item/satellite_component/science_instrument/meteorological_surveyor
	name = "meteorological surveyor"
	icon_state = "adv_scan_module"
	desc = "A meteorological surveyor meant for a satellite. Allows collecting data from ash storms and acid rain clouds."
	component_stats = new /datum/satellite_stats/science_instrument/meteorological_surveyor()

/obj/item/satellite_component/science_instrument/plasma_lab
	name = "plasma lab"
	icon_state = "scan_module"
	desc = "A plasma lab meant for a satellite. Provides a large one time data collection."
	component_stats = new /datum/satellite_stats/science_instrument/plasma_lab()


/obj/item/satellite_component/science_instrument/magnetometer
	name = "magnetometer"
	icon_state = "super_scan_module"
	desc = "A magnetormeter meant for a satellite. Allows collecting data from ash storms and volcanism."
	component_stats = new /datum/satellite_stats/science_instrument/magnetometer()


////////////////////////////////////////
// MARK: Misc parts
////////////////////////////////////////

/obj/item/satellite_component/misc_part/solar_panel
	name = "satellite solar panels"
	icon_state = "quadratic_capacitor"
	desc = "A set of solar panels for a satellite."
	component_stats = new /datum/satellite_stats/misc_part/solar_panel()


/obj/item/satellite_component/misc_part/electric_generator
	name = "satellite generator"
	icon_state = "ultra_high_micro_laser"
	desc = "An electric generator for a satellite."
	component_stats = new /datum/satellite_stats/misc_part/electric_generator()


/obj/item/satellite_component/misc_part/power_cell
	name = "satellite power cell"
	icon_state = "adv_capacitor"
	desc = "An electric generator for a satellite."
	component_stats = new /datum/satellite_stats/misc_parts/power_cell()


/obj/item/satellite_component/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if (!istype(target, /obj/machinery/science_satellite))
		return

	var/obj/machinery/science_satellite/chassis = target
	if (!chassis.panel_open)
		return


	user.drop_item()
	forceMove(chassis)
	chassis.parts += src
	chassis.adjust_stats(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/satellite_component/engine/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if (!istype(target, /obj/machinery/science_satellite))
		return

	var/obj/machinery/science_satellite/chassis = target

	for(var/obj/item/satellite_component/component in chassis.parts)
		if(istype(component, /obj/item/satellite_component/engine))
			to_chat(user, SPAN_WARNING("There is already an engine in \the [chassis]"))
			return NONE

	return ..()
