/turf/simulated/wall/flock
	name = "weird wall"
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

/turf/simulated/wall/flock/atom_break(damage_flag)
	. = ..()
	ScrapeAway()

/turf/simulated/wall/flock/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(!.)
		return
	//playsound here?

/turf/simulated/wall/flock/CanAStarPass(to_dir, datum/can_pass_info/pass_info, leaving)
	. = ..()
	if(.)
		return

	return pass_info.able_to_flockphase

/turf/simulated/wall/flock/CanAllowThrough(atom/movable/mover, border_dir)
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
