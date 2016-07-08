// Areas.dm

// ===
/area
	var/global/global_uid = 0
	var/uid
	var/list/ambientsounds = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg',\
								'sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg',\
								'sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg',\
								'sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg',\
								'sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg',\
								'sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg')


/area/New()
	icon_state = ""
	layer = 10
	uid = ++global_uid
	all_areas += src

	if(type == /area)	// override defaults for space. TODO: make space areas of type /area/space rather than /area
		requires_power = 1
		always_unpowered = 1
		lighting_use_dynamic = 1
		power_light = 0
		power_equip = 0
		power_environ = 0
//		lighting_state = 4
		//has_gravity = 0    // Space has gravity.  Because.. because.

	if(!requires_power)
		power_light = 0			//rastaf0
		power_equip = 0			//rastaf0
		power_environ = 0		//rastaf0

	..()

//	spawn(15)
	power_change()		// all machines set to current power level, also updates lighting icon

/area/proc/get_cameras()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in src)
		cameras += C
	return cameras


/area/proc/atmosalert(danger_level, var/alarm_source)
	if(danger_level == 0)
		atmosphere_alarm.clearAlarm(src, alarm_source)
	else
		atmosphere_alarm.triggerAlarm(src, alarm_source, severity = danger_level)

	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for(var/obj/machinery/alarm/AA in src)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.report_danger_level)
			danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if(danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()
		else if(danger_level >= 2 && atmosalm < 2)
			air_doors_close()

		atmosalm = danger_level
		for(var/obj/machinery/alarm/AA in src)
			AA.update_icon()

		air_alarm_repository.update_cache(src)
		return 1
	air_alarm_repository.update_cache(src)
	return 0

/area/proc/air_doors_close()
	if(!src.air_doors_activated)
		src.air_doors_activated = 1
		for(var/obj/machinery/door/firedoor/E in src.all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = CLOSED
				else if(!E.density)
					spawn(0)
						E.close()

/area/proc/air_doors_open()
	if(src.air_doors_activated)
		src.air_doors_activated = 0
		for(var/obj/machinery/door/firedoor/E in src.all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = OPEN
				else if(E.density)
					spawn(0)
						E.open()


/area/proc/fire_alert()
	if(!fire)
		fire = 1	//used for firedoor checks
		updateicon()
		mouse_opacity = 0
		air_doors_close()

/area/proc/fire_reset()
	if(fire)
		fire = 0	//used for firedoor checks
		updateicon()
		mouse_opacity = 0
		air_doors_open()

	return

/area/proc/burglaralert(var/obj/trigger)
	if(always_unpowered == 1) //no burglar alarms in space/asteroid
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
	fire = 1
	updateicon()
	mouse_opacity = 0

/area/proc/readyalert()
	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/radiation_alert()
	if(!radalert)
		radalert = 1
		updateicon()
	return

/area/proc/reset_radiation_alert()
	if(radalert)
		radalert = 0
		updateicon()
	return

/area/proc/partyalert()
	if(!( party ))
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if(party)
		party = 0
		mouse_opacity = 0
		updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
						D.open()
	return

/area/proc/updateicon()
	if(radalert) // always show the radiation alert, regardless of power
		icon_state = "radiation"
		blend_mode = BLEND_MULTIPLY
	else if((fire || eject || party) && (!requires_power||power_environ))//If it doesn't require power, can still activate this proc.
		if(fire && !radalert && !eject && !party)
			icon_state = "red"
			blend_mode = BLEND_MULTIPLY
		/*else if(atmosalm && !fire && !eject && !party)
			icon_state = "bluenew"*/
		else if(!fire && eject && !party)
			icon_state = "red"
			blend_mode = BLEND_MULTIPLY
		else if(party && !fire && !eject)
			icon_state = "party"
			blend_mode = BLEND_MULTIPLY
		else
			icon_state = "blue-red"
			blend_mode = BLEND_MULTIPLY
	else
	//	new lighting behaviour with obj lights
		icon_state = null
		blend_mode = BLEND_DEFAULT

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

// called when power status changes

/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	if(fire || eject || party)
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
			M.lastarea = get_area_master(M)
		newarea = get_area_master(M)
		oldarea = M.lastarea

		if(newarea==oldarea) return

		M.lastarea = src

		// /vg/ - EVENTS!
		CallHook("MobAreaChange", list("mob" = M, "new" = newarea, "old" = oldarea))

	if(!istype(A,/mob/living))	return

	var/mob/living/L = A
	if(!L.ckey)	return
	if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (L.m_intent == "run")) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(L && L.client && !L.client.ambience_playing && (L.client.prefs.sound & SOUND_BUZZ))	//split off the white noise from the rest of the ambience because of annoyance complaints - Kluys
		L.client.ambience_playing = 1
		L << sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = 2)
	else if(L && L.client && !(L.client.prefs.sound & SOUND_BUZZ)) L.client.ambience_playing = 0

	if(prob(35) && !newarea.media_source && L && L.client && (L.client.prefs.sound & SOUND_AMBIENCE))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			L << sound(sound, repeat = 0, wait = 0, volume = 25, channel = 1)
			L.client.played = 1
			spawn(600)			//ewww - this is very very bad
				if(L.&& L.client)
					L.client.played = 0

/area/proc/gravitychange(var/gravitystate = 0, var/area/A)
	A.has_gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/M in A)
			thunk(M)

/area/proc/thunk(var/mob/living/carbon/human/M)
	if(istype(M,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		if(istype(M.shoes, /obj/item/clothing/shoes/magboots) && (M.shoes.flags & NOSLIP))
			return

	if(M.buckled) //Cam't fall down if you are buckled
		return

	if(istype(get_turf(M), /turf/space)) // Can't fall onto nothing.
		return

	if((istype(M,/mob/living/carbon/human/)) && (M.m_intent == "run")).
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
		if(T && gravity_generators["[T.z]"] && length(gravity_generators["[T.z]"]))
			return 1
	return 0

/area/proc/prison_break()
	for(var/obj/machinery/power/apc/temp_apc in src)
		temp_apc.overload_lighting(70)
	for(var/obj/machinery/door/airlock/temp_airlock in src)
		temp_airlock.prison_open()
	for(var/obj/machinery/door/window/temp_windoor in src)
		temp_windoor.open()