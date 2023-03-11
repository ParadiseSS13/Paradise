/area
	var/fire = null
	var/atmosalm = ATMOS_ALARM_NONE
	var/poweralm = TRUE
	var/report_alerts = TRUE // Should atmos alerts notify the AI/computers
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	plane = BLACKNESS_PLANE //Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	luminosity = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	var/valid_territory = TRUE //used for cult summoning areas on station zlevel
	var/map_name // Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.
	var/lightswitch = TRUE

	var/debug = FALSE
	var/requires_power = TRUE
	var/always_unpowered = FALSE	//this gets overriden to 1 for space in area/New()

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE
	var/used_equip = FALSE
	var/used_light = FALSE
	var/used_environ = FALSE
	var/static_equip
	var/static_light = FALSE
	var/static_environ

	var/has_gravity = TRUE
	var/list/apc = list()
	var/no_air = null

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

	var/global/global_uid = 0
	var/uid

	var/list/ambientsounds = GENERIC_SOUNDS

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/firedoors_last_closed_on = 0

	var/fast_despawn = FALSE
	var/can_get_auto_cryod = TRUE
	var/hide_attacklogs = FALSE // For areas such as thunderdome, lavaland syndiebase, etc which generate a lot of spammy attacklogs. Reduces log priority.

	var/parallax_movedir = 0
	var/moving = FALSE
	/// "Haunted" areas such as the morgue and chapel are easier to boo. Because flavor.
	var/is_haunted = FALSE
	///Used to decide what kind of reverb the area makes sound have
	var/sound_environment = SOUND_ENVIRONMENT_NONE

/area/New(loc, ...)
	if(!there_can_be_many) // Has to be done in New else the maploader will fuck up and find subtypes for the parent
		GLOB.all_unique_areas[type] = src
	..()

/area/Initialize(mapload)
	GLOB.all_areas += src
	icon_state = ""
	layer = AREA_LAYER
	uid = ++global_uid

	map_name = name // Save the initial (the name set in the map) name of the area.

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else if(dynamic_lighting != DYNAMIC_LIGHTING_IFSTARLIGHT)
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	if(dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
		dynamic_lighting = config.starlight ? DYNAMIC_LIGHTING_ENABLED : DYNAMIC_LIGHTING_DISABLED

	. = ..()

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

	reg_in_areas_in_z()

	return INITIALIZE_HINT_LATELOAD

/area/LateInitialize()
	. = ..()
	power_change()		// all machines set to current power level, also updates lighting icon

/area/proc/reg_in_areas_in_z()
	if(contents.len)
		var/list/areas_in_z = GLOB.space_manager.areas_in_z
		var/z
		for(var/i in 1 to contents.len)
			var/atom/thing = contents[i]
			if(!thing)
				continue
			z = thing.z
			break
		if(!z)
			WARNING("No z found for [src]")
			return
		if(!areas_in_z["[z]"])
			areas_in_z["[z]"] = list()
		areas_in_z["[z]"] += src

/area/proc/get_cameras()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in src)
		cameras += C
	return cameras

/area/proc/air_doors_close()
	if(!air_doors_activated)
		air_doors_activated = TRUE
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.welded)
				D.activate_alarm()
				if(D.operating)
					D.nextstate = FD_CLOSED
				else if(!D.density)
					spawn(0)
						D.close()

/area/proc/air_doors_open()
	if(air_doors_activated)
		air_doors_activated = FALSE
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.welded)
				D.deactivate_alarm()
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
						D.open()


/area/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/**
  * Generate a power alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/poweralert(state, obj/source)
	if(state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C) && is_station_level(C.z))
					if(state)
						C.network -= "Power Alarms"
					else
						C.network |= "Power Alarms"

			if(state)
				SSalarm.cancelAlarm("Power", src, source)
			else
				SSalarm.triggerAlarm("Power", src, cameras, source)

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
				if(!QDELETED(C) && is_station_level(C.z))
					C.network |= "Atmosphere Alarms"


			SSalarm.triggerAlarm("Atmosphere", src, cameras, source)

		else if(atmosalm == ATMOS_ALARM_DANGER)
			for(var/thing in cameras)
				var/obj/machinery/camera/C = locateUID(thing)
				if(!QDELETED(C) && is_station_level(C.z))
					C.network -= "Atmosphere Alarms"

			SSalarm.cancelAlarm("Atmosphere", src, source)

		atmosalm = danger_level
		return TRUE
	return FALSE

/**
  * Try to close all the firedoors in the area
  */
/area/proc/ModifyFiredoors(opening)
	if(firedoors)
		firedoors_last_closed_on = world.time
		for(var/FD in firedoors)
			var/obj/machinery/door/firedoor/D = FD
			var/cont = !D.welded
			if(cont && opening)	//don't open if adjacent area is on fire
				for(var/I in D.affecting_areas)
					var/area/A = I
					if(A.fire)
						cont = FALSE
						break
			if(cont && D.is_operational())
				if(D.operating)
					D.nextstate = opening ? FD_OPEN : FD_CLOSED
				else if(!(D.density ^ opening))
					INVOKE_ASYNC(D, (opening ? /obj/machinery/door/firedoor.proc/open : /obj/machinery/door/firedoor.proc/close))

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

	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C) && is_station_level(C.z))
			C.network |= "Fire Alarms"

	SSalarm.triggerAlarm("Fire", src, cameras, source)

	START_PROCESSING(SSobj, src)

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
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()

	for(var/thing in cameras)
		var/obj/machinery/camera/C = locateUID(thing)
		if(!QDELETED(C) && is_station_level(C.z))
			C.network -= "Fire Alarms"

	SSalarm.cancelAlarm("Fire", src, source)

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

	if(SSalarm.triggerAlarm("Burglar", src, cameras, trigger))
		//Cancel silicon alert after 1 minute
		addtimer(CALLBACK(SSalarm, /datum/controller/subsystem/alarm.proc/cancelAlarm, "Burglar", src, trigger), 600)

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
	for(var/obj/machinery/light/L in src)
		L.update()

/**
  * unset the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/unset_fire_alarm_effects()
	fire = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	for(var/obj/machinery/light/L in src)
		L.update()

/area/proc/updateicon()
	var/weather_icon
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.stage != END_STAGE && (src in W.impacted_areas))
			W.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null

/area/space/updateicon()
	icon_state = null

/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

/area/space/powered(chan) //Nope.avi
	return 0

/**
  * Called when the area power status changes
  *
  * Updates the area icon, calls power change on all machines in the area, and sends the `COMSIG_AREA_POWER_CHANGE` signal.
  */
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	SEND_SIGNAL(src, COMSIG_AREA_POWER_CHANGE)
	updateicon()

/area/proc/usage(var/chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
		if(STATIC_EQUIP)
			used += static_equip
		if(STATIC_LIGHT)
			used += static_light
		if(STATIC_ENVIRON)
			used += static_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()

	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(var/amount, var/chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/proc/use_battery_power(var/amount, var/chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount


/area/Entered(A)
	var/area/newarea
	var/area/oldarea

	if(istype(A,/mob))
		var/mob/M=A

		if(!M.lastarea)
			M.lastarea = get_area(M)
		newarea = get_area(M)
		oldarea = M.lastarea

		if(newarea==oldarea) return

		M.lastarea = src

	if(!istype(A,/mob/living))	return

	var/mob/living/L = A
	if(!L.ckey)	return
	if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (L.m_intent == MOVE_INTENT_RUN)) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(L && L.client && !L.client.ambience_playing && (L.client.prefs.sound & SOUND_BUZZ))	//split off the white noise from the rest of the ambience because of annoyance complaints - Kluys
		L.client.ambience_playing = TRUE
		SEND_SOUND(L, sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = FALSE, volume = 35 * L.client.prefs.get_channel_volume(CHANNEL_BUZZ), channel = CHANNEL_BUZZ))
	else if(L && L.client && !(L.client.prefs.sound & SOUND_BUZZ))
		L.client.ambience_playing = FALSE

	if(prob(35) && L && L.client && (L.client.prefs.sound & SOUND_AMBIENCE))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			SEND_SOUND(L, sound(sound, repeat = FALSE, wait = FALSE, volume = 25 * L.client.prefs.get_channel_volume(CHANNEL_AMBIENCE), channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/**
  * Reset the played var to false on the client
  */
/client/proc/ResetAmbiencePlayed()
	played = FALSE

/area/proc/gravitychange(var/gravitystate = 0, var/area/A)
	A.has_gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/M in A)
			thunk(M)

/area/proc/thunk(var/mob/living/carbon/human/M)
	if(istype(M,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		if(istype(M.shoes, /obj/item/clothing/shoes/magboots) && (M.shoes.flags & NOSLIP))
			return

	if(M.dna.species.spec_thunk(M)) //Species level thunk overrides
		return

	if(M.buckled) //Cam't fall down if you are buckled
		return

	if(istype(get_turf(M), /turf/space)) // Can't fall onto nothing.
		return

	if((istype(M,/mob/living/carbon/human/)) && (M.m_intent == MOVE_INTENT_RUN))
		M.Stun(5)
		M.Weaken(5)

	else if(istype(M,/mob/living/carbon/human/))
		M.Stun(2)
		M.Weaken(2)


	to_chat(M, "Gravity!")

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT)
	var/area/A = get_area(T)
	if(istype(T, /turf/space)) // Turf never has gravity
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
		INVOKE_ASYNC(temp_apc, /obj/machinery/power/apc.proc/overload_lighting, 70)
	for(var/obj/machinery/door/airlock/temp_airlock in src)
		temp_airlock.prison_open()
	for(var/obj/machinery/door/window/temp_windoor in src)
		temp_windoor.open()

/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/area/drop_location()
	CRASH("Bad op: area/drop_location() called")
