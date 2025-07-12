#define EXTERNAL_PRESSURE_BOUND ONE_ATMOSPHERE
#define INTERNAL_PRESSURE_BOUND 0

/obj/machinery/atmospherics/unary/vent_pump
	name = "air vent"
	desc = "Has a valve and pump attached to it."
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_vent"
	power_state = IDLE_POWER_USE
	plane = FLOOR_PLANE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET
	can_unwrench = TRUE

	/// Is the vent open to put a piece of paper in it
	var/open = FALSE // A living relic of papercult

	var/area/initial_loc

	/// If false, siphons instead of releasing air
	var/releasing = TRUE
	var/max_transfer_joules = 200 /*kPa*/ * 2 * ONE_ATMOSPHERE

	var/external_pressure_bound = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound = INTERNAL_PRESSURE_BOUND

	/// What do we check when releasing/siphoning air - internal or external pressure
	var/pressure_checks = ONLY_CHECK_EXT_PRESSURE

	/// Is this vent welded shut
	var/welded = FALSE
	/// How much pressure does there have to be in the pipe to burst the vent open?
	var/weld_burst_pressure = 50 * ONE_ATMOSPHERE

	connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SUPPLY) //connects to regular and supply pipes

/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This pumps the contents of the attached pipenet out into the atmosphere. Can be controlled from an Air Alarm.</span>"
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/unary/vent_pump/on
	on = TRUE
	icon_state = "map_vent_out"

/obj/machinery/atmospherics/unary/vent_pump/siphon
	releasing = FALSE
	external_pressure_bound = 0

/obj/machinery/atmospherics/unary/vent_pump/siphon/on
	on = TRUE
	icon_state = "map_vent_in"

/obj/machinery/atmospherics/unary/vent_pump/Initialize(mapload)
	. = ..()
	GLOB.all_vent_pumps += src
	icon = null
	initial_loc = get_area(loc)
	if(!autolink_id) // Autolink vents are externally managed, and should not show up on the air alarm
		initial_loc.vents += src
		name = "[initial_loc.name] Vent Pump #[length(initial_loc.vents)]"

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = PW_CHANNEL_EQUIPMENT

/obj/machinery/atmospherics/unary/vent_pump/high_volume/Initialize(mapload)
	. = ..()
	air_contents.volume = 1000

/obj/machinery/atmospherics/unary/vent_pump/update_overlays()
	. = ..()
	plane = FLOOR_PLANE
	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(welded)
		vent_icon += "weld"
	else if(!has_power())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[releasing ? "out" : "in"]" : "off"]"

	. += GLOB.pipe_icon_manager.get_atmos_icon("device", state = vent_icon)
	update_pipe_image(.)

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
				add_underlay(T, null, dir)
			var/icon/frame = icon('icons/atmos/vent_pump.dmi', "frame")
			underlays += frame

/obj/machinery/atmospherics/unary/vent_pump/hide()
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_pump/process_atmos()
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(QDELETED(parent))
		// We're orphaned!
		return FALSE
	var/turf/T = get_turf(src)
	if(T.density) //No, you should not be able to get free air from walls
		return
	if(!node)
		on = FALSE
	if(!on)
		return FALSE

	if(welded)
		if(air_contents.return_pressure() >= weld_burst_pressure && prob(5))	//the weld is on but the cover is welded shut, can it withstand the internal pressure?
			visible_message("<span class='danger'>The welded cover of [src] bursts open!</span>")
			for(var/mob/living/M in range(1))
				unsafe_pressure_release(M, air_contents.return_pressure())	//let's send everyone flying
			welded = FALSE
			update_icon()
		return FALSE

	var/datum/gas_mixture/environment = T.get_readonly_air()
	if(releasing) //internal -> external
		var/pressure_delta = 10000
		if(pressure_checks == ONLY_CHECK_EXT_PRESSURE)
			// Only checks difference between set pressure and environment pressure
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment.return_pressure()))
		if(pressure_checks == ONLY_CHECK_INT_PRESSURE)
			pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

		if(pressure_delta > 0.5 && air_contents.temperature() > 0)
			// 1kPa * 1L = 1J
			var/wanted_joules = pressure_delta * environment.volume
			var/transfer_moles = min(max_transfer_joules, wanted_joules) / (air_contents.temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			// This isn't exactly "blind", but using the data from last tick is good enough for a vent.
			T.blind_release_air(removed)
			parent.update = TRUE

	else //external -> internal
		var/datum/milla_safe/vent_pump_siphon/milla = new()
		milla.invoke_async(src)

	return TRUE

/datum/milla_safe/vent_pump_siphon

/datum/milla_safe/vent_pump_siphon/on_run(obj/machinery/atmospherics/unary/vent_pump/vent_pump)
	var/turf/T = get_turf(vent_pump)
	var/datum/gas_mixture/environment = get_turf_air(T)
	var/pressure_delta = 10000
	if(vent_pump.pressure_checks == ONLY_CHECK_EXT_PRESSURE)
		pressure_delta = min(pressure_delta, (environment.return_pressure() - vent_pump.external_pressure_bound))
	if(vent_pump.pressure_checks == ONLY_CHECK_INT_PRESSURE)
		pressure_delta = min(pressure_delta, (vent_pump.internal_pressure_bound - vent_pump.air_contents.return_pressure()))

	if(pressure_delta > 0.5 && environment.temperature() > 0)
		// 1kPa * 1L = 1J
		var/wanted_joules = pressure_delta * environment.volume
		var/transfer_moles = min(vent_pump.max_transfer_joules, wanted_joules) / (environment.temperature() * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed = environment.remove(transfer_moles)
		vent_pump.air_contents.merge(removed)
		vent_pump.parent.update = TRUE

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

/obj/machinery/atmospherics/unary/vent_pump/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/paper))
		if(!welded)
			if(open)
				user.drop_item(used)
				used.forceMove(src)
			if(!open)
				to_chat(user, "You can't shove that down there when it is closed")
		else
			to_chat(user, "The vent is welded.")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/atmospherics/unary/vent_pump/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I))
		return

	var/obj/item/multitool/M = I
	M.buffer_uid = UID()
	to_chat(user, "<span class='notice'>You save [src] into [M]'s buffer</span>")

/obj/machinery/atmospherics/unary/vent_pump/screwdriver_act(mob/living/user, obj/item/I)
	if(welded)
		return
	to_chat(user, "<span class='notice'>You start screwing the vent [open ? "shut" : "open"].</span>")
	if(do_after(user, 20 * I.toolspeed, target = src))
		I.play_tool_sound(src)
		user.visible_message("<span class='notice'>[user] screws the vent [open ? "shut" : "open"].</span>", "<span class='notice'>You screw the vent [open ? "shut" : "open"].</span>", "You hear a screwdriver.")
		open = !open
	return TRUE

/obj/machinery/atmospherics/unary/vent_pump/welder_act(mob/user, obj/item/I)
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


/obj/machinery/atmospherics/unary/vent_pump/attack_hand()
	if(!welded)
		if(open)
			for(var/obj/item/W in src)
				if(istype(W, /obj/item/pipe))
					continue
				W.forceMove(get_turf(src))

/obj/machinery/atmospherics/unary/vent_pump/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/vent_pump/Destroy()
	GLOB.all_vent_pumps -= src
	if(initial_loc)
		initial_loc.vents -= src
	return ..()

#undef EXTERNAL_PRESSURE_BOUND
#undef INTERNAL_PRESSURE_BOUND
