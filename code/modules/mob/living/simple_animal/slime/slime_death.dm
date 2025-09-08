/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	if(Target)
		Target = null

	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new(loc, colour)
			M.rabid = TRUE
			M.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive()
			regenerate_icons()
			update_appearance(UPDATE_NAME)
			return

	set_stat(DEAD) //Temporarily set to dead for icon updates
	regenerate_icons()
	set_stat(CONSCIOUS)
	if(holding_organ)
		eject_organ()
	underlays.Cut()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)
