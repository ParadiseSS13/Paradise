/obj/machinery/atmospherics/trinary/filter
	icon = 'icons/atmos/filter.dmi'
	icon_state = "map"

	can_unwrench = 1

	name = "gas filter"

	var/temp = null // -- TLE

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
-1: Nothing
 0: Toxins: Toxins, Oxygen Agent B
 1: Oxygen: Oxygen ONLY
 2: Nitrogen: Nitrogen ONLY
 3: Carbon Dioxide: Carbon Dioxide ONLY
 4: Sleeping Agent (N2O)
*/

	var/frequency = 0
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/trinary/filter/flipped
	icon_state = "mmap"
	flipped = 1

/obj/machinery/atmospherics/trinary/filter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(flipped)
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += on ? "on" : "off"
	else
		icon_state += "off"
		on = 0

/obj/machinery/atmospherics/trinary/filter/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(flipped)
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/filter/process()
	if(!..() || !on)
		return 0

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure || air2.return_pressure() >= target_pressure )
		//No need to mix if target is already full!
		return 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles

	if(air1.temperature > 0)
		transfer_moles = pressure_delta*air3.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return
		var/datum/gas_mixture/filtered_out = new
		filtered_out.temperature = removed.temperature

		switch(filter_type)
			if(0) //removing hydrocarbons
				filtered_out.toxins = removed.toxins
				removed.toxins = 0

				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

			if(1) //removing O2
				filtered_out.oxygen = removed.oxygen
				removed.oxygen = 0

			if(2) //removing N2
				filtered_out.nitrogen = removed.nitrogen
				removed.nitrogen = 0

			if(3) //removing CO2
				filtered_out.carbon_dioxide = removed.carbon_dioxide
				removed.carbon_dioxide = 0

			if(4)//removing N2O
				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/sleeping_agent))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

			else
				filtered_out = null


		air2.merge(filtered_out)
		air3.merge(removed)

	parent2.update = 1

	parent3.update = 1

	parent1.update = 1

	return 1

/obj/machinery/atmospherics/trinary/filter/initialize()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/trinary/filter/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(!src.allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	var/dat
	var/current_filter_type
	switch(filter_type)
		if(0)
			current_filter_type = "Toxins"
		if(1)
			current_filter_type = "Oxygen"
		if(2)
			current_filter_type = "Nitrogen"
		if(3)
			current_filter_type = "Carbon Dioxide"
		if(4)
			current_filter_type = "Nitrous Oxide"
		if(-1)
			current_filter_type = "Nothing"
		else
			current_filter_type = "ERROR - Report this bug to the admin, please!"

	dat += {"
			<b>Power: </b><a href='?src=[UID()];power=1'>[on?"On":"Off"]</a><br>
			<b>Filtering: </b>[current_filter_type]<br><HR>
			<h4>Set Filter Type:</h4>
			<A href='?src=[UID()];filterset=0'>Toxins</A><BR>
			<A href='?src=[UID()];filterset=1'>Oxygen</A><BR>
			<A href='?src=[UID()];filterset=2'>Nitrogen</A><BR>
			<A href='?src=[UID()];filterset=3'>Carbon Dioxide</A><BR>
			<A href='?src=[UID()];filterset=4'>Nitrous Oxide</A><BR>
			<A href='?src=[UID()];filterset=-1'>Nothing</A><BR>
			<HR><B>Desirable output pressure:</B>
			[src.target_pressure]kPa | <a href='?src=[UID()];set_press=1'>Change</a>
			"}

	var/datum/browser/popup = new(user, "atmo_filter", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "atmo_filter")
	return

/obj/machinery/atmospherics/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["filterset"])
		src.filter_type = text2num(href_list["filterset"])
	if(href_list["temp"])
		src.temp = null
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
	if(href_list["power"])
		on=!on
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return
