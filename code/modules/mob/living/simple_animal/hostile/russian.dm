/mob/living/simple_animal/hostile/russian
	name = "Russian"
	desc = "For the Motherland!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead" // Does not actually exist. del_on_death.
	icon_gib = "russianmelee_gib" // Does not actually exist. del_on_death.
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
	faction = list("russian")
	status_flags = CANPUSH
	loot = list(/obj/effect/mob_spawn/human/corpse/russian,
			/obj/item/kitchen/knife)
	del_on_death = 1
	sentience_type = SENTIENCE_OTHER

/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	casingtype = /obj/item/ammo_casing/a357
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged, /obj/item/gun/projectile/revolver/mateba)

/mob/living/simple_animal/hostile/russian/ranged/mosin
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged,
				/obj/item/gun/projectile/shotgun/boltaction)
	casingtype = /obj/item/ammo_casing/a762
