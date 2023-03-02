/mob/living/simple_animal/hostile/retaliate/araneus
	name = "Сержант Аранеус"
	real_name = "Сержант Аранеус"
	voice_name = "неизвестный голос"
	desc = "Свирепый компаньон любого влиятельного лица, эта паучиха была тщательно обучена специалистами NanoTrasen. От пристального взгляда её глаз-бусинок у вас по спине бегают мурашки."
	faction = list("spiders")
	icon_state = "guard(old)"
	icon_living = "guard(old)"
	icon_dead = "guard_dead(old)"
	icon_gib = "guard_dead(old)"
	tts_seed = "Anubarak"
	turns_per_move = 8
	response_help = "pets"
	emote_hear = list("chitters")
	maxHealth = 250
	health = 250
	harm_intent_damage = 3
	melee_damage_lower = 15
	melee_damage_upper = 20
	unique_pet = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	gender = FEMALE

