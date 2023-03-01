/datum/weather/solar_flare
	name = "solar flare"
	desc = "An intense blast of light and heat from the sun, affecting all space around the station."

	telegraph_duration = 30 SECONDS
	telegraph_message = null // handled via event announcement

	weather_message = "<span class='userdanger'><i>Началась солнечная вспышка! Найдите укрытие!</i></span>"
	weather_overlay = "light_ash"
	weather_duration_lower = 5 MINUTES
	weather_duration_upper = 10 MINUTES
	weather_color = COLOR_YELLOW
	weather_sound = 'sound/misc/bloblarm.ogg' // also used by radiation storm and SM

	end_duration = 10 // wind_down() does not do anything for this event, so we just trigger end() semi-immediately
	end_message = null
	area_type = /area/space // read generate_area_list() as well below
	protected_areas = list()
	target_trait = STATION_LEVEL
	immunity_type = "burn"

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

/datum/weather/solar_flare/weather_act(mob/living/L)
	L.adjustFireLoss(1)
	if(prob(10))
		to_chat(L, "<span class='warning'Солнечная вспышка сжигает вас! Ищите укрытие!</span>")

/datum/weather/solar_flare/end()
	if(..())
		return
	GLOB.event_announcement.Announce("Солнечная вспышка прошла.", "ОПОВЕЩЕНИЕ: СОЛНЕЧНАЯ ВСПЫШКА.")
	// Ends the temporary 40x increase that happened during the weather event
	SSsun.solar_gen_rate = initial(SSsun.solar_gen_rate)
