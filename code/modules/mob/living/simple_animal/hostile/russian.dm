/mob/living/simple_animal/hostile/russian
	name = "Russian"
	desc = "For the Motherland!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
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
	a_intent = I_HARM
	unsuitable_atmos_damage = 15
	faction = list("russian")
	status_flags = CANPUSH
	loot = list(/obj/effect/landmark/mobcorpse/russian,
			/obj/item/weapon/kitchen/knife)
	del_on_death = 1


/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/a357
	loot = list(/obj/effect/landmark/mobcorpse/russian/ranged, /obj/item/weapon/gun/projectile/revolver/mateba)

/mob/living/simple_animal/hostile/russian/ranged/mosin
	loot = list(/obj/effect/landmark/mobcorpse/russian/ranged,
				/obj/item/weapon/gun/projectile/shotgun/boltaction)
	casingtype = /obj/item/ammo_casing/a762
