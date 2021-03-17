/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber"

	req_one_access_txt = "24;10"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it"
	layer = GAS_SCRUBBER_LAYER
	plane = FLOOR_PLANE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 60

	can_unwrench = 1

	var/area/initial_loc

	frequency = ATMOS_VENTSCRUB

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

/obj/machinery/atmospherics/unary/vent_scrubber/on
	on = TRUE

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
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

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

/obj/machinery/atmospherics/unary/vent_scrubber/update_icon(safety = 0)
	..()

	plane = FLOOR_PLANE

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

	overlays += SSair.icon_manager.get_atmos_icon("device", , , scrubber_icon)
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

/obj/machinery/atmospherics/unary/vent_scrubber/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, radio_filter_in)
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

/obj/machinery/atmospherics/unary/vent_scrubber/proc/scrub(turf/simulated/tile)
	if(!tile || !istype(tile))
		return 0

	var/datum/gas_mixture/environment = tile.return_air()

	if(scrubbing)
		if((scrub_O2 && environment.oxygen>0.001) || (scrub_N2 && environment.nitrogen>0.001) || (scrub_CO2 && environment.carbon_dioxide>0.001) || (scrub_Toxins && environment.toxins>0.001) || (environment.sleeping_agent) || (environment.agent_b))
			var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

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

			if(removed.agent_b)
				filtered_out.agent_b = removed.agent_b
				removed.agent_b = 0

			if(scrub_N2O)
				filtered_out.sleeping_agent = removed.sleeping_agent
				removed.sleeping_agent = 0

			//Remix the resulting gases
			air_contents.merge(filtered_out)

			tile.assume_air(removed)
			tile.air_update_turf()

	else //Just siphoning all air
		if(air_contents.return_pressure()>=50*ONE_ATMOSPHERE)
			return

		var/transfer_moles = environment.total_moles()*(volume_rate/environment.volume)

		var/datum/gas_mixture/removed = tile.remove_air(transfer_moles)

		air_contents.merge(removed)
		tile.air_update_turf()

	parent.update = 1

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/hide(i) //to make the little pipe section invisible, the icon changes.
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"] != "command"))
		return FALSE

	if("power" in signal.data)
		on = text2num(signal.data["power"])
	if("power_toggle" in signal.data)
		on = !on

	if("widenet" in signal.data)
		widenet = text2num(signal.data["widenet"])
	if("toggle_widenet" in signal.data)
		widenet = !widenet

	if("scrubbing" in signal.data)
		scrubbing = text2num(signal.data["scrubbing"])
	if("toggle_scrubbing" in signal.data)
		scrubbing = !scrubbing

	if("o2_scrub" in signal.data)
		scrub_O2 = text2num(signal.data["o2_scrub"])
	if("toggle_o2_scrub" in signal.data)
		scrub_O2 = !scrub_O2

	if("n2_scrub" in signal.data)
		scrub_N2 = text2num(signal.data["n2_scrub"])
	if("toggle_n2_scrub" in signal.data)
		scrub_N2 = !scrub_N2

	if("co2_scrub" in signal.data)
		scrub_CO2 = text2num(signal.data["co2_scrub"])
	if("toggle_co2_scrub" in signal.data)
		scrub_CO2 = !scrub_CO2

	if("tox_scrub" in signal.data)
		scrub_Toxins = text2num(signal.data["tox_scrub"])
	if("toggle_tox_scrub" in signal.data)
		scrub_Toxins = !scrub_Toxins

	if("n2o_scrub" in signal.data)
		scrub_N2O = text2num(signal.data["n2o_scrub"])
	if("toggle_n2o_scrub" in signal.data)
		scrub_N2O = !scrub_N2O

	if("init" in signal.data)
		name = signal.data["init"]
		return

	if("status" in signal.data)
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_menu(mob/user, obj/item/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[ATMOS_VENTSCRUB]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag", "set_id")]</li>
	</ul>
	"}

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_topic(mob/user, list/href_list, obj/O)
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

/obj/machinery/atmospherics/unary/vent_scrubber/attack_alien(mob/user)
	if(!welded || !(do_after(user, 20, target = src)))
		return
	user.visible_message("<span class='warning'>[user] furiously claws at [src]!</span>", "<span class='notice'>You manage to clear away the stuff blocking the scrubber.</span>", "<span class='italics'>You hear loud scraping noises.</span>")
	welded = FALSE
	update_icon()
	pipe_image = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
	pipe_image.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, TRUE)

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/wrench))
		if(!(stat & NOPOWER) && on)
			to_chat(user, "<span class='danger'>You cannot unwrench this [src], turn it off first.</span>")
			return 1

	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		if(!welded)
			welded = TRUE
			user.visible_message("<span class='notice'>[user] welds [src] shut!</span>",\
				"<span class='notice'>You weld [src] shut!</span>")
		else
			welded = FALSE
			user.visible_message("<span class='notice'>[user] unwelds [src]!</span>",\
				"<span class='notice'>You unweld [src]!</span>")
		update_icon()
