// MARK: Reactor Power Output

/obj/machinery/power/reactor_power
	name = "reactor output terminal"
	desc = "A bundle of heavy watt power cables for managing power output from the reactor."
	icon_state = "term"
	plane = FLOOR_PLANE
	layer = WIRE_TERMINAL_LAYER // A bit above wires
	resistance_flags = INDESTRUCTIBLE
	var/obj/machinery/atmospherics/fission_reactor/linked_reactor

/obj/machinery/power/reactor_power/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

// Needs lateload to prevent reactor not being initialized yet and thus not able to set the link.
/obj/machinery/power/reactor_power/LateInitialize()
	. = ..()
	linked_reactor = GLOB.main_fission_reactor

/obj/machinery/power/reactor_power/process()
	if(linked_reactor && linked_reactor.can_create_power)
		produce_direct_power(linked_reactor.final_power)

// MARK: Monitor

/obj/machinery/computer/fission_monitor
	name = "NGCR monitoring console"
	desc = "Used to monitor the Nanotrasen Gas Cooled Fission Reactor."
	icon_keyboard = "power_key"
	icon_screen = "smmon_0"
	circuit = /obj/item/circuitboard/fission_monitor
	light_color = LIGHT_COLOR_YELLOW
	/// Last status of the active reactor for caching purposes
	var/last_status
	/// Reference to the active reactor
	var/obj/machinery/atmospherics/fission_reactor/active
	/// Is this monitor a controller? Affected by visibility from the reactor
	var/controller = TRUE

/obj/machinery/computer/fission_monitor/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/fission_monitor/LateInitialize()
	. = ..()
	active = GLOB.main_fission_reactor
	determine_control()

/obj/machinery/computer/fission_monitor/Destroy()
	active = null
	return ..()

// This can normally never happen, but just in case.
/obj/machinery/computer/fission_monitor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	determine_control()

/obj/machinery/computer/fission_monitor/proc/determine_control()
	if(!active)
		return
	if(active in oview(12, src))
		controller = TRUE
	else
		controller = FALSE

/obj/machinery/computer/fission_monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/fission_monitor/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/fission_monitor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/fission_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	if(active)
		var/new_status = active.get_status()
		if(last_status != new_status)
			last_status = new_status
			icon_screen = "smmon_[last_status]"
			update_icon()

	return TRUE

/obj/machinery/computer/fission_monitor/multitool_act(mob/living/user, obj/item/I)
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/multitool = I
	if(istype(multitool.buffer, /obj/machinery/atmospherics/fission_reactor))
		active = multitool.buffer
		to_chat(user, SPAN_NOTICE("You load the buffer's linking data to [src]."))

/obj/machinery/computer/fission_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReactorMonitor", name)
		ui.open()

	return TRUE

/obj/machinery/computer/fission_monitor/ui_data(mob/user)
	var/list/data = list()
	// If we somehow dont have an engine anymore, handle it here.
	if(!active)
		return
	if(active.stat & BROKEN)
		active = null
		return

	var/datum/gas_mixture/air = active.air_contents
	var/power_kilowatts = round((active.final_power / 1000), 1)

	data["venting"] = active.venting
	data["NGCR_integrity"] = active.get_integrity()
	data["NGCR_power"] = power_kilowatts
	data["NGCR_ambienttemp"] = air.temperature()
	data["NGCR_ambientpressure"] = air.return_pressure()
	data["NGCR_coefficient"] = active.reactivity_multiplier
	if(active.control_lockout)
		data["NGCR_throttle"] = 0
	else
		data["NGCR_throttle"] = 100 - active.desired_power
	data["NGCR_operatingpower"] = 100 - active.operating_power
	var/list/gasdata = list()
	var/TM = air.total_moles()
	if(TM)
		gasdata.Add(list(list("name" = "Oxygen", "amount" = air.oxygen(), "portion" = round(100 * air.oxygen() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Carbon Dioxide", "amount" = air.carbon_dioxide(), "portion" = round(100 * air.carbon_dioxide() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Nitrogen", "amount" = air.nitrogen(), "portion" = round(100 * air.nitrogen() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Plasma", "amount" = air.toxins(), "portion" = round(100 * air.toxins() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Nitrous Oxide", "amount" = air.sleeping_agent(), "portion" = round(100 * air.sleeping_agent() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Agent B", "amount" = air.agent_b(), "portion" = round(100 * air.agent_b() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Hydrogen", "amount" = air.hydrogen(), "portion" = round(100 * air.hydrogen() / TM, 0.01))))
		gasdata.Add(list(list("name" = "Water Vapor", "amount" = air.water_vapor(), "portion" = round(100 * air.water_vapor() / TM, 0.01))))
	else
		gasdata.Add(list(list("name" = "Oxygen", "amount" = 0, "portion" = 0)))
		gasdata.Add(list(list("name" = "Carbon Dioxide", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name" = "Nitrogen", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name" = "Plasma", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name" = "Nitrous Oxide", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name" = "Agent B", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name" = "Hydrogen", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name" = "Water Vapor", "amount" = 0,"portion" = 0)))
	data["gases"] = gasdata
	data["controlling"] = controller

	return data

/obj/machinery/computer/fission_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(action == "set_throttle")
		if(!controller)
			visible_message(SPAN_WARNING("Error: Reactor is out of sight from laser guidance control."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return
		var/temp_number = text2num(params["NGCR_throttle"])
		active.desired_power = 100 - temp_number

	if(action == "toggle_vent")
		if(!controller)
			visible_message(SPAN_WARNING("Error: Reactor is out of sight from laser guidance control."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return
		if(active.vent_lockout)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			visible_message(SPAN_WARNING("ERROR: Vent servos unresponsive. Manual closure required."))
		else
			active.venting = !active.venting

// MARK: Slag

/obj/item/slag
	name = "corium slag"
	desc = "A large clump of active nuclear fuel fused with structural reactor metals."
	icon = 'icons/effects/effects.dmi'
	icon_state = "big_molten"
	move_resist = MOVE_FORCE_STRONG // Massive chunk of metal slag, shouldnt be moving it without carrying.
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	throwforce = 10

/obj/item/slag/Initialize(mapload)
	. = ..()
	scatter_atom()
	var/datum/component/inherent_radioactivity/rad_component = AddComponent(/datum/component/inherent_radioactivity, 5000, 5000, 5000, 2)
	START_PROCESSING(SSradiation, rad_component)
	START_PROCESSING(SSprocessing, src)

/obj/item/slag/process()
	. = ..()
	radiation_pulse(src, 500, ALPHA_RAD)
	radiation_pulse(src, 500, BETA_RAD)
	radiation_pulse(src, 500, GAMMA_RAD)

// MARK: Starter Grenade

/obj/item/grenade/nuclear_starter
	name = "Neutronic Agitator"
	desc = "A throwable device capable of inducing an artificial startup in rod chambers. Won't do anything for chambers not positioned correctly, or chambers without any rods inserted."
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GOLD = 2000)

/obj/item/grenade/nuclear_starter/deconstruct(disassembled)
	qdel(src)

/obj/item/grenade/nuclear_starter/prime()
	playsound(src.loc, 'sound/weapons/bsg_explode.ogg', 50, TRUE, -3)
	var/obj/effect/temp_visual/neutronic/warp = new(loc)
	warp.pixel_x += 16
	warp.pixel_y += 16
	warp.transform = matrix().Scale(0.01, 0.01)
	animate(warp, time = 0.5 SECONDS, transform = matrix().Scale(1, 1))
	var/list/chamber_list = list()
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in range(3, loc))
		chamber_list += chamber
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in chamber_list)
		if(chamber.chamber_state == CHAMBER_DOWN && chamber.held_rod)
			chamber.operational = TRUE
			chamber.update_icon(UPDATE_OVERLAYS)
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in chamber_list)
		if(chamber.check_status())
			chamber.requirements_met = TRUE
		else
			chamber.requirements_met = FALSE
		chamber.update_icon(UPDATE_OVERLAYS)
	qdel(src)

/obj/effect/temp_visual/neutronic
	icon = 'icons/effects/light_352.dmi'
	icon_state = "light"
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	duration = 0.5 SECONDS
	pixel_x = -176
	pixel_y = -176

// MARK: Rad Proof Pool

/turf/simulated/floor/plasteel/reactor_pool
	name = "holding pool"
	icon = 'icons/obj/fission/pool.dmi'
	icon_state = "pool_round"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	/// Holds our pool controller
	var/obj/machinery/poolcontroller/linkedcontroller
	/// Holds our effect overlay
	var/obj/item/effect/pool_overlay/effect

/turf/simulated/floor/plasteel/reactor_pool/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(initialized_on))
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/plasteel/reactor_pool/LateInitialize()
	. = ..()
	effect = new(src)

/turf/simulated/floor/plasteel/reactor_pool/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/plasteel/reactor_pool/proc/initialized_on(atom/A)
	SIGNAL_HANDLER // COMSIG_ATOM_INITIALIZED_ON
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

/turf/simulated/floor/plasteel/reactor_pool/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool += AM

/turf/simulated/floor/plasteel/reactor_pool/Exited(atom/movable/AM, direction)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool -= AM

/turf/simulated/floor/plasteel/reactor_pool/ChangeTurf(turf/simulated/floor/T, defer_change, keep_icon, ignore_air, copy_existing_baseturf)
	QDEL_NULL(effect)
	. = ..()

/turf/simulated/floor/plasteel/reactor_pool/Destroy()
	QDEL_NULL(effect)
	. = ..()

/turf/simulated/floor/plasteel/reactor_pool/wall
	icon_state = "pool_wall_round"

/turf/simulated/floor/plasteel/reactor_pool/wall/ladder
	icon_state = "ladder_wall_round"

/turf/simulated/floor/plasteel/reactor_pool/wall/filter
	icon_state = "filter_wall_round"

/turf/simulated/floor/plasteel/reactor_pool/square
	icon_state = "pool_sharp_square"

/obj/structure/railing/pool_lining
	name = "pool lining"
	icon = 'icons/obj/fission/pool.dmi'
	icon_state = "poolborder"
	flags = ON_BORDER | NODECONSTRUCT | INDESTRUCTIBLE
	max_integrity = 200

/obj/structure/railing/pool_lining/ex_act(severity)
	if(severity == EXPLODE_HEAVY || severity == EXPLODE_DEVASTATE)
		qdel(src)

/obj/item/effect/pool_overlay
	name = "holding pool"
	desc = "water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "seadeep"
	alpha = 75
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/structure/railing/corner/pool_corner
	name = "pool lining"
	icon = 'icons/obj/fission/pool.dmi'
	icon_state = "bordercorner"

/obj/structure/railing/corner/pool_corner/inner
	icon_state = "innercorner"

/obj/machinery/poolcontroller/invisible/nuclear
	srange = 6
	deep_water = TRUE

/obj/machinery/poolcontroller/invisible/nuclear/Initialize(mapload)
	var/contents_loop = linked_area
	if(!linked_area)
		contents_loop = range(srange, src)

	for(var/turf/simulated/floor/plasteel/reactor_pool/T in contents_loop)
		T.linkedcontroller = src
		linkedturfs += T
	return ..()

/obj/machinery/poolcontroller/invisible/nuclear/Destroy()
	for(var/turf/simulated/floor/plasteel/reactor_pool/W in linkedturfs)
		if(W.linkedcontroller == src)
			W.linkedcontroller = null
	return ..()

/obj/machinery/poolcontroller/invisible/nuclear/processMob()
	for(var/mob/M in mobinpool)
		if(!istype(get_turf(M), /turf/simulated/floor/plasteel/reactor_pool))
			mobinpool -= M
			continue

		M.clean_blood(radiation_clean = TRUE)

		if(isliving(M))
			var/mob/living/L = M
			L.ExtinguishMob()
			L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily

		if(ishuman(M))
			handleDrowning(M)

// MARK: Fab upgrade

/obj/item/rod_fabricator_upgrade
	name = "Nuclear Fabricator Upgrade"
	desc = "A design disk containing a dizzying amount of designs and improvements for nuclear rod fabrication."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk5"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_URANIUM = 500, MAT_GOLD = 400)
	new_attack_chain = TRUE

// MARK: Chamber Doors

/obj/effect/temp_visual/chamber_closing
	icon = 'icons/obj/fission/reactor_chamber.dmi'
	icon_state = "doors_closing"
	duration = 0.7 SECONDS
	layer = ABOVE_ALL_MOB_LAYER + 0.03

