/// The maximum `target_pressure` you can set on the station. Equates to about 1013.25 kPa.
#define MAX_TARGET_PRESSURE 10 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/refill_station
	name = "refill station"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "filler_oxy"
	anchored = TRUE
	density = TRUE
	resistance_flags = NONE
	idle_power_consumption = 1
	active_power_consumption = 5
	power_channel = PW_CHANNEL_ENVIRONMENT
	/// The desired pressure the refill station should be outputting into a holding tank.
	target_pressure = MAX_TARGET_PRESSURE
	can_unwrench_while_on = FALSE
	/// The current air contents of this device
	var/datum/gas_mixture/air_contents = new
	/// The tank inserted into the machine
	var/obj/item/tank/holding_tank
	/// The maximum pressure of the device
	var/maximum_pressure = 10 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/refill_station/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src
	air_contents.volume = 1000
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/refill_station/examine(mob/user)
	. = ..()
	. += "The Nanotrasen standard [src] is a vital piece of equipment for \
	ensuring a multi-species crew. By providing an easy-to-access source of refillable air of \
	various mixes, Nanotrasen aims to ensure worker productivity through the provision of breathable \
	atmospherics to their crew."
	if(holding_tank)
		. += ""
		. += "<span class='notice'>The pressure gauge on the inserted tank displays [round(holding_tank.air_contents.return_pressure())] kPa.</span>"

/obj/machinery/atmospherics/refill_station/update_overlays()
	overlays.Cut()
	if(holding_tank)
		overlays += "tank_oxy"
		var/pressure = holding_tank.air_contents.return_pressure()
		if(stat & (NOPOWER|BROKEN))
			return
		if(pressure < 1000)
			overlays += "filling_oxy"
		else
			overlays += "filled_oxy"

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

/obj/machinery/atmospherics/refill_station/oxygen/Initialize(mapload)
	. = ..()
	air_contents.set_oxygen(maximum_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/refill_station/nitrogen
	name = "nitrogen refill station"
	icon_state = "filler_nitro"

/obj/machinery/atmospherics/refill_station/nitrogen/Initialize(mapload)
	. = ..()
	air_contents.set_nitrogen(maximum_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/refill_station/nitrogen/update_overlays()
	overlays.Cut()
	if(holding_tank)
		overlays += "tank_nitro"
		var/pressure = holding_tank.air_contents.return_pressure()
		if(stat & (NOPOWER|BROKEN))
			return
		if(pressure < 1000)
			overlays += "filling_nitro"
		else
			overlays += "filled_nitro"

/obj/machinery/atmospherics/refill_station/plasma
	name = "plasma refill station"
	icon_state = "filler_plasma"

/obj/machinery/atmospherics/refill_station/plasma/Initialize(mapload)
	. = ..()
	air_contents.set_toxins(maximum_pressure * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/refill_station/plasma/update_overlays()
	overlays.Cut()
	if(holding_tank)
		overlays += "tank_plasma"
		var/pressure = holding_tank.air_contents.return_pressure()
		if(stat & (NOPOWER|BROKEN))
			return
		if(pressure < 1000)
			overlays += "filling_plasma"
		else
			overlays += "filled_plasma"

/obj/machinery/atmospherics/refill_station/plasma/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/analyzer))
		return ..()
	if(!istype(used, /obj/item/tank/internals/plasmaman))
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
