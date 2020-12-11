
#define MAX_RATE 10 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = TRUE
	volume = 750
	/// Whether the scrubber is switched on or off.
	var/on = FALSE
	/// The volume of gas that can be scrubbed every time `process_atmos()` is called (0.5 seconds).
	var/volume_rate = 101.325
	/// Is this scrubber acting on the 3x3 area around it.
	var/widenet = FALSE

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on
		update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	if(holding)
		overlays += "scrubber-open"

	if(connected_port)
		overlays += "scrubber-connector"

	return

/obj/machinery/portable_atmospherics/scrubber/process_atmos()
	..()

	if(!on)
		return
	scrub(loc)
	if(widenet)
		var/turf/T = loc
		if(istype(T))
			for(var/turf/simulated/tile in T.GetAtmosAdjacentTurfs(alldir=1))
				scrub(tile)

/obj/machinery/portable_atmospherics/scrubber/proc/scrub(turf/simulated/tile)
	var/datum/gas_mixture/environment
	if(holding)
		environment = holding.air_contents
	else
		environment = tile.return_air()
	var/transfer_moles = min(1,volume_rate/environment.volume)*environment.total_moles()

	//Take a gas sample
	var/datum/gas_mixture/removed
	if(holding)
		removed = environment.remove(transfer_moles)
	else
		removed = loc.remove_air(transfer_moles)

	//Filter it
	if(removed)
		var/datum/gas_mixture/filtered_out = new

		filtered_out.temperature = removed.temperature


		filtered_out.toxins = removed.toxins
		removed.toxins = 0

		filtered_out.carbon_dioxide = removed.carbon_dioxide
		removed.carbon_dioxide = 0

		filtered_out.sleeping_agent = removed.sleeping_agent
		removed.sleeping_agent = 0

		filtered_out.agent_b = removed.agent_b
		removed.agent_b = 0

	//Remix the resulting gases
		air_contents.merge(filtered_out)

		if(holding)
			environment.merge(removed)
		else
			tile.assume_air(removed)
			tile.air_update_turf()

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(mob/user)
	ui_interact(user)
	return

/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PortableScrubber", "Portable Scrubber", 433, 346, master_ui, state)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/portable_atmospherics/scrubber/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"port_connected" = connected_port ? TRUE : FALSE,
		"max_rate" = MAX_RATE,
		"rate" = round(volume_rate, 0.001),
		"tank_pressure" = air_contents.return_pressure() > 0 ? round(air_contents.return_pressure(), 0.001) : 0
	)
	if(holding)
		data["has_holding_tank"] = TRUE
		data["holding_tank"] = list("name" = holding.name, "tank_pressure" = holding.air_contents.return_pressure() > 0 ? round(holding.air_contents.return_pressure(), 0.001) : 0)
	else
		data["has_holding_tank"] = FALSE

	return data

/obj/machinery/portable_atmospherics/scrubber/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
			update_icon()
			return TRUE

		if("remove_tank")
			if(holding)
				holding.forceMove(get_turf(src))
				holding = null
			update_icon()
			return TRUE

		if("set_rate")
			volume_rate = clamp(text2num(params["rate"]), 0, MAX_RATE)
			return TRUE

	add_fingerprint(usr)

/obj/machinery/portable_atmospherics/scrubber/huge
	name = "Huge Air Scrubber"
	icon_state = "scrubber:0"
	anchored = 1
	volume = 50000
	volume_rate = 5000
	widenet = 1

	var/global/gid = 1
	var/id = 0
	var/stationary = 0

/obj/machinery/portable_atmospherics/scrubber/huge/New()
	..()
	id = gid
	gid++

	name = "[name] (ID [id])"

/obj/machinery/portable_atmospherics/scrubber/huge/attack_hand(mob/user)
	to_chat(usr, "<span class='warning'>You can't directly interact with this machine. Use the area atmos computer.</span>")

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon()
	overlays = 0

	if(on)
		icon_state = "scrubber:1"
	else
		icon_state = "scrubber:0"

/obj/machinery/portable_atmospherics/scrubber/huge/attackby(obj/item/W, mob/user, params)
	if((istype(W, /obj/item/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)
		return
	return ..()

/obj/machinery/portable_atmospherics/scrubber/huge/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(stationary)
		to_chat(user, "<span class='warning'>The bolts are too tight for you to unscrew!</span>")
		return
	if(on)
		to_chat(user, "<span class='warning'>Turn it off first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] [src].</span>")

/obj/machinery/portable_atmospherics/scrubber/huge/stationary
	name = "Stationary Air Scrubber"
	stationary = 1

#undef MAX_RATE
