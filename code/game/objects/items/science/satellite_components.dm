/obj/item/satellite_component
	name = "satellite component"
	new_attack_chain = TRUE
	icon = 'icons/obj/stock_parts.dmi'
	new_attack_chain = TRUE
	var/weight = 0
	var/fuel_efficiency = 0
	var/fuel_capacity = 0
	var/science_multiplier = 0
	var/power_generation = 0
	var/power_storage = 0
	var/power_consumption = 0
	var/power_capacity = 0

////////////////////////////////////////
// MARK: Computers
////////////////////////////////////////

/obj/item/satellite_component/computer/basic
	name = "basic on-board computer"
	icon_state = "nano_mani"
	desc = "A standard satellite computer that doesn't specialize in anything."
	weight = 10
	power_consumption = 10
	science_multiplier = 10
	power_capacity = 10

/obj/item/satellite_component/computer/science
	name = "scientific on-board computer"
	icon_state = "pico_mani"
	desc = "A satelite computer that focuses on processing more data at the cost of more power usage. "
	weight = 10
	power_consumption = 25
	science_multiplier = 20
	power_capacity = 10

/obj/item/satellite_component/computer/efficient
	name = "efficient on-board computer"
	icon_state = "femto_mani"
	desc = "A computer that focuses on powersaving at the cost of data processing."
	weight = 10
	power_consumption = 7
	science_multiplier = 5
	power_capacity = 10

////////////////////////////////////////
// MARK: Engines
////////////////////////////////////////

/obj/item/satellite_component/engine/basic_engine
	name = "basic engine"
	icon_state = "advanced_matter_bin"
	desc = "A basic engine that doesn't specialize in anything."
	weight = 10
	fuel_capacity = 10
	fuel_efficiency = 10
	power_generation = 1

/obj/item/satellite_component/engine/small_engine
	name = "basic engine"
	icon_state = "super_matter_bin"
	desc = "A small engine that has a lower weight, but also lower fuel efficiency."
	weight = 5
	fuel_capacity = 5
	fuel_efficiency = 7
	power_generation = 1

/obj/item/satellite_component/engine/ion_engine
	name = "basic engine"
	icon_state = "bluespace_matter_bin"
	desc = "An ion engine that uses ionized gass as a propellant. Extremely high fuel efficiency, buy uses power."
	weight = 10
	fuel_capacity = 1
	fuel_efficiency = 50
	power_consumption = 10

////////////////////////////////////////
// MARK: Science instruments
////////////////////////////////////////

/obj/item/satellite_component/meteorological_surveyor
	name = "meteorological surveyor"
	icon_state = "adv_scan_module"
	desc = "A meteorological surveyor meant for a satellite. Allows collecting data from ash storms and acid rain clouds."
	weight = 10
	power_consumption = 10

/obj/item/satellite_component/plasma_lab
	name = "plasma lab"
	icon_state = "scan_module"
	desc = "A plasma lab meant for a satellite. Provides a large one time data collection."
	weight = 10
	power_consumption = 5

/obj/item/satellite_component/magnetometer
	name = "magnetometer"
	icon_state = "super_scan_module"
	desc = "A magnetormeter meant for a satellite. Allows collecting data from ash storms and volcanism."
	weight = 10
	power_consumption = 10

////////////////////////////////////////
// MARK: Misc parts
////////////////////////////////////////

/obj/item/satellite_component/solar_panel
	name = "satellite solar panels"
	icon_state = "quadratic_capacitor"
	desc = "A set of solar panels for a satellite."
	weight = 2
	power_generation = 5

/obj/item/satellite_component/electric_generator
	name = "satellite generator"
	icon_state = "ultra_high_micro_laser"
	desc = "An electric generator for a satellite."
	weight = 5
	power_generation = 20

/obj/item/satellite_component/power_cell
	name = "satellite power cell"
	icon_state = "adv_capacitor"
	desc = "An electric generator for a satellite."
	weight = 5
	power_capacity = 20

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
	//qdel(src)
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
