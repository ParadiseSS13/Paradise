// Base type for basic mob megafauna
/mob/living/basic/megafauna
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
	faction = list("boss")
	weather_immunities = list("lava","ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	speed = 0
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER // Looks weird with them slipping under mineral walls and cameras and shit otherwise
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2
	initial_traits = list(TRAIT_FLYING)
	/// The loot the mob should drop if killed with a crusher
	var/list/crusher_loot
	/// The type of medal it drops if on hard mode
	var/medal_type
	/// The type of boss for the medal it drops
	var/score_type
	/// Is the mob truly dead?
	var/elimination = FALSE
	/// The mob's internal GPS, if it has one
	var/obj/item/gps/internal_gps
	/// If this is a megafauna that should grant achievements, or have a gps signal
	var/true_spawn = TRUE
	/// Has someone enabled hard mode?
	var/enraged = FALSE
	/// Path of the hardmode loot disk, if applicable.
	var/enraged_loot
	/// How much ore should killing this give
	var/difficulty_ore_modifier = 0
	/// Actions to grant on Initialize
	var/list/innate_actions = list()

/mob/living/basic/megafauna/Initialize(mapload)
	. = ..()
	GLOB.alive_megafauna_list |= UID()
	if(internal_gps && true_spawn)
		internal_gps = new internal_gps(src)
	grant_actions_by_list(innate_actions)
	generate_random_loot()
	RegisterSignal(src, , PROC_REF(hoverboard_deactivation))

/mob/living/basic/megafauna/Destroy()
	QDEL_NULL(internal_gps)
	UnregisterSignal(src, COMSIG_HOSTILE_FOUND_TARGET)
	GLOB.alive_megafauna_list -= UID()
	return ..()

/mob/living/basic/megafauna/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			devour(L)

/mob/living/basic/megafauna/can_die()
	return ..() && health <= 0

/mob/living/basic/megafauna/death(gibbed)
	GLOB.alive_megafauna_list -= UID()
	// lets normalize the icons a bit
	pixel_x = 0
	pixel_y = 0
	// this happens before the parent call because `del_on_death` may be set
	if(can_die() && !admin_spawned)
		var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(C && crusher_loot && C.total_damage >= maxHealth * 0.6)
			spawn_crusher_loot()
		if(enraged && length(loot) && enraged_loot) // Don't drop a disk if the boss drops no loot. Important for legion.
			for(var/mob/living/M in urange(20, src)) // Yes big range, but for bubblegum arena
				if(M.client)
					loot += enraged_loot // Disk for each miner / borg.
		if(!elimination)	// used so the achievment only occurs for the last legion to die.
			SSblackbox.record_feedback("tally", "megafauna_kills", 1, "[initial(name)]")
		calc_ore_reward()
	return ..()

/// If the megafauna has a pool of random loot items to pick from, override this proc to have it be set on initialization
/mob/living/basic/megafauna/proc/generate_random_loot()
	return list()

/// Handling the ore part of the mega reward, the higher the difficulty_ore_modifier the more ore will spawn
/mob/living/basic/megafauna/proc/calc_ore_reward()
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
		var/obj/item/stack/O = new ore(loc)
		O.amount = roll(difficulty_ore_modifier * 2, 4 + difficulty_ore_modifier)
	for(var/ore in rare_ore)
		var/obj/item/stack/O = new ore(loc)
		O.amount = roll(difficulty_ore_modifier, 4 + difficulty_ore_modifier)

/mob/living/basic/megafauna/proc/spawn_crusher_loot()
	loot += crusher_loot

/mob/living/basic/megafauna/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(!istype(get_area(src), /area/shuttle))
		unrage()

/mob/living/basic/megafauna/onShuttleMove(turf/oldT, turf/T1, rotation, mob/caller_mob)
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] \
		([ADMIN_FLW(src,"FLW")]) \
		moved via shuttle from ([oldloc.x], [oldloc.y], [oldloc.z]) to \
		([newloc.x], [newloc.y], [newloc.z])[caller_mob ? " called by [ADMIN_LOOKUP(caller_mob)]" : ""]")

/mob/living/basic/megafauna/proc/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		"<span class='danger'>[src] devours [L]!</span>",
		"<span class='userdanger'>You feast on [L], restoring your health!</span>")
	if(!is_station_level(z) || client) // NPC monsters won't heal while on station
		adjustBruteLoss(-L.maxHealth/2)
	L.gib()
	return TRUE

/mob/living/basic/megafauna/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(250)

		if(2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)

/// This proc is called by the HRD-MDE grenade to enrage the megafauna. This should increase the megafaunas attack speed if possible, give it new moves, or disable weak moves. This should be reverseable, and reverses on zlvl change.
/mob/living/basic/megafauna/proc/enrage()
	if(enraged || ((health / maxHealth) * 100 <= 80))
		return
	difficulty_ore_modifier += 4 // Hardmode only helps the station more and gives you bragging rights, no special items for hardmode
	enraged = TRUE

/mob/living/basic/megafauna/proc/unrage()
	difficulty_ore_modifier -= 4
	enraged = FALSE

// MARK: PTL Interaction
/mob/living/basic/megafauna/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	ptl.RegisterSignal(src, COMSIG_MOB_DEATH, TYPE_PROC_REF(/obj/machinery/power/transmission_laser, untarget), ptl)
	if(ptl?.firing)
		on_ptl_fire(ptl)
	return

/mob/living/basic/megafauna/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	loot = list() // disable loot drops form the target to prevent cheese
	if(10 * output_level * damage_coeff[BURN] / (1 MW) > health) // If we would kill the target dust it.
		health = 0 // We need this so can_die() won't prevent dusting
		visible_message("<span class='danger'>\The [src] is reduced to dust by the beam!</span>")
		dust()
	else
		adjustFireLoss(10 * output_level / (1 MW))

/mob/living/basic/megafauna/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	on_ptl_stop(ptl)
	if(ptl)
		ptl.UnregisterSignal(src, COMSIG_MOB_DEATH)

/mob/living/basic/megafauna/on_ptl_fire(obj/machinery/power/transmission_laser/ptl)
	var/orbital_strike = image(icon, src, "orbital_strike", FLY_LAYER, SOUTH)
	add_overlay(orbital_strike)

/mob/living/basic/megafauna/on_ptl_stop(obj/machinery/power/transmission_laser/ptl)
	for(var/image/overlay in overlays)
		if(overlay.name == "orbital_strike")
			cut_overlay(overlay)

/mob/living/basic/megafauna/proc/hoverboard_deactivation(source, target)
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
