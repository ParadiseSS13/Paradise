//Causes fire damage to anyone not standing on a dense object.
/datum/weather/floor_is_lava
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = "<span class='warning'>You feel the ground beneath you getting hot. Waves of heat distort the air.</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>The floor is lava! Get on top of something!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = "<span class='danger'>The ground cools and returns to its usual form.</span>"
	end_duration = 0

	area_type = /area
	protected_areas = list(/area/space)
	target_trait = STATION_LEVEL

	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only
	immunity_type = "lava"


/datum/weather/floor_is_lava/weather_act(mob/living/L)
	if(issilicon(L))
		return
	for(var/obj/structure/O in L.loc)
		if(O.density || O.buckled_mob && istype(O, /obj/structure/bed))
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	L.adjustFireLoss(3)

/datum/weather/floor_is_lava/fake
	name = "the floor is lava (fake)"
	aesthetic = TRUE
