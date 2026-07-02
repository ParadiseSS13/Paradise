/datum/action/cooldown/flock/nest
	name = "Lay Egg"
	button_icon_state = "spawn_egg"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/flock/nest/is_valid_target(atom/cast_on)
	var/mob/living/basic/flock/drone/bird = owner
	var/turf/simulated/floor/flock/flockfloor = get_turf(cast_on)
	if(!istype(flockfloor) || flockfloor.is_blocked_turf(source_atom = owner))
		to_chat(owner, SPAN_WARNING("The egg must be placed on an open flock tile."))
		return FALSE

	if(!bird.flock)
		to_chat(owner, SPAN_WARNING("Our prime directives prohibit us from synthesizing an egg."))
		return FALSE

	if(!bird.substrate.has_points(bird.flock.current_egg_cost))
		to_chat(owner, SPAN_WARNING("Error: Not enough resources. (We need [bird.flock.current_egg_cost])"))
		return FALSE

	if(HAS_TRAIT(bird, TRAIT_FLOCKPHASE))
		to_chat(owner, SPAN_WARNING("We can not synthesize eggs while flockrunning."))
		return FALSE

	return TRUE

/datum/action/cooldown/flock/nest/Activate(atom/target)
	. = ..()
	var/mob/living/basic/flock/drone/bird = owner
	if(!bird.substrate.has_points(bird.flock?.current_egg_cost || FLOCK_SUBSTRATE_COST_LAY_EGG))
		return FALSE
	var/turf/simulated/floor/flock/flockfloor = get_turf(target)
	bird.stop_flockphase(TRUE)

	to_chat(bird, SPAN_NOTICE("Our internal fabricators spring into action, we must hold still."))

	if(!do_after_once(bird, 8 SECONDS, needhand = FALSE, target = bird.loc, interaction_key = "flock_lay_egg"))
		return FALSE

	bird.substrate.remove_points(bird.flock.current_egg_cost)
	bird.visible_message(SPAN_NOTICE("[bird] deploys some sort of device."))

	new /obj/structure/flock/egg(flockfloor)
	return TRUE
