/datum/flock_unlockable
	// auto populated field
	var/name
	// auto populated field
	var/purchase_cost

	var/obj/structure/flock/structure_type

	var/unlocked = FALSE

/datum/flock_unlockable/New()
	name = initial(structure_type.flock_id)
	purchase_cost = initial(structure_type.active_bandwidth_cost)

/datum/flock_unlockable/proc/refresh_lock_status(datum/flock/flock, total_compute, available_compute)
	if(is_unlockable(flock, total_compute, available_compute))
		if(!unlocked)
			unlock(flock)

	else if(unlocked)
		lock(flock)

/datum/flock_unlockable/proc/is_unlockable(datum/flock/flock, total_compute, available_compute)
	return TRUE

/datum/flock_unlockable/proc/unlock(datum/flock/flock)
	unlocked = TRUE
	flock_talk(null, "New structure devised: [name]", flock)

/datum/flock_unlockable/proc/lock(datum/flock/flock)
	unlocked = FALSE
	flock_talk(null, "Alert, structure tealprint disabled: [name]", flock)

/datum/flock_unlockable/sentinel
	structure_type = /obj/structure/flock/sentinel

/datum/flock_unlockable/collector
	structure_type = /obj/structure/flock/collector

/datum/flock_unlockable/interceptor
	structure_type = /obj/structure/flock/interceptor

/datum/flock_unlockable/turret
	structure_type = /obj/structure/flock/gnesis_turret

/datum/flock_unlockable/relay
	structure_type = /obj/structure/flock/relay

/datum/flock_unlockable/relay/is_unlockable(datum/flock/flock, total_compute, available_compute)
	return (flock.total_bandwidth() >= FLOCK_COMPUTE_COST_RELAY) && flock.flock_game_status == NONE
