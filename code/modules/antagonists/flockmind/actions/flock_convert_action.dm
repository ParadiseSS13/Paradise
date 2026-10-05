/datum/action/cooldown/flock/convert
	name = "Convert"
	click_to_activate = TRUE
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/flock/convert/New(Target)
	. = ..()

/datum/action/cooldown/flock/convert/Destroy()
	return ..()

/datum/action/cooldown/flock/convert/is_valid_target(atom/cast_on)
	var/turf/clicked_atom_turf = get_turf(cast_on)
	if(!clicked_atom_turf)
		return FALSE

	// This breaks pathfinding :(
	// if(!owner.CanReach(clicked_atom_turf))
	// 	return FALSE

	// So instead:
	if(get_dist(owner, clicked_atom_turf) > 1)
		return FALSE

	if(!clicked_atom_turf.can_flock_convert())
		return FALSE

	return TRUE

/datum/action/cooldown/flock/convert/Activate(atom/target)
	. = ..()
	playsound(owner, 'sound/goonstation/flockmind/flockdrone_convert.ogg', 30, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

	var/turf/clicked_atom_turf = get_turf(target)

	if(isfloorturf(clicked_atom_turf) || iswallturf(clicked_atom_turf))
		return convert_turf(clicked_atom_turf)

	return FALSE

/datum/action/cooldown/flock/convert/proc/convert_turf(turf/T)

	if(!is_valid_target(T))
		return FALSE

	var/mob/living/basic/flock/bird = owner

	var/obj/effect/temp_visual/flock_effect

	if(iswallturf(T))
		flock_effect = new /obj/effect/temp_visual/flock/wall_convert(T)
	else
		flock_effect = new /obj/effect/temp_visual/flock/floor_convert(T)

	owner.face_atom(T)

	bird.flock?.reserve_turf(bird, T)
	if(!do_after(owner, 4.5 SECONDS, target = T, interaction_key = "flock_convert"))
		qdel(flock_effect)
		bird.flock?.free_turf(bird)
		return FALSE

	bird.flock?.free_turf(bird)
	qdel(flock_effect)

	bird.flock?.claim_turf(T)
	return TRUE
