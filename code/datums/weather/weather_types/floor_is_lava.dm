//Causes fire damage to anyone not standing on a dense object.
/datum/weather/floor_is_lava
	name = "пол это лава"
	desc = "Пол превращается в необычно холодную лаву, которая слегка повреждает все, что в неё попадёт."

	telegraph_message = "<span class='warning'>Вы чувствуете, как земля под вами становится всё горячее. Волны жара создают миражи в воздухе.</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>Пол это лава! Взбирайтесь на что-нибудь!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = "<span class='danger'>Пол остывает и возвращается в свое обыкновенное состояние.</span>"
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
	name = "пол это лава (фальшивая)"
	aesthetic = TRUE
