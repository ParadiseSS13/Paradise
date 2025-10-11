/mob/living/simple_animal/hostile/megafauna
	name = "megafauna"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC | MOB_EPIC
	obj_damage = 400
	light_range = 3
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	stat_attack = DEAD
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	minbodytemp = 0
	maxbodytemp = INFINITY
	vision_range = 5
	aggro_vision_range = 18
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2
	dodging = FALSE // This needs to be false until someone fixes megafauna pathing so they dont lag-switch teleport at you (09-15-2023)
	initial_traits = list(TRAIT_FLYING)
	var/list/crusher_loot
	var/medal_type
	var/score_type = BOSS_SCORE
	var/elimination = FALSE
	var/anger_modifier = 0
	var/obj/item/gps/internal_gps
	var/recovery_time = 0
	var/true_spawn = TRUE // if this is a megafauna that should grant achievements, or have a gps signal
	var/nest_range = 10
	var/chosen_attack = 1 // chosen attack num
	var/list/attack_action_types = list()
	/// Has someone enabled hard mode?
	var/enraged = FALSE
	/// Path of the hardmode loot disk, if applicable.
	var/enraged_loot
	/// How much ore should killing this give
	var/difficulty_ore_modifier = 1

/mob/living/simple_animal/hostile/megafauna/Initialize(mapload)
	. = ..()
	GLOB.alive_megafauna_list |= UID()
	if(internal_gps && true_spawn)
		internal_gps = new internal_gps(src)
	for(var/action_type in attack_action_types)
		var/datum/action/innate/megafauna_attack/attack_action = new action_type()
		attack_action.Grant(src)
	generate_random_loot()
	RegisterSignal(src, COMSIG_HOSTILE_FOUND_TARGET, PROC_REF(hoverboard_deactivation))

/mob/living/simple_animal/hostile/megafauna/Destroy()
	QDEL_NULL(internal_gps)
	UnregisterSignal(src, COMSIG_HOSTILE_FOUND_TARGET)
	GLOB.alive_megafauna_list -= UID()
	return ..()

/mob/living/simple_animal/hostile/megafauna/Moved()
	if(target)
		DestroySurroundings() //So they can path through chasms.
	if(nest && nest.parent && get_dist(nest.parent, src) > nest_range)
		var/turf/closest = get_turf(nest.parent)
		for(var/i = 1 to nest_range)
			closest = get_step(closest, get_dir(closest, src))
		forceMove(closest) // someone teleported out probably and the megafauna kept chasing them
		target = null
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/can_die()
	return ..() && health <= 0

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	GLOB.alive_megafauna_list -= UID()
	// lets normalize the icons a bit
	pixel_x = 0
	pixel_y = 0
	// this happens before the parent call because `del_on_death` may be set
	if(can_die() && !admin_spawned)
		var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(C && crusher_loot && C.total_damage >= maxHealth * 0.6)
			spawn_crusher_loot()
		if(enraged && length(loot) && enraged_loot) //Don't drop a disk if the boss drops no loot. Important for legion.
			for(var/mob/living/M in urange(20, src)) //Yes big range, but for bubblegum arena
				if(M.client)
					loot += enraged_loot //Disk for each miner / borg.
		if(!elimination)	//used so the achievment only occurs for the last legion to die.
			SSblackbox.record_feedback("tally", "megafauna_kills", 1, "[initial(name)]")
	return ..()

/mob/living/simple_animal/hostile/megafauna/drop_loot()
	var/obj/structure/closet/crate/necropolis/loot_drop = new(get_turf(src))
	for(var/item in loot)
		new item(loot_drop)
	spawn_ore_reward(loot_drop)

/// If the megafauna has a pool of random loot items to pick from, override this proc to have it be set on initialization
/mob/living/simple_animal/hostile/megafauna/proc/generate_random_loot()
	return

/// Handling the ore part of the mega reward, the higher the difficulty_ore_modifier the more ore will spawn
/mob/living/simple_animal/hostile/megafauna/proc/spawn_ore_reward(atom/spawn_location)
	var/list/common_ore = list(
		/obj/item/stack/ore/uranium,
		/obj/item/stack/ore/silver,
		/obj/item/stack/ore/gold,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/titanium)
	var/list/rare_ore = list(
		/obj/item/stack/ore/diamond,
		/obj/item/stack/ore/bluespace_crystal)

	for(var/ore in common_ore)
		var/obj/item/stack/O = new ore(spawn_location)
		O.amount = roll(difficulty_ore_modifier * 2, 4 + difficulty_ore_modifier)
	for(var/ore in rare_ore)
		var/obj/item/stack/O = new ore(spawn_location)
		O.amount = roll(difficulty_ore_modifier, 4 + difficulty_ore_modifier)

/mob/living/simple_animal/hostile/megafauna/proc/spawn_crusher_loot()
	loot += crusher_loot

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	if(recovery_time >= world.time)
		return
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire(L)
		else
			devour(L)

/mob/living/simple_animal/hostile/megafauna/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(!istype(get_area(src), /area/shuttle)) //I'll be funny and make non teleported enrage mobs not lose enrage. Harder to pull off, and also funny when it happens accidently. Or if one gets on the escape shuttle.
		unrage()

/mob/living/simple_animal/hostile/megafauna/onShuttleMove(turf/oldT, turf/T1, rotation, mob/caller_mob)
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] \
		([ADMIN_FLW(src,"FLW")]) \
		moved via shuttle from ([oldloc.x], [oldloc.y], [oldloc.z]) to \
		([newloc.x], [newloc.y], [newloc.z])[caller_mob ? " called by [ADMIN_LOOKUP(caller_mob)]" : ""]")

/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		"<span class='danger'>[src] devours [L]!</span>",
		"<span class='userdanger'>You feast on [L], restoring your health!</span>")
	if(!is_station_level(z) || client) //NPC monsters won't heal while on station
		adjustBruteLoss(-L.maxHealth/2)
	L.gib()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(250)

		if(2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)

/mob/living/simple_animal/hostile/megafauna/proc/SetRecoveryTime(buffer_time)
	recovery_time = world.time + 2.5 DECISECONDS
	ranged_cooldown = world.time + buffer_time

/// This proc is called by the HRD-MDE grenade to enrage the megafauna. This should increase the megafaunas attack speed if possible, give it new moves, or disable weak moves. This should be reverseable, and reverses on zlvl change.
/mob/living/simple_animal/hostile/megafauna/proc/enrage()
	if(enraged || ((health / maxHealth) * 100 <= 80))
		return
	difficulty_ore_modifier += 4 // Hardmode only helps the station more and gives you bragging rights, no special items for hardmode
	enraged = TRUE

/mob/living/simple_animal/hostile/megafauna/proc/unrage()
	difficulty_ore_modifier -= 4
	enraged = FALSE

// MARK: PTL Interaction
/mob/living/simple_animal/hostile/megafauna/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	ptl.RegisterSignal(src, COMSIG_MOB_DEATH, TYPE_PROC_REF(/obj/machinery/power/transmission_laser, untarget), ptl)
	if(ptl?.firing)
		on_ptl_fire(ptl)
	return

/mob/living/simple_animal/hostile/megafauna/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	loot = list() // disable loot drops form the target to prevent cheese
	if(10 * output_level * damage_coeff[BURN] / (1 MW) > health) // If we would kill the target dust it.
		health = 0 // We need this so can_die() won't prevent dusting
		visible_message("<span class='danger'>\The [src] is reduced to dust by the beam!</span>")
		dust()
	else
		adjustFireLoss(10 * output_level / (1 MW))

/mob/living/simple_animal/hostile/megafauna/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	on_ptl_stop(ptl)
	if(ptl)
		ptl.UnregisterSignal(src, COMSIG_MOB_DEATH)

/mob/living/simple_animal/hostile/megafauna/on_ptl_fire(obj/machinery/power/transmission_laser/ptl)
	var/orbital_strike = image(icon, src, "orbital_strike", FLY_LAYER, SOUTH)
	add_overlay(orbital_strike)

/mob/living/simple_animal/hostile/megafauna/on_ptl_stop(obj/machinery/power/transmission_laser/ptl)
	for(var/image/overlay in overlays)
		if(overlay.name == "orbital_strike")
			cut_overlay(overlay)

/mob/living/simple_animal/hostile/megafauna/DestroySurroundings()
	. = ..()
	for(var/turf/simulated/floor/chasm/C in circlerangeturfs(src, 1))
		C.density = FALSE //I hate it.
		addtimer(VARSET_CALLBACK(C, density, TRUE), 2 SECONDS) // Needed to make them path. I hate it.

/mob/living/simple_animal/hostile/megafauna/proc/hoverboard_deactivation(source, target)
	SIGNAL_HANDLER // COMSIG_HOSTILE_FOUND_TARGET
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(!L.buckled)
		return
	if(!istype(L.buckled, /obj/tgvehicle/scooter/skateboard/hoverboard))
		return
	var/obj/tgvehicle/scooter/skateboard/hoverboard/cursed_board = L.buckled
	// Not a visible message, as walls or such may be in the way
	to_chat(L, "<span class='userdanger'><b>You hear a loud roar in the distance, and the lights on [cursed_board] begin to spark dangerously, as the board rumbles heavily!</b></span>")
	playsound(get_turf(src), 'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	cursed_board.necropolis_curse()

/datum/action/innate/megafauna_attack
	name = "Megafauna Attack"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = ""
	var/mob/living/simple_animal/hostile/megafauna/M
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/megafauna_attack/Grant(mob/living/L)
	if(ismegafauna(L))
		M = L
		return ..()
	return FALSE

/datum/action/innate/megafauna_attack/Activate()
	M.chosen_attack = chosen_attack_num
	to_chat(M, chosen_message)
