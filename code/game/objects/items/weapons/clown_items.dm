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
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/spam_flag = 0
	var/honk_sound = 'sound/items/bikehorn.ogg'
	var/cooldowntime = 20

/obj/item/bikehorn/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!spam_flag)
		playsound(loc, honk_sound, 50, 1, -1) //plays instead of tap.ogg!
	return ..()

/obj/item/bikehorn/attack_self(mob/user)
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, honk_sound, 50, 1)
		src.add_fingerprint(user)
		spawn(cooldowntime)
			spam_flag = 0
	return


/obj/item/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	honk_sound = 'sound/items/AirHorn2.ogg'
	cooldowntime = 50
	origin_tech = "materials=4;engineering=4"

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
	if(!spam_flag)
		var/turf/T = get_turf(src)
		for(M in ohearers(7, T))
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs) || H.ear_deaf)
					continue
			M.emote("flip")
