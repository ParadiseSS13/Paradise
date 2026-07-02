/turf/simulated/wall/flock
	name = "cybernetic wall"
	icon = 'icons/goonstation/turf/flock.dmi'
	icon_state = "flock-0"
	base_icon_state = "flock"

	pathing_pass_method = TURF_PATHING_PASS_PROC

	light_color = "#19b299"
	light_power = 0.5
	light_range = 0.6

/turf/simulated/wall/flock/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)

/turf/simulated/wall/flock/Destroy(force)
	REMOVE_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT) // Turfs are persistent refs
	qdel(GetComponent(/datum/component/flock_protection))
	return ..()

/turf/simulated/wall/flock/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(!isflockdrone(mover))
		return

	var/mob/living/basic/flock/drone/bird = mover
	if(HAS_TRAIT(bird, TRAIT_FLOCKPHASE))
		return TRUE

	if(bird.can_flockphase())
		return TRUE

/turf/simulated/wall/flock/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/M = locateUID(pass_info.caller_uid)
	if(!M)
		return ..()
	if(!isflockdrone(M))
		return ..()
	var/mob/living/basic/flock/drone/bird = M
	if(!bird.can_flockphase())
		return ..()
	return TRUE
