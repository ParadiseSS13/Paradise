//Causes fire damage to anyone not standing on a dense object.
/datum/weather/floor_is_lava
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = SPAN_WARNING("You feel the ground beneath you getting hot. Waves of heat distort the air.")
	telegraph_duration = 150

	weather_message = SPAN_USERDANGER("The floor is lava! Get on top of something!")
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = SPAN_DANGER("The ground cools and returns to its usual form.")
	end_duration = 0

	area_types = list(/area)
	protected_areas = list(/area/space)

	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only
	overlay_plane = FLOOR_PLANE
	immunity_type = "lava"


/datum/weather/floor_is_lava/weather_act(mob/living/L)
	if(issilicon(L))
		return
	if(istype(L.buckled, /obj/structure/bed))
		return
	for(var/obj/structure/O in L.loc)
		if(O.density)
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	if(HAS_TRAIT(L, TRAIT_FLYING))
		return
	L.adjustFireLoss(3)

/datum/weather/floor_is_lava/fake
	name = "the floor is lava (fake)"
	aesthetic = TRUE
