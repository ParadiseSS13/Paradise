/datum/action/cooldown/flock/cage_mob
	name = "Cage"
	cooldown_time = 5 SECONDS
	click_to_activate = TRUE

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

	var/obj/effect/temp_visual/flock_effect
	if(iswallturf(T))
		flock_effect = new /obj/effect/temp_visual/flock/wall_convert(T)

	log_attack(owner, target, "attempted to cage")

	. = TRUE
	playsound(owner, 'sound/goonstation/flockmind/flockdrone_build.ogg', 30, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	if(!do_after(owner, 4.5 SECONDS,  target = target, interaction_key = "flock_cage"))
		. = FALSE

	qdel(flock_effect)
	if(!.)
		return

	log_attack(owner, target, "caged")

	playsound(owner, 'sound/goonstation/flockmind/flockdrone_build_complete.ogg', 70, TRUE)
	var/obj/structure/flock/cage/cage = new(T, bird.flock)
	cage.cage_mob(target)
	..()
