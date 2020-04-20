/mob/living/simple_animal/hostile/megafauna
	name = "megafauna"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 400
	light_range = 3
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")
	flying = TRUE
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
	mouse_opacity = MOUSE_OPACITY_OPAQUE // Easier to click on in melee, they're giant targets anyway
	var/list/crusher_loot
	var/medal_type
	var/score_type = BOSS_SCORE
	var/elimination = 0
	var/anger_modifier = 0
	var/obj/item/gps/internal_gps
	var/internal_type
	var/recovery_time = 0
	var/true_spawn = TRUE // if this is a megafauna that should grant achievements, or have a gps signal
	var/nest_range = 10
	var/chosen_attack = 1 // chosen attack num
	var/list/attack_action_types = list()

/mob/living/simple_animal/hostile/megafauna/Initialize(mapload)
	. = ..()
	if(internal_type && true_spawn)
		internal = new internal_type(src)
	apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	for(var/action_type in attack_action_types)
		var/datum/action/innate/megafauna_attack/attack_action = new action_type()
		attack_action.Grant(src)

/mob/living/simple_animal/hostile/megafauna/Destroy()
	QDEL_NULL(internal_gps)
	return ..()

/mob/living/simple_animal/hostile/megafauna/Moved()
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
	// this happens before the parent call because `del_on_death` may be set
	if(can_die() && !admin_spawned)
		var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(C && crusher_loot && C.total_damage >= maxHealth * 0.6)
			spawn_crusher_loot()
		if(!elimination)	//used so the achievment only occurs for the last legion to die.
			grant_achievement(medal_type,score_type)
			feedback_set_details("megafauna_kills","[initial(name)]")
	return ..()

/mob/living/simple_animal/hostile/megafauna/proc/spawn_crusher_loot()
	loot = crusher_loot

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	if(recovery_time >= world.time)
		return
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()
		else
			devour(L)

/mob/living/simple_animal/hostile/megafauna/onShuttleMove()
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] \
		([ADMIN_FLW(src,"FLW")]) \
		moved via shuttle from ([oldloc.x], [oldloc.y], [oldloc.z]) to \
		([newloc.x], [newloc.y], [newloc.z])")

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
	recovery_time = world.time + buffer_time
	ranged_cooldown = world.time + buffer_time

/mob/living/simple_animal/hostile/megafauna/proc/grant_achievement(medaltype, scoretype, crusher_kill)
	if(!medal_type || admin_spawned || !SSmedals.hub_enabled) //Don't award medals if the medal type isn't set
		return FALSE

	for(var/mob/living/L in view(7,src))
		if(L.stat || !L.client)
			continue
		var/client/C = L.client
		SSmedals.UnlockMedal("Boss [BOSS_KILL_MEDAL]", C)
		SSmedals.UnlockMedal("[medaltype] [BOSS_KILL_MEDAL]", C)
		SSmedals.SetScore(BOSS_SCORE, C, 1)
		SSmedals.SetScore(score_type, C, 1)
	return TRUE

/datum/action/innate/megafauna_attack
	name = "Megafauna Attack"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = ""
	var/mob/living/simple_animal/hostile/megafauna/M
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/megafauna_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/megafauna))
		M = L
		return ..()
	return FALSE

/datum/action/innate/megafauna_attack/Activate()
	M.chosen_attack = chosen_attack_num
	to_chat(M, chosen_message)
