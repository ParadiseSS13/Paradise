/* Scavengers */
/mob/living/simple_animal/hostile/scavengers
	name = "Scavenger"
	desc = "One of the many random looters or bandits of the frontiers."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
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

/* Undead */
/mob/living/simple_animal/hostile/undead
	name = "zombie"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_l"
	mob_biotypes = MOB_UNDEAD | MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 10
	response_help = "gently prods"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 50
	health = 50
	faction = list("zombie")

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

/* Whiteship Undead */
/mob/living/simple_animal/hostile/undead/zombie
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_chance = 1
	speak_emote = list("growls","roars")

	icon_living = "zombie2_s"
	icon_state = "zombie2_s"
	maxHealth = 100
	health = 100
	speed = 0

/mob/living/simple_animal/hostile/undead/zombie/fast
	name = "fast zombie"
	icon = 'icons/mob/human.dmi'
	icon_living = "zombie_s"
	icon_state = "zombie_s"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 30
	speed = -1

/* Vox Raiders */
/mob/living/simple_animal/hostile/vox
	name = "Vox Raider"
	desc = "Vox are typically one of two things. Shady traders or hostile raiders. This one seems to be pretty hostile."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "vox"
	icon_living = "vox"
	icon_dead = "voxdead"
	mob_biotypes =  MOB_ORGANIC | MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	speak = list("SKREEEEE!", "KRRYYY-CHICHICHI!", "KRCHHH'CHI'KRII!")
	speak_chance = 1
	turns_per_move = 5
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 90
	health = 90
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/spawner/lootdrop/maintenance = 1)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 5, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list("vox")
	check_friendly_fire = TRUE
	status_flags = CANPUSH
	del_on_death = TRUE
	rapid_melee = 2

/mob/living/simple_animal/hostile/vox/melee
	name = "Vox Shanker"
	desc = "A Vox pirate armed with a knife.SKREEEEE!"
	icon_state = "voxmelee"
	icon_living = "voxmelee"
	icon_dead = "voxmeleedead"
	melee_damage_lower = 15
	melee_damage_upper = 15
	loot = list(/obj/effect/spawner/lootdrop/maintenance/two = 1)
	attacktext = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	status_flags = 0

/mob/living/simple_animal/hostile/vox/ranged_gun
	name = "Vox Gunman"
	desc = "A Vox pirate armed with a self-made gun. SKREEEEE!"
	icon_state = "voxgun"
	icon_living = "voxgun"
	icon_dead = "voxdead"
	melee_damage_lower = 20
	melee_damage_upper = 20
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshots/gunshot_strong.ogg'
	loot = list(/obj/effect/spawner/lootdrop/maintenance/three = 1)

/mob/living/simple_animal/hostile/vox/ranged_laser
	name = "Vox Laser Gunman"
	desc = "Vox pirates often utilize a mix of energy and ballistic weapons in combat."
	icon_state = "voxlaser"
	icon_living = "voxlaser"
	icon_dead = "voxsuitdead"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	rapid = 2
	melee_damage_lower = 20
	melee_damage_upper = 20
	projectiletype = /obj/item/projectile/beam/laser
	projectilesound = 'sound/weapons/laser.ogg'
	loot = list(/obj/effect/spawner/lootdrop/maintenance = 1)

/mob/living/simple_animal/hostile/vox/ranged_laser/space
	name = "Vox Helmsman"
	desc = "Space-faring Vox raider, armed with a laser rifle and wearing a MODsuit."
	icon_state = "voxspacelaser"
	icon_living = "voxspacelaser"
	icon_dead = "voxspacedead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	wander = FALSE
	minbodytemp = 0
	loot = list(/obj/effect/spawner/lootdrop/maintenance/three = 1)

/* Jungle Mob */
/mob/living/simple_animal/hostile/jungle_lizard
	name = "tribal lizardman"
	desc = "Представитель коренного населения этой планеты. Этот варвар не потерпит незваных гостей."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "lizardman_1"
	icon_living = "lizardman_1"
	icon_dead = "lizard_dead"
	speak = list("RAWR!","HSS-sss-ss!!!","Azkh'a Azss'ss!","Ssshazi's Ghzass!")
	speak_chance = 2
	turns_per_move = 5
	mob_biotypes =  MOB_ORGANIC | MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	speed = -0.5
	move_to_delay = 2
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 80
	health = 80
	harm_intent_damage = 8
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "рвёт"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	faction = list("junglemob")
	check_friendly_fire = 1
	status_flags = CANPUSH
	unsuitable_atmos_damage = 10
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/jungle_lizard/meele
	icon_state = "lizardman_2"
	icon_living = "lizardman_2"
	maxHealth = 70
	health = 70

/mob/living/simple_animal/hostile/jungle_lizard/spearman
	name = "tribal spearman"
	desc = "Представитель коренного населения этой планеты. Вооружен острым копьем, крепким деревянным баклером и яростным желанием защищать свои земли."
	icon_state = "lizardman_spear"
	icon_living = "lizardman_spear"
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	rapid_melee = 2
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "колет"

/mob/living/simple_animal/hostile/jungle_lizard/archer
	name = "tribal archer"
	desc = "Представитель коренного населения этой планеты. Вооружен мастерски сделанным композитным луком и смертоносными стрелами."
	icon_state = "lizardman_bow"
	icon_living = "lizardman_bow"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 6
	projectiletype = /obj/item/projectile/bullet/arrow
	projectilesound = 'sound/weapons/grenadelaunch.ogg'
	attacktext = "стреляет"

/obj/item/projectile/bullet/arrow //not reusable
	name = "arrow"
	icon_state = "arrow"
	range = 10
	damage = 25
	damage_type = BRUTE

/mob/living/simple_animal/hostile/jungle_lizard/axeman
	name = "tribal axeman"
	desc = "Представитель коренного населения этой планеты. Закован в плотный самодельный костяной панцырь и вооружен огромным топором, таким же опасным, как и он сам."
	icon_state = "lizardman_axe"
	icon_living = "lizardman_axe"
	maxHealth = 160
	health = 160
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "рубит"

/mob/living/simple_animal/hostile/jungle_lizard/leader
	name = "tribal leader"
	desc = "Представитель коренного населения этой планеты. Этот ящер заслужил свое звание жестокостью и кровожадностью по отношению к врагам."
	icon_state = "lizardman_leader"
	icon_living = "lizardman_leader"
	maxHealth = 200
	health = 200
	melee_damage_lower = 30
	melee_damage_upper = 30
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "рубит"
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 1, CLONE = 2, STAMINA = 1, OXY = 1)

/mob/living/simple_animal/hostile/panther/huge_panther
	name = "huge panther"
	desc = "Большой, гладкий черный кот с острыми клыками и когтями. Этот выглядит особенно огромным."
	maxHealth = 120
	health = 120
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 18
	rapid_melee = 2
	move_to_delay = 2
	speed = -2
	dodging = 1
	sidestep_per_cycle = 2
	faction = list("junglemob")

/mob/living/simple_animal/hostile/poison_snake
	name = "poison snake"
	desc = "Изворотливая змея, незаметно скользящая своим брюхом по земле. Яд многих из них может быть смертельно опасным."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	tts_seed = "Ladyvashj"
	health = 20
	maxHealth = 20
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	melee_damage_lower = 5
	melee_damage_upper = 6
	obj_damage = 0
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = HOSTILE_SPAWN
	environment_smash = ENVIRONMENT_SMASH_NONE
	faction = list("junglemob")

/mob/living/simple_animal/hostile/poison_snake
	var/poison_per_bite = 3
	var/poison_type = "neurotoxin2"

/mob/living/simple_animal/hostile/poison_snake/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents && !poison_per_bite == 0)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		return .

/* Jungle Mob Spawners */
/obj/effect/landmark/awaymissions/gate_lizard/mine_spawner
	icon = 'icons/obj/items.dmi'
	icon_state = "fleshtrap"
	var/id = null
	var/triggered = 0
	var/faction = null
	var/safety_z_check = 1

/obj/effect/landmark/awaymissions/gate_lizard/mob_spawn
	name = "spawner"
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	var/id = null
	var/jungle_mob = null

/obj/effect/landmark/awaymissions/gate_lizard/mine_spawner/Crossed(AM as mob|obj, oldloc)
	if(!isliving(AM))
		return
	var/mob/living/M = AM
	if(faction && (faction in M.faction))
		return
	triggerlandmark(M)

/obj/effect/landmark/awaymissions/gate_lizard/mine_spawner/proc/triggerlandmark(mob/living/victim)
	if(triggered)
		return
	victim.spawn_alert(victim)
	for(var/obj/effect/landmark/awaymissions/gate_lizard/mob_spawn/S in GLOB.landmarks_list)
		if(safety_z_check && S.z != z)
			continue
		if(S.id == id)
			new S.jungle_mob(get_turf(S))
			triggered = 1
	qdel(src)

/mob/living/proc/spawn_alert(atom/A) // Вызывает появление восклицательного знака над головой при наступании на маркер
	var/image/I
	I = image('icons/obj/cardboard_boxes.dmi', A, "cardboard_special", A.layer+1)
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client)
			viewing |= M.client
	flick_overlay(I,viewing,8)
	I.alpha = 0
	animate(I, pixel_z = 32, alpha = 255, time = 5, easing = ELASTIC_EASING)

/obj/effect/landmark/awaymissions/gate_lizard/mob_spawn/melee
	name = "Melee"
	icon_state = "spawner"
	jungle_mob = /mob/living/simple_animal/hostile/jungle_lizard

/obj/effect/landmark/awaymissions/gate_lizard/mob_spawn/melee_spear
	name = "Spearman"
	icon_state = "spawner_spear"
	jungle_mob = /mob/living/simple_animal/hostile/jungle_lizard/spearman

/obj/effect/landmark/awaymissions/gate_lizard/mob_spawn/melee_axe
	name = "Axeman"
	icon_state = "spawner_axe"
	jungle_mob = /mob/living/simple_animal/hostile/jungle_lizard/axeman

/obj/effect/landmark/awaymissions/gate_lizard/mob_spawn/ranged
	name = "Bowman"
	icon_state = "spawner_bow"
	jungle_mob = /mob/living/simple_animal/hostile/jungle_lizard/archer
