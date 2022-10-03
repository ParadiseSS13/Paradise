/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(age_state.age != SLIME_BABY)
			var/mob/living/simple_animal/slime/M = new(loc, colour)
			M.rabid = TRUE
			M.regenerate_icons()

			age_state = new /datum/slime_age/baby
			maxHealth = age_state.health
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive()
			regenerate_icons()
			update_name()
			return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	stat = DEAD //Temporarily set to dead for icon updates
	regenerate_icons()
	stat = CONSCIOUS

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)
