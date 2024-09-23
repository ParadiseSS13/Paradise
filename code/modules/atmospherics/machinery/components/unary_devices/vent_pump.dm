#define EXTERNAL_PRESSURE_BOUND ONE_ATMOSPHERE
#define INTERNAL_PRESSURE_BOUND 0
#define PRESSURE_CHECKS 1

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
	var/open = FALSE

	var/area/initial_loc

	var/releasing = TRUE //FALSE = siphoning, TRUE = releasing

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

	var/welded = FALSE // Added for aliens -- TLE
	var/weld_burst_pressure = 50 * ONE_ATMOSPHERE	//the (internal) pressure at which welded covers will burst off

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

	. += SSair.icon_manager.get_atmos_icon("device", state = vent_icon)

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
				add_underlay(T, null, dir)
			var/icon/frame = icon('icons/atmos/vent_pump.dmi', "frame")
			underlays += frame

/obj/machinery/atmospherics/unary/vent_pump/hide()
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_pump/process_atmos()
	var/datum/milla_safe/vent_pump_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/vent_pump_process

/datum/milla_safe/vent_pump_process/on_run(obj/machinery/atmospherics/unary/vent_pump/vent_pump)
	if(vent_pump.stat & (NOPOWER|BROKEN))
		return FALSE
	if(QDELETED(vent_pump.parent))
		// We're orphaned!
		return FALSE
	var/turf/T = get_turf(vent_pump)
	if(T.density) //No, you should not be able to get free air from walls
		return
	if(!vent_pump.node)
		vent_pump.on = FALSE
	if(!vent_pump.on)
		return FALSE

	if(vent_pump.welded)
		if(vent_pump.air_contents.return_pressure() >= vent_pump.weld_burst_pressure && prob(5))	//the weld is on but the cover is welded shut, can it withstand the internal pressure?
			vent_pump.visible_message("<span class='danger'>The welded cover of [vent_pump] bursts open!</span>")
			for(var/mob/living/M in range(1))
				vent_pump.unsafe_pressure_release(M, vent_pump.air_contents.return_pressure())	//let's send everyone flying
			vent_pump.welded = FALSE
			vent_pump.update_icon()
		return FALSE

	var/datum/gas_mixture/environment = get_turf_air(T)
	var/environment_pressure = environment.return_pressure()
	if(vent_pump.releasing) //internal -> external
		var/pressure_delta = 10000
		if(vent_pump.pressure_checks & 1)
			pressure_delta = min(pressure_delta, (vent_pump.external_pressure_bound - environment_pressure))
		if(vent_pump.pressure_checks & 2)
			pressure_delta = min(pressure_delta, (vent_pump.air_contents.return_pressure() - vent_pump.internal_pressure_bound))

		if(pressure_delta > 0.5 && vent_pump.air_contents.temperature() > 0)
			var/transfer_moles = pressure_delta * environment.volume / (vent_pump.air_contents.temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = vent_pump.air_contents.remove(transfer_moles)
			environment.merge(removed)
			vent_pump.parent.update = TRUE

	else //external -> internal
		var/pressure_delta = 10000
		if(vent_pump.pressure_checks & 1)
			pressure_delta = min(pressure_delta, (environment_pressure - vent_pump.external_pressure_bound))
		if(vent_pump.pressure_checks & 2)
			pressure_delta = min(pressure_delta, (vent_pump.internal_pressure_bound - vent_pump.air_contents.return_pressure()))

		if(pressure_delta > 0.5 && environment.temperature() > 0)
			var/transfer_moles = pressure_delta * vent_pump.air_contents.volume / (environment.temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = environment.remove(transfer_moles)
			vent_pump.air_contents.merge(removed)
			vent_pump.parent.update = TRUE

	return TRUE

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
	if(istype(W, /obj/item/paper))
		if(!welded)
			if(open)
				user.drop_item(W)
				W.forceMove(src)
			if(!open)
				to_chat(user, "You can't shove that down there when it is closed")
		else
			to_chat(user, "The vent is welded.")
		return TRUE

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
#undef PRESSURE_CHECKS
