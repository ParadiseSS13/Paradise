/datum/species/zombie
	name = "Zombie"
	name_plural = "Zombies"
	blurb = "It's a corpse, one dead person." //Descripcion de la raza.

	icobase = 'icons/mob/human_races/r_zombie.dmi'
	deform = 'icons/mob/human_races/r_zombie.dmi'
	unarmed_type = /datum/unarmed_attack/zombie
	species_traits = list(NO_BREATHE, NO_BLOOD, RADIMMUNE, NOGUNS, NOCRITDAMAGE, RESISTCOLD, NO_EXAMINE)
	reagent_tag = null
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	hunger_drain = -1
	dietflags = DIET_OMNI
	language = "Zombie"
	default_language = "Zombie"
	speech_sounds = list('sound/voice/zombievoice.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	has_fine_manipulation = 0
	death_message = "Stops moving..."
	total_health = 85
	brute_mod = 1.0
	burn_mod = 0.85
	stun_mod = 0.3
	tox_mod = 0
	clone_mod = 0
	oxy_mod = 0
	brain_mod = 0
	slowdown = 2
	punchdamagelow = 3
	punchdamagehigh = 5
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" = /obj/item/organ/internal/eyes/zombie,
		)

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/zombie),
		"groin" =  list("path" = /obj/item/organ/external/groin/zombie),
		"head" =   list("path" = /obj/item/organ/external/head/zombie),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/zombie),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/zombie),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/zombie),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/zombie),
		"l_hand" = list("path" = /obj/item/organ/external/hand/zombie),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/zombie),
		"l_foot" = list("path" = /obj/item/organ/external/foot/zombie),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/zombie))

/datum/species/zombie/handle_life(mob/living/carbon/human/H)
	if(prob(7))
		H.adjustBruteLoss(-7)
		H.adjustToxLoss(-7)

/obj/machinery/door/airlock/attack_hand(mob/user)
	..()
	return



