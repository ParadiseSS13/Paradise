/**********************Mineral deposits**************************/

/// wall piece
/turf/simulated/mineral
	name = "rock"
	icon = 'icons/turf/walls/smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_MINERAL_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_MINERAL_WALLS)
	baseturf = /turf/simulated/floor/plating/asteroid/airless
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation_beta = RAD_BETA_BLOCKER
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	color = COLOR_ROCK
	var/environment_type = "asteroid"
	var/turf/simulated/floor/plating/turf_type = /turf/simulated/floor/plating/asteroid/airless
	var/last_act = 0

	var/defer_change = 0
	var/mine_time = 4 SECONDS //Changes how fast the turf is mined by pickaxes, multiplied by toolspeed
	/// Should this be set to the normal rock colour on init?
	var/should_reset_color = TRUE

	/// The ore type, if any, that should spawn in the wall on Initialize.
	/// Expected to be a subtype of [/datum/ore].
	var/preset_ore_type
	/// The representation of the unmined ore in the wall, if any.
	var/datum/ore/ore

/turf/simulated/mineral/Initialize(mapload)
	. = ..()

	if(should_reset_color)
		color = COLOR_ROCK

	if(preset_ore_type)
		set_ore(preset_ore_type)

	AddComponent(/datum/component/debris, DEBRIS_ROCK, -20, 10, 1)

/turf/simulated/mineral/proc/set_ore(ore_type)
	if(!ore_type)
		return

	if(ore)
		qdel(ore)

	ore = new ore_type()
	if(ore.spread_chance)
		for(var/dir in GLOB.cardinal)
			if(prob(ore.spread_chance))
				var/turf/simulated/mineral/T = get_step(src, dir)
				if(istype(T))
					T.set_ore(ore_type)

/turf/simulated/mineral/shuttleRotate(rotation)
	QUEUE_SMOOTH(src)

/turf/simulated/mineral/proc/invalid_tool(mob/user, obj/item/pickaxe/axe)
	if(!istype(axe))
		return TRUE

	return FALSE

/turf/simulated/mineral/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK

	if(!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FINISH_ATTACK

	if(istype(attacking, /obj/item/pickaxe))
		var/obj/item/pickaxe/P = attacking
		if(invalid_tool(user, P))
			return FINISH_ATTACK

		var/turf/T = user.loc
		if(!isturf(T))
			return FINISH_ATTACK

		if(last_act + (mine_time * P.toolspeed) > world.time) // Prevents message spam
			return FINISH_ATTACK

		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")
		P.playDigSound()

		if(do_after(user, mine_time * P.toolspeed, target = src))
			if(ismineralturf(src)) //sanity check against turf being deleted during digspeed delay
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				gets_drilled(user, productivity_mod = P.bit_productivity_mod)
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, P.name)

		return FINISH_ATTACK
	else
		return attack_hand(user)

/turf/simulated/mineral/proc/mine_ore(mob/user, triggered_by_explosion, productivity_mod = 1)
	if(!ore)
		return MINERAL_ALLOW_DIG

	for(var/obj/effect/temp_visual/mining_overlay/M in src)
		qdel(M)

	return ore.on_mine(src, user, triggered_by_explosion, productivity_mod)

/turf/simulated/mineral/proc/gets_drilled(mob/user, triggered_by_explosion = FALSE, productivity_mod = 1)
	if(mine_ore(user, triggered_by_explosion, productivity_mod) == MINERAL_PREVENT_DIG)
		return

	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, PROC_REF(AfterChange)), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		gets_drilled()
	..()

/turf/simulated/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, "<span class='notice'>You start digging into the rock...</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
	if(do_after(M, 40, target = src))
		to_chat(M, "<span class='notice'>You tunnel into the rock.</span>")
		gets_drilled(M)

/turf/simulated/mineral/Bumped(atom/movable/AM)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/pickaxe)) && (!H.hand))
			attack_by(H.l_hand, H)
		else if((istype(H.r_hand,/obj/item/pickaxe)) && H.hand)
			attack_by(H.r_hand, H)
		return

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.selected_item, /obj/item/pickaxe))
			attack_by(R.selected_item, R)

	else if(ismecha(AM))
		var/obj/mecha/M = AM
		if(istype(M.selected, /obj/item/mecha_parts/mecha_equipment/drill))
			M.selected.action(src)


/turf/simulated/mineral/acid_melt()
	ChangeTurf(baseturf)

/turf/simulated/mineral/ex_act(severity)
	..()
	switch(severity)
		if(3)
			if(prob(75))
				gets_drilled(null, 1)
		if(2)
			if(prob(90))
				gets_drilled(null, 1)
		if(1)
			gets_drilled(null, 1)

/turf/simulated/mineral/random
	var/mineralSpawnChanceList = list(
		/datum/ore/iron = 40,
		/datum/ore/plasma = 20,
		/datum/ore/silver = 12,
		/datum/ore/titanium = 11,
		/datum/ore/gold = 10,
		/datum/ore/uranium = 5,
		/datum/ore/gibtonite = 4,
		/datum/ore/bluespace = 1,
		/datum/ore/diamond = 1,
	)

	var/mineralChance = 10

/turf/simulated/mineral/random/Initialize(mapload)
	. = ..()

	mineralSpawnChanceList = typelist("mineralSpawnChanceList", mineralSpawnChanceList)
	if(prob(mineralChance))
		var/new_ore_type = pickweight(mineralSpawnChanceList)
		set_ore(new_ore_type)

/turf/simulated/mineral/random/space
	mineralSpawnChanceList = list(
		/datum/ore/iron = 40,
		/datum/ore/plasma = 20,
		/datum/ore/silver = 12,
		/datum/ore/titanium = 11,
		/datum/ore/gold = 10,
		/datum/ore/uranium = 5,
		/datum/ore/gibtonite = 4,
		/datum/ore/bluespace = 1,
		/datum/ore/diamond = 1,
		/datum/ore/platinum = 3,
		/datum/ore/palladium = 3,
		/datum/ore/iridium = 3
	)

/turf/simulated/mineral/ancient
	name = "ancient rock"
	desc = "A rare asteroid rock that appears to be resistant to all mining tools except pickaxes!"
	smoothing_groups = list(SMOOTH_GROUP_MINERAL_WALLS, SMOOTH_GROUP_ASTEROID_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_MINERAL_WALLS, SMOOTH_GROUP_ASTEROID_WALLS)
	mine_time = 6 SECONDS
	color = COLOR_ANCIENT_ROCK
	layer = MAP_EDITOR_TURF_LAYER
	should_reset_color = FALSE
	baseturf = /turf/simulated/floor/plating/asteroid/ancient

/turf/simulated/mineral/ancient/blob_act(obj/structure/blob/B)
	if(prob(50))
		blob_destruction()

/turf/simulated/mineral/ancient/proc/blob_destruction()
	playsound(src, pick('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg'), 30, 1 )

	for(var/obj/O in contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

	ChangeTurf(/turf/simulated/floor/plating/asteroid/ancient)
	return TRUE

/turf/simulated/mineral/ancient/outer
	name = "cold ancient rock"
	desc = "A rare and dense asteroid rock that appears to be resistant to everything except diamond and sonic tools! Can not be used to create portals to hell."
	mine_time = 15 SECONDS
	color = COLOR_COLD_ANCIENT_ROCK
	var/static/list/allowed_picks_typecache

/turf/simulated/mineral/ancient/outer/Initialize(mapload)
	. = ..()
	allowed_picks_typecache = typecacheof(list(
			/obj/item/pickaxe/drill/jackhammer,
			/obj/item/pickaxe/diamond,
			/obj/item/pickaxe/drill/cyborg/diamond,
			/obj/item/pickaxe/drill/diamonddrill,
			))

/turf/simulated/mineral/ancient/outer/invalid_tool(mob/user, obj/item/pickaxe/axe)
	if(..())
		return TRUE

	if(!(is_type_in_typecache(axe, allowed_picks_typecache)))
		to_chat(user, "<span class='notice'>Only diamond tools or a sonic jackhammer can break this rock.</span>")
		return TRUE

/turf/simulated/mineral/ancient/lava_land_surface_hard
	name = "hardened volcanic rock"
	desc = "A dense volcanic rock that appears to be resistant to everything except diamond and sonic tools!"
	mine_time = 15 SECONDS
	color = COLOR_HARD_ROCK
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface_hard
	var/static/list/allowed_picks_typecache

/turf/simulated/mineral/ancient/lava_land_surface_hard/Initialize(mapload)
	. = ..()
	allowed_picks_typecache = typecacheof(list(
			/obj/item/pickaxe/drill/jackhammer,
			/obj/item/pickaxe/diamond,
			/obj/item/pickaxe/drill/cyborg/diamond,
			/obj/item/pickaxe/drill/diamonddrill,
			))

/turf/simulated/mineral/ancient/lava_land_surface_hard/invalid_tool(mob/user, obj/item/pickaxe/axe)
	if(..())
		return TRUE

	if(!(is_type_in_typecache(axe, allowed_picks_typecache)))
		to_chat(user, "<span class='notice'>Only diamond tools or a sonic jackhammer can break this rock.</span>")
		return TRUE

/turf/simulated/mineral/random/high_chance
	color = COLOR_YELLOW
	mineralChance = 25
	mineralSpawnChanceList = list(
		/datum/ore/silver = 50,
		/datum/ore/plasma = 50,
		/datum/ore/gold = 45,
		/datum/ore/titanium = 45,
		/datum/ore/uranium = 35,
		/datum/ore/diamond = 30,
		/datum/ore/bluespace = 20,
	)

/turf/simulated/mineral/random/high_chance/space
	mineralSpawnChanceList = list(
		/datum/ore/silver = 50,
		/datum/ore/plasma = 50,
		/datum/ore/gold = 45,
		/datum/ore/titanium = 45,
		/datum/ore/uranium = 35,
		/datum/ore/diamond = 30,
		/datum/ore/bluespace = 20,
		/datum/ore/platinum = 25,
		/datum/ore/palladium = 25,
		/datum/ore/iridium = 25
	)

/turf/simulated/mineral/random/high_chance/clown
	mineralChance = 40
	mineralSpawnChanceList = list(
		/datum/ore/uranium = 35,
		/datum/ore/iron = 30,
		/datum/ore/bananium = 15,
		/datum/ore/tranquillite = 15,
		/datum/ore/bluespace = 10,
		/datum/ore/gold = 5,
		/datum/ore/silver = 5,
		/datum/ore/diamond = 2,
	)

/turf/simulated/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	defer_change = 1
	mineralSpawnChanceList = list(
		/datum/ore/silver = 50,
		/datum/ore/plasma = 50,
		/datum/ore/gold = 45,
		/datum/ore/titanium = 45,
		/datum/ore/uranium = 35,
		/datum/ore/diamond = 30,
		/datum/ore/bluespace = 20,
	)

/turf/simulated/mineral/random/low_chance
	color = COLOR_VIOLET
	mineralChance = 6
	mineralSpawnChanceList = list(
		/datum/ore/iron = 40,
		/datum/ore/plasma = 15,
		/datum/ore/silver = 6,
		/datum/ore/gold = 4,
		/datum/ore/titanium = 4,
		/datum/ore/gibtonite = 2,
		/datum/ore/uranium = 2,
		/datum/ore/diamond = 1,
		/datum/ore/bluespace = 1,
	)

/turf/simulated/mineral/random/low_chance/space
	mineralSpawnChanceList = list(
		/datum/ore/iron = 40,
		/datum/ore/plasma = 15,
		/datum/ore/silver = 6,
		/datum/ore/gold = 4,
		/datum/ore/titanium = 4,
		/datum/ore/gibtonite = 2,
		/datum/ore/uranium = 2,
		/datum/ore/diamond = 1,
		/datum/ore/bluespace = 1,
		/datum/ore/platinum = 1,
		/datum/ore/palladium = 1,
		/datum/ore/iridium = 1
	)

/turf/simulated/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	defer_change = 1

/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/datum/ore/iron = 95,
		/datum/ore/plasma = 30,
		/datum/ore/silver = 20,
		/datum/ore/gold = 8,
		/datum/ore/titanium = 8,
		/datum/ore/uranium = 3,
		/datum/ore/gibtonite = 2,
		/datum/ore/diamond = 1,
	)
	color = COLOR_MAROON

/turf/simulated/mineral/random/volcanic/labormineral
	mineralSpawnChanceList = list(
		/datum/ore/iron = 95,
		/datum/ore/plasma = 30,
		/datum/ore/silver = 20,
		/datum/ore/titanium = 8,
		/datum/ore/gold = 8,
		/datum/ore/uranium = 3,
		/datum/ore/gibtonite = 2,
		/datum/ore/bluespace = 1,
		/datum/ore/diamond = 1,
	)

// Actual minerals
/turf/simulated/mineral/clown
	preset_ore_type = /datum/ore/bananium

/turf/simulated/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	defer_change = 1

/turf/simulated/mineral/volcanic/clown
	preset_ore_type = /datum/ore/bananium

/turf/simulated/mineral/volcanic/lava_land_surface
	baseturf = /turf/simulated/floor/lava/mapping_lava
