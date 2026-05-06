/datum/action/cooldown/flock/convert
	name = "Convert"
	click_to_activate = TRUE
	check_flags = AB_CHECK_CONSCIOUS
	render_button = FALSE

	var/obj/effect/abstract/flock_conversion/turf_effect

/datum/action/cooldown/flock/convert/New(Target)
	. = ..()
	turf_effect = new(null)

/datum/action/cooldown/flock/convert/Destroy()
	QDEL_NULL(turf_effect)
	return ..()

/datum/action/cooldown/flock/convert/is_valid_target(atom/cast_on)
	var/turf/clicked_atom_turf = get_turf(cast_on)
	if(!clicked_atom_turf)
		return FALSE

	// This breaks pathfinding :(
	// if(!clicked_atom_turf.IsReachableBy(owner))
	// 	return FALSE

	// So instead:
	if(get_dist(owner, clicked_atom_turf) > 1)
		return FALSE

	if(!clicked_atom_turf.can_flock_convert())
		return FALSE

	return TRUE

/datum/action/cooldown/flock/convert/Activate(atom/target)
	. = ..()
	playsound(owner, 'goon/sounds/flockmind/flockdrone_convert.ogg', 30, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

	var/turf/clicked_atom_turf = get_turf(target)
	var/mob/living/basic/flock/bird = owner
	astype(bird, /mob/living/basic/flock/drone)?.stop_flockphase(TRUE)

	if(!bird.substrate.has_points(FLOCK_SUBSTRATE_COST_CONVERT))
		return FALSE

	if(isfloorturf(clicked_atom_turf) || iswallturf(clicked_atom_turf))
		return convert_turf(clicked_atom_turf)

	return FALSE

/datum/action/cooldown/flock/convert/proc/convert_turf(turf/T)
	var/mob/living/basic/flock/bird = owner

	T.add_viscontents(turf_effect)
	if(iswallturf(T))
		turf_effect.icon_state = "spawn-wall-loop"
		flick("spawn-wall", turf_effect)
	else
		turf_effect.icon_state = "spawn-floor-loop"
		flick("spawn-floor", turf_effect)

	owner.face_atom(T)

	bird.flock?.reserve_turf(bird, T)
	if(!do_after(owner, T, 4.5 SECONDS, DO_PUBLIC, interaction_key = "flock_convert"))
		T.remove_viscontents(turf_effect)
		bird.flock?.free_turf(bird)
		return FALSE

	bird.flock?.free_turf(bird)
	T.remove_viscontents(turf_effect)

	if(!is_valid_target(T))
		return FALSE

	if(bird.flock)
		bird.flock.claim_turf(T)
	else
		flock_convert_turf(T, bird.flock)

	bird.substrate.remove_points(FLOCK_SUBSTRATE_COST_CONVERT)
	return TRUE

/obj/effect/abstract/flock_conversion
	icon = 'goon/icons/mob/featherzone.dmi'
	icon_state = "blank"
	layer = ABOVE_NORMAL_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	appearance_flags = parent_type::appearance_flags | RESET_COLOR
	vis_flags = parent_type::vis_flags | VIS_INHERIT_LAYER
