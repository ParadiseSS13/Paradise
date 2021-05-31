/datum/weather/naga_snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."

	telegraph_message = "<span class='notice'>Drifting particles of snow begin to dust the surrounding area..</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<span class='notice'><i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i></span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1200

	end_duration = 300
	end_message = "<span class='notice'>The snowfall dies down, it should be safe to go outside again.</span>"

	area_type = /area/snowland/unexplored
	target_trait = PLANET_STORMS

	immunity_type = "snow"

	probability = 90
	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

	barometer_predictable = TRUE

/datum/weather/naga_snow_storm/telegraph()
	. = ..()
	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += GLOB.space_manager.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
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

	sound_wo.start()
	sound_wi.start()


/datum/weather/naga_snow_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(22, 37))

/datum/weather/naga_snow_storm/start()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()

	sound_ao.start()
	sound_ai.start()

/datum/weather/naga_snow_storm/wind_down()
	. = ..()
	sound_ao.stop()
	sound_ai.stop()

	sound_wo.start()
	sound_wi.start()

/datum/weather/naga_snow_storm/end()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()
