/mob/living/simple_animal/hostile/soviet
	name = "Soviet"
	desc = "For the Union!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "sovietmelee"
	icon_living = "sovietmelee"
	icon_dead = "sovietmelee_dead" // Does not actually exist. del_on_death.
	icon_gib = "sovietmelee_gib" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	unsuitable_atmos_damage = 15
	faction = list("soviet")
	status_flags = CANPUSH
	loot = list(/obj/effect/mob_spawn/human/corpse/soviet,
		/obj/item/kitchen/knife,
		/obj/item/salvage/loot/soviet)
	del_on_death = TRUE
	sentience_type = SENTIENCE_OTHER
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/soviet/ranged
	icon_state = "sovietranged"
	icon_living = "sovietranged"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	casingtype = /obj/item/ammo_casing/a357
	loot = list(/obj/effect/mob_spawn/human/corpse/soviet/ranged, /obj/item/gun/projectile/revolver/mateba)

/mob/living/simple_animal/hostile/soviet/ranged/mosin
	loot = list(/obj/effect/mob_spawn/human/corpse/soviet/ranged,
				/obj/item/gun/projectile/shotgun/boltaction,
				/obj/item/salvage/loot/soviet)
	casingtype = /obj/item/ammo_casing/a762
