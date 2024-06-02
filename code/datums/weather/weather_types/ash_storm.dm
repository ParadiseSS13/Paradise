//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounceic'>The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_trait = ORE_LEVEL

	immunity_type = "ash"

	probability = 90

	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/ash_storm/proc/is_shuttle_docked(shuttleId, dockId)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	return M && M.getDockedId() == dockId

/datum/weather/ash_storm/proc/update_eligible_areas()
	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += GLOB.space_manager.areas_in_z["[z]"]

	// Don't play storm audio to shuttles that are not at lavaland
	var/miningShuttleDocked = is_shuttle_docked("mining", "mining_away")
	if(!miningShuttleDocked)
		eligible_areas -= get_areas(/area/shuttle/mining)

	var/laborShuttleDocked = is_shuttle_docked("laborcamp", "laborcamp_away")
	if(!laborShuttleDocked)
		eligible_areas -= get_areas(/area/shuttle/siberia)

	var/golemShuttleOnPlanet = is_shuttle_docked("freegolem", "freegolem_lavaland")
	if(!golemShuttleOnPlanet)
		eligible_areas -= get_areas(/area/shuttle/freegolem)

	for(var/i in 1 to length(eligible_areas))
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			outside_areas += place
		else
			inside_areas += place
		CHECK_TICK

	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

/datum/weather/ash_storm/proc/update_audio()
	switch(stage)
		if(WEATHER_STARTUP_STAGE)
			sound_wo.start()
			sound_wi.start()

		if(WEATHER_MAIN_STAGE)
			sound_wo.stop()
			sound_wi.stop()

			sound_ao.start()
			sound_ai.start()

		if(WEATHER_WIND_DOWN_STAGE)
			sound_ao.stop()
			sound_ai.stop()

			sound_wo.start()
			sound_wi.start()

		if(WEATHER_END_STAGE)
			sound_wo.stop()
			sound_wi.stop()

/datum/weather/ash_storm/telegraph()
	. = ..()
	update_eligible_areas()
	update_audio()

/datum/weather/ash_storm/start()
	. = ..()
	update_audio()

/datum/weather/ash_storm/wind_down()
	. = ..()
	update_audio()

/datum/weather/ash_storm/end()
	. = ..()
	update_audio()

/datum/weather/ash_storm/proc/is_ash_immune(atom/L)
	while(L && !isturf(L))
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(ishuman(L)) //Are you immune?
			var/mob/living/carbon/human/H = L
			var/thermal_protection = H.get_thermal_protection()
			if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
				return TRUE
		L = L.loc //Matryoshka check
	return FALSE //RIP you

/datum/weather/ash_storm/weather_act(mob/living/L)
	if(is_ash_immune(L))
		return
	L.adjustFireLoss(4)


//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"
	end_sound = null

	aesthetic = TRUE

	probability = 10
