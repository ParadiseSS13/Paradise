// Areas.dm

// ===
/area
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	luminosity = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	var/map_name // Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.
	var/valid_territory = TRUE //used for cult summoning areas on station zlevel
	var/lightswitch = TRUE
	var/fire = null // used for fire alarms
	var/atmosalm = ATMOS_ALARM_NONE
	var/party = null // used for party alarms
	var/report_alerts = TRUE // Should atmos alerts notify the AI/computers

	var/music = null
	var/eject = null

	var/requires_power = TRUE
	var/always_unpowered = FALSE	//this gets overriden to 1 for space in area/New()
	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE


	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip
	var/static_light = 0
	var/static_environ

	var/dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	var/outdoors = FALSE // For space, the asteroid, lavaland, etc. Used with blueprints to determine if we are adding a new area (vs editing a station room)
	var/xenobiology_compatible = FALSE // Can the Xenobio management console transverse this area by default?
	var/has_gravity = TRUE
	var/list/apc = list()

	/// If false, loading multiple maps with this area type will create multiple instances.
	var/unique = TRUE

	var/air_doors_activated = FALSE

	var/tele_proof = FALSE
	var/no_teleportlocs = FALSE

	var/global/global_uid = 0
	var/uid
	var/list/ambientsounds = GENERIC

	// This var is used with the maploader (modules/awaymissions/maploader/reader.dm)
	// if this is 1, when used in a map snippet, this will instantiate a unique
	// area from any other instances already present (meaning you can have
	// separate APCs, and so on)
	var/there_can_be_many = FALSE


/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if (unique)
		GLOB.areas_by_type[type] = src
	return ..()

/area/Initialize()
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

	/*if(requires_power != 0)
		power_light = 0			//rastaf0
		power_equip = 0			//rastaf0
		power_environ = 0		//rastaf0
		*/
	. = ..()

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	if(contents.len)
		var/list/areas_in_z = space_manager.areas_in_z
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

	return INITIALIZE_HINT_LATELOAD

/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon

/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	return ..()

/area/proc/get_cameras()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in src)
		cameras += C
	return cameras


/area/proc/atmosalert(danger_level, var/alarm_source, var/force = FALSE)
	if(danger_level == ATMOS_ALARM_NONE)
		atmosphere_alarm.clearAlarm(src, alarm_source)
	else
		atmosphere_alarm.triggerAlarm(src, alarm_source, severity = danger_level)

	//Check all the alarms before lowering atmosalm. Raising is perfectly fine. If force = 1 we don't care.
	for(var/obj/machinery/alarm/AA in src)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.report_danger_level && !force)
			danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if(danger_level < ATMOS_ALARM_WARNING && atmosalm >= ATMOS_ALARM_WARNING)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()
		else if(danger_level >= ATMOS_ALARM_DANGER && atmosalm < ATMOS_ALARM_DANGER)
			air_doors_close()

		atmosalm = danger_level
		for(var/obj/machinery/alarm/AA in src)
			AA.update_icon()

		air_alarm_repository.update_cache(src)
		return 1
	air_alarm_repository.update_cache(src)
	return 0

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


/area/proc/fire_alert()
	if(!fire)
		fire = TRUE	//used for firedoor checks
		updateicon()
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		air_doors_close()

/area/proc/fire_reset()
	if(fire)
		fire = FALSE	//used for firedoor checks
		updateicon()
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		air_doors_open()

	return

/area/proc/burglaralert(var/obj/trigger)
	if(always_unpowered) //no burglar alarms in space/asteroid
		return

	//Trigger alarm effect
	set_fire_alarm_effect()

	//Lockdown airlocks
	for(var/obj/machinery/door/airlock/A in src)
		spawn(0)
			A.close()
			if(A.density)
				A.lock()

	burglar_alarm.triggerAlarm(src, trigger)
	spawn(600)
		burglar_alarm.clearAlarm(src, trigger)

/area/proc/set_fire_alarm_effect()
	fire = TRUE
	updateicon()
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/area/proc/readyalert()
	if(!eject)
		eject = TRUE
		updateicon()

/area/proc/readyreset()
	if(eject)
		eject = FALSE
		updateicon()

/area/proc/partyalert()
	if(!party)
		party = TRUE
		updateicon()
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/area/proc/partyreset()
	if(party)
		party = FALSE
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		updateicon()

/area/proc/updateicon()
	if((fire || eject || party) && (!requires_power||power_environ))//If it doesn't require power, can still activate this proc.
		if(fire && !eject && !party)
			icon_state = "red"
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
		invisibility = INVISIBILITY_LIGHTING
	else
		var/weather_icon
		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.stage != END_STAGE && (src in W.impacted_areas))
				W.update_areas()
				weather_icon = TRUE
		if(!weather_icon)
			icon_state = null
			invisibility = INVISIBILITY_MAXIMUM

/area/space/updateicon()
	icon_state = null
	invisibility = INVISIBILITY_MAXIMUM


/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return FALSE

/area/space/powered(chan) //Nope.avi
	return FALSE

// called when power status changes

/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
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

		// /vg/ - EVENTS!
		callHook("mob_area_change", list("mob" = M, "newarea" = newarea, "oldarea" = oldarea))

	if(!istype(A,/mob/living))	return

	var/mob/living/L = A
	if(!L.ckey)	return
	if((oldarea.has_gravity == FALSE) && (newarea.has_gravity == TRUE) && (L.m_intent == MOVE_INTENT_RUN)) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(L && L.client && !L.client.ambience_playing && (L.client.prefs.sound & SOUND_BUZZ))	//split off the white noise from the rest of the ambience because of annoyance complaints - Kluys
		L.client.ambience_playing = TRUE
		L << sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = 0, volume = 35, channel = CHANNEL_BUZZ)
	else if(L && L.client && !(L.client.prefs.sound & SOUND_BUZZ))
		L.client.ambience_playing = FALSE

	if(prob(35) && L && L.client && (L.client.prefs.sound & SOUND_AMBIENCE))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			L << sound(sound, repeat = FALSE, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE)
			L.client.played = TRUE
			spawn(600)			//ewww - this is very very bad
				if(L.&& L.client)
					L.client.played = FALSE

/area/proc/gravitychange(var/gravitystate = FALSE, var/area/A)
	A.has_gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/M in A)
			thunk(M)

/area/proc/thunk(var/mob/living/carbon/human/M)
	if(istype(M,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		if(istype(M.shoes, /obj/item/clothing/shoes/magboots) && (M.shoes.flags & NOSLIP))
			return

	if(M.buckled) // Can't fall down if you are buckled
		return

	if(istype(get_turf(M), /turf/space)) // Can't fall onto nothing.
		return

	if((istype(M,/mob/living/carbon/human/)) && (M.m_intent == MOVE_INTENT_RUN)).
		M.Stun(5)
		M.Weaken(5)

	else if(istype(M,/mob/living/carbon/human/))
		M.Stun(2)
		M.Weaken(2)


	to_chat(M, "<span class='warning'>Gravity!</span>")

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT)
	var/area/A = get_area(T)
	if(istype(T, /turf/space)) // Turf never has gravity
		return FALSE
	else if(A && A.has_gravity) // Areas which always has gravity
		return TRUE
	else
		// There's a gravity generator on our z level
		// This would do well when integrated with the z level manager
		if(T && gravity_generators["[T.z]"] && length(gravity_generators["[T.z]"]))
			return TRUE
	return FALSE

/area/proc/prison_break()
	for(var/obj/machinery/power/apc/temp_apc in src)
		temp_apc.overload_lighting(70)
	for(var/obj/machinery/door/airlock/temp_airlock in src)
		temp_airlock.prison_open()
	for(var/obj/machinery/door/window/temp_windoor in src)
		temp_windoor.open()

/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/area/drop_location()
	CRASH("Bad op: area/drop_location() called")
