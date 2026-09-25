RESTRICT_TYPE(/datum/weather/sleet_storm)

/datum/weather/sleet_storm
	name = "Sleet storm"
	desc = "An intense freezing rain hurtles down on the area, obstructing visibility."

	telegraph_message = "<span class='boldwarning'>The air around you grows colder, and the clouds darken. Seek shelter.</span>"
	telegraph_overlay = "light_snow"

	weather_message = "<span class='userdanger'><i>You are caught in a storm of freezing rain! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "snow_storm"

	end_message = "<span class='boldannounceic'>The sleet slows, and the patter of ice on the ground softens. It should be safe to go outside now.</span>"
	end_overlay = "light_snow"

	area_types = list(/area/iceplanet/surface)
	target_trait = ZTRAIT_WINTER_LEVEL
	immunity_type = "snow"
	probability = 25
	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)


/datum/weather/sleet_storm/update_eligible_areas()
	. = ..()
	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

/datum/weather/sleet_storm/update_audio()
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

/datum/weather/sleet_storm/on_shelter_placed(datum/source, turf/center)
	. = ..()
	if(center.z in impacted_z_levels)
		var/area/A = get_area(center)
		inside_areas |= A
		sound_ai.output_atoms |= A
		sound_wi.output_atoms |= A

/datum/weather/sleet_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(5, 15))
