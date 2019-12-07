var/global/totaltribbles = 0   //global variable so it updates for all tribbles, not just the new one being made.


/mob/living/simple_animal/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	icon_living = "tribble1"
	icon_dead = "tribble1_dead"
	speak = list("Prrrrr...")
	speak_emote = list("purrs", "trills")
	emote_hear = list("shuffles", "purrs")
	emote_see = list("trundles around", "rolls")
	speak_chance = 10
	turns_per_move = 5
	maxHealth = 10
	health = 10
	butcher_results = list(/obj/item/stack/sheet/fur = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/gestation = 0
	var/maxtribbles = 50     //change this to change the max limit
	wander = 1


/mob/living/simple_animal/tribble/New()
	..()
	var/list/types = list("tribble1","tribble2","tribble3")
	src.icon_state = pick(types)
	src.icon_living = src.icon_state
	src.icon_dead = "[src.icon_state]_dead"
	//random pixel offsets so they cover the floor
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)
	totaltribbles += 1


/mob/living/simple_animal/tribble/attack_hand(mob/user as mob)
	..()
	if(src.stat != DEAD)
		new /obj/item/toy/tribble(user.loc)
		for(var/obj/item/toy/tribble/T in user.loc)
			T.icon_state = src.icon_state
			T.item_state = src.icon_state
			T.gestation = src.gestation
			T.pickup(user)
			user.put_in_active_hand(T)
			qdel(src)


/mob/living/simple_animal/tribble/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/scalpel))
		to_chat(user, "<span class='notice'>You try to neuter the tribble, but it's moving too much and you fail!</span>")
	else if(istype(O, /obj/item/cautery))
		to_chat(user, "<span class='notice'>You try to un-neuter the tribble, but it's moving too much and you fail!</span>")
	..()


/mob/living/simple_animal/tribble/proc/procreate()
	..()
	if(totaltribbles <= maxtribbles)
		for(var/mob/living/simple_animal/tribble/F in src.loc)
			if(!F || F == src)
				new /mob/living/simple_animal/tribble(src.loc)
				gestation = 0


/mob/living/simple_animal/tribble/Life(seconds, times_fired)
	..()
	if(src.health > 0) //no mostly dead procreation
		if(gestation != null) //neuter check
			if(gestation < 30)
				gestation++
			else if(gestation >= 30)
				if(prob(80))
					src.procreate()


/mob/living/simple_animal/tribble/death(gibbed) // Gotta make sure to remove tribbles from the list on death
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	totaltribbles -= 1


//||Item version of the trible ||
/obj/item/toy/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	item_state = "tribble1"
	w_class = 10
	var/gestation = 0
	flags = DROPDEL

/obj/item/toy/tribble/attack_self(mob/user as mob) //hug that tribble (and play a sound if we add one)
	..()
	to_chat(user, "<span class='notice'>You nuzzle the tribble and it trills softly.</span>")

/obj/item/toy/tribble/dropped(mob/user as mob) //now you can't item form them to get rid of them all so easily
	new /mob/living/simple_animal/tribble(user.loc)
	for(var/mob/living/simple_animal/tribble/T in user.loc)
		T.icon_state = src.icon_state
		T.icon_living = src.icon_state
		T.icon_dead = "[src.icon_state]_dead"
		T.gestation = src.gestation

	to_chat(user, "<span class='notice'>The tribble gets up and wanders around.</span>")
	. = ..()

/obj/item/toy/tribble/attackby(var/obj/item/O as obj, var/mob/user as mob) //neutering and un-neutering
	..()
	if(istype(O, /obj/item/scalpel) && src.gestation != null)
		gestation = null
		to_chat(user, "<span class='notice'>You neuter the tribble so that it can no longer re-produce.</span>")
	else if(istype(O, /obj/item/cautery) && src.gestation == null)
		gestation = 0
		to_chat(user, "<span class='notice'>You fuse some recently cut tubes together, it should be able to reproduce again.</span>")

//||Fur and Fur Products ||

/obj/item/stack/sheet/fur //basic fur sheets (very lumpy furry piles of sheets)
	name = "pile of fur"
	desc = "The by-product of tribbles."
	singular_name = "fur piece"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "sheet-fur"
	origin_tech = "materials=2"
	max_amount = 50


/obj/item/clothing/ears/earmuffs/tribblemuffs //earmuffs but with tribbles
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribblemuffs"
	item_state = "tribblemuffs"

/* The advanced cold protection of the non-coat items has been removed, so as not
	to give patreon donors an unfair advantage - the winter coat provides equivalent
	cold protection
*/
/obj/item/clothing/gloves/furgloves
	desc = "These gloves are warm and furry."
	name = "fur gloves"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furglovesico"
	item_state = "furgloves"
	transfer_prints = TRUE
	transfer_blood = TRUE

// Equivalent to a winter coat's hood
/obj/item/clothing/head/furcap
	name = "fur cap"
	desc = "A warm furry cap."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcap"
	item_state = "furcap"

	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/furboots
	name = "fur boots"
	desc = "Warm, furry boots."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furboots"
	item_state = "furboots"

// As a donator piece of clothing, this is now in line with the winter coat
/obj/item/clothing/suit/furcoat
	name = "fur coat"
	desc = "A trenchcoat made from fur. You could put an oxygen tank in one of the pockets."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcoat"
	item_state = "furcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO
	allowed = list (/obj/item/tank/emergency_oxygen)
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/furcape
	name = "fur cape"
	desc = "A cape made from fur. You'll really be stylin' now."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcape"
	item_state = "furcape"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|ARMS
	cold_protection = UPPER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
