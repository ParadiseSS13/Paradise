/obj/item/satellite_component
	name = "satellite component"
	new_attack_chain = TRUE
	icon = 'icons/obj/stock_parts.dmi'

	var/weight = 0
	var/fuel_efficiency = 0
	var/fuel_capacity = 0
	var/science_multiplier = 0
	var/power_generation = 0
	var/power_storage = 0
	var/power_consumption = 0
	var/power_capacity = 0

/obj/item/satellite_component/computer/basic
	name = "basic on-board computer"
	icon_state = "nano_mani"
	weight = 10
	power_consumption = 10
	science_multiplier = 10
	power_capacity = 10

/obj/item/satellite_component/computer/science
	name = "scientific on-board computer"
	icon_state = "pico_mani"
	weight = 20
	power_consumption = 25
	science_multiplier = 25
	power_capacity = 10

/obj/item/satellite_component/computer/efficient
	name = "efficient on-board computer"
	icon_state = "femto_mani"
	weight = 15
	power_consumption = 5
	science_multiplier = 10
	power_capacity = 10

	/*
/obj/item/satellite_component/engine/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if (!istype(target, /obj/machinery/science_satellite))
		return

	var/obj/machinery/science_satellite/chassis = target
	//if (!chassis.panel_open)
	//	return
	if(/obj/item/satellite_component/engine in chassis.parts)
		to_chat(user, SPAN_ERROR("There is already an engine in [src]"))
		return
	chassis.parts += src
*/

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
