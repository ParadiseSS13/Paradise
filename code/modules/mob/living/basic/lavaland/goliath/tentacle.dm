/obj/effect/temp_visual/goliath_tentacle
	name = "goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	var/mob/living/spawner

/obj/effect/temp_visual/goliath_tentacle/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	for(var/obj/effect/temp_visual/goliath_tentacle/T in loc)
		if(T != src)
			return INITIALIZE_HINT_QDEL
	if(!QDELETED(new_spawner))
		spawner = new_spawner
	if(ismineralturf(loc))
		var/turf/simulated/mineral/M = loc
		M.gets_drilled()
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(tripanim)), 7, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/original/Initialize(mapload, new_spawner)
	. = ..()
	var/list/directions = GLOB.cardinal.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			new /obj/effect/temp_visual/goliath_tentacle(T, spawner)

/obj/effect/temp_visual/goliath_tentacle/proc/tripanim()
	icon_state = "Goliath_tentacle_wiggle"
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(trip)), 3, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message("<span class='danger'>[src] grabs hold of [L]!</span>")
		L.Stun(10 SECONDS)
		L.adjustBruteLoss(rand(10,15))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), 10, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/retract()
	icon_state = "Goliath_tentacle_retract"
	deltimer(timerid)
	timerid = QDEL_IN(src, 7)

/// Goliath tentacle stun with special removal conditions
/datum/status_effect/incapacitating/stun/goliath_tentacled
	id = "goliath_tentacled"
	duration = 10 SECONDS
	/// The tentacle that is tenderly holding us close
	var/obj/effect/temp_visual/goliath_tentacle/tentacle

/datum/status_effect/incapacitating/stun/goliath_tentacled/on_creation(mob/living/new_owner, set_duration, obj/effect/temp_visual/goliath_tentacle/tentacle)
	. = ..()
	if(!.)
		return
	src.tentacle = tentacle

/datum/status_effect/incapacitating/stun/goliath_tentacled/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(on_helped))
	RegisterSignals(owner, SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE), PROC_REF(release))
	RegisterSignals(tentacle, list(COMSIG_PARENT_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING), PROC_REF(on_tentacle_left))

/datum/status_effect/incapacitating/stun/goliath_tentacled/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_CARBON_PRE_MISC_HELP, SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE)))
	if(isnull(tentacle))
		return
	UnregisterSignal(tentacle, list(COMSIG_PARENT_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING))
	tentacle.retract()
	tentacle = null

/// Some kind soul has rescued us
/datum/status_effect/incapacitating/stun/goliath_tentacled/proc/on_helped(mob/source, mob/helping)
	SIGNAL_HANDLER // COMSIG_CARBON_PRE_MISC_HELP
	release()
	source.visible_message("<span class='notice'>[helping] rips [source] from the tentacle's grasp!</span>")
	return COMPONENT_BLOCK_MISC_HELP

/// Something happened to make the tentacle let go
/datum/status_effect/incapacitating/stun/goliath_tentacled/proc/release()
	SIGNAL_HANDLER // SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE)
	owner.remove_status_effect(/datum/status_effect/incapacitating/stun/goliath_tentacled)

/// Something happened to our associated tentacle
/datum/status_effect/incapacitating/stun/goliath_tentacled/proc/on_tentacle_left()
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING + COMSIG_GOLIATH_TENTACLE_RETRACTING
	UnregisterSignal(tentacle, list(COMSIG_PARENT_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING)) // No endless loops for us please
	tentacle = null
	release()
