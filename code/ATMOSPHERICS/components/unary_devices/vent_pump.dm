#define EXTERNAL_PRESSURE_BOUND ONE_ATMOSPHERE
#define INTERNAL_PRESSURE_BOUND 0
#define PRESSURE_CHECKS 1

/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_vent"

	name = "air vent"
	desc = "Has a valve and pump attached to it"
	use_power = IDLE_POWER_USE

	layer = GAS_SCRUBBER_LAYER

	can_unwrench = 1
	var/open = 0

	var/area/initial_loc
	var/area_uid
	var/id_tag = null

	req_one_access_txt = "24;10"

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound = INTERNAL_PRESSURE_BOUND

	var/pressure_checks = PRESSURE_CHECKS
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	// Used when handling incoming radio signals requesting default settings
	var/external_pressure_bound_default = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound_default = INTERNAL_PRESSURE_BOUND
	var/pressure_checks_default = PRESSURE_CHECKS

	var/welded = 0 // Added for aliens -- TLE
	var/weld_burst_pressure = 50 * ONE_ATMOSPHERE	//the (internal) pressure at which welded covers will burst off

	var/frequency = ATMOS_VENTSCRUB
	var/datum/radio_frequency/radio_connection
	Mtoollink = 1
	var/advcontrol = 0//does this device listen to the AAC

	var/radio_filter_out
	var/radio_filter_in

	connect_types = list(1,2) //connects to regular and supply pipes

/obj/machinery/atmospherics/unary/vent_pump/on
	on = 1
	icon_state = "map_vent_out"

/obj/machinery/atmospherics/unary/vent_pump/siphon
	pump_direction = 0

/obj/machinery/atmospherics/unary/vent_pump/siphon/on
	on = 1
	icon_state = "map_vent_in"

/obj/machinery/atmospherics/unary/vent_pump/New()
	..()
	GLOB.all_vent_pumps += src
	icon = null
	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if(!id_tag)
		assign_uid()
		id_tag = num2text(uid)

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = EQUIP

/obj/machinery/atmospherics/unary/vent_pump/high_volume/New()
	..()
	air_contents.volume = 1000

/obj/machinery/atmospherics/unary/vent_pump/update_icon(safety = 0)
	..()

	plane = FLOOR_PLANE

	if(!check_icon_cache())
		return

	overlays.Cut()

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(T.intact && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(welded)
		vent_icon += "weld"
	else if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[pump_direction ? "out" : "in"]" : "off"]"

	overlays += GLOB.pipe_icon_manager.get_atmos_icon("device", , , vent_icon)

	update_pipe_image()

/obj/machinery/atmospherics/unary/vent_pump/update_underlays()
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

/obj/machinery/atmospherics/unary/vent_pump/hide()
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_pump/process_atmos()
	..()
	if((stat & (NOPOWER|BROKEN)))
		return 0
	if(!node)
		on = 0
	//broadcast_status() // from now air alarm/control computer should request update purposely --rastaf0
	if(!on)
		return 0

	if(welded)
		if(air_contents.return_pressure() >= weld_burst_pressure && prob(5))	//the weld is on but the cover is welded shut, can it withstand the internal pressure?
			visible_message("<span class='danger'>The welded cover of [src] bursts open!</span>")
			for(var/mob/M in range(1, src))
				unsafe_pressure_release(M, air_contents.return_pressure())	//let's send everyone flying
			welded = FALSE
			update_icon()
		return 0

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(pump_direction) //internal -> external
		var/pressure_delta = 10000

		if(pressure_checks&1)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&2)
			pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

		if(pressure_delta > 0.5)
			if(air_contents.temperature > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				loc.assume_air(removed)
				air_update_turf()

				parent.update = 1

	else //external -> internal
		var/pressure_delta = 10000
		if(pressure_checks&1)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks&2)
			pressure_delta = min(pressure_delta, (internal_pressure_bound - air_contents.return_pressure()))

		if(pressure_delta > 0.5)
			if(environment.temperature > 0)
				var/transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
				if(isnull(removed)) //in space
					return

				air_contents.merge(removed)
				air_update_turf()

				parent.update = 1

	return 1

//Radio remote control

/obj/machinery/atmospherics/unary/vent_pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency,radio_filter_in)
	if(frequency != ATMOS_VENTSCRUB)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
		name = "vent pump"
	else
		broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"area" = src.area_uid,
		"tag" = src.id_tag,
		"device" = "AVP",
		"power" = on,
		"direction" = pump_direction?("release"):("siphon"),
		"checks" = pressure_checks,
		"internal" = internal_pressure_bound,
		"external" = external_pressure_bound,
		"timestamp" = world.time,
		"sigtype" = "status"
	)
	if(frequency == ATMOS_VENTSCRUB)
		if(!initial_loc.air_vent_names[id_tag])
			var/new_name = "[initial_loc.name] Vent Pump #[initial_loc.air_vent_names.len+1]"
			initial_loc.air_vent_names[id_tag] = new_name
			src.name = new_name
		initial_loc.air_vent_info[id_tag] = signal.data

	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1


/obj/machinery/atmospherics/unary/vent_pump/atmos_init()
	..()

	//some vents work his own special way
	radio_filter_in = frequency==ATMOS_VENTSCRUB?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==ATMOS_VENTSCRUB?(RADIO_TO_AIRALARM):null
	if(frequency)
		set_frequency(frequency)
		src.broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/atmospherics/unary/vent_pump/receive_signal([signal.debug_print()])")
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command") || (signal.data["advcontrol"] && !advcontrol))
		return 0

	if(signal.data["purge"] != null)
		pressure_checks &= ~1
		pump_direction = 0

	if(signal.data["stabilize"] != null)
		pressure_checks |= 1
		pump_direction = 1

	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["checks"] != null)
		if(signal.data["checks"] == "default")
			pressure_checks = pressure_checks_default
		else
			pressure_checks = text2num(signal.data["checks"])

	if(signal.data["checks_toggle"] != null)
		pressure_checks = (pressure_checks?0:3)

	if(signal.data["direction"] != null)
		pump_direction = text2num(signal.data["direction"])

	if(signal.data["set_internal_pressure"] != null)
		if(signal.data["set_internal_pressure"] == "default")
			internal_pressure_bound = internal_pressure_bound_default
		else
			internal_pressure_bound = between(
				0,
				text2num(signal.data["set_internal_pressure"]),
				ONE_ATMOSPHERE*50
			)

	if(signal.data["set_external_pressure"] != null)
		if(signal.data["set_external_pressure"] == "default")
			external_pressure_bound = external_pressure_bound_default
		else
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE*50
			)

	if(signal.data["adjust_internal_pressure"] != null)
		internal_pressure_bound = between(
			0,
			internal_pressure_bound + text2num(signal.data["adjust_internal_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["adjust_external_pressure"] != null)


		external_pressure_bound = between(
			0,
			external_pressure_bound + text2num(signal.data["adjust_external_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		spawn(2)
			broadcast_status()
		return //do not update_icon

		//log_admin("DEBUG \[[world.timeofday]\]: vent_pump/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_pump/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_pump/attack_alien(mob/user)
	if(!welded || !(do_after(user, 20, target = src)))
		return
	user.visible_message("<span class='warning'>[user] furiously claws at [src]!</span>", "<span class='notice'>You manage to clear away the stuff blocking the vent.</span>", "<span class='italics'>You hear loud scraping noises.</span>")
	welded = FALSE
	update_icon()
	pipe_image = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
	pipe_image.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, TRUE)

/obj/machinery/atmospherics/unary/vent_pump/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver))
		if(!welded)
			if(open)
				to_chat(user, "<span class='notice'>Now closing the vent.</span>")
				if(do_after(user, 20 * W.toolspeed, target = src))
					playsound(loc, W.usesound, 100, 1)
					open = 0
					user.visible_message("[user] screwdrivers the vent shut.", "You screwdriver the vent shut.", "You hear a screwdriver.")
			else
				to_chat(user, "<span class='notice'>Now opening the vent.</span>")
				if(do_after(user, 20 * W.toolspeed, target = src))
					playsound(loc, W.usesound, 100, 1)
					open = 1
					user.visible_message("[user] screwdrivers the vent open.", "You screwdriver the vent open.", "You hear a screwdriver.")
		return
	if(istype(W, /obj/item/paper))
		if(!welded)
			if(open)
				user.drop_item(W)
				W.forceMove(src)
			if(!open)
				to_chat(user, "You can't shove that down there when it is closed")
		else
			to_chat(user, "The vent is welded.")
		return 1
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/wrench))
		if(!(stat & NOPOWER) && on)
			to_chat(user, "<span class='danger'>You cannot unwrench this [src], turn it off first.</span>")
			return 1

	return ..()

/obj/machinery/atmospherics/unary/vent_pump/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		if(!welded)
			welded = TRUE
			visible_message("<span class='notice'>[user] welds [src] shut!</span>",\
				"<span class='notice'>You weld [src] shut!</span>")
		else
			welded = FALSE
			visible_message("<span class='notice'>[user] unwelds [src]!</span>",\
				"<span class='notice'>You unweld [src]!</span>")
		update_icon()


/obj/machinery/atmospherics/unary/vent_pump/attack_hand()
	if(!welded)
		if(open)
			for(var/obj/item/W in src)
				if(istype(W, /obj/item/pipe))
					continue
				W.forceMove(get_turf(src))


/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/unary/vent_pump/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()


/obj/machinery/atmospherics/unary/vent_pump/interact(mob/user as mob)
	update_multitool_menu(user)

/obj/machinery/atmospherics/unary/vent_pump/multitool_menu(var/mob/user,var/obj/item/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[ATMOS_VENTSCRUB]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</li>
		<li><b>AAC Acces:</b> <a href="?src=[UID()];toggleadvcontrol=1">[advcontrol ? "Allowed" : "Blocked"]</a>
		</ul>
	"}

/obj/machinery/atmospherics/unary/vent_pump/multitool_topic(var/mob/user, var/list/href_list, var/obj/O)
	if("toggleadvcontrol" in href_list)
		advcontrol = !advcontrol
		return TRUE

	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src.id_tag) as null|text), 1, MAX_MESSAGE_LEN)
		if(!newid)
			return
		if(frequency == ATMOS_VENTSCRUB)
			initial_loc.air_vent_info -= id_tag
			initial_loc.air_vent_names -= id_tag

		id_tag = newid
		broadcast_status()

		return TRUE

	return ..()

/obj/machinery/atmospherics/unary/vent_pump/Destroy()
	GLOB.all_vent_pumps -= src
	if(initial_loc)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()
