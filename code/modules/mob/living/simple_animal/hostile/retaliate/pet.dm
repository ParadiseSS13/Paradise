/mob/living/simple_animal/hostile/retaliate/araneus
	name = "Sergeant Araneus"
	real_name = "Sergeant Araneus"
	voice_name = "unidentifiable voice"
	desc = "A fierce companion for any person of power, this spider has been carefully trained by Nanotrasen specialists. Its beady, staring eyes send shivers down your spine."
	faction = list("spiders")
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	icon_gib = "guard_dead"
	turns_per_move = 8
	response_help = "pets"
	emote_hear = list("chitters")
	maxHealth = 250
	health = 250
	harm_intent_damage = 3
	melee_damage_lower = 15
	melee_damage_upper = 20

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
