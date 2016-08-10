//The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

/datum/weather
	var/name = "space wind"
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."

	var/telegraph_message = "<span class='warning'>The wind begins to pick up.</span>" //The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_duration = 300 //In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_sound //The sound file played to everyone on an affected z-level
	var/telegraph_overlay //The overlay applied to all tiles on the z-level

	var/weather_message = "<span class='userdanger'>The wind begins to blow ferociously!</span>" //Displayed in chat once the weather begins in earnest
	var/weather_duration = 1200 //In deciseconds, how long the weather lasts once it begins
	var/weather_duration_lower = 1200 //See above - this is the lowest possible duration
	var/weather_duration_upper = 1500 //See above - this is the highest possible duration
	var/weather_sound
	var/weather_overlay

	var/end_message = "<span class='danger'>The wind relents its assault.</span>" //Displayed once the wather is over
	var/end_duration = 300 //In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_sound
	var/end_overlay

	var/area_type = /area/space //Types of area to affect
	var/list/impacted_areas = list() //Areas to be affected by the weather, calculated when the weather begins
	var/target_level = MAIN_STATION //The z-level to affect

	var/overlay_layer = 10 //Since it's above everything else, this is the layer used by default. 2 is below mobs and walls if you need to use that.
	var/aesthetic = FALSE //If the weather has no purpose other than looks
	var/immunity_type = "storm" //Used by mobs to prevent them from being affected by the weather

	var/stage = END_STAGE //The stage of the weather, from 1-4

	var/probability = FALSE //Percent chance to happen if there are other possible weathers on the z-level

/datum/weather/New()
	..()
	weather_master.existing_weather |= src

/datum/weather/Destroy()
	weather_master.existing_weather -= src
	return ..()

/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	stage = STARTUP_STAGE
	for(var/V in get_areas(area_type))
		var/area/A = V
		if(is_on_level_name(A,target_level))
			impacted_areas |= A
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	update_areas()
	for(var/V in player_list)
		var/mob/M = V
		if(is_on_level_name(M,target_level))
			if(telegraph_message)
				to_chat(M, telegraph_message)
			if(telegraph_sound)
				M << sound(telegraph_sound)
	addtimer(src, "start", telegraph_duration)

/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	stage = MAIN_STAGE
	update_areas()
	for(var/V in player_list)
		var/mob/M = V
		if(is_on_level_name(M,target_level))
			if(weather_message)
				to_chat(M, weather_message)
			if(weather_sound)
				M << sound(weather_sound)
	weather_master.processing_weather |= src
	addtimer(src, "wind_down", weather_duration)

/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/V in player_list)
		var/mob/M = V
		if(is_on_level_name(M,target_level))
			if(end_message)
				to_chat(M, end_message)
			if(end_sound)
				M << sound(end_sound)
	weather_master.processing_weather -= src
	addtimer(src, "end", end_duration)

/datum/weather/proc/end()
	if(stage == END_STAGE)
		return
	stage = END_STAGE
	update_areas()

/datum/weather/proc/can_impact(mob/living/L) //Can this weather impact a mob?
	if(!is_on_level_name(L,target_level))
		return
	if(immunity_type in L.weather_immunities)
		return
	if(!(get_area(L) in impacted_areas))
		return
	return 1

/datum/weather/proc/impact(mob/living/L) //What effect does this weather have on the hapless mob?
	return

/datum/weather/proc/update_areas()
	for(var/V in impacted_areas)
		var/area/N = V
		N.layer = overlay_layer
		N.icon = 'icons/effects/weather_effects.dmi'
		N.invisibility = 0
		switch(stage)
			if(STARTUP_STAGE)
				N.icon_state = telegraph_overlay
			if(MAIN_STAGE)
				N.icon_state = weather_overlay
			if(WIND_DOWN_STAGE)
				N.icon_state = end_overlay
			if(END_STAGE)
				N.icon_state = initial(N.icon_state)
				N.icon = 'icons/turf/areas.dmi'
				N.layer = 10 //Just default back to normal area stuff since I assume setting a var is faster than initial
				N.invisibility = INVISIBILITY_MAXIMUM
				N.opacity = 0
