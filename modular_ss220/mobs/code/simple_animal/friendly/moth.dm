/mob/living/simple_animal/moth
	name = "моль"
	desc = "Смотря на эту моль становится понятно куда пропали шубы перевозимые СССП."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "moth"
	icon_living = "moth"
	icon_dead = "moth_dead"
	turns_per_move = 1
	emote_see = list("flutters")
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_chance = 0
	maxHealth = 15
	health = 15
	see_in_dark = 100
	friendly = "nudges"
	density = 0
	flying = TRUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = 2
	mob_size = MOB_SIZE_TINY
	butcher_results = list(/obj/item/food/snacks/monstermeat/xenomeat = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	holder_type = /obj/item/holder/moth

/mob/living/simple_animal/mothroach
	name = "mothroach"
	desc = "Мотылёк. Обожает светочи."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	icon_resting = "mothroach_sleep"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	faction = list("neutral")
	maxHealth = 15
	health = 15
	see_in_dark = 30
	turns_per_move = 10
	emote_see = list("flutters")
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	friendly = "nudges"
	density = 0
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_BAREFOOT
	butcher_results = list(/obj/item/food/snacks/monstermeat/xenomeat = 1)
	holder_type = /obj/item/holder/mothroach
