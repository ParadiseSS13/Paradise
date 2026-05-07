/datum/action/cooldown/flock/cage_mob
	name = "Cage"
	cooldown_time = 5 SECONDS
	click_to_activate = TRUE

	var/obj/effect/abstract/flock_conversion/turf_effect

/datum/action/cooldown/flock/cage_mob/New(Target)
	. = ..()
	turf_effect = new(null)

/datum/action/cooldown/flock/cage_mob/Destroy()
	QDEL_NULL(turf_effect)
	return ..()

/datum/action/cooldown/flock/cage_mob/is_valid_target(atom/cast_on)
	return isliving(cast_on) && !isflockmob(cast_on) && isturf(cast_on.loc)

/datum/action/cooldown/flock/cage_mob/Activate(atom/target)
	if(DOING_INTERACTION(owner, "flock_cage"))
		return FALSE

	var/mob/living/basic/flock/drone/bird = owner
	bird.stop_flockphase(TRUE)
	var/turf/T = get_turf(target)

	owner.visible_message(
		SPAN_NOTICE("<b>[owner]</b> begins forming a cuboid structure around <b>[target]</b>."),
		blind_message = SPAN_HEAR("You hear a strange synthetic whirring."),
	)

	T.vis_contents += turf_effect
	if(iswallturf(T))
		turf_effect.icon_state = "spawn-wall-loop"
		flick("spawn-wall", turf_effect)

	log_attack(owner, target, "attempted to cage")

	. = TRUE
	playsound(owner, 'goon/sounds/flockmind/flockdrone_build.ogg', 30, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	if(!do_after(owner, 4.5 SECONDS,  target = target, interaction_key = "flock_cage"))
		. = FALSE

	T.vis_contents -= turf_effect
	if(!.)
		return

	log_attack(owner, target, "caged")

	playsound(owner, 'goon/sounds/flockmind/flockdrone_build_complete.ogg', 70, TRUE)
	var/obj/structure/flock/cage/cage = new(T, bird.flock)
	cage.cage_mob(target)
	..()
