/datum/component/spawner
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
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
	spawned_mobs = null

/datum/component/spawner/proc/try_spawn_mob()
	var/atom/P = parent
	if(length(spawned_mobs) >= max_mobs)
		return 0
	if(spawn_delay > world.time)
		return 0
	spawn_delay = world.time + spawn_time
	var/chosen_mob_type = pick(mob_types)
	var/mob/living/simple_animal/L = new chosen_mob_type(P.loc)
	L.admin_spawned = P.admin_spawned
	spawned_mobs += L
	L.nest = src
	L.faction = src.faction
	P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")
	P.on_mob_spawn(L)

/datum/component/spawner/proc/rally_spawned_mobs(parent, mob/living/target)
	SIGNAL_HANDLER // COMSIG_SPAWNER_SET_TARGET

	if(!(COOLDOWN_FINISHED(src, last_rally) && length(spawned_mobs)))
		return

	// start the cooldown first, because a rallied mob might fire on
	// ourselves while this is happening, causing confusion
	COOLDOWN_START(src, last_rally, 30 SECONDS)
	for(var/mob/living/simple_animal/hostile/rallied as anything in spawned_mobs)
		INVOKE_ASYNC(rallied, TYPE_PROC_REF(/mob/living/simple_animal/hostile, aggro_fast), target)
