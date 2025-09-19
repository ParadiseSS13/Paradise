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
	icon_state = "bike_horn"
	inhand_icon_state = "bike_horn"
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	var/list/honk_sounds = list('sound/items/bikehorn.ogg' = 1)
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")

/obj/item/bikehorn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, honk_sounds, 50, falloff_exponent = 20) //die off quick please

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
	inhand_icon_state = "gold_horn"
	var/cooldown = 0

/obj/item/bikehorn/golden/attack__legacy__attackchain(mob/M, mob/user)
	flip_mobs(user)
	return ..()

/obj/item/bikehorn/golden/attack_self__legacy__attackchain(mob/user)
	flip_mobs(user)
	..()

/obj/item/bikehorn/golden/proc/flip_mobs(mob/user)
	if(cooldown >= world.time)
		to_chat(user, "<span class='warning'>You can't make others flip yet!</span>")
		return
	cooldown = world.time + 30 SECONDS
	var/turf/T = get_turf(src)
	for(var/mob/living/carbon/M in ohearers(7, T))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.can_hear())
				continue
		M.emote("flip")

#define LAUGH_COOLDOWN 30 SECONDS
#define LAUGH_COOLDOWN_CMAG 10 SECONDS

/obj/item/clown_recorder
	name = "clown recorder"
	desc = "When you just can't get those laughs coming the natural way!"
	icon = 'icons/obj/device.dmi'
	icon_state = "clown_recorder"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 180, MAT_GLASS = 90)
	force = 2
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	actions_types = list(/datum/action/item_action/laugh_track)
	var/cooldown = 0

/obj/item/clown_recorder/attack_self__legacy__attackchain(mob/user)
	if(cooldown > world.time)
		to_chat(user, "<span class='notice'>The tape is still winding back.</span>")
		return
	playsound(src, pick('sound/voice/sitcom_laugh.ogg', 'sound/voice/sitcom_laugh2.ogg'), 50, FALSE)
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		cooldown = world.time + LAUGH_COOLDOWN
	else
		cooldown = world.time + LAUGH_COOLDOWN_CMAG

/obj/item/clown_recorder/cmag_act(mob/user)
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		to_chat(user, "<span class='notice'>Winding back speed has been improved by the bananium ooze!</span>")
		ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
		return TRUE
	return FALSE

#undef LAUGH_COOLDOWN
#undef LAUGH_COOLDOWN_CMAG
