/datum/species/zombie
	name = "Zombie"
	name_plural = "Zombies"
	blurb = "It's a corpse, a dead person." //Descripcion de la raza.
	icobase = 'icons/mob/human_races/r_zombie.dmi'
	deform = 'icons/mob/human_races/r_zombie.dmi'
	unarmed_type = /datum/unarmed_attack/zombie
	species_traits = list(NO_BREATHE, NO_BLOOD, RADIMMUNE, NOGUNS, NOCRITDAMAGE, RESISTCOLD, NO_EXAMINE, NO_DNA, NOTRANSSTING, NO_INTORGANS, NO_PAIN, VIRUSIMMUNE)
	reagent_tag = null
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	hunger_drain = 0
	dietflags = DIET_CARN //Comen carne.
	language = "Zombie"
	default_language = "Zombie"
	speech_sounds = list('sound/voice/zombievoice.ogg') 
	speech_chance = 30
	male_scream_sound = 'sound/voice/zombievoice.ogg'
	female_scream_sound = 'sound/voice/zombievoice.ogg'
	has_fine_manipulation = 0
	death_message = "Stops moving..."
	total_health = 85
	brute_mod = 1.0
	burn_mod = 0.80
	stun_mod = 0.3
	//Estas muerto, no respiras, no metabolizas.
	tox_mod = 0
	clone_mod = 0
	oxy_mod = 0
	brain_mod = 0
	slowdown = 2 //Mas lentos que un humano.
	punchdamagelow = 5
	punchdamagehigh = 9
	punchstunthreshold = 14 //Cantidad de daño que deben ejercer para tumbar.
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	has_organ = list(
		"brain" =	/obj/item/organ/internal/brain/zombie,
		"heart" =	/obj/item/organ/internal/heart/zombie,
		"lungs" =	/obj/item/organ/internal/lungs/zombie,
		"liver" =	/obj/item/organ/internal/liver/zombie,
		"kidneys" =	/obj/item/organ/internal/kidneys/zombie,
		"appendix" =	/obj/item/organ/internal/appendix/zombie,
		"eyes" =	/obj/item/organ/internal/eyes/zombie,
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
		H.adjustBruteLoss(-10)
		H.adjustFireLoss(-10)
		H.adjustToxLoss(-10)