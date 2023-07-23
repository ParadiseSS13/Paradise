/datum/weather/solar_flare
	name = "solar flare"
	desc = "An intense blast of light and heat from the sun, affecting all space around the station."

	telegraph_duration = 40 SECONDS
	telegraph_message = null // handled via event announcement

	weather_message = "<span class='userdanger'><i>A solar flare has arrived! Do not conduct space walks or approach windows until the flare has passed!</i></span>"
	weather_overlay = "light_ash"
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 5 MINUTES
	weather_color = COLOR_YELLOW
	weather_sound = 'sound/misc/bloblarm.ogg' // also used by radiation storm and SM

	end_duration = 10 // wind_down() does not do anything for this event, so we just trigger end() semi-immediately
	end_message = null
	area_type = /area // read generate_area_list() as well below
	protected_areas = list(/area/shuttle/arrival/station)
	target_trait = STATION_LEVEL
	immunity_type = "burn"
	var/damage = 4
	/// Areas which are "semi-protected". Mobs inside these areas take reduced burn damage from the solar flare.
	var/list/semi_protected_areas = list(/area/hallway/secondary/entry)

/datum/weather/solar_flare/generate_area_list()
	..()
	var/list/bonus_areas = get_areas(/area/solar)
	// no, solars in space are NOT a subtype of /area/space.
	// no, we don't want to re-path every reference to all the subtypes of /area/solar across every map file.
	// no, we don't want to change /datum/weather/var/area_type into a list as that requires changing every item that touches weather
	for(var/V in bonus_areas)
		var/area/A = V
		if(A.z in impacted_z_levels)
			impacted_areas |= A

/datum/weather/solar_flare/start()
	..()
	// Solars produce 40x as much power. 240KW becomes 9.6MW. Enough to cause APCs to arc all over the station if >=2 solars are hotwired.
	SSsun.solar_gen_rate = initial(SSsun.solar_gen_rate) * 40

/datum/weather/solar_flare/can_weather_act(mob/living/L)
	if(isanimal(L)) //while this might break immersion, I don't want to spam the server with calling this on simplemobs
		return FALSE
	if(isdrone(L)) //same with poor maint drones who just wanna have fun
		return FALSE
	. = ..()
	if(!.) // If false the mob is not currently a valid target, no need to keep processing
		return FALSE
	for(var/turf/T in oview(get_turf(L)))
		if(isspaceturf(T) || istransparentturf(T))
			return TRUE
	return FALSE

/datum/weather/solar_flare/weather_act(mob/living/L)
	var/target_area = get_area(L)
	if(target_area in protected_areas) // We do wanna protect new arrivals from horrible death.
		return
	var/adjusted_damage = damage
	if(target_area in semi_protected_areas)
		adjusted_damage = 1
	L.adjustFireLoss(adjusted_damage)
	L.flash_eyes()
	if(prob(25))
		to_chat(L, "<span class='warning'>The solar flare burns you! Seek shelter!</span>")

/datum/weather/solar_flare/end()
	if(..())
		return
	GLOB.minor_announcement.Announce("The solar flare has passed.", "Solar Flare Advisory")
	// Ends the temporary 40x increase that happened during the weather event
	SSsun.solar_gen_rate = initial(SSsun.solar_gen_rate)
