/mob/living/basic/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens_running"
	icon_living = "aliens_running"
	icon_dead = "aliens_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 15
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/alien/sentinel

	is_ranged = TRUE
	projectile_type = /obj/item/projectile/neurotox
	projectile_sound = 'sound/weapons/pierce.ogg'
	ranged_cooldown = 3 SECONDS

/mob/living/basic/alien/sentinel/corgi
	name = "angry corgi"
	real_name = "angry corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	icon = 'icons/mob/pets.dmi';
	desc = "This is no longer a goodboy. Not anymore. He has seen too much.";
	attack_sound = 'sound/weapons/bite.ogg';
	attack_verb_continuous = "bites";
	attack_verb_simple = "bites";
	damage_coeff = list("brute" = 1, "fire" = 1, "tox" = 1, "clone" = 1, "stamina" = 1, "oxy" = 1);
	death_sound = null;
	deathmessage = "";

	ai_controller = /datum/ai_controller/basic_controller/alien/corgi

/mob/living/basic/alien/sentinel/lavaland
	maximum_survivable_temperature = INFINITY
