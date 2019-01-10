/obj/machinery/portable_atmospherics/pump
	name = "Portable Air Pump"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "psiphon:0"
	density = 1

	var/on = 0
	var/direction_out = 0 //0 = siphoning, 1 = releasing
	var/target_pressure = 100

	var/pressuremin = 0
	var/pressuremax = 10 * ONE_ATMOSPHERE

	volume = 1000

/obj/machinery/portable_atmospherics/pump/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "psiphon:1"
	else
		icon_state = "psiphon:0"

	if(holding)
		overlays += "siphon-open"

	if(connected_port)
		overlays += "siphon-connector"

	return

/obj/machinery/portable_atmospherics/pump/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on

	if(prob(100/severity))
		direction_out = !direction_out

	target_pressure = rand(0,1300)
	update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/pump/process_atmos()
	..()
	if(on)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()
		if(direction_out)
			var/pressure_delta = target_pressure - environment.return_pressure()
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(air_contents.temperature > 0)
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				if(holding)
					environment.merge(removed)
				else
					loc.assume_air(removed)
					air_update_turf()
		else
			var/pressure_delta = target_pressure - air_contents.return_pressure()
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(environment.temperature > 0)
				transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed
				if(holding)
					removed = environment.remove(transfer_moles)
				else
					removed = loc.remove_air(transfer_moles)
					air_update_turf()

				air_contents.merge(removed)
		//src.update_icon()

	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/pump/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/pump/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_ghost(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/portable_atmospherics/pump/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = physical_state)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "portpump.tmpl", "Portable Pump", 480, 400, state = state)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/pump/ui_data(mob/user, ui_key = "main", datum/topic_state/state = physical_state)
	var/data[0]
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() > 0 ? air_contents.return_pressure() : 0)
	data["targetpressure"] = round(target_pressure)
	data["pump_dir"] = direction_out
	data["minpressure"] = round(pressuremin)
	data["maxpressure"] = round(pressuremax)
	data["on"] = on ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if(holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure() > 0 ? holding.air_contents.return_pressure() : 0))

	return data

/obj/machinery/portable_atmospherics/pump/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["power"])
		on = !on
		update_icon()

	if(href_list["direction"])
		direction_out = !direction_out

	if(href_list["remove_tank"])
		if(holding)
			on = FALSE
			holding.loc = loc
			holding = null
		update_icon()

	if(href_list["pressure_adj"])
		var/diff = text2num(href_list["pressure_adj"])
		target_pressure = Clamp(target_pressure+diff, pressuremin, pressuremax)
		update_icon()

	src.add_fingerprint(usr)
