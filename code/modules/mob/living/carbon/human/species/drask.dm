/datum/species/drask
	name = "Drask"
	name_plural = "Drask"
	icobase = 'icons/mob/human_races/r_drask.dmi'
	deform = 'icons/mob/human_races/r_drask.dmi'
	path = /mob/living/carbon/human/drask
	default_language = "Galactic Common"
	language = "Orluum"
	unarmed_type = /datum/unarmed_attack/punch
	eyes = "drask_eyes_s"
	darksight = 5

	speech_sounds = list('sound/voice/DraskTalk.ogg')
	speech_chance = 20
	male_scream_sound = 'sound/voice/DraskTalk2.ogg'
	female_scream_sound = 'sound/voice/DraskTalk2.ogg'

	burn_mod = 4
	//exotic_blood = "cryoxadone"
	body_temperature = 273
	can_revive_by_healing // Doesn't seem to do much for non-robots, still needs a defib

	blurb = "Hailing from Hoorlm, planet outside what is usually considered a habitable \
	orbit, the Drask evolved to live in extreme cold. Their strange bodies seem \
	to operate better the colder their surroundings are, and can regenerate rapidly \
	when breathing supercooled gas. <br/><br/> On their homeworld, the Drask live long lives \
	in their labyrinthine settlements, carved out beneath Hoorlm's icy surface, where the air \
	is of breathable density."

	flags = HAS_LIPS
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = FEET_CLAWS
	dietflags = DIET_OMNI

	cold_level_1 = -1 //Default 260 - Lower is better
	cold_level_2 = -1 //Default 200
	cold_level_3 = -1 //Default 120
	cold_env_multiplier = -1

	heat_level_1 = 300 //Default 360 - Higher is better
	heat_level_2 = 340 //Default 400
	heat_level_3 = 400 //Default 460
	heat_level_3_breathe = 600 //Default 1000

	flesh_color = "#a3d4eb"
	reagent_tag = PROCESS_ORG
	base_color = "#a3d4eb"
	blood_color = "#a3d4eb"

	has_organ = list(
		"heart" =      				/obj/item/organ/internal/heart/drask,
		"lungs" =     				/obj/item/organ/internal/lungs/drask,
		"metabolic strainer" =      /obj/item/organ/internal/liver/drask,
		"eyes" =     				/obj/item/organ/internal/eyes/drask,
		"brain" =  					/obj/item/organ/internal/brain/drask
		)


/datum/species/drask/handle_temperature(datum/gas_mixture/breath, var/mob/living/carbon/human/H) // called by human/life, handles temperatures
	if( (abs(310.15 - breath.temperature) > 50) && !(RESIST_HEAT in H.mutations)) // Hot air hurts :(
		if(H.status_flags & GODMODE)	return 1	//godmode
		if(breath.temperature < 260)
			if(prob(20))
				H << "\blue You feel an invigorating coldness in your lungs!"
		else if(breath.temperature > heat_level_1)
			if(prob(20))
				H << "\red You feel your face burning and a searing heat in your lungs!"



		switch(breath.temperature)
			if(-INFINITY to 120)
				H.adjustFireLoss(cold_env_multiplier*COLD_GAS_DAMAGE_LEVEL_3)
				H.adjustBruteLoss(cold_env_multiplier*10)
				H.fire_alert = max(H.fire_alert, 1)		//To alert that their breath is cold enough for healing. Does not seem to affect cold movement slowdown

			if(121 to 200)
				H.adjustFireLoss(cold_env_multiplier*COLD_GAS_DAMAGE_LEVEL_2)
				H.adjustBruteLoss(cold_env_multiplier*6)
				H.fire_alert = max(H.fire_alert, 1)

			if(201 to 260)
				H.adjustFireLoss(cold_env_multiplier*COLD_GAS_DAMAGE_LEVEL_1)
				H.adjustBruteLoss(cold_env_multiplier*3)
				H.fire_alert = max(H.fire_alert, 1)

			if(heat_level_1 to heat_level_2)
				H.apply_damage(hot_env_multiplier*HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

			if(heat_level_2 to heat_level_3_breathe)
				H.apply_damage(hot_env_multiplier*HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

			if(heat_level_3_breathe to INFINITY)
				H.apply_damage(hot_env_multiplier*HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)