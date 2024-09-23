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
	loot = list(/obj/effect/spawner/random/maintenance/one = 1)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 5, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list("Vox")
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
	loot = list(/obj/effect/spawner/random/maintenance/two = 1)
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
	loot = list(/obj/effect/spawner/random/maintenance/three = 1)

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
	loot = list(/obj/effect/spawner/random/maintenance/one = 1)

/mob/living/simple_animal/hostile/vox/ranged_laser/space
	name = "Vox Helmsman"
	desc = "Space-faring Vox raider, armed with a laser rifle and wearing a MODsuit."
	icon_state = "voxspacelaser"
	icon_living = "voxspacelaser"
	icon_dead = "voxspacedead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	wander = FALSE
	minbodytemp = 0
	loot = list(/obj/effect/spawner/random/maintenance/three = 1)

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
	desc = "Скуластое, громоздкое чудовище. Еще один неудачный эксперимент. Что именно они пытались создать?"
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "abomination1"
	icon_living = "abomination1"
	icon_dead = "abomination_dead"
	health = 230
	maxHealth = 230
	melee_damage_lower = 15
	melee_damage_upper = 25
	obj_damage = 60
	attacktext = "грызёт"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("abomination")
	speak_emote = list("кричит")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	weather_immunities = list("ash")
	stat_attack = UNCONSCIOUS
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/mob/living/simple_animal/hostile/abomination/super
	desc = "Оскалившийся, страшный монстр. Этот кажется проворным."
	icon_state = "abomination_headcrab"
	icon_living = "abomination_headcrab"
	icon_dead = "abomination_headcrab_dead"
	health = 200
	maxHealth = 200

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

/* Caves bosses */
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

/mob/living/simple_animal/hostile/deadwizard
	name = "\improper древний маг"
	desc = "Древний некромант, тысячелетиями властвующий над проклятым могильником."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_living = "deadwizard"
	icon_state = "deadwizard"
	mob_biotypes = MOB_UNDEAD | MOB_HUMANOID
	turns_per_move = 5
	speak_emote = list("rattles")
	emote_see = list("rattles")
	a_intent = INTENT_HARM
	maxHealth = 400
	health = 400
	ranged = TRUE
	retreat_distance = 7
	minimum_distance = 5
	ranged_cooldown_time = 5
	ranged_ignores_vision = TRUE
	robust_searching = TRUE
	aggro_vision_range = 12
	vision_range = 12
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	minbodytemp = 0
	maxbodytemp = 1500
	speed = 1
	healable = FALSE
	stat_attack = UNCONSCIOUS
	faction = list("skeleton")
	projectilesound = 'sound/magic/blind.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	deathmessage = "collapses into a pile of bones!"
	del_on_death = TRUE
	loot = list(
	/obj/effect/decal/remains/human,
	/obj/item/clothing/head/crown,
	/obj/item/clothing/suit/imperium_monk,
	/obj/effect/particle_effect/smoke/bad,
	/obj/item/emerald_stone)

/mob/living/simple_animal/hostile/deadwizard/Shoot(atom/targeted_atom)
	..()
	if(get_dist(src, targeted_atom) > 9)
		rapid = 1
		ranged_cooldown_time = 15
		projectiletype = /obj/item/projectile/magic/fireball/infernal
	else
		projectiletype = /obj/item/projectile/magic/arcane_barrage
		rapid = 4
		rapid_fire_delay = 1
		ranged_cooldown_time = 15

/*Black Mesa*/
//Alert sound
/mob/living/simple_animal/hostile/blackmesa
	var/list/alert_sounds
	var/alert_cooldown = 3 SECONDS
	var/alert_cooldown_time


/mob/living/simple_animal/hostile/blackmesa/Initialize(mapload)
	. = ..()
	add_language("Sol Common")
	default_language = GLOB.all_languages["Sol Common"]

/mob/living/simple_animal/hostile/blackmesa/Aggro()
	if(!alert_sounds)
		return
	if(world.time > alert_cooldown_time)
		playsound(src, pick(alert_sounds), 70)
		alert_cooldown_time = world.time + alert_cooldown
//Humans
/mob/living/simple_animal/hostile/blackmesa/hecu
	name = "HECU Grunt"
	desc = "I didn't sign on for this shit. Monsters, sure, but civilians? Who ordered this operation anyway?"
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "hecu_melee"
	icon_living = "hecu_melee"
	icon_dead = "hecu_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	turns_per_move = 5
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 90
	health = 90
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/gibspawner/human)
	unsuitable_atmos_damage = 7.5
	faction = list("hecu")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 2
	footstep_type = FOOTSTEP_MOB_SHOE
	alert_cooldown = 8 SECONDS
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert01.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert03.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert04.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert05.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert06.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert08.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/hecu/hg_alert10.ogg'
	)

/mob/living/simple_animal/hostile/blackmesa/hecu/ranged
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "hecu_ranged"
	icon_living = "hecu_ranged"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshots/gunshot_strong.ogg'
	loot = list(/obj/effect/gibspawner/human)
	dodging = TRUE
	rapid_melee = 1

/mob/living/simple_animal/hostile/blackmesa/hecu/ranged/smg
	rapid = 3
	icon_state = "hecu_ranged_smg"
	icon_living = "hecu_ranged_smg"
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/blackmesa/sec
	name = "Security Guard"
	desc = "About that beer I owe'd ya!"
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "security_guard_melee"
	icon_living = "security_guard_melee"
	icon_dead = "security_guard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	turns_per_move = 5
	speed = 0
	robust_searching = 1
	maxHealth = 70
	health = 70
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/genhit2.ogg'
	loot = list(/obj/effect/gibspawner/human)
	a_intent = INTENT_HARM
	unsuitable_atmos_damage = 7.5
	faction = list("hecu")
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE
	alert_cooldown = 8 SECONDS
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance01.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance02.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance03.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance04.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance05.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance06.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance07.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance08.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance09.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/security_guard/annoyance10.ogg'
	)

/mob/living/simple_animal/hostile/blackmesa/sec/ranged
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "security_guard_ranged"
	icon_living = "security_guard_ranged"
	casingtype = /obj/item/ammo_casing/c9mm
	projectilesound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	loot = list(/obj/effect/gibspawner/human, /obj/item/clothing/suit/armor/vest)
	rapid_melee = 1

/mob/living/simple_animal/hostile/blackmesa/blackops
	name = "black operative"
	desc = "Why do we always have to clean up a mess the grunts can't handle?"
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "blackops"
	icon_living = "blackops"
	icon_dead = "blackops"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	turns_per_move = 3
	speed = -0.5
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 150
	health = 150
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "strikes"
	attack_sound = 'sound/weapons/rapierhit.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/gibspawner/human)
	unsuitable_atmos_damage = 7.5
	faction = list("blackops")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 2
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	footstep_type = FOOTSTEP_MOB_SHOE
	alert_cooldown = 8 SECONDS
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert01.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert02.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert03.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert04.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert05.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert06.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert07.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/blackops/bo_alert08.ogg'
	)

/mob/living/simple_animal/hostile/blackmesa/blackops/ranged
	ranged = TRUE
	rapid = 2
	retreat_distance = 6
	minimum_distance = 6
	icon_state = "blackops_ranged"
	icon_living = "blackops_ranged"
	casingtype = /obj/item/ammo_casing/a556
	projectilesound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	loot = list(/obj/effect/gibspawner/human)
	rapid_melee = 1
	aggro_vision_range = 7
	vision_range = 7
	ranged_cooldown_time = 15

//Zombie
/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie
	name = "headcrab zombie"
	desc = "This unlucky person has had a headcrab latch onto their head. Ouch."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	maxHealth = 70
	health = 70
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	icon_dead = "zombie_dead"
	speak_chance = 1
	speak_emote = list("growls")
	speed = 1
	move_to_delay = 3.8
	emote_taunt = list("growls", "snarls", "grumbles")
	taunt_chance = 100
	melee_damage_lower = 15
	melee_damage_upper = 21
	attack_sound = 'modular_ss220/mobs/sound/creatures/zombie_attack.ogg'
	alert_cooldown_time = 8 SECONDS
	alert_sounds = list(
		'modular_ss220/mobs/sound/creatures/zombie_idle1.ogg',,
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/alert3.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/alert4.ogg',
		'modular_ss220/mobs/sound/creatures/zombie_idle2.ogg',
		'modular_ss220/mobs/sound/creatures/zombie_idle3.ogg',
	)
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/scientist
	name = "zombified scientist"
	desc = "Even after death, I still have to wear this horrible tie!"
	icon_state = "scientist_zombie"
	icon_living = "scientist_zombie"
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/guard
	name = "zombified guard"
	desc = "About that brain I owed ya!"
	icon_state = "security_zombie"
	icon_living = "security_zombie"
	maxHealth = 100 // Armor!
	health = 100
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/hecu
	name = "zombified marine"
	desc = "MY. ASS. IS. DEAD."
	icon_state = "hecu_zombie"
	icon_living = "hecu_zombie"
	maxHealth = 130 // More armor!
	health = 130
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/hev
	name = "zombified hazardous environment specialist"
	desc = "User death... surpassed."
	icon_state = "hev_zombie"
	icon_living = "hev_zombie"
	maxHealth = 160
	health = 160
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv1.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv2.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv3.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv4.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv5.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv6.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv7.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv8.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv9.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv10.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv11.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv12.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv13.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/zombies/hzv14.ogg',
	)


//Bullsquid
/mob/living/simple_animal/hostile/blackmesa/xen/bullsquid
	name = "bullsquid"
	desc = "Some highly aggressive alien creature. Thrives in toxic environments."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "bullsquid"
	icon_living = "bullsquid"
	icon_dead = "bullsquid_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_chance = 1
	speak_emote = list("growls")
	emote_taunt = list("growls", "snarls", "grumbles")
	taunt_chance = 100
	turns_per_move = 7
	maxHealth = 110
	health = 110
	obj_damage = 50
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = TRUE
	del_on_death = FALSE
	retreat_distance = 5
	minimum_distance = 5
	dodging = TRUE
	butcher_results = list(/obj/item/food/monstermeat/xenomeat = 2)
	projectiletype = /obj/item/projectile/bullet/bullsquid
	projectilesound = 'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/goo_attack3.ogg'
	melee_damage_upper = 18
	attack_sound = 'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/attack1.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/detect1.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/detect2.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/detect3.ogg'
	)

/obj/item/projectile/bullet/bullsquid
	name = "nasty ball of ooze"
	icon_state = "neurotoxin"
	damage = 13
	damage_type = BURN
	flag = ACID
	knockdown = 2 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	hitsound = 'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/splat1.ogg'
	hitsound_wall = 'modular_ss220/aesthetics_sounds/sound/mobs/bullsquid/splat1.ogg'

/obj/item/projectile/bullet/bullsquid/on_hit(atom/target, blocked, pierce_hit)
	new /obj/effect/decal/cleanable/greenglow(target.loc)
	return ..()

//Houndeye
/mob/living/simple_animal/hostile/blackmesa/xen/houndeye
	name = "houndeye"
	desc = "Some highly aggressive alien creature. Thrives in toxic environments."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "houndeye"
	icon_living = "houndeye"
	icon_dead = "houndeye_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_chance = 1
	speak_emote = list("growls")
	speed = 0
	move_to_delay = 2.6
	emote_taunt = list("growls", "snarls", "grumbles")
	taunt_chance = 100
	turns_per_move = 2
	maxHealth = 100
	health = 100
	obj_damage = 50
	harm_intent_damage = 10
	melee_damage_lower = 20
	melee_damage_upper = 20
	rapid_melee = 2
	del_on_death = FALSE
	butcher_results = list(/obj/item/food/monstermeat/xenomeat = 3)
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	minbodytemp = 0
	maxbodytemp = 1500
	loot = list(/obj/item/stack/ore/bluespace_crystal)
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/houndeye/he_alert1.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/houndeye/he_alert2.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/houndeye/he_alert3.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/houndeye/he_alert4.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/houndeye/he_alert5.ogg'
	)

//Vortiger
/mob/living/simple_animal/hostile/blackmesa/xen/vortigaunt/slave
	name = "slave vortigaunt"
	desc = "Bound by the shackles of a sinister force. He does not want to hurt you."
	icon = 'modular_ss220/maps220/icons/simple_human.dmi'
	icon_state = "vortigaunt_slave"
	icon_dead = "vortigaunt_dead"
	gender = MALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_chance = 1
	speak_emote = list("galungs")
	speed = 1
	emote_taunt = list("galalungas", "galungas", "gungs")
	projectiletype = /obj/item/projectile/beam/emitter/hitscan
	projectilesound = 'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/attack_shoot4.ogg'
	ranged_cooldown_time = 3 SECONDS
	ranged_message = "fires"
	taunt_chance = 100
	turns_per_move = 3
	maxHealth = 80
	health = 80
	speed = 2
	ranged = TRUE
	dodging = TRUE
	del_on_death = FALSE
	harm_intent_damage = 15
	melee_damage_lower = 10
	melee_damage_upper = 10
	retreat_distance = 8
	minimum_distance = 8
	aggro_vision_range = 9
	vision_range = 8
	attack_sound = 'sound/weapons/bite.ogg'
	loot = list(/obj/item/stack/sheet/bone)
	gold_core_spawnable = HOSTILE_SPAWN
	alert_sounds = list(
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert01.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert01b.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert02.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert03.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert04.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert05.ogg',
		'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/alert06.ogg',
	)

//Nihilanth
/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth
	name = "nihilanth"
	desc = "Holy shit."
	icon = 'modular_ss220/maps220/icons/nihilanth.dmi'
	icon_state = "nihilanth"
	icon_living = "nihilanth"
	pixel_x = -32
	speed = 3
	move_to_delay = 3.7
	bound_height = 32
	bound_width = 32
	icon_dead = "bullsquid_dead"
	maxHealth = 2000
	health = 2000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	universal_speak = TRUE
	projectilesound = 'sound/weapons/lasercannonfire.ogg'
	projectiletype = /obj/item/projectile/nihilanth
	ranged = TRUE
	ranged_cooldown_time = 25
	rapid = 3
	alert_cooldown = 30 SECONDS
	harm_intent_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 30
	attacktext = "lathes"
	attack_sound = 'sound/misc/demon_consume.ogg'
	status_flags = NONE
	wander = TRUE
	loot = list(/obj/effect/gibspawner/xeno, /obj/item/stack/ore/bluespace_crystal/refined = 30, /obj/item/card/id/xen_key, /obj/item/gun/energy/wormhole_projector)
	flying = TRUE
	death_sound = 'modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_pain01.ogg'

/obj/item/card/id/xen_key
	name = "xen key"
	desc = ""
	icon_state = "emag"
	item_state = "card-id"
	access = list (271)

/obj/item/projectile/nihilanth
	name = "portal energy"
	icon_state = "parry"
	damage = 20
	damage_type = BURN
	light_range = 2
	flag = ENERGY
	light_color = LIGHT_COLOR_FADEDPURPLE
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'

/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth/Aggro()
	. = ..()
	if(world.time > alert_cooldown_time)
		alert_cooldown_time = world.time + alert_cooldown
		switch(health)
			if(0 to 499)
				playsound(src, pick(list('modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_pain01.ogg', 'modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_freeeemmaan01.ogg')), 100)
			if(500 to 999)
				playsound(src, pick(list('modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_youalldie01.ogg', 'modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_foryouhewaits01.ogg')), 100)
			if(1000 to 1999)
				playsound(src, pick(list('modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_whathavedone01.ogg', 'modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_deceiveyou01.ogg')), 100)
			else
				playsound(src, pick(list('modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_thetruth01.ogg', 'modular_ss220/aesthetics_sounds/sound/mobs/nihilanth/nihilanth_iamthelast01.ogg')), 100)

/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth/death(gibbed)
	..()

//Freeman
/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/gordon_freeman
	name = "\improper Gordon Freeman"
	desc = "Gordon Freeman in the flesh. Or in the zombified form, it seems."
	icon_state = "gordon_freeman"
	speed = -2
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	health = 1000
	maxHealth = 1000
	rapid_melee = 2
	melee_damage_lower = 30
	melee_damage_upper = 30
	wander = FALSE
	attack_sound = 'sound/weapons/genhit3.ogg'
	loot = list(/obj/item/crowbar/freeman/ultimate)

/obj/structure/xen_pylon/freeman
	shield_range = 30
	max_integrity = 300

/obj/structure/xen_pylon/freeman/register_mob(mob/living/simple_animal/hostile/blackmesa/xen/mob_to_register)
	if(!istype(mob_to_register, /mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/gordon_freeman))
		return
	if(mob_to_register in shielded_mobs)
		return
	shielded_mobs += mob_to_register
	mob_to_register.shielded = TRUE
	mob_to_register.shield_count++
	mob_to_register.update_appearance()
	var/datum/beam/created_beam = Beam(mob_to_register, icon_state = "sm_arc_dbz_referance", time = 10 MINUTES, maxdistance = shield_range)
	shielded_mobs[mob_to_register] = created_beam
	RegisterSignal(created_beam, COMSIG_PARENT_QDELETING, PROC_REF(beam_died))
	RegisterSignal(mob_to_register, COMSIG_PARENT_QDELETING, PROC_REF(mob_died))

/obj/effect/freeman_blocker
	name = "freeman blocker"

/obj/effect/freeman_blocker/CanPass(atom/blocker, movement_dir, blocker_opinion)
	. = ..()
	if(istype(blocker, /mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/gordon_freeman))
		return FALSE
	return TRUE

//Spawners
#define MOB_PLACER_RANGE 16

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer
	name = "mob placer"
	icon = 'modular_ss220/maps220/icons/mapping_helpers.dmi'
	icon_state = "mobspawner"
	var/list/possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/xen/headcrab,
	/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/fast,
	/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/poison)
	//SS220 edit START
	var/list/faction = list()
	var/health
	var/maxHealth
	var/melee_damage_lower
	var/melee_damage_upper
	//SS220 edit END

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/Initialize(mapload)
	. = ..()
	for(var/turf/iterating_turf in range(MOB_PLACER_RANGE, src))
		RegisterSignal(iterating_turf, COMSIG_ATOM_ENTERED, PROC_REF(trigger))

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/proc/trigger(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER
	if(!isliving(entered_atom))
		return
	var/mob/living/entered_mob = entered_atom

	if(!entered_mob.client)
		return

	var/mob/picked_mob = pick(possible_mobs)
	//SS220 edit START
	var/mob/living/simple_animal/hostile/new_mob = new picked_mob(loc)
	if(name != initial(src.name)) new_mob.name = name
	if(desc != initial(src.desc)) new_mob.desc = desc
	if(length(faction)) 	new_mob.faction = faction
	if(health)				new_mob.health = health
	if(maxHealth)			new_mob.maxHealth = maxHealth
	if(melee_damage_lower) 	new_mob.melee_damage_lower = melee_damage_lower
	if(melee_damage_upper) 	new_mob.melee_damage_upper = melee_damage_upper
	//SS220 edit END
	qdel(src)

#undef MOB_PLACER_RANGE

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/xen
	icon_state = "spawn_xen"
	possible_mobs = list(
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab,
		/mob/living/simple_animal/hostile/blackmesa/xen/houndeye,
		/mob/living/simple_animal/hostile/blackmesa/xen/bullsquid,
	)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/xen/zombie
	icon_state = "spawn_zombie"
	possible_mobs = list(
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/scientist,
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/guard,
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/hecu,
	)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/blackops
	icon_state = "spawn_blackops"
	possible_mobs = list(
		/mob/living/simple_animal/hostile/blackmesa/blackops,
		/mob/living/simple_animal/hostile/blackmesa/blackops/ranged,
	)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/hev_zombie
	icon_state = "spawn_hev"
	possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/hev)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/scientist_zombie
	icon_state = "spawn_zombiescientist"
	possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/scientist)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/scientist_zombie
	icon_state = "spawn_zombiesec"
	possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/guard)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/security_guard
	icon_state = "spawn_guard"
	possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/sec, /mob/living/simple_animal/hostile/blackmesa/sec/ranged)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/vortigaunt_hostile
	icon_state = "spawn_vortigaunt_slave"
	possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/xen/vortigaunt/slave)

/obj/effect/landmark/awaymissions/black_mesa/random_mob_placer/hecu
	icon_state = "spawn_vortigaunt"
	possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/hecu, /mob/living/simple_animal/hostile/blackmesa/hecu/ranged,/mob/living/simple_animal/hostile/blackmesa/hecu/ranged/smg)

/* Space Battle */
//Spawners
/obj/effect/landmark/awaymissions/spacebattle/mine_spawner
	icon = 'modular_ss220/maps220/icons/spacebattle.dmi'
	icon_state = "spawner_mine"
	var/id = null
	var/triggered = 0
	var/faction = "syndicate"
	var/safety_z_check = 1

/obj/effect/landmark/awaymissions/spacebattle/mob_spawn
	name = "spawner"
	icon = 'modular_ss220/maps220/icons/spacebattle.dmi'
	var/id = null
	var/syndi_mob = null

/obj/effect/landmark/awaymissions/spacebattle/mine_spawner/Crossed(AM as mob|obj, oldloc)
	if(!isliving(AM))
		return
	var/mob/living/M = AM
	if(faction && (faction in M.faction))
		return
	triggerlandmark(M)

/obj/effect/landmark/awaymissions/spacebattle/mine_spawner/proc/triggerlandmark(mob/living/victim)
	if(triggered)
		return
	victim.spawn_alert(victim)
	for(var/obj/effect/landmark/awaymissions/spacebattle/mob_spawn/S in GLOB.landmarks_list)
		if(safety_z_check && S.z != z)
			continue
		if(S.id == id)
			new S.syndi_mob(get_turf(S))
			triggered = 1
	qdel(src)

/obj/effect/landmark/awaymissions/spacebattle/mob_spawn/melee
	name = "melee"
	icon_state = "melee"
	syndi_mob = /mob/living/simple_animal/hostile/syndicate/melee/autogib/spacebattle

/obj/effect/landmark/awaymissions/spacebattle/mob_spawn/melee_space
	name = "melee_space"
	icon_state = "space_melee"
	syndi_mob = /mob/living/simple_animal/hostile/syndicate/melee/space/autogib/spacebattle

/obj/effect/landmark/awaymissions/spacebattle/mob_spawn/ranged
	name = "ranged"
	icon_state = "range"
	syndi_mob = /mob/living/simple_animal/hostile/syndicate/ranged/autogib/spacebattle

/obj/effect/landmark/awaymissions/spacebattle/mob_spawn/ranged_space
	name = "ranged_space"
	icon_state = "space_range"
	syndi_mob = /mob/living/simple_animal/hostile/syndicate/ranged/space/autogib/spacebattle

/obj/effect/landmark/awaymissions/spacebattle/mob_spawn/drone
	name = "drone"
	icon_state = "drone"
	syndi_mob = /mob/living/simple_animal/hostile/malf_drone/spacebattle

//Enemies
/mob/living/simple_animal/hostile/syndicate
	//Обычный лут, дропается со всех
	var/SynMobDrop
	//Выпадение бладрига
	var/SynSpace
	//Лут с милишников
	var/SynMelee
	//Лут с дальников
	var/SynRange

/mob/living/simple_animal/hostile/syndicate/Initialize()
	var/RollForLoot = rand(1,50)
	switch(RollForLoot)
		// 16%
		if(1 to 8)
			pick(SynMobDrop = /obj/item/food/syndicake,
				SynMobDrop = /obj/item/poster/random_contraband)
		// 14%
		if(8 to 15)
			pick(SynMobDrop = /obj/item/clothing/mask/gas/syndicate,
				SynMobDrop = /obj/item/tank/internals/emergency_oxygen/engi/syndi)
		// 10%
		if(15 to 20)
			pick(SynMobDrop = /obj/item/target/syndicate,
				SynMobDrop = /obj/item/deck/cards/syndicate,
				SynMobDrop = /obj/item/kitchen/knife/combat/survival)
		// 8%
		if(20 to 24)
			pick(SynMobDrop = /obj/item/clothing/glasses/night,
				SynMobDrop = /obj/item/stack/medical/bruise_pack,
				SynMobDrop = /obj/item/stack/medical/ointment)
		// 6%
		if(24 to 27)
			pick(SynMobDrop = /obj/item/reagent_containers/patch/styptic/small,
				SynMobDrop = /obj/item/reagent_containers/patch/silver_sulf/small,
				SynMobDrop = /obj/item/food/donkpocket)
		// 4%
		if(27 to 29)
			pick(SynMobDrop = /obj/item/reagent_containers/patch/styptic,
				SynMobDrop = /obj/item/reagent_containers/patch/silver_sulf,
				SynMobDrop = /obj/item/storage/backpack/duffel/syndie,
				SynMobDrop = /obj/item/clothing/gloves/combat)
		// 2%
		if(30)
			pick(SynMobDrop = /obj/item/storage/fancy/cigarettes/cigpack_syndicate,
				SynMobDrop = /obj/item/storage/box/syndidonkpockets,
				SynMobDrop = /obj/item/card/id/syndicate)
		// 40%
		else
			SynMobDrop = /obj/item/ammo_casing/c10mm
	. = ..()

/mob/living/simple_animal/hostile/syndicate/Initialize()
	switch(rand(1,100))
		// 1%
		if(1)
			SynSpace = /obj/item/mod/control/pre_equipped/nuclear
		else
			SynSpace = /obj/item/ammo_casing/c10mm
	return ..()

/mob/living/simple_animal/hostile/syndicate/melee/Initialize()
	switch(rand(1,100))
		// 1%
		if(1)
			SynMelee = /obj/item/melee/energy/sword/saber
		// 2%
		if(2 to 3)
			SynMelee = /obj/item/shield/energy
		else
			SynMelee = /obj/item/ammo_casing/c10mm
	return ..()

/mob/living/simple_animal/hostile/syndicate/ranged/Initialize()
	switch(rand(rand(1,100)))
		// 10%
		if(25 to 35)
			SynRange = /obj/item/ammo_box/magazine/m10mm
		// 5%
		if(35 to 40)
			SynRange = /obj/item/gun/projectile/automatic/pistol
		// 7%
		if(40 to 47)
			SynRange = /obj/item/clothing/accessory/holster
		// 3%
		if(47 to 50)
			SynRange = /obj/item/ammo_box/magazine/smgm45
		// 1%
		if(50 to 51)
			SynRange = /obj/item/gun/projectile/automatic/c20r
		else
			SynRange = /obj/item/ammo_casing/c10mm
	. = ..()

/mob/living/simple_animal/hostile/syndicate/melee/autogib/spacebattle
	damage_coeff = list("brute" = 1, "fire" = 0.6, "tox" = 1, "clone" = 2, "stamina" = 0, "oxy" = 0.5)
	melee_damage_type = BURN
	attack_sound = 'sound/weapons/saberon.ogg'
	maxHealth = 160
	health = 160

/mob/living/simple_animal/hostile/syndicate/melee/autogib/spacebattle/Initialize()
	. = ..()
	loot = list(/obj/effect/decal/cleanable/ash, SynMobDrop, SynMelee)
	return .

/mob/living/simple_animal/hostile/syndicate/melee/space/autogib/spacebattle
	damage_coeff = list("brute" = 1, "fire" = 0.8, "tox" = 1, "clone" = 2, "stamina" = 0, "oxy" = 0)
	melee_damage_type = BURN
	attack_sound = 'sound/weapons/saberon.ogg'
	maxHealth = 200
	health = 200

/mob/living/simple_animal/hostile/syndicate/melee/space/autogib/spacebattle/Initialize()
	. = ..()
	loot = list(/obj/effect/decal/cleanable/ash, SynMobDrop, SynMelee, SynSpace)
	return .

/mob/living/simple_animal/hostile/syndicate/ranged/autogib/spacebattle
	damage_coeff = list("brute" = 1, "fire" = 0.6, "tox" = 1, "clone" = 2, "stamina" = 0, "oxy" = 0.5)
	maxHealth = 150
	health = 150

/mob/living/simple_animal/hostile/syndicate/ranged/autogib/spacebattle/Initialize()
	. = ..()
	loot = list(/obj/effect/decal/cleanable/ash, SynMobDrop, SynRange)
	return .

/mob/living/simple_animal/hostile/syndicate/ranged/space/autogib/spacebattle
	maxHealth = 180
	health = 180

/mob/living/simple_animal/hostile/syndicate/ranged/space/autogib/spacebattle/Initialize()
	. = ..()
	loot = list(/obj/effect/decal/cleanable/ash, SynMobDrop, SynRange, SynSpace)
	return .

/mob/living/simple_animal/hostile/malf_drone/spacebattle
	icon = 'modular_ss220/maps220/icons/spacebattle.dmi'
	icon_state = "wisewill-Combat-roll"
	icon_living = "wisewill-Combat-roll"
	icon_gib = "drone_dead"
	health = 50
	maxHealth = 50
	faction = list("syndicate")
	projectiletype = /obj/item/projectile/beam/laser/syndrone

/obj/item/projectile/beam/laser/syndrone
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"
	eyeblur = 1

/mob/living/simple_animal/hostile/malf_drone/spacebattle/drop_loot()
	do_sparks(3, 1, src)
	var/turf/T = get_turf(src)

	//shards
	var/obj/O = new /obj/item/shard(T)
	step_to(O, get_turf(pick(view(7, src))))
	if(prob(50))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(25))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))

	//rods
	var/obj/item/stack/K = new /obj/item/stack/rods(T, rand(1,5))
	step_to(K, get_turf(pick(view(7, src))))
	K.update_icon()

	//plastitanuim
	K = new /obj/item/stack/sheet/mineral/plastitanium(T, rand(1,5))
	step_to(K, get_turf(pick(view(7, src))))
	K.update_icon()

/mob/living/simple_animal/hostile/malf_drone/spacebattle/update_icons()
	if(passive_mode)
		icon_state = "wisewill-Combat"
	else if(health / maxHealth > 0.9)
		icon_state = "wisewill-Combat-roll2"
	else if(health / maxHealth > 0.5)
		icon_state = "wisewill-Combat-roll"
	else if(health / maxHealth < 0.5)
		icon_state = "wisewill-Combat"

