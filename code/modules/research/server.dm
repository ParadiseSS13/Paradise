/obj/machinery/r_n_d/server
	name = "RnD Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-off"
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null
	/// Is this server currently working
	var/working = TRUE
	/// How many process cycles to wait before producing heat
	var/heat_cycle_delay = 5
	/// Counter of how many process cycles we are in before heating again
	var/heat_cycle_counter = 0
	/// Pointgen scale - scales based on the scanning module rating
	var/pointgen_scale = 1
	/// Points to generate per cycle
	var/points_per_cycle = 20
	/// How much heat to throw into the room
	var/heating_power = 50000


/obj/machinery/r_n_d/server/Initialize(mapload)
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/r_n_d/server/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.servers += UID()


/obj/machinery/r_n_d/server/RefreshParts()
	var/gain = 0
	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		gain = SM.rating

	pointgen_scale = (gain / 2) // Doubles with bluespace parts


/obj/machinery/r_n_d/server/Destroy()
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(RNC)
		// Unlink us
		RNC.servers -= UID()

	return ..()


/obj/machinery/r_n_d/server/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "RD-server-off"
	else
		icon_state = "RD-server-on"


/obj/machinery/r_n_d/server/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/r_n_d/server/process()
	if(prob(3))
		playsound(loc, "computer_ambience", 50, 1)

	if(!network_manager_uid)
		return

	// See if we have a host
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(!RNC)
		network_manager_uid = null
		return null

	// ITS MATHS TIME
	var/pointscale_tempdiff = 0

	var/datum/gas_mixture/environment = loc.return_air()
	switch(environment.temperature)
		if(0 to T0C) // -273.15C to 0C
			pointscale_tempdiff = 1 // Full efficiency
		if(T0C to (T0C + 5))
			pointscale_tempdiff = 0.5 // Half efficiency
		if((T0C + 5) to (T0C + 15))
			pointscale_tempdiff = 0.1 // Shit efficiency - servers like the cold!

		// If the server temperature is >15C, it wont do any work

	// This needs tweaks
	var/points_to_generate = (points_per_cycle * pointgen_scale) * pointscale_tempdiff
	RNC.research_files.research_points += points_to_generate

	heat_cycle_counter++

	// Warm the room
	if(heat_cycle_counter > heat_cycle_delay)
		produce_heat(100)
		heat_cycle_counter = 0


/obj/machinery/r_n_d/server/proc/produce_heat(heat_amt)
	if(!(stat & (NOPOWER|BROKEN))) // Blatantly stolen from space heater.
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt + T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature * heat_capacity + heating_power) / heat_capacity, 1000)

				env.merge(removed)
				air_update_turf()


/obj/machinery/r_n_d/server/proc/unlink()
	network_manager_uid = null
	SStgui.update_uis(src)


/obj/machinery/r_n_d/server/station
	autolink_id = "station_rnd"

#warn needs TGUI for linkage and other stuff, make sure only links to this zlevle
