/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(age_state.age != SLIME_BABY)
			if (nutrition >= get_hunger_nutrition())
				force_split(FALSE)
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
