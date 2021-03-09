/mob/living/simple_animal/hostile/deathsquid
	name = "death squid"
	desc = "A large, floating eldritch horror. Its body glows with an evil red light, and its tentacles look to have been dipped in alien blood."

	speed = 1
	speak_emote = list("telepathically thunders", "telepathically booms")
	maxHealth = 2500 // same as megafauna
	health = 2500

	icon = 'icons/mob/deathsquid_large.dmi' // Credit: FullofSkittles
	icon_state = "deathsquid"
	icon_living = "deathsquid"
	icon_dead = "deathsquiddead"
	pixel_x = -24
	pixel_y = -24

	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 25
	melee_damage_lower = 10
	melee_damage_upper = 100
	environment_smash = ENVIRONMENT_SMASH_RWALLS

	force_threshold = 15
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	heat_damage_per_tick = 0

	see_in_dark = 8
	mob_size = MOB_SIZE_LARGE
	ventcrawler = 0
	gold_core_spawnable = NO_SPAWN



/mob/living/simple_animal/hostile/deathsquid/Process_Spacemove(var/movement_dir = 0)
	return 1 //copypasta from carp code

/mob/living/simple_animal/hostile/deathsquid/ex_act(severity)
	return

/mob/living/simple_animal/hostile/deathsquid/joke
	name = "deaf squid"
	desc = "An elderly, hard-of-hearing eldrich horror."
	maxHealth = 200
	health = 200
	speed = 3
	armour_penetration = 5
	melee_damage_lower = 10
	melee_damage_upper = 20
	environment_smash = 2
