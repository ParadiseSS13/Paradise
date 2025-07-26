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

	var/volume_rate = 200
	var/widenet = FALSE //is this scrubber acting on the 3x3 area around it.

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
	if(initial_loc)
		initial_loc.scrubbers -= src

	GLOB.all_scrubbers -= src

	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This filters the atmosphere of harmful gas. Filtered gas goes straight into the connected pipenet. Controlled by an Air Alarm.</span>"
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

	if(stat & (NOPOWER|BROKEN))
		return

	var/turf/T = loc
	if(T.density) //No, you should not be able to get free air from walls
		return

	if(!node)
		on = FALSE

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

	if(scrubbing && !should_scrub(tile.get_readonly_air()))
		return 0

	var/datum/milla_safe/vent_scrubber_process/milla = new()
	milla.invoke_async(src, tile)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/should_scrub(datum/gas_mixture/environment)
	if(scrub_O2 && environment.oxygen() > 0.001)
		return TRUE
	if(scrub_N2 && environment.nitrogen() > 0.001)
		return TRUE
	if(scrub_CO2 && environment.carbon_dioxide() > 0.001)
		return TRUE
	if(scrub_Toxins && environment.toxins() > 0.001)
		return TRUE
	if(environment.sleeping_agent() > 0.001)
		return TRUE
	if(environment.agent_b() > 0.001)
		return TRUE

	return FALSE

/datum/milla_safe/vent_scrubber_process

/datum/milla_safe/vent_scrubber_process/on_run(obj/machinery/atmospherics/unary/vent_scrubber/scrubber, turf/simulated/tile)
	if(!tile || !istype(tile))
		return 0

	var/datum/gas_mixture/environment = get_turf_air(tile)

	if(scrubber.scrubbing)
		if(scrubber.should_scrub(environment))
			var/transfer_moles = min(1, scrubber.volume_rate / environment.volume) * environment.total_moles()

			//Take a gas sample
			var/datum/gas_mixture/removed = environment.remove(transfer_moles)
			if(isnull(removed)) //in space
				return

			//Filter it
			var/datum/gas_mixture/filtered_out = new
			filtered_out.set_temperature(removed.temperature())
			if(scrubber.scrub_O2)
				filtered_out.set_oxygen(removed.oxygen())
				removed.set_oxygen(0)
			if(scrubber.scrub_N2)
				filtered_out.set_nitrogen(removed.nitrogen())
				removed.set_nitrogen(0)
			if(scrubber.scrub_Toxins)
				filtered_out.set_toxins(removed.toxins())
				removed.set_toxins(0)
			if(scrubber.scrub_CO2)
				filtered_out.set_carbon_dioxide(removed.carbon_dioxide())
				removed.set_carbon_dioxide(0)

			if(removed.agent_b())
				filtered_out.set_agent_b(removed.agent_b())
				removed.set_agent_b(0)

			if(scrubber.scrub_N2O)
				filtered_out.set_sleeping_agent(removed.sleeping_agent())
				removed.set_sleeping_agent(0)

			//Remix the resulting gases
			scrubber.air_contents.merge(filtered_out)

			environment.merge(removed)

	else //Just siphoning all air
		if(scrubber.air_contents.return_pressure() >= (50 * ONE_ATMOSPHERE))
			return

		var/transfer_moles = environment.total_moles() * (scrubber.volume_rate / environment.volume)

		var/datum/gas_mixture/removed = environment.remove(transfer_moles)

		scrubber.air_contents.merge(removed)

	if(!QDELETED(scrubber.parent))
		scrubber.parent.update = 1

	return 1

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
	user.visible_message("<span class='warning'>[user] furiously claws at [src]!</span>", "<span class='notice'>You manage to clear away the stuff blocking the scrubber.</span>", "<span class='italics'>You hear loud scraping noises.</span>")
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
			user.visible_message("<span class='notice'>[user] welds [src] shut!</span>",\
				"<span class='notice'>You weld [src] shut!</span>")
		else
			welded = FALSE
			user.visible_message("<span class='notice'>[user] unwelds [src]!</span>",\
				"<span class='notice'>You unweld [src]!</span>")
		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I))
		return

	var/obj/item/multitool/M = I
	M.buffer_uid = UID()
	to_chat(user, "<span class='notice'>You save [src] into [M]'s buffer.</span>")
