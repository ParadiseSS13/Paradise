/obj/effect/map_effect/marker/mapmanip/submap/extract/ruin/sieged_lab/vert_hallway
	name = "Sieged Lab, Vertical Hallway"
	color = COLOR_CYAN

/obj/effect/map_effect/marker/mapmanip/submap/insert/ruin/sieged_lab/vert_hallway
	name = "Sieged Lab, Vertical Hallway"
	color = COLOR_CYAN

/obj/effect/map_effect/marker/mapmanip/submap/extract/ruin/sieged_lab/horiz_hallway
	name = "Sieged Lab, Horizontal hallway"

/obj/effect/map_effect/marker/mapmanip/submap/insert/ruin/sieged_lab/horiz_hallway
	name = "Sieged Lab, Horizontal hallway"

/obj/effect/map_effect/marker/mapmanip/submap/extract/ruin/sieged_lab/medium_room
	name = "Sieged Lab, Medium room"
	color = COLOR_LIME

/obj/effect/map_effect/marker/mapmanip/submap/insert/ruin/sieged_lab/medium_room
	name = "Sieged Lab, Medium room"
	color = COLOR_LIME

/obj/effect/map_effect/marker/mapmanip/submap/extract/ruin/sieged_lab/wide_room
	name = "Sieged Lab, Wide room"
	color = COLOR_SUN

/obj/effect/map_effect/marker/mapmanip/submap/insert/ruin/sieged_lab/wide_room
	name = "Sieged Lab, Wide room"
	color = COLOR_SUN

// MARK: SYNDICATE BOSS

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate
	name = "Syndicate Harbinger"
	desc = "A blood-crazed, murderous Syndicate fanatic."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate_harbinger"
	icon_living = "syndicate_harbinger"
	speak_emote = list("snarls")
	projectiletype = /obj/item/projectile/bullet/heavybullet
	projectilesound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	internal_gps = null
	faction = list("syndicate", "spawned_corpse")
	attack_action_types = list(/datum/action/innate/megafauna_attack/dash)
	var/doors_opened = FALSE
	pixel_x = 0
	medal_type = null
	score_type = null

/obj/item/melee/energy/cleaving_saw/syndicate_harbinger
	name = "energy sword"
	force = 15
	force_on = 20
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "swordred"
	hitsound = 'sound/weapons/blade1.ogg' // Probably more appropriate than the previous hitsound. -- Dave
	usesound = 'sound/weapons/blade1.ogg'
	is_a_cleaving_saw = FALSE

/obj/effect/temp_visual/dir_setting/syndicate_harbinger_death
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate_harbinger"
	duration = 15

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate/death()
	if(health > 0)
		return
	new /obj/effect/temp_visual/dir_setting/syndicate_harbinger_death(loc, dir)
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate/transform_weapon()
	return

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate/Initialize(mapload)
	. = ..()
	qdel(miner_saw)
	miner_saw = new/obj/item/melee/energy/cleaving_saw/syndicate_harbinger(src)

	set_light(2, 2, COLOR_RED)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate/DestroyPathToTarget()
	if(!doors_opened)
		for(var/turf/T in RANGE_TURFS(4, src))
			for(var/obj/machinery/door/airlock/airlock in T)
				airlock.open(forced = TRUE)
				airlock.lock(forced = TRUE)
		doors_opened = TRUE

// No turf/window smashing for this guy
/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate/DestroyObjectsInDirection(direction)
	var/turf/T = get_step(targets_from, direction)
	if(QDELETED(T))
		return
	for(var/obj/O in T.contents)
		if(!O.Adjacent(targets_from))
			continue
		if((istype(O, /obj/structure/window)))
			continue
		if((ismachinery(O) || isstructure(O)) && O.density && environment_smash >= ENVIRONMENT_SMASH_STRUCTURES && !O.IsObscured())
			O.attack_animal(src)
			return

// MARK: LOOT

// Hacky solution for allowing us to have random spawns
// but make sure we don't spawn the same kind of tech
// level research paper twice on the ruin.
GLOBAL_LIST_INIT(ruin_sieged_lab_research_loot, list(
	"materials",
	"engineering",
	"plasmatech",
	"powerstorage",
	"bluespace",
	"biotech",
	"combat",
	"magnets",
	"programming",
	"syndicate"
))

/obj/item/paper/sieged_lab_research_paper

/obj/item/paper/sieged_lab_research_paper/Initialize(mapload)
	. = ..()
	if(!length(GLOB.ruin_sieged_lab_research_loot))
		log_debug("Ran out of research tech levels for sieged lab loot")
		return INITIALIZE_HINT_QDEL

	var/tech_level = rand(7, 9)
	var/tech_name = pick_n_take(GLOB.ruin_sieged_lab_research_loot)
	origin_tech = "[tech_name]=[tech_level]"
	name = "research notes - [tech_name] [tech_level]"

/obj/effect/spawner/random/sieged_lab/research_paper
	name = "sieged lab loot research paper spawner"
	loot = list(
		/obj/item/paper/sieged_lab_research_paper
	)
