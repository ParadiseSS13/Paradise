/datum/action/cooldown/flock/deconstruct
	name = "Deconstruct"
	click_to_activate = TRUE
	check_flags = AB_CHECK_CONSCIOUS
	render_button = FALSE

/datum/action/cooldown/flock/deconstruct/is_valid_target(atom/cast_on)
	var/turf/clicked_atom_turf = get_turf(cast_on)
	if(!clicked_atom_turf)
		return FALSE

	// This breaks pathfinding :(
	// if(!clicked_atom_turf.IsReachableBy(owner))
	// 	return FALSE

	// So instead:
	if(get_dist(owner, clicked_atom_turf) > 1)
		return FALSE

	if(ismob(cast_on) || !HAS_TRAIT(cast_on, TRAIT_FLOCK_THING) || HAS_TRAIT(cast_on, TRAIT_FLOCK_NODECON))
		return FALSE

	return TRUE

/datum/action/cooldown/flock/deconstruct/Activate(atom/target)
	. = ..()
	var/mob/living/basic/flock/bird = owner
	astype(bird, /mob/living/basic/flock/drone)?.stop_flockphase(TRUE)
	bird.face_atom(target)

	bird.visible_message(span_notice("[bird] begins to deconstruct [target]."), blind_message = span_hear("You hear an otherwordly whirring."))
	if(!do_after(bird, 6 SECONDS, target = target, interaction_key = "flock_deconstruct"))
		return FALSE

	if(!is_valid_target(target))
		return FALSE

	// Structures
	if(isobj(target))
		var/obj/obj_target = target
		obj_target.deconstruct(TRUE)
		return TRUE

	else if(isflockturf(target))
		var/turf/turf = target
		turf.ChangeTurf(/turf/simulated/floor/flock, flags = CHANGETURF_INHERIT_AIR)
	else
		CRASH("Tried to flock deconstruct incompatible object of type: [target.type]")
	return TRUE
