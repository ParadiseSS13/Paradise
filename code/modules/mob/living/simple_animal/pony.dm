/mob/living/simple_animal/pony
	name = "\improper pony"
	desc = "A young horse"
	icon = 'icons/mob/pony.dmi'
//	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("whinnys")
	emote_hear = list("neighs")
	speak = list("NEIGHH!!")
	response_help  = "pets"
	response_disarm = "pushes"
	response_harm   = "kicks"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "kicks"
	minbodytemp = 0
	maxbodytemp = 4000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = 0
	stop_automated_movement = 0
	status_flags = 0
	faction = list("pony")
	status_flags = CANPUSH
	universal_speak = 0