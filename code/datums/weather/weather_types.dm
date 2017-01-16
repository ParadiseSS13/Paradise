//Different types of weather.

/datum/weather/floor_is_lava //The Floor is Lava: Makes all turfs damage anyone on them unless they're standing on a solid object.
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = "<span class='warning'>Waves of heat emanate from the ground...</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>The floor is lava! Get on top of something!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = "<span class='danger'>The ground cools and returns to its usual form.</span>"
	end_duration = 0

	area_type = /area
	target_level = MAIN_STATION

	overlay_layer = 2 //Covers floors only
	immunity_type = "lava"

/datum/weather/floor_is_lava/impact(mob/living/L)
	for(var/obj/structure/O in L.loc)
		if(O.density)
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	L.adjustFireLoss(3)

/datum/weather/floor_is_lava/fake
	name = "fake lava"
	aesthetic = TRUE

/datum/weather/advanced_darkness //Advanced Darkness: Restricts the vision of all affected mobs to a single tile in the cardinal directions.
	name = "advanced darkness"
	desc = "Everything in the area is effectively blinded, unable to see more than a foot or so around itself."

	telegraph_message = "<span class='warning'>The lights begin to dim... is the power going out?</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>This isn't your everyday darkness... this is <i>advanced</i> darkness!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 300

	end_message = "<span class='danger'>At last, the darkness recedes.</span>"
	end_duration = 0

	area_type = /area
	target_level = MAIN_STATION

/datum/weather/advanced_darkness/update_areas()
	for(var/V in impacted_areas)
		var/area/A = V
		if(stage == MAIN_STAGE)
			A.invisibility = 0
			A.opacity = 1
			A.layer = overlay_layer
			A.icon = 'icons/effects/weather_effects.dmi'
			A.icon_state = "darkness"
		else
			A.invisibility = INVISIBILITY_MAXIMUM
			A.opacity = 0


/datum/weather/ash_storm //Ash Storms: Common happenings on lavaland. Heavily obscures vision and deals heavy fire damage to anyone caught outside.
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_sound = 'sound/lavaland/ash_storm_windup.ogg'
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/lavaland/ash_storm_start.ogg'
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounce'>The shrieking wind whips away the last of the ash falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_sound = 'sound/lavaland/ash_storm_end.ogg'
	end_overlay = "light_ash"

	area_type = /area/mine/dangerous
	target_level = MINING

	immunity_type = "ash"

	probability = 90

/datum/weather/ash_storm/impact(mob/living/L)
	if(istype(L.loc, /obj/mecha))
		return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/thermal_protection = H.get_thermal_protection()
		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return
	L.adjustFireLoss(4)

/datum/weather/ash_storm/emberfall //Emberfall: An ash storm passes by, resulting in harmless embers falling like snow. 10% to happen in place of an ash storm.
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_sound = 'sound/lavaland/ash_storm_windup.ogg'
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"

	aesthetic = TRUE

	probability = 10
