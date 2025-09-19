/area
	var/fire = null
	var/area_emergency_mode = FALSE // When true, fire alarms cannot unset emergency lighting. Not to be confused with emergency_mode var on light objects.
	var/atmosalm = ATMOS_ALARM_NONE
	var/poweralm = TRUE
	var/report_alerts = TRUE // Should atmos alerts notify the AI/computers
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	plane = AREA_PLANE //Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	luminosity = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	/// used for cult summoning areas on station zlevel
	var/valid_territory = TRUE
	/// Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.
	var/map_name
	/// Is the lightswitch in this area on? Controls whether or not lights are on and off
	var/lightswitch = TRUE
	/// Is the window tint control in this area on? Controls whether electrochromic windows and doors are tinted or not
	var/window_tint = FALSE
	/// If TRUE, the local powernet in this area will have all its power channels switched off
	var/apc_starts_off = FALSE
	/// If TRUE, this area's local powernet will require power to properly operate machines
	var/requires_power = TRUE
	/// If TRUE, machines that require power in this area will never be powered
	var/always_unpowered = FALSE
	/// The local powernet of this area, this is where all machine/apc/object power related operations are handled
	var/datum/local_powernet/powernet = null
	/// All APCs currently constructed in this area
	var/list/apc = list()

	var/has_gravity = TRUE

	var/air_doors_activated = FALSE

	var/tele_proof = FALSE
	var/no_teleportlocs = FALSE

	var/outdoors = FALSE //For space, the asteroid, lavaland, etc. Used with blueprints to determine if we are adding a new area (vs editing a station room)
	var/xenobiology_compatible = FALSE //Can the Xenobio management console transverse this area by default?
	var/nad_allowed = FALSE //is the station NAD allowed on this area?

	// This var is used with the maploader (modules/awaymissions/maploader/reader.dm)
	// if this is 1, when used in a map snippet, this will instantiate a unique
	// area from any other instances already present (meaning you can have
	// separate APCs, and so on)
	var/there_can_be_many = FALSE

	/// Static var that is incremented when the UID of a area is being assigned.
	var/global/global_uid = 0
	var/uid

	var/list/ambientsounds = GENERIC_SOUNDS

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/firedoors_last_closed_on = 0

	/// Timer to stop ongoing fire alarm sounds
	var/firealarm_sound_stop_timer = null
	/// The air alarms present in this area.
	var/list/air_alarms = list()
	/// The list of vents in our area.
	var/list/obj/machinery/atmospherics/unary/vent_pump/vents = list()
	/// The list of scrubbers in our area.
	var/list/obj/machinery/atmospherics/unary/vent_scrubber/scrubbers = list()

	/// Do we quickly despawn the person in this area? Pretty much just used in permabrig
	var/fast_despawn = FALSE
	/// Do we despawn the person in this area? Pretty much just used in security areas that aren't permabrig
	var/can_get_auto_cryod = TRUE
	/// For areas such as thunderdome which generate a lot of spammy attacklogs. Reduces log priority.
	var/hide_attacklogs = FALSE
	/// Handles the direction parallax will be moved in. References
	var/parallax_move_direction = 0
	/// Is a shuttle moving to our area?
	var/moving = FALSE
	/// "Haunted" areas such as the morgue and chapel are easier to boo. Because flavor.
	var/is_haunted = FALSE
	///Used to decide what kind of reverb the area makes sound have
	var/sound_environment = SOUND_ENVIRONMENT_NONE

	/// Used to decide what the minimum time between ambience is
	var/min_ambience_cooldown = 30 SECONDS
	/// Used to decide what the maximum time between ambience is
	var/max_ambience_cooldown = 90 SECONDS

	/// Turrets use this list to see if individual power/lethal settings are allowed. Contains the /obj/machinery/turretid for this area
	var/list/turret_controls = list()

	/// Wire assignment for airlocks in this area
	var/airlock_wires = /datum/wires/airlock

	/// The flags applied to request consoles spawned in this area.
	/// See [RC_ASSIST], [RC_SUPPLY], [RC_INFO].
	var/request_console_flags = 0
	/// The name for any spawned request consoles. Defaults to the area name.
	var/request_console_name
	/// Whether request consoles in this area can send announcements.
	var/request_console_announces = FALSE
	/// Fire alarm camera network
	var/fire_cam_network = "Fire Alarms Debug"
	/// Power alarm camera network
	var/power_cam_network = "Power Alarms Debug"
	/// Atmosphere alarm camera network
	var/atmos_cam_network = "Atmosphere Alarms Debug"
	/*
	Lighting Vars
	*/
	luminosity = TRUE
	var/dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/New(loc, ...)
	if(!there_can_be_many) // Has to be done in New else the maploader will fuck up and find subtypes for the parent
		GLOB.all_unique_areas[type] = src
	GLOB.all_areas += src
	return ..()

/area/Initialize(mapload)
	if(is_station_level(z))
		RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_update))

	icon_state = ""
	layer = AREA_LAYER
	uid = ++global_uid

	map_name = name // Save the initial (the name set in the map) name of the area.

	if(!powernet) // we may already have a powernet due to machine init, better to be safe than sorry
		create_powernet() // no powernet yet, create one

	//setting lighting
	if(!requires_power)
		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else if(dynamic_lighting != DYNAMIC_LIGHTING_IFSTARLIGHT)
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	if(dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
		dynamic_lighting = GLOB.configuration.general.starlight ? DYNAMIC_LIGHTING_ENABLED : DYNAMIC_LIGHTING_DISABLED

	. = ..()

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

	reg_in_areas_in_z()

	return INITIALIZE_HINT_LATELOAD

/area/proc/on_security_level_update(datum/source, previous_level_number, new_level_number)
	SIGNAL_HANDLER

	area_emergency_mode = (new_level_number >= SEC_LEVEL_EPSILON)

/area/proc/create_powernet()
	powernet = new()
	powernet.powernet_area = src

	//setting power flags and channel breakers
	if(always_unpowered) //area will never be powered, set all power channels to off
		powernet.lighting_powered = FALSE
		powernet.equipment_powered = FALSE
		powernet.environment_powered = FALSE
		powernet.power_flags |= PW_ALWAYS_UNPOWERED  //ensures all power checks will return FALSE
	else if(requires_power) //area does require power
		luminosity = 0
		if(apc_starts_off) //flip all the channels off if apc starts off
			powernet.lighting_powered = FALSE
			powernet.equipment_powered = FALSE
			powernet.environment_powered = FALSE
	else // area doesn't require power
		powernet.power_flags |= PW_ALWAYS_POWERED //ensures all power checks will return TRUE

	return powernet

/area/proc/reg_in_areas_in_z()
	if(!length(contents)) // if its nullspaced or something, I guess
		return
	if(!z)
		WARNING("No z found for [src]")
		return
	var/list/areas_in_z = GLOB.space_manager.areas_in_z
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src

/area/proc/get_cameras()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in src)
		cameras += C
	return cameras

/area/proc/air_doors_close()
	if(air_doors_activated)
		return
	air_doors_activated = TRUE
	for(var/obj/machinery/door/firedoor/D in src)
		if(!D.is_operational())
			continue
		D.activate_alarm()
		if(D.welded)
			continue
		if(D.operating && D.operating != DOOR_CLOSING)
			D.nextstate = FD_CLOSED
		else if(!D.density)
			INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/firedoor, close))

/area/proc/air_doors_open()
	if(!air_doors_activated)
		return
	air_doors_activated = FALSE
	for(var/obj/machinery/door/firedoor/D in src)
		if(!D.is_operational())
			continue
		D.deactivate_alarm()
		if(D.welded)
			continue
		if(D.operating && D.operating != DOOR_OPENING)
			D.nextstate = FD_OPEN
		else if(D.density)
			INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/firedoor, open))

/area/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/**
  * Generate a power alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/poweralert(state, obj/source)
	if(state == poweralm)
		return
	poweralm = state
	if(!istype(source))	//Only report power alarms on the z-level where the source is located.
		return
	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C))
			if(state)
				C.network -= power_cam_network
			else
				C.network |= power_cam_network

	if(state)
		GLOB.alarm_manager.cancel_alarm("Power", src, source)
	else
		GLOB.alarm_manager.trigger_alarm("Power", src, cameras, source)

/**
  * Generate an atmospheric alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/atmosalert(danger_level, obj/source)
	if(danger_level != atmosalm)
		if(danger_level == ATMOS_ALARM_DANGER)

			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C))
					C.network |= atmos_cam_network


			GLOB.alarm_manager.trigger_alarm("Atmosphere", src, cameras, source)

		else if(atmosalm == ATMOS_ALARM_DANGER)
			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C))
					C.network -= atmos_cam_network

			GLOB.alarm_manager.cancel_alarm("Atmosphere", src, source)

		atmosalm = danger_level
		return TRUE
	return FALSE

/**
  * Try to close all the firedoors in the area
  */
/area/proc/ModifyFiredoors(opening)
	if(!firedoors)
		return
	firedoors_last_closed_on = world.time
	for(var/obj/machinery/door/firedoor/D in firedoors)
		if(!D.is_operational())
			continue
		var/valid = TRUE
		if(opening)	//don't open if adjacent area is on fire
			for(var/I in D.affecting_areas)
				var/area/A = I
				if(A.fire)
					valid = FALSE
					break
		if(!valid)
			continue

		// At this point, the area is safe and the door is technically functional.
		// Firedoors do not close automatically by default, and setting it to false when the alarm is off prevents unnecessary timers from being created. Emagged doors are permanently disabled from automatically closing, or being operated by alarms altogether apart from the lights.
		if(!D.emagged)
			if(opening)
				D.autoclose = FALSE
			else
				D.autoclose = TRUE

		INVOKE_ASYNC(D, (opening ? TYPE_PROC_REF(/obj/machinery/door/firedoor, deactivate_alarm) : TYPE_PROC_REF(/obj/machinery/door/firedoor, activate_alarm)))
		if(D.welded || D.emagged)
			continue // Alarm is toggled, but door stuck

		if(D.operating)
			if((D.operating == DOOR_OPENING && opening) || (D.operating == DOOR_CLOSING && !opening))
				continue
			else
				D.nextstate = opening ? FD_OPEN : FD_CLOSED
		else if(D.density == opening)
			INVOKE_ASYNC(D, (opening ? TYPE_PROC_REF(/obj/machinery/door/firedoor, open) : TYPE_PROC_REF(/obj/machinery/door/firedoor, close)))

/**
  * Generate a firealarm alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  *
  * Also starts the area processing on SSobj
  */
/area/proc/firealert(obj/source)
	if(always_unpowered) //no fire alarms in space/asteroid
		return

	if(!fire)
		set_fire_alarm_effect()
		ModifyFiredoors(FALSE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()
			GLOB.firealarm_soundloop.start(F)
		if(!firealarm_sound_stop_timer)
			firealarm_sound_stop_timer = addtimer(CALLBACK(src, PROC_REF(stop_alarm_sounds)), 4 MINUTES, TIMER_STOPPABLE | TIMER_UNIQUE)

	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C))
			C.network |= fire_cam_network

	GLOB.alarm_manager.trigger_alarm("Fire", src, cameras, source)

	START_PROCESSING(SSobj, src)

/area/proc/stop_alarm_sounds()
	for(var/obj/machinery/firealarm/F in firealarms)
		F.update_icon()
		GLOB.firealarm_soundloop.stop(F)
/**
  * Reset the firealarm alert for this area
  *
  * resets the alert sent to all ai players, alert consoles, drones and alarm monitor programs
  * in the world
  *
  * Also cycles the icons of all firealarms and deregisters the area from processing on SSOBJ
  */
/area/proc/firereset(obj/source)
	if(fire)
		unset_fire_alarm_effects()
		ModifyFiredoors(TRUE)
		if(firealarm_sound_stop_timer)
			deltimer(firealarm_sound_stop_timer)
			firealarm_sound_stop_timer = null
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()
			GLOB.firealarm_soundloop.stop(F, TRUE)

	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C))
			C.network -= fire_cam_network

	GLOB.alarm_manager.cancel_alarm("Fire", src, source)

	STOP_PROCESSING(SSobj, src)

/**
  * If 100 ticks has elapsed, toggle all the firedoors closed again
  */
/area/process()
	if(firedoors_last_closed_on + 100 < world.time)	//every 10 seconds
		ModifyFiredoors(FALSE)

/**
  * Close and lock a door passed into this proc
  *
  * Does this need to exist on area? probably not
  */
/area/proc/close_and_lock_door(obj/machinery/door/DOOR)
	set waitfor = FALSE
	DOOR.close()
	if(DOOR.density)
		DOOR.lock()

/**
  * Raise a burglar alert for this area
  *
  * Close and locks all doors in the area and alerts silicon mobs of a break in
  *
  * Alarm auto resets after 600 ticks
  */
/area/proc/burglaralert(obj/trigger)
	if(always_unpowered) //no burglar alarms in space/asteroid
		return

	//Trigger alarm effect
	set_fire_alarm_effect()
	//Lockdown airlocks
	for(var/obj/machinery/door/DOOR in src)
		close_and_lock_door(DOOR)

	if(GLOB.alarm_manager.trigger_alarm("Burglar", src, cameras, trigger))
		//Cancel silicon alert after 1 minute
		addtimer(CALLBACK(GLOB.alarm_manager, TYPE_PROC_REF(/datum/alarm_manager, cancel_alarm), "Burglar", src, trigger), 1 MINUTES)

/**
  * Trigger the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/set_fire_alarm_effect()
	fire = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	if(area_emergency_mode) //Fires are not legally allowed if the power is off
		return
	for(var/obj/machinery/light/L in src)
		L.fire_mode = TRUE
		L.update(TRUE, TRUE, FALSE)

///unset the fire alarm visual affects in an area
/area/proc/unset_fire_alarm_effects()
	fire = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	if(area_emergency_mode) //The lights stay red until the crisis is resolved
		return
	for(var/obj/machinery/light/L in src)
		L.fire_mode = FALSE
		L.update(TRUE, TRUE, FALSE)

/area/update_icon_state()
	var/weather_icon
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.stage != WEATHER_END_STAGE && (src in W.impacted_areas))
			W.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null

/area/space/update_icon_state()
	icon_state = null

/area/Entered(A)
	var/area/newarea
	var/area/oldarea

	if(ismob(A))
		var/mob/M = A

		if(!M.lastarea)
			M.lastarea = get_area(M)
		newarea = get_area(M)
		oldarea = M.lastarea

		if(newarea==oldarea) return

		M.lastarea = src

	if(!isliving(A))	return

	var/mob/living/L = A
	if(!L.ckey)	return
	SEND_SIGNAL(L, COMSIG_AREA_ENTERED, newarea)
	if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (L.m_intent == MOVE_INTENT_RUN)) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)

	if(GLOB.configuration.general.disable_ambient_noise)
		return

	//Ship ambience just loops if turned on.
	if(L && L.client && !L.client.ambience_playing && (L.client.prefs.sound & SOUND_BUZZ))
		L.client.ambience_playing = TRUE
		SEND_SOUND(L, sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = FALSE, volume = 35 * L.client.prefs.get_channel_volume(CHANNEL_BUZZ), channel = CHANNEL_BUZZ))
	else if(L && L.client && !(L.client.prefs.sound & SOUND_BUZZ))
		L.client.ambience_playing = FALSE

/area/proc/gravitychange(gravitystate = 0, area/A)
	A.has_gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/M in A)
			thunk(M)
		for(var/obj/effect/decal/cleanable/blood/B in A)
			B.splat(B)
		for(var/obj/effect/decal/cleanable/vomit/V in A)
			V.splat(V)

/area/proc/thunk(mob/living/carbon/human/M)
	if(!istype(M)) // Rather not have non-humans get hit with a THUNK
		return

	if(HAS_TRAIT(M, TRAIT_MAGPULSE)) // Only humans can wear magboots, so we give them a chance to.
		return

	if(M.dna.species.spec_thunk(M)) //Species level thunk overrides
		return

	if(M.buckled) //Cam't fall down if you are buckled
		return

	if(isspaceturf(get_turf(M))) // Can't fall onto nothing.
		return

	if((ishuman(M)) && (M.m_intent == MOVE_INTENT_RUN))
		M.Weaken(10 SECONDS)

	else if(ishuman(M))
		M.Weaken(4 SECONDS)


	to_chat(M, "Gravity!")

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT) // If we still don't have a turf, don't process the other stuff
		if(!T)
			return
	var/area/A = get_area(T)
	if(isspaceturf(T)) // Turf never has gravity
		return 0
	else if(A && A.has_gravity) // Areas which always has gravity
		return 1
	else
		// There's a gravity generator on our z level
		// This would do well when integrated with the z level manager
		if(T && GLOB.gravity_generators["[T.z]"] && length(GLOB.gravity_generators["[T.z]"]))
			return 1
	return 0

/area/proc/prison_break()
	for(var/obj/machinery/power/apc/temp_apc in src)
		INVOKE_ASYNC(temp_apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting), 70)
	for(var/obj/machinery/door/airlock/temp_airlock in src)
		INVOKE_ASYNC(temp_airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, prison_open))
	for(var/obj/machinery/door/window/temp_windoor in src)
		INVOKE_ASYNC(temp_windoor, TYPE_PROC_REF(/obj/machinery/door, open))
	for(var/obj/machinery/door/poddoor/temp_poddoor in src)
		INVOKE_ASYNC(temp_poddoor, TYPE_PROC_REF(/obj/machinery/door, open))

/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/area/drop_location()
	CRASH("Bad op: area/drop_location() called")

/// Returns highest area type in the hirarchy of a given ruin or /area/station if it is given a station area.
/// For an example the top parent of area/ruin/space/bar/backroom is area/ruin/space/bar
/area/proc/get_top_parent_type()
	var/top_parent_type = type

	if(parent_type in subtypesof(/area/ruin))
		// figure out which ruin we are on
		while(!(type2parent(top_parent_type) in GLOB.ruin_prototypes))
			top_parent_type = type2parent(top_parent_type)
	else if(parent_type in subtypesof(/area/station))
		top_parent_type = /area/station
	else
		top_parent_type = null
	return top_parent_type
