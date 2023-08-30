//Scavengers
/mob/living/simple_animal/hostile/scavengers
	name = "Scavenger"
	desc = "One of the many random looters or bandits of the frontiers."
	icon = 'modular_ss220/_maps220/icons/simple_human.dmi'
	icon_state = "scav"
	icon_living = "scav"
	icon_dead = "scavdead"
	mob_biotypes =  MOB_ORGANIC | MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 75
	health = 75
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	unsuitable_atmos_damage = 10
	faction = list("scavengers")
	check_friendly_fire = TRUE
	status_flags = CANPUSH
	del_on_death = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/scavengers/meele
	name = "Scrapper Scavenger"
	desc = "One of the many random looters or bandits of the frontiers. This one is carrying a pipe."
	icon_state = "scavmeelepipe"
	icon_living = "scavmeelepipe"
	icon_dead = "scavdead"
	maxHealth = 90
	health = 90
	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	rapid_melee = 2
	attack_sound = 'sound/weapons/genhit1.ogg'
	attacktext = "bashing"

/mob/living/simple_animal/hostile/scavengers/meele/crusher
	name = "Heavy Scavenger"
	desc = "One of the many random looters or bandits of the frontiers. This one is carrying a KC."
	icon_state = "scavmeelecrush"
	icon_living = "scavmeelecrush"
	icon_dead = "scavdead"
	maxHealth = 100
	health = 100
	rapid_melee = 0
	harm_intent_damage = 8
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "smashes"

/mob/living/simple_animal/hostile/scavengers/meele/axe
	name = "Shipbreaker Scavenger"
	desc = "A shipbreaker scavenger. This one is carrying a axe."
	icon_state = "scavmeeleaxe"
	icon_living = "scavmeeleaxe"
	icon_dead = "scavdead"
	maxHealth = 120
	health = 120
	rapid_melee = 0
	harm_intent_damage = 8
	melee_damage_lower = 20
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "cuts"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	wander = FALSE

/mob/living/simple_animal/hostile/scavengers/laser
	name = " Scavenger Gunslinger"
	desc = "A bandit scum, who has learned to shoot accurately and quickly."
	icon_state = "scavpistol"
	icon_living = "scavpistol"
	icon_dead = "scavdead"
	maxHealth = 100
	health = 100
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	rapid = 2
	melee_damage_lower = 10
	melee_damage_upper = 10
	projectiletype = /obj/item/projectile/beam/laser
	projectilesound = 'sound/weapons/laser.ogg'

/mob/living/simple_animal/hostile/scavengers/laser/spacelaser
	name = "Spacetrooper Scavenger"
	desc = "A shipbreaker scavenger. This one is carrying a laser gun."
	icon_state = "scavlaser"
	icon_living = "scavlaser"
	icon_dead = "scavdead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	rapid = 3
	wander = FALSE

/mob/living/simple_animal/hostile/scavengers/gun
	name = "Scavenger Gunman"
	desc = "A bandit scum with a shotgun."
	icon_state = "scavshotgun"
	icon_living = "scavshotgun"
	icon_dead = "scavdead"
	maxHealth = 100
	health = 100
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	rapid = 0
	melee_damage_lower = 10
	melee_damage_upper = 10
	casingtype = /obj/item/ammo_casing/shotgun
	projectilesound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'

/mob/living/simple_animal/hostile/scavengers/gun/spacegun
	name = "Spacetrooper Scavenger"
	desc = "A shipbreaker scavenger. This one is carrying a submachine gun."
	icon_state = "scavm90"
	icon_living = "scavm90"
	icon_dead = "scavdead"
	casingtype = /obj/item/ammo_casing/a556
	rapid = 2
	projectilesound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	wander = FALSE

