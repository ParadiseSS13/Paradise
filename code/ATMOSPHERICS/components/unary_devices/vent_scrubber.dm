/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber"

	req_one_access_txt = "24;10"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it"

	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 60

	can_unwrench = 1

	var/area/initial_loc
	var/id_tag = null
	var/frequency = ATMOS_VENTSCRUB
	var/datum/radio_frequency/radio_connection
	var/advcontrol = 0//does this device listen to the AAC?

	var/list/turf/simulated/adjacent_turfs = list()

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/scrub_O2 = 0
	var/scrub_N2 = 0
	var/scrub_CO2 = 1
	var/scrub_Toxins = 0
	var/scrub_N2O = 0

	var/volume_rate = 200
	var/widenet = 0 //is this scrubber acting on the 3x3 area around it.

	var/welded = 0

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in

	connect_types = list(1,3) //connects to regular and scrubber pipes

/obj/machinery/atmospherics/unary/vent_scrubber/New()
	..()
	icon = null
	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if(!id_tag)
		assign_uid()
		id_tag = num2text(uid)

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	if(initial_loc && frequency == ATMOS_VENTSCRUB)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	..(user)
	if(welded)
		to_chat(user, "It seems welded shut.")

/obj/machinery/atmospherics/unary/vent_scrubber/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(!on || welded)
		return 0
	if(stat & (NOPOWER|BROKEN))
		return 0

	var/amount = idle_power_usage

	if(scrubbing)
		if(scrub_CO2)
			amount += idle_power_usage
		if(scrub_Toxins)
			amount += idle_power_usage
		if(scrub_N2)
			amount += idle_power_usage
		if(scrub_N2O)
			amount += idle_power_usage
	else
		amount = active_power_usage

	if(widenet)
		amount += amount*(adjacent_turfs.len*(adjacent_turfs.len/2))
	use_power(amount, power_channel)
	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	overlays.Cut()

	var/scrubber_icon = "scrubber"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(!powered())
		scrubber_icon += "off"
	else
		scrubber_icon += "[on ? "[scrubbing ? "on" : "in"]" : "off"]"
	if(welded)
		scrubber_icon = "scrubberweld"

	overlays += GLOB.pipe_icon_manager.get_atmos_icon("device", , , scrubber_icon)
	update_pipe_image()

/obj/machinery/atmospherics/unary/vent_scrubber/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(T.intact && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)
	if(frequency != ATMOS_VENTSCRUB)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag
		name = "air Scrubber"
	else
		broadcast_status()

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data = list(
		"area" = area_uid,
		"tag" = id_tag,
		"device" = "AScr",
		"timestamp" = world.time,
		"power" = on,
		"scrubbing" = scrubbing,
		"widenet" = widenet,
		"filter_o2" = scrub_O2,
		"filter_n2" = scrub_N2,
		"filter_co2" = scrub_CO2,
		"filter_toxins" = scrub_Toxins,
		"filter_n2o" = scrub_N2O,
		"sigtype" = "status"
	)
	if(frequency == ATMOS_VENTSCRUB)
		if(!initial_loc.air_scrub_names[id_tag])
			var/new_name = "[initial_loc.name] Air Scrubber #[initial_loc.air_scrub_names.len+1]"
			initial_loc.air_scrub_names[id_tag] = new_name
			src.name = new_name
		initial_loc.air_scrub_info[id_tag] = signal.data
	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/atmos_init()
	..()
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if(frequency)
		set_frequency(frequency)
		src.broadcast_status()
	check_turfs()

/obj/machinery/atmospherics/unary/vent_scrubber/process_atmos()
	..()

	if(widenet)
		check_turfs()

	if(stat & (NOPOWER|BROKEN))
		return

	if(!node)
		on = 0

	if(welded)
		return 0
	//broadcast_status()
	if(!on)
		return 0

	scrub(loc)
	if(widenet)
		for(var/turf/simulated/tile in adjacent_turfs)
			scrub(tile)

//we populate a list of turfs with nonatmos-blocked cardinal turfs AND
//	diagonal turfs that can share atmos with *both* of the cardinal turfs
/obj/machinery/atmospherics/unary/vent_scrubber/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/T = loc
	if(istype(T))
		adjacent_turfs = T.GetAtmosAdjacentTurfs(alldir=1)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/scrub(var/turf/simulated/tile)
	if(!tile || !istype(tile))
		return 0

	var/datum/gas_mixture/environment = tile.return_air()

	if(scrubbing)
		if((scrub_O2 && environment.oxygen>0.001) || (scrub_N2 && environment.nitrogen>0.001) || (scrub_CO2 && environment.carbon_dioxide>0.001) || (scrub_Toxins && environment.toxins>0.001) || (environment.trace_gases.len>0))
			var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles() / 5

			//Take a gas sample
			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			if(isnull(removed)) //in space
				return

			//Filter it
			var/datum/gas_mixture/filtered_out = new
			filtered_out.temperature = removed.temperature
			if(scrub_O2)
				filtered_out.oxygen = removed.oxygen
				removed.oxygen = 0
			if(scrub_N2)
				filtered_out.nitrogen = removed.nitrogen
				removed.nitrogen = 0
			if(scrub_Toxins)
				filtered_out.toxins = removed.toxins
				removed.toxins = 0
			if(scrub_CO2)
				filtered_out.carbon_dioxide = removed.carbon_dioxide
				removed.carbon_dioxide = 0

			if(removed.trace_gases.len>0)
				for(var/datum/gas/trace_gas in removed.trace_gases)
					if(istype(trace_gas, /datum/gas/oxygen_agent_b))
						removed.trace_gases -= trace_gas
						filtered_out.trace_gases += trace_gas
					else if(istype(trace_gas, /datum/gas/sleeping_agent) && scrub_N2O)
						removed.trace_gases -= trace_gas
						filtered_out.trace_gases += trace_gas

			//Remix the resulting gases
			air_contents.merge(filtered_out)

			tile.assume_air(removed)
			tile.air_update_turf()

	else //Just siphoning all air
		if(air_contents.return_pressure()>=50*ONE_ATMOSPHERE)
			return

		var/transfer_moles = environment.total_moles()*(volume_rate/environment.volume) / 5

		var/datum/gas_mixture/removed = tile.remove_air(transfer_moles)

		air_contents.merge(removed)
		tile.air_update_turf()

	parent.update = 1

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command") || (signal.data["advcontrol"] && !advcontrol))
		return 0

	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])
	if(signal.data["power_toggle"] != null)
		on = !on

	if("widenet" in signal.data)
		widenet = text2num(signal.data["widenet"])
	if("toggle_widenet" in signal.data)
		widenet = !widenet

	if(signal.data["scrubbing"] != null)
		scrubbing = text2num(signal.data["scrubbing"])
	if(signal.data["toggle_scrubbing"])
		scrubbing = !scrubbing

	if(signal.data["o2_scrub"] != null)
		scrub_O2 = text2num(signal.data["o2_scrub"])
	if(signal.data["toggle_o2_scrub"])
		scrub_O2 = !scrub_O2

	if(signal.data["n2_scrub"] != null)
		scrub_N2 = text2num(signal.data["n2_scrub"])
	if(signal.data["toggle_n2_scrub"])
		scrub_N2 = !scrub_N2

	if(signal.data["co2_scrub"] != null)
		scrub_CO2 = text2num(signal.data["co2_scrub"])
	if(signal.data["toggle_co2_scrub"])
		scrub_CO2 = !scrub_CO2

	if(signal.data["tox_scrub"] != null)
		scrub_Toxins = text2num(signal.data["tox_scrub"])
	if(signal.data["toggle_tox_scrub"])
		scrub_Toxins = !scrub_Toxins

	if(signal.data["n2o_scrub"] != null)
		scrub_N2O = text2num(signal.data["n2o_scrub"])
	if(signal.data["toggle_n2o_scrub"])
		scrub_N2O = !scrub_N2O

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_menu(var/mob/user,var/obj/item/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[ATMOS_VENTSCRUB]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag", "set_id")]</li>
		<li><b>AAC Acces:</b> <a href="?src=[UID()];toggleadvcontrol=1">[advcontrol ? "Allowed" : "Blocked"]</a>
	</ul>
	"}

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_topic(var/mob/user, var/list/href_list, var/obj/O)
	if("toggleadvcontrol" in href_list)
		advcontrol = !advcontrol
		return TRUE

	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(!newid)
			return

		if(frequency == ATMOS_VENTSCRUB)
			initial_loc.air_scrub_info -= id_tag
			initial_loc.air_scrub_names -= id_tag

		id_tag = newid
		broadcast_status()

		return TRUE

	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>Now welding the scrubber.</span>")
			if(do_after(user, 20 * WT.toolspeed, target = src))
				if(!src || !WT.isOn()) return
				playsound(get_turf(src), WT.usesound, 50, 1)
				if(!welded)
					user.visible_message("[user] welds the scrubber shut.", "You weld the vent scrubber.", "You hear welding.")
					welded = 1
					update_icon()
				else
					user.visible_message("[user] unwelds the scrubber.", "You unweld the scrubber.", "You hear welding.")
					welded = 0
					update_icon()
			else
				to_chat(user, "<span class='notice'>The welding tool needs to be on to start this task.</span>")
			return 1
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return 1
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/wrench))
		if(!(stat & NOPOWER) && on)
			to_chat(user, "<span class='danger'>You cannot unwrench this [src], turn it off first.</span>")
			return 1

	return ..()
