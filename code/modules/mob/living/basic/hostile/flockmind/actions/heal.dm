/datum/action/cooldown/flock/flock_heal
	name = "Repair"
	render_button = FALSE
	click_to_activate = TRUE

/datum/action/cooldown/flock/flock_heal/Activate(atom/target)
	var/mob/living/basic/flock/drone/this_bird = owner
	if(!this_bird.substrate.has_points(FLOCK_SUBSTRATE_COST_REPAIR))
		return FALSE

	astype(this_bird, /mob/living/basic/flock/drone)?.stop_flockphase(TRUE)

	if(isflockmob(target))
		var/mob/living/basic/flock/bird = target
		ADD_TRAIT(bird, TRAIT_AI_PAUSED, ref(src))

		if(!do_after(owner, target, 1 SECOND, DO_PUBLIC, interaction_key = "flock_repair"))
			REMOVE_TRAIT(bird, TRAIT_AI_PAUSED, ref(src))
			return FALSE

		REMOVE_TRAIT(bird, TRAIT_AI_PAUSED, ref(src))
		bird.heal_overall_damage(10, 10)
		this_bird.substrate.remove_points(FLOCK_SUBSTRATE_COST_REPAIR)
	..()
	return TRUE
