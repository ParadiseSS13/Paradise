/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = 0
	var/volume_rate = 800
	var/widenet = 0 //is this scrubber acting on the 3x3 area around it.

	volume = 750
	
	var/minrate = 0//probably useless, but whatever
	var/maxrate = 10 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on
		update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	if(holding)
		overlays += "scrubber-open"

	if(connected_port)
		overlays += "scrubber-connector"

	return

/obj/machinery/portable_atmospherics/scrubber/process()
	..()

	if(!on)
		return
	scrub(loc)
	if(widenet)
		var/turf/T = loc
		if(istype(T))
			for(var/turf/simulated/tile in T.GetAtmosAdjacentTurfs(alldir=1))
				scrub(tile)
	
/obj/machinery/portable_atmospherics/scrubber/proc/scrub(var/turf/simulated/tile)
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

		if(removed.trace_gases.len>0)
			for(var/datum/gas/trace_gas in removed.trace_gases)
				if(istype(trace_gas, /datum/gas/sleeping_agent))
					removed.trace_gases -= trace_gas
					filtered_out.trace_gases += trace_gas

		if(removed.trace_gases.len>0)
			for(var/datum/gas/trace_gas in removed.trace_gases)
				if(istype(trace_gas, /datum/gas/oxygen_agent_b))
					removed.trace_gases -= trace_gas
					filtered_out.trace_gases += trace_gas

	//Remix the resulting gases
		air_contents.merge(filtered_out)

		if(holding)
			environment.merge(removed)
		else
			tile.assume_air(removed)
			tile.air_update_turf()

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)
	
/obj/machinery/portable_atmospherics/scrubber/attack_ghost(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(var/mob/user as mob)
	ui_interact(user)
	return

/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	var/list/data[0]
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() > 0 ? air_contents.return_pressure() : 0)
	data["rate"] = round(volume_rate)
	data["minrate"] = round(minrate)
	data["maxrate"] = round(maxrate)
	data["on"] = on ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if(holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure() > 0 ? holding.air_contents.return_pressure() : 0))

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "portscrubber.tmpl", "Portable Scrubber", 480, 400, state = physical_state)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["power"])
		on = !on
		update_icon()

	if(href_list["remove_tank"])
		if(holding)
			holding.loc = loc
			holding = null

	if(href_list["volume_adj"])
		var/diff = text2num(href_list["volume_adj"])
		volume_rate = Clamp(volume_rate+diff, minrate, maxrate)

	src.add_fingerprint(usr)
	
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

/obj/machinery/portable_atmospherics/scrubber/huge/attack_hand(var/mob/user as mob)
	to_chat(usr, "<span class='warning'>You can't directly interact with this machine. Use the area atmos computer.</span>")

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "scrubber:1"
	else
		icon_state = "scrubber:0"

/obj/machinery/portable_atmospherics/scrubber/huge/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(stationary)
			to_chat(user, "<span class='warning'>The bolts are too tight for you to unscrew!</span>")
			return
		if(on)
			to_chat(user, "<span class='warning'>Turn it off first!</span>")
			return

		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return

	else if((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)
		
/obj/machinery/portable_atmospherics/scrubber/huge/stationary
	name = "Stationary Air Scrubber"
	stationary = 1