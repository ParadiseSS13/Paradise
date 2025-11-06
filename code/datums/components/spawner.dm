/datum/component/spawner
	var/mob_types = list(/mob/living/basic/carp)
	var/spawn_time = 300 //30 seconds default
	var/list/spawned_mobs = list()
	var/spawn_delay = 0
	var/max_mobs = 5
	var/spawn_text = "emerges from"
	var/list/faction = list("mining")

	COOLDOWN_DECLARE(last_rally)


/datum/component/spawner/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_faction)
		faction=_faction
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(stop_spawning))
	RegisterSignal(parent, COMSIG_SPAWNER_SET_TARGET, PROC_REF(rally_spawned_mobs))
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()


/datum/component/spawner/proc/stop_spawning(force)
	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/simple_animal/L in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	for(var/mob/living/basic/L in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	spawned_mobs = null

/datum/component/spawner/proc/try_spawn_mob()
	var/atom/P = parent
	if(length(spawned_mobs) >= max_mobs)
		return
	if(spawn_delay > world.time)
		return
	spawn_delay = world.time + spawn_time
	var/chosen_mob_type = pick(mob_types)
	var/mob/living/simple_animal/L = new chosen_mob_type(P.loc)
	L.admin_spawned = P.admin_spawned
	spawned_mobs += L
	L.nest = src
	L.faction = src.faction
	ADD_TRAIT(L, TRAIT_FROM_TENDRIL, INNATE_TRAIT)
	P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")
	P.on_mob_spawn(L)
	return L

/datum/component/spawner/proc/rally_spawned_mobs(parent, mob/living/target)
	SIGNAL_HANDLER // COMSIG_SPAWNER_SET_TARGET

	if(!(COOLDOWN_FINISHED(src, last_rally) && length(spawned_mobs)))
		return

	// start the cooldown first, because a rallied mob might fire on
	// ourselves while this is happening, causing confusion
	COOLDOWN_START(src, last_rally, 30 SECONDS)
	for(var/mob/living/rallied as anything in spawned_mobs)
		if(istype(rallied, /mob/living/basic))
			var/mob/living/basic/basic = rallied
			basic.ai_controller.cancel_actions()
			basic.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
		if(istype(rallied, /mob/living/simple_animal/hostile))
			var/mob/living/simple_animal/hostile/simple = rallied
			INVOKE_ASYNC(simple, TYPE_PROC_REF(/mob/living/simple_animal/hostile, aggro_fast), target)

/datum/component/spawner/demon_incursion_portal

/datum/component/spawner/demon_incursion_portal/try_spawn_mob()
	var/atom/result = ..()
	if(result && istype(result.ai_controller))
		result.ai_controller.set_blackboard_key(BB_INCURSION_HOME_PORTAL, parent)

	return result

/datum/component/spawner/demon_incursion_portal/rally_spawned_mobs(parent, mob/living/target)
	if(!(COOLDOWN_FINISHED(src, last_rally)))
		return

	COOLDOWN_START(src, last_rally, 30 SECONDS)
	for(var/mob/living/basic/rallied as anything in spawned_mobs)
		rallied.ai_controller.cancel_actions()
		rallied.ai_controller.queue_behavior(/datum/ai_behavior/return_home/incursion_portal, BB_INCURSION_HOME_PORTAL)
