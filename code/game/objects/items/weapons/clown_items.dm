/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Bike Horns
 */

/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	hitsound = null
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	var/list/honk_sounds = list('sound/items/bikehorn.ogg' = 1)
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")

/obj/item/bikehorn/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, honk_sounds, 50)

/obj/item/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	origin_tech = "materials=4;engineering=4"
	honk_sounds = list('sound/items/airhorn2.ogg' = 1)

/obj/item/bikehorn/golden
	name = "golden bike horn"
	desc = "Golden? Clearly, its made with bananium! Honk!"
	icon_state = "gold_horn"
	item_state = "gold_horn"

/obj/item/bikehorn/golden/attack()
	flip_mobs()
	return ..()

/obj/item/bikehorn/golden/attack_self(mob/user)
	flip_mobs()
	..()

/obj/item/bikehorn/golden/proc/flip_mobs(mob/living/carbon/M, mob/user)
	var/turf/T = get_turf(src)
	for(M in ohearers(7, T))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!H.can_hear())
				continue
		M.emote("flip")
