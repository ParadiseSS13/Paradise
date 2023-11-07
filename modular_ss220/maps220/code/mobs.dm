/* Scavengers */
/mob/living/simple_animal/hostile/scavengers
	name = "scavenger"
	desc = "One of the many random bandits of the frontiers."
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
	robust_searching = TRUE
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
	name = "scrapper scavenger"
	desc = "One of the many random bandits of the frontiers. This one is carrying a pipe."
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
	name = "heavy scavenger"
	desc = "One of the many random bandits of the frontiers. This one is carrying a KC."
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
	name = "shipbreaker scavenger"
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
	name = "gunslinger scavenger "
	desc = "A bandit scum, who has learned to shoot accurately and quickly."
	icon_state = "scavpistol"
	icon_living = "scavpistol"
	icon_dead = "scavdead"
	maxHealth = 100
	health = 100
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	rapid = 2
	melee_damage_lower = 10
	melee_damage_upper = 10
	projectiletype = /obj/item/projectile/beam/laser
	projectilesound = 'sound/weapons/laser.ogg'

/mob/living/simple_animal/hostile/scavengers/laser/spacelaser
	name = "spacetrooper scavenger"
	desc = "A shipbreaker scavenger. This one is carrying a laser gun."
	icon_state = "scavlaser"
	icon_living = "scavlaser"
	icon_dead = "scavdead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	rapid = 3
	wander = FALSE

/mob/living/simple_animal/hostile/scavengers/gun
	name = "gunman scavenger"
	desc = "A bandit scum with a shotgun."
	icon_state = "scavshotgun"
	icon_living = "scavshotgun"
	icon_dead = "scavdead"
	maxHealth = 100
	health = 100
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	rapid = 0
	melee_damage_lower = 10
	melee_damage_upper = 10
	casingtype = /obj/item/ammo_casing/shotgun
	projectilesound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'

/mob/living/simple_animal/hostile/scavengers/gun/spacegun
	name = "spacetrooper scavenger"
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

/mob/living/simple_animal/hostile/skeleton/deadwizard
	name = "древний маг"
	desc = "Древний волшебник, тысячелетиями властвующий над проклятым могильником."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_living = "deadwizard"
	icon_state = "deadwizard"
	maxHealth = 400
	health = 400
	ranged = 1
	retreat_distance = 7
	minimum_distance = 5
	ranged_cooldown_time = 5
	ranged_ignores_vision = TRUE
	aggro_vision_range = 12
	vision_range = 12
	del_on_death = 1
	projectilesound = 'sound/magic/blind.ogg'
	loot = list(
	/obj/effect/decal/remains/human,
	/obj/item/clothing/head/crown,
	/obj/item/clothing/suit/imperium_monk,
	/obj/effect/particle_effect/smoke/bad,
	/obj/item/emerald_stone)

/mob/living/simple_animal/hostile/skeleton/deadwizard/Shoot(atom/targeted_atom)
	..()
	if (get_dist(src, targeted_atom) > 9)
		rapid = 1
		ranged_cooldown_time = 15
		projectiletype = /obj/item/projectile/magic/fireball/infernal
	else
		projectiletype = /obj/item/projectile/magic/arcane_barrage
		rapid = 4
		rapid_fire_delay = 1
		ranged_cooldown_time = 15

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
	robust_searching = TRUE
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
	ranged = TRUE
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
	ranged = TRUE
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
	speed = 0
	move_to_delay = 2.8
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	maxHealth = 80
	health = 80
	harm_intent_damage = 8
	melee_damage_lower = 5
	melee_damage_upper = 8
	attacktext = "рвёт"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	faction = list("junglemob")
	check_friendly_fire = 1
	status_flags = CANPUSH
	unsuitable_atmos_damage = 10
	loot = list(/obj/effect/gibspawner/human)
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
	melee_damage_lower = 12
	melee_damage_upper = 12
	rapid_melee = 2
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "колет"

/mob/living/simple_animal/hostile/jungle_lizard/archer
	name = "tribal archer"
	desc = "Представитель коренного населения этой планеты. Вооружен мастерски сделанным композитным луком и смертоносными стрелами."
	icon_state = "lizardman_bow"
	icon_living = "lizardman_bow"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 6
	projectiletype = /obj/item/projectile/bullet/arrow
	projectilesound = 'sound/weapons/grenadelaunch.ogg'
	attacktext = "стреляет"

/obj/item/projectile/bullet/arrow //not reusable
	name = "arrow"
	icon_state = "arrow"
	range = 10
	damage = 20
	damage_type = BRUTE

/mob/living/simple_animal/hostile/jungle_lizard/axeman
	name = "tribal axeman"
	desc = "Представитель коренного населения этой планеты. Закован в плотный самодельный костяной панцырь и вооружен огромным топором, таким же опасным, как и он сам."
	icon_state = "lizardman_axe"
	icon_living = "lizardman_axe"
	maxHealth = 160
	health = 160
	melee_damage_lower = 20
	melee_damage_upper = 23
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
	melee_damage_upper = 15
	rapid_melee = 2
	move_to_delay = 2.8
	speed = -0.2
	dodging = TRUE
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
		if(L.reagents && poison_per_bite)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		return .

/* Jungle Mob Spawners */
/obj/effect/landmark/awaymissions/gate_lizard/mine_spawner
	icon = 'icons/obj/items.dmi'
	icon_state = "fleshtrap"
	var/id = null
	var/triggered = FALSE
	var/faction = null
	var/safety_z_check = TRUE

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
			triggered = TRUE
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

/* Abomination */
/mob/living/simple_animal/hostile/abomination
	name = "мерзость"
	desc = "Скуластое, громоздкое чудовище. Еще один неудачный эксперимент абдукторов. Что именно они пытались создать?"
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "abomination1"
	icon_living = "abomination1"
	icon_dead = "abomination_dead"
	health = 300
	maxHealth = 300
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "грызёт"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("abomination")
	speak_emote = list("кричит")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	weather_immunities = list("ash")
	stat_attack = UNCONSCIOUS

/mob/living/simple_animal/hostile/abomination/super
	desc = "Оскалившийся, страшный монстр. Этот кажется проворным."
	icon_state = "abomination_headcrab"
	icon_living = "abomination_headcrab"
	icon_dead = "abomination_headcrab_dead"
	health = 250
	maxHealth = 250

/mob/living/simple_animal/hostile/abomination/altform1
	icon_state = "abomination2"
	icon_living = "abomination2"
	icon_dead = "abomination_dead"

/mob/living/simple_animal/hostile/abomination/altform2
	icon_state = "abomination3"
	icon_living = "abomination3"
	icon_dead = "abomination_dead"

/mob/living/simple_animal/hostile/abomination/altform3
	icon_state = "abomination4"
	icon_living = "abomination4"
	icon_dead = "abomination_dead"

/mob/living/simple_animal/hostile/abomination/altform4
	icon_state = "abomination5"
	icon_living = "abomination5"
	icon_dead = "abomination_dead"

/mob/living/simple_animal/hostile/carp/eyeball
	name = "глазок"
	desc = "Странное на вид существо, оно не перестает смотреть..."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = null
	gender = NEUTER
	mob_biotypes = MOB_ORGANIC
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("glares")
	taunt_chance = 25
	maxHealth = 45
	health = 45
	speak_emote = list("телепатически вопит")

	harm_intent_damage = 15
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "моргает на"
	attack_sound = 'sound/weapons/pierce.ogg'
	flying = TRUE

	faction = list("spooky")
	del_on_death = TRUE
	random_color = FALSE

/* Clown */
/mob/living/simple_animal/hostile/clown/mutant
	name = "неизвестный"
	desc = "Что бы это не было, уничтожь его!"
	icon = 'modular_ss220/maps220/icons/clown_mobs.dmi'
	icon_state = "mutant"
	icon_living = "mutant"
	move_resist = INFINITY
	turns_per_move = 10
	response_help = "осторожно погружает палец в"
	response_disarm = "втягивается в"
	response_harm = "втягивается в"
	speak = list("уааааааааа-хааууууууаааааа!", "ААААаааууАААУааХУААААА!!!", "уууууууухххх.... ххххх-ххьооооонкккхх....", "ХХХХУУАААООНККК!!!")
	speak_emote = list("извивается", "корчится", "пульсирует", "бурлит", "расползается")
	speak_chance = 10
	tts_seed = "Kleiner"
	maxHealth = 500
	health = 500
	pixel_x = -16
	speed = 3
	move_to_delay = 3
	harm_intent_damage = 10
	melee_damage_lower = 30
	melee_damage_upper = 40
	attacktext = "неловко замахивается на"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/gibspawner/human, /obj/item/grown/bananapeel, /obj/item/bikehorn/golden)
	wander = FALSE
