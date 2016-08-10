//Used for all kinds of weather, ex. lavaland ash storms.
// TODO: This could probably be better-integrated with the space manager
var/global/datum/controller/process/weather/weather_master

/datum/controller/process/weather
	var/list/processing_weather = list()
	var/list/existing_weather = list()
	var/list/eligible_zlevels = list()

/datum/controller/process/weather/setup()
	name = "weather"
	schedule_interval = 10
	weather_master = src

	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		existing_weather |= new W

/datum/controller/process/weather/statProcess()
	..()
	stat(null, "[processing_weather.len] weather")

/datum/controller/process/weather/doWork()
	for(var/V in processing_weather)
		var/datum/weather/W = V
		if(W.aesthetic)
			continue
		for(var/mob/living/L in mob_list)
			if(W.can_impact(L))
				W.impact(L)
				SCHECK
	for(var/Z in eligible_zlevels)
		var/list/possible_weather_for_this_z = list()
		for(var/V in existing_weather)
			var/datum/weather/WE = V
			if(WE.target_level == Z && WE.probability) //Another check so that it doesn't run extra weather
				possible_weather_for_this_z[WE] = WE.probability
		var/datum/weather/W = pickweight(possible_weather_for_this_z)
		run_weather(W.name)
		eligible_zlevels -= Z
		addtimer(src, "make_z_eligible", rand(3000, 6000) + W.weather_duration_upper, TRUE, Z) //Around 5-10 minutes between weathers

/datum/controller/process/weather/proc/run_weather(weather_name)
	if(!weather_name)
		return
	for(var/V in existing_weather)
		var/datum/weather/W = V
		if(W.name == weather_name)
			W.telegraph()
			SCHECK

/datum/controller/process/weather/proc/make_z_eligible(zlevel)
	eligible_zlevels |= zlevel
