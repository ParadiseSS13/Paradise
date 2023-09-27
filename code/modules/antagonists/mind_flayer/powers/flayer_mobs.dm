/*
* In here is the basetype simplemob and every subtype used for every flayer mob.
*
*
*
*/

/mob/living/simple_animal/hostile/flayer
	name = "Flayerbot"
	faction = list("flayer")
	icon = 'icons/mob/guardian.dmi'
	icon_state = "techOrchid"
	icon_living = "techOrchid"
	icon_dead = "techOrchid"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0) // Remind me to later test if I can just null this list and it still works
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1.5, BURN = 1.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) // We're too cool for that biological damage
	attacktext = "rends"
	unique_pet = TRUE // No you are not naming your killer robot "Fluffy"
	del_on_death = TRUE
	AIStatus = AI_OFF
