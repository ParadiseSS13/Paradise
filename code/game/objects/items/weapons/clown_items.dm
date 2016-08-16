/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M =	AM
		M.slip("banana peel", 4, 2)

/*
 * Soap
 */
/obj/item/weapon/soap/Crossed(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip("soap", 4, 2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(target == user && user.a_intent == I_GRAB && ishuman(target))
		var/mob/living/carbon/human/muncher = user
		if(muncher && muncher.get_species() == "Drask")
			to_chat(user, "You take a bite of the [src.name]. Delicious!")
			playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
			user.nutrition += 2
	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("<span class='warning'>[user] begins to scrub \the [target.name] out with [src].</span>")
		if(do_after(user, src.cleanspeed, target = target) && target)
			to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
			qdel(target)
	else
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src].</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("\red \the [user] washes \the [target]'s mouth out with [src.name]!")
		return
	..()

/*
 * Bike Horns
 */

/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	hitsound = null
	throwforce = 3
	w_class = 1
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/spam_flag = 0
	var/honk_sound = 'sound/items/bikehorn.ogg'
	var/cooldowntime = 20

/obj/item/weapon/bikehorn/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!spam_flag)
		playsound(loc, honk_sound, 50, 1, -1) //plays instead of tap.ogg!
	return ..()

/obj/item/weapon/bikehorn/attack_self(mob/user)
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, honk_sound, 50, 1)
		src.add_fingerprint(user)
		spawn(cooldowntime)
			spam_flag = 0
	return


/obj/item/weapon/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	honk_sound = 'sound/items/AirHorn2.ogg'
	cooldowntime = 50

/obj/item/weapon/bikehorn/golden
	name = "golden bike horn"
	desc = "Golden? Clearly, its made with bananium! Honk!"
	icon_state = "gold_horn"
	item_state = "gold_horn"

/obj/item/weapon/bikehorn/golden/attack()
	flip_mobs()
	return ..()

/obj/item/weapon/bikehorn/golden/attack_self(mob/user)
	flip_mobs()
	..()

/obj/item/weapon/bikehorn/golden/proc/flip_mobs(mob/living/carbon/M, mob/user)
	if(!spam_flag)
		var/turf/T = get_turf(src)
		for(M in ohearers(7, T))
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs) || H.ear_deaf)
					continue
			M.emote("flip")