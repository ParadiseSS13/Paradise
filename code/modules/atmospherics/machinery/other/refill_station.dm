/// The maximum `target_pressure` you can set on the station. Equates to about 1013.25 kPa.
#define MAX_TARGET_PRESSURE 10 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/refill_station
	name = "refill station"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "filler_oxygen"
	density = TRUE
	resistance_flags = NONE
	idle_power_consumption = 1
	active_power_consumption = 5
	/// The desired pressure the refill station should be outputting into a holding tank.
	target_pressure = MAX_TARGET_PRESSURE
	can_unwrench_while_on = FALSE
	/// The current air contents of this device
	var/datum/gas_mixture/air_contents = new
	/// The tank inserted into the machine
	var/obj/item/tank/holding_tank
	/// The maximum pressure of the device
	var/maximum_pressure = 10 * ONE_ATMOSPHERE
	/// Type of atmos refilled. Used in examines
	var/refill_type = "oxygen"
	/// Color of the station's environmental lighting
	var/light_color_on
	/// Light power of the station's environmental lighting
	var/light_power_on = 1.4

/obj/machinery/atmospherics/refill_station/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src
	air_contents.volume = 1000
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/refill_station/examine(mob/user)
	. = ..()
	. += "The Nanotrasen standard refill station is a vital piece of equipment for \
	ensuring a multi-species crew. By providing an easy-to-access source of refillable [refill_type], \
	Nanotrasen aims to ensure worker productivity through the provision of breathable \
	atmospherics to their crew."
	if(holding_tank)
		. += ""
		. += "<span class='notice'>The pressure gauge on the inserted tank displays [round(holding_tank.air_contents.return_pressure())] kPa.</span>"

/obj/machinery/atmospherics/refill_station/update_overlays()
	. = ..()
	if(stat & (NOPOWER|BROKEN))
		return

	if(holding_tank)
		. += "tank_[refill_type]"
		var/pressure = holding_tank.air_contents.return_pressure()
		if(pressure < 1000)
			. += "filling_[refill_type]"
			. += emissive_appearance(icon, "filling_meter_lightmask")
		else
			. += "filled_[refill_type]"
			. += emissive_appearance(icon, "filled_meter_lightmask")

	. += emissive_appearance(icon, "filler_[refill_type]_lightmask")

/obj/machinery/atmospherics/refill_station/power_change()
	. = ..()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(MINIMUM_USEFUL_LIGHT_RANGE, light_power_on, light_color_on)

	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/refill_station/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/refill_station/proc/replace_tank(mob/living/user, obj/item/tank/new_tank)
	if(!holding_tank)
		return FALSE
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(holding_tank)
	holding_tank = new_tank
	if(!(stat & NOPOWER))
		on = TRUE
		change_power_mode(ACTIVE_POWER_USE)
	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/atmospherics/refill_station/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/analyzer))
		return ..()
	if(!istype(used, /obj/item/tank))
		to_chat(user, "<span class='warning'>[used] does not fit in [src]'s tank slot.</span>")
		return ITEM_INTERACT_COMPLETE
	if(!(stat & BROKEN))
		if(used.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/tank/new_tank = used
		to_chat(user, "<span class='notice'>[holding_tank ? "In one smooth motion you pop [holding_tank] out of [src]'s connector and replace it with [new_tank]" : "You insert [new_tank] into [src]"].</span>")
		investigate_log("[key_name(user)] started a transfer into [new_tank] at [src].<br>", "atmos")
		if(holding_tank)
			replace_tank(user, new_tank)
		else
			holding_tank = new_tank
			if(!(stat & NOPOWER))
				on = TRUE
				change_power_mode(ACTIVE_POWER_USE)
		update_icon(UPDATE_OVERLAYS)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/atmospherics/refill_station/attack_hand(mob/living/user)
	if(!holding_tank)
		to_chat(user, "<span class='warning'>There is no tank to remove.</span>")
		return FINISH_ATTACK
	user.put_in_hands(holding_tank)
	holding_tank = null
	on = FALSE
	change_power_mode(IDLE_POWER_USE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/refill_station/process_atmos()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	var/datum/milla_safe/refill_station_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/refill_station_process

/datum/milla_safe/refill_station_process/on_run(obj/machinery/atmospherics/refill_station/refill_station)
	// Refill the holding tank
	if(!refill_station.on)
		return
	if(!refill_station.holding_tank)
		return
	var/datum/gas_mixture/holding_environment
	holding_environment = refill_station.holding_tank.air_contents

	var/pressure_delta = refill_station.target_pressure - holding_environment.return_pressure()
	// Can not have a pressure delta that would cause environment pressure > tank pressure

	var/transfer_moles = 0
	transfer_moles = pressure_delta * holding_environment.volume / (refill_station.air_contents.temperature() * R_IDEAL_GAS_EQUATION)
	// Make it take some time. Max half a mole per cycle.
	transfer_moles = min(transfer_moles, 0.5)
	// Actually transfer the gas
	var/datum/gas_mixture/removed = refill_station.air_contents.remove(transfer_moles)
	holding_environment.merge(removed)
	refill_station.update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/refill_station/oxygen
	name = "oxygen refill station"
	light_color_on = "#587ad0"
	light_power_on = 2 // slightly stronger because blue is a little less intense

/obj/machinery/atmospherics/refill_station/oxygen/Initialize(mapload)
	. = ..()
	air_contents.set_oxygen(maximum_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/refill_station/nitrogen
	name = "nitrogen refill station"
	icon_state = "filler_nitrogen"
	refill_type = "nitrogen"
	light_color_on = "#e57252"

/obj/machinery/atmospherics/refill_station/nitrogen/Initialize(mapload)
	. = ..()
	air_contents.set_nitrogen(maximum_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/refill_station/plasma
	name = "plasma refill station"
	icon_state = "filler_plasma"
	refill_type = "plasma"
	light_color_on = "#b985cd"
	/// What types of tanks can the plasma refill station accept?
	var/list/accepted_types = list(/obj/item/tank/internals/emergency_oxygen/plasma, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/plasmaman/belt)

/obj/machinery/atmospherics/refill_station/plasma/Initialize(mapload)
	. = ..()
	air_contents.set_toxins(maximum_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))
	accepted_types = typecacheof(accepted_types)

/obj/machinery/atmospherics/refill_station/plasma/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/analyzer))
		return ..()
	if(!is_type_in_typecache(used, accepted_types))
		to_chat(user, "<span class='warning'>[used] does not fit in [src]'s tank slot.</span>")
		return ITEM_INTERACT_COMPLETE
	if(!(stat & BROKEN))
		if(used.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/tank/new_tank = used
		to_chat(user, "<span class='notice'>[holding_tank ? "In one smooth motion you pop [holding_tank] out of [src]'s connector and replace it with [new_tank]" : "You insert [new_tank] into [src]"].</span>")
		investigate_log("[key_name(user)] started a transfer into [new_tank] at [src].<br>", "atmos")
		if(holding_tank)
			replace_tank(user, new_tank)
		else
			holding_tank = new_tank
			if(!(stat & NOPOWER))
				on = TRUE
				change_power_mode(ACTIVE_POWER_USE)
		update_icon(UPDATE_OVERLAYS)
	return ITEM_INTERACT_COMPLETE

#undef MAX_TARGET_PRESSURE
