/obj/item/satellite_component
	name = "satellite component"
	var/overlay_icon = null
	new_attack_chain = TRUE
	icon = 'icons/obj/machines/science_satellite.dmi'
	var/datum/satellite_stats/component_stats = new()

////////////////////////////////////////
// MARK: Computers
////////////////////////////////////////

/obj/item/satellite_component/computer/basic
	name = "basic on-board computer"
	icon_state = "basic_comp"
	overlay_icon = "overlay_bascomp"
	desc = "A basic satellite computer."
	component_stats = new /datum/satellite_stats/computer/basic()

/obj/item/satellite_component/computer/science
	name = "scientific on-board computer"
	icon_state = "science_comp"
	overlay_icon = "overlay_scicomp"
	desc = "A satelite computer that focuses on processing more data but has a lower power capacity. "
	component_stats = new /datum/satellite_stats/computer/science()


/obj/item/satellite_component/computer/efficient
	name = "efficient on-board computer"
	icon_state = "efficient_comp"
	overlay_icon = "overlay_effcomp"
	desc = "A computer that is lighter and has more power capacity, but is worse at collecting data."
	component_stats = new /datum/satellite_stats/computer/efficient()


////////////////////////////////////////
// MARK: Engines
////////////////////////////////////////

/obj/item/satellite_component/engine/basic_engine
	name = "basic engine"
	icon_state = "basic_thrust"
	overlay_icon = "overlay_basethrust"
	desc = "A basic engine that doesn't specialize in anything."
	component_stats = new /datum/satellite_stats/engine/basic_engine()


/obj/item/satellite_component/engine/small_engine
	name = "small engine"
	icon_state = "small_thrust"
	overlay_icon = "overlay_smallthrust"
	desc = "A small engine that has a lower weight and also lower fuel efficiency."
	component_stats = new /datum/satellite_stats/engine/small_engine()


/obj/item/satellite_component/engine/ion_engine
	name = "ion engine"
	icon_state = "ion_thrust"
	overlay_icon = "overlay_ionthrust"
	desc = "An ion engine that uses ionized gass as a propellant. Extremely high fuel efficiency, but uses power instead of generating it."
	component_stats = new /datum/satellite_stats/engine/ion_engine()


////////////////////////////////////////
// MARK: Science instruments
////////////////////////////////////////

/obj/item/satellite_component/science_instrument
	name = "instrument of science"
	desc = "You shouldn't be seeing this, it doesn't even sound musical!"
	attack_verb = list("probed")

/obj/item/satellite_component/science_instrument/meteorological_surveyor
	name = "meteorological surveyor"
	icon_state = "surveyor"
	desc = "A meteorological surveyor meant for a satellite. Allows collecting data from ash storms, windstorms, and acid rainfall."
	component_stats = new /datum/satellite_stats/science_instrument/meteorological_surveyor()

/obj/item/satellite_component/science_instrument/plasma_lab
	name = "plasma lab"
	icon_state = "plasma_lab"
	desc = "A plasma lab meant for a satellite. Provides collects data once when launched. The experiment will fail if the satellite has insufficient power."
	component_stats = new /datum/satellite_stats/science_instrument/plasma_lab()


/obj/item/satellite_component/science_instrument/magnetometer
	name = "magnetometer"
	icon_state = "magnetometer"
	desc = "A magnetormeter meant for a satellite. Allows collecting data from volcanism and the poles."
	component_stats = new /datum/satellite_stats/science_instrument/magnetometer()


////////////////////////////////////////
// MARK: Misc parts
////////////////////////////////////////

/obj/item/satellite_component/misc_part/solar_panel
	name = "satellite solar panels"
	icon_state = "solar"
	overlay_icon = "overlay_solar"
	desc = "A set of solar panels for a satellite."
	component_stats = new /datum/satellite_stats/misc_part/solar_panel()

/obj/item/satellite_component/misc_part/radioisotope_thermoelectric_generator
	name = "radioisotope thermoelectric generator"
	icon_state = "rtg"
	desc = "A radioisotope thermoelectric generator. Has a radioactive core that keeps producing electricity for decades. Leaks a small amount of radiation."
	component_stats = new /datum/satellite_stats/misc_part/radioisotope_thermoelectric_generator()

/obj/item/satellite_component/misc_part/radioisotope_thermoelectric_generator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inherent_radioactivity, 20, 20, 0, 2) // 20 alpha, 20 beta, with a 2 second cooldown


/obj/item/satellite_component/misc_part/electric_generator
	name = "satellite generator"
	icon_state = "generator"
	overlay_icon = "overlay_generator"
	desc = "An electric generator a satellite can use to convert fuel into electricity."
	component_stats = new /datum/satellite_stats/misc_part/electric_generator()


/obj/item/satellite_component/misc_part/power_cell
	name = "satellite power cell"
	icon_state = "powercell"
	overlay_icon = "overlay_powercell"
	desc = "A power cell for a satellite allowing it to store generated power when its not processing data."
	component_stats = new /datum/satellite_stats/misc_part/power_cell()


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

	if(overlay_icon)
		chassis.update_icon()

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
