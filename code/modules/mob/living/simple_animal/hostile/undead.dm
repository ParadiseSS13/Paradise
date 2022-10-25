// This is important
/mob/living/attack_ghost(mob/dead/observer/user)
	if(prob(80)) return ..()
	var/found = 0
	for(var/mob/living/simple_animal/hostile/R in range(4,src))
		if(!R.retaliate_only)
			continue
		if(R.faction != "undead" || R == src || prob(50)) continue
		found = 1
		R.enemies ^= src
		if(src in R.enemies)
			R.visible_message("[R]'s head swivels eerily towards [src].")
		else
			R.visible_message("[R] stares at [src] for a minute before turning away.")
			if(R.target == src)
				R.target = null
	if(!found)
		return ..()

/mob/living/simple_animal/hostile/ghost
	icon = 'icons/mob/mob.dmi'
	name = "ghost"
	icon_state = "ghost2"
	icon_living = "ghost2"
	icon_dead = "ghost"
	density = 0 // ghost
	invisibility = 60 // no seriously ghost
	speak_chance = 0 // fyi, ghost


	response_help = "passes through" // by the way ghost
	response_disarm = "shoves"
	response_harm = "hits"
	turns_per_move = 10
	speed = 0
	maxHealth = 20
	health = 20

	emote_taunt = list("wails")
	taunt_chance = 20

	harm_intent_damage = 10
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "сжимает"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	flying = TRUE
	pressure_resistance = 300
	gold_core_spawnable = NO_SPAWN //too spooky for science
	faction = list("undead") // did I mention ghost
	loot = list(/obj/item/reagent_containers/food/snacks/ectoplasm)
	del_on_death = 1

/mob/living/simple_animal/hostile/ghost/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/ghost/Life(seconds, times_fired)
	if(target)
		invisibility = pick(0,0,60,invisibility)
	else
		invisibility = pick(0,60,60,invisibility)
	..()

/mob/living/simple_animal/hostile/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	turns_per_move = 5
	response_help = "shakes hands with"
	response_disarm = "shoves"
	response_harm = "hits"
	speak_emote = list("rattles")
	emote_see = list("rattles")
	a_intent = INTENT_HARM
	maxHealth = 40
	health = 40
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	minbodytemp = 0
	maxbodytemp = 1500
	healable = FALSE //they're skeletons how would bruise packs help them??
	attacktext = "бьёт"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("undead")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "collapses into a pile of bones!"
	del_on_death = TRUE
	loot = list(/obj/effect/decal/remains/human)

/mob/living/simple_animal/hostile/skeleton/eskimo
	name = "undead eskimo"
	desc = "The reanimated remains of some poor traveler."
	icon_state = "eskimo"
	icon_living = "eskimo"
	maxHealth = 55
	health = 55
	weather_immunities = list("snow")
	gold_core_spawnable = NO_SPAWN
	melee_damage_lower = 17
	melee_damage_upper = 20
	faction = list("undead", "winter")
	deathmessage = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/twohanded/spear,
				/obj/item/clothing/shoes/winterboots,
				/obj/item/clothing/suit/hooded/wintercoat)

/mob/living/simple_animal/hostile/zombie
	name = "zombie"
	desc = "The undead. Its good time to RUN!"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_l"
	speak_chance = 0
	turns_per_move = 10
	response_help = "gently prods"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 20
	health = 20

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "терзает"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("undead")
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	del_on_death = 1

/mob/living/simple_animal/hostile/zombie/whiteship
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_chance = 1
	speak_emote = list("growls","roars")

	faction = list("zombie")
	icon_living = "zombie2_s"
	icon_state = "zombie2_s"
	maxHealth = 100
	health = 100
	speed = 0

/mob/living/simple_animal/hostile/zombie/whiteship/fast
	name = "fast zombie"
	icon = 'icons/mob/human.dmi'
	icon_living = "zombie_s"
	icon_state = "zombie_s"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 30
	speed = -1
