/mob/living/simple_animal/possum
	name = "possum"
	desc = "The opossum is a small, scavenging marsupial of the order Didelphimorphia, previously \
	endemic to the Americas of Earth, but now inexplicably found across settled space. Nobody is \
	entirely sure how they travel to such disparate locations, with the leading theories including \
	smuggling, cargo stowaways, fungal spore reproduction, teleportation, or unknown quantum effects."
	icon = 'icons/mob/pets.dmi'
	icon_state = "possum"
	icon_living = "possum"
	icon_dead = "possum_dead"
	icon_resting = "possum_sleep"
	var/icon_harm = "possum_aaa"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("Hsss...", "Hisss...")
	speak_emote = list("Hsss", "Hisss")
	emote_hear = list("Aaaaa!", "Ahhss!")
	emote_see = list("shakes its head.", "chases its tail.", "shivers.")
	tts_seed = "Clockwerk"
	faction = list("neutral")
	maxHealth = 30
	health = 30
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	blood_volume = BLOOD_VOLUME_NORMAL
	melee_damage_type = STAMINA
	melee_damage_lower = 3
	melee_damage_upper = 8
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	holder_type = /obj/item/holder/possum

/mob/living/simple_animal/possum/attackby(obj/item/O, mob/living/user)
	icon_state = icon_harm
	. = ..()

/mob/living/simple_animal/possum/attack_hand(mob/living/carbon/human/M)
	switch(M.a_intent)
		if(INTENT_HELP)
			icon_state = initial(icon_state)
		if(INTENT_HARM, INTENT_DISARM, INTENT_GRAB)
			icon_state = icon_harm
	. = ..()

/mob/living/simple_animal/possum/Poppy
	name = "Ключик"
	desc = "Маленький работяга. Его жилетка подчеркивает его рабочие... лапы. Тот еще трудяга. Очень не любит ассистентов в инженерном отделе. И Полли. Интересно, почему?"
	icon_state = "possum_poppy"
	icon_living = "possum_poppy"
	icon_dead = "possum_poppy_dead"
	icon_resting = "possum_poppy_sleep"
	icon_harm = "possum_poppy_aaa"
	holder_type = /obj/item/holder/possum/poppy
	maxHealth = 50
	health = 50
