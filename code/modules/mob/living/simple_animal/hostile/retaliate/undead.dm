/mob/living/simple_animal/hostile/retaliate/ghost
	icon = 'icons/mob/mob.dmi'
	name = "ghost"
	icon_state = "ghost2"
	icon_living = "ghost2"
	icon_dead = "ghost"
	mob_biotypes = MOB_SPIRIT
	density = FALSE // ghost
	invisibility = 60 // no seriously ghost


	response_help = "passes through" // by the way ghost
	turns_per_move = 10
	speed = 0

	emote_taunt = list("wails")
	taunt_chance = 20

	harm_intent_damage = 10
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "grips"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	pressure_resistance = 300
	faction = list("undead") // did I mention ghost
	loot = list(/obj/item/food/ectoplasm)
	del_on_death = TRUE

	initial_traits = list(TRAIT_FLYING)

/mob/living/simple_animal/hostile/retaliate/ghost/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1

/mob/living/simple_animal/hostile/retaliate/ghost/Life(seconds, times_fired)
	if(target)
		invisibility = pick(0,0,60,invisibility)
	else
		invisibility = pick(0,60,60,invisibility)
	..()

/mob/living/simple_animal/hostile/retaliate/skeleton
	name = "skeleton"
	icon = 'icons/mob/human.dmi'
	icon_state = "skeleton_s"
	icon_living = "skeleton_s"
	icon_dead = "skeleton_l"
	mob_biotypes = MOB_UNDEAD | MOB_HUMANOID
	turns_per_move = 10
	response_help = "shakes hands with"
	speed = 0

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("undead")
	loot = list(/obj/effect/decal/remains/human)
	del_on_death = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/zombie
	name = "zombie"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_l"
	mob_biotypes = MOB_UNDEAD | MOB_HUMANOID
	turns_per_move = 10
	response_help = "gently prods"
	speed = -1

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("undead")
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	del_on_death = TRUE
