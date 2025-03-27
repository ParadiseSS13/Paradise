/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "piratespace"
	icon_living = "piratespace"
	icon_dead = "piratemelee_dead" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 1
	turns_per_move = 3
	death_sound = 'sound/creatures/piratedeath.ogg'
	response_help = "pushes the"
	response_disarm = "shoves"
	response_harm = "slashes"
	speed = 0
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/blade1.ogg'
	minbodytemp = 0

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("yarrs")
	loot = list(/obj/item/melee/energy/sword/pirate,
			/obj/item/clothing/head/helmet/space/pirate,
			/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
	del_on_death = TRUE
	faction = list("pirate")
	sentience_type = SENTIENCE_OTHER
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/pirate/Initialize(mapload)
	. = ..()
	if(prob(50))
		loot = list(/obj/item/clothing/head/helmet/space/pirate,
			/obj/item/salvage/loot/pirate,
			/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/pirate/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/pirate/ListTargetsLazy()
	return ListTargets()

/mob/living/simple_animal/hostile/pirate/Aggro()
	. = ..()
	if(target)
		playsound(loc, 'sound/creatures/pirateengage.ogg', 70, TRUE)

/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "piratespaceranged"
	icon_living = "piratespaceranged"
	icon_dead = "piratemelee_dead" // Does not actually exist. del_on_death.
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = TRUE
	rapid = 2
	turns_per_move = 5
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate,
				/obj/item/gun/energy/laser,
				/obj/item/clothing/head/helmet/space/pirate,
				/obj/effect/decal/cleanable/blood/innards,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/gibspawner/generic,
				/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/pirate/ranged/Initialize(mapload)
	. = ..()
	if(prob(50))
		loot = list(/obj/item/clothing/head/helmet/space/pirate,
			/obj/item/salvage/loot/pirate,
			/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
