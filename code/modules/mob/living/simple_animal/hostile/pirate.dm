/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead" // Does not actually exist. del_on_death.
	speak_chance = 0
	turns_per_move = 5
	response_help = "pushes the"
	response_disarm = "shoves"
	response_harm = "hits the"
	speed = 0
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	speak_emote = list("yarrs")
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/item/melee/energy/sword/pirate)
	del_on_death = 1
	faction = list("pirate")
	sentience_type = SENTIENCE_OTHER

/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "piratemelee_dead" // Does not actually exist. del_on_death.
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 2
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate/ranged,
				/obj/item/gun/energy/laser)
