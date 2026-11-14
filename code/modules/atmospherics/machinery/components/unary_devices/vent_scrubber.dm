/// The gases that start a scrubber scrubbing no matter how it's set up
#define ALWAYS_SCRUBBED_GASES (MILLA_WATCHED_GAS_SLEEPING_AGENT | MILLA_WATCHED_GAS_AGENT_B | MILLA_WATCHED_GAS_HYDROGEN | MILLA_WATCHED_GAS_WATER_VAPOR)
/// Every gas there is, for a scrubber that's siphoning
#define ALL_SCRUBBED_GASES (MILLA_WATCHED_GAS_OXYGEN | MILLA_WATCHED_GAS_CARBON_DIOXIDE | MILLA_WATCHED_GAS_NITROGEN | MILLA_WATCHED_GAS_TOXINS | ALWAYS_SCRUBBED_GASES)

/obj/machinery/atmospherics/unary/vent_scrubber
	name = "air scrubber"
	desc = "Has a valve and pump attached to it."
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber_off"
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET
	plane = FLOOR_PLANE
	power_state = ACTIVE_POWER_USE
	idle_power_consumption = 10
	active_power_consumption = 60
	can_unwrench_while_on = FALSE

	can_unwrench = TRUE

	var/area/initial_loc

	var/list/turf/simulated/adjacent_turfs = list()

	var/scrubbing = TRUE //FALSE = siphoning, TRUE = scrubbing
	var/scrub_O2 = FALSE
	var/scrub_N2 = FALSE
	var/scrub_CO2 = TRUE
	var/scrub_Toxins = FALSE
	var/scrub_N2O = FALSE
	var/scrub_H2 = FALSE
	var/scrub_H2O = FALSE

	var/volume_rate = 200
	var/widenet = FALSE //is this scrubber acting on the 3x3 area around it.
	// MILLA does the scrubbing, all we do is check our settings
	atmos_napping = TRUE

	/// The turfs MILLA is scrubbing for us, each with the number MILLA knows that by. The scrubbing itself happens in MILLA's tick.
	var/list/turf/milla_scrubbed_turfs
	/// What we last told MILLA to start scrubbing for, as MILLA_WATCHED_GAS_* bits
	var/milla_starts_for = 0
	/// What we last told MILLA to take
	var/milla_takes = 0
	/// How much of what's on the turf we last told MILLA to take each tick
	var/milla_share = 0

	var/welded = FALSE

	connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SCRUBBER) //connects to regular and scrubber pipes

/obj/machinery/atmospherics/unary/vent_scrubber/on
	on = TRUE
	icon_state = "map_scrubber"

/obj/machinery/atmospherics/unary/vent_scrubber/on/toxins
	scrub_CO2 = FALSE
	scrub_Toxins = TRUE

/obj/machinery/atmospherics/unary/vent_scrubber/on/toxins_siphon
	scrubbing = FALSE
	scrub_CO2 = FALSE
	scrub_Toxins = TRUE

/obj/machinery/atmospherics/unary/vent_scrubber/Initialize(mapload)
	. = ..()
	icon = null
	initial_loc = get_area(loc)
	initial_loc.scrubbers += src
	GLOB.all_scrubbers += src
	name = "[initial_loc.name] Air Scrubber #[length(initial_loc.scrubbers)]"

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	set_milla_scrubbing(null, 0, 0, 0)
	if(initial_loc)
		initial_loc.scrubbers -= src

	GLOB.all_scrubbers -= src

	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("This filters the atmosphere of harmful gas. Filtered gas goes straight into the connected pipenet. Controlled by an Air Alarm.")
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/unary/vent_scrubber/update_overlays()
	. = ..()
	plane = FLOOR_PLANE
	var/scrubber_icon = "scrubber"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(!has_power())
		scrubber_icon += "off"
	else
		scrubber_icon += "[on ? "[scrubbing ? "on" : "in"]" : "off"]"
		if(on && widenet)
			scrubber_icon += "_expanded"

	if(welded)
		scrubber_icon = "scrubberweld"

	. += GLOB.pipe_icon_manager.get_atmos_icon("device", state = scrubber_icon)
	update_pipe_image(.)

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
				add_underlay(T, null, dir)
			var/icon/frame = icon('icons/atmos/vent_scrubber.dmi', "frame")
			underlays += frame


/obj/machinery/atmospherics/unary/vent_scrubber/atmos_init()
	..()
	check_turfs()

/obj/machinery/atmospherics/unary/vent_scrubber/process_atmos()
	if(widenet)
		check_turfs()

	// Work out what MILLA should be taking off our turfs right now, if anything. It does the scrubbing in its tick.
	var/starts_for = 0
	var/takes = 0
	var/share = 0
	var/turf/T = loc
	if(!(stat & (NOPOWER|BROKEN)) && !T.density) //No, you should not be able to get free air from walls
		if(!node)
			on = FALSE
		if(on && !welded)
			if(scrubbing)
				// Agent B gets taken whatever we're set to
				takes = MILLA_WATCHED_GAS_AGENT_B
				if(scrub_O2)
					takes |= MILLA_WATCHED_GAS_OXYGEN
				if(scrub_N2)
					takes |= MILLA_WATCHED_GAS_NITROGEN
				if(scrub_CO2)
					takes |= MILLA_WATCHED_GAS_CARBON_DIOXIDE
				if(scrub_Toxins)
					takes |= MILLA_WATCHED_GAS_TOXINS
				// These four get us started even when we're not set to take them, the other four only when we are
				starts_for = (takes & (MILLA_WATCHED_GAS_OXYGEN | MILLA_WATCHED_GAS_NITROGEN | MILLA_WATCHED_GAS_CARBON_DIOXIDE | MILLA_WATCHED_GAS_TOXINS)) | ALWAYS_SCRUBBED_GASES
				if(scrub_N2O)
					takes |= MILLA_WATCHED_GAS_SLEEPING_AGENT
				if(scrub_H2)
					takes |= MILLA_WATCHED_GAS_HYDROGEN
				if(scrub_H2O)
					takes |= MILLA_WATCHED_GAS_WATER_VAPOR
				share = min(1, volume_rate / CELL_VOLUME)
			// Just siphoning all air, for as long as there's room in the pipe
			else if(air_contents.return_pressure() < (50 * ONE_ATMOSPHERE))
				takes = ALL_SCRUBBED_GASES
				starts_for = ALL_SCRUBBED_GASES
				share = volume_rate / CELL_VOLUME

	// Nothing to tell MILLA unless something's different from last time
	if(starts_for == milla_starts_for && takes == milla_takes && share == milla_share)
		if(!takes)
			return
		if(!widenet && length(milla_scrubbed_turfs) == 1 && milla_scrubbed_turfs[T])
			return
	var/list/turf/tiles = list()
	if(takes)
		if(issimulatedturf(T))
			tiles += T
		if(widenet)
			for(var/turf/simulated/tile in adjacent_turfs)
				tiles |= tile
	set_milla_scrubbing(tiles, starts_for, takes, share)

/// Tells MILLA which turfs to scrub for us and how.
/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_milla_scrubbing(list/turf/tiles, starts_for, takes, share)
	var/changed = (starts_for != milla_starts_for || takes != milla_takes || share != milla_share)
	// Turfs we've stopped scrubbing
	for(var/turf/old_tile as anything in milla_scrubbed_turfs)
		if(old_tile in tiles)
			continue
		SSair.remove_scrubber(milla_scrubbed_turfs[old_tile])
		milla_scrubbed_turfs -= old_tile
	for(var/turf/tile as anything in tiles)
		var/id = milla_scrubbed_turfs ? milla_scrubbed_turfs[tile] : null
		if(id && !changed)
			continue
		id = milla_set_scrubber(id || 0, tile, starts_for, takes, share)
		LAZYSET(milla_scrubbed_turfs, tile, id)
		SSair.add_scrubber(id, src)
	milla_starts_for = starts_for
	milla_takes = takes
	milla_share = share

//we populate a list of turfs with nonatmos-blocked cardinal turfs AND
//	diagonal turfs that can share atmos with *both* of the cardinal turfs
/obj/machinery/atmospherics/unary/vent_scrubber/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/T = loc
	if(istype(T))
		adjacent_turfs = T.GetAtmosAdjacentTurfs(alldir=1)

/obj/machinery/atmospherics/unary/vent_scrubber/hide(i) //to make the little pipe section invisible, the icon changes.
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_scrubber/attack_alien(mob/user)
	if(!welded || !(do_after(user, 20, target = src)))
		return
	user.visible_message(SPAN_WARNING("[user] furiously claws at [src]!"), SPAN_NOTICE("You manage to clear away the stuff blocking the scrubber."), SPAN_ITALICS("You hear loud scraping noises."))
	welded = FALSE
	update_icon()
	pipe_image = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
	pipe_image.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, TRUE)

/obj/machinery/atmospherics/unary/vent_scrubber/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		if(!welded)
			welded = TRUE
			user.visible_message(SPAN_NOTICE("[user] welds [src] shut!"),\
				SPAN_NOTICE("You weld [src] shut!"))
		else
			welded = FALSE
			user.visible_message(SPAN_NOTICE("[user] unwelds [src]!"),\
				SPAN_NOTICE("You unweld [src]!"))
		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I))
		return

	var/obj/item/multitool/M = I
	M.buffer_uid = UID()
	to_chat(user, SPAN_NOTICE("You save [src] into [M]'s buffer."))

#undef ALWAYS_SCRUBBED_GASES
#undef ALL_SCRUBBED_GASES
