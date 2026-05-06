// Shows an image to flock mobs.
/datum/atom_hud/alternate_appearance/basic/flock

/datum/atom_hud/alternate_appearance/basic/flock/mobShouldSee(mob/M)
	return isflockmob(M)


// Shows an image to nnon-ghost flockmobs.
/datum/atom_hud/alternate_appearance/basic/flock_simplemob

/datum/atom_hud/alternate_appearance/basic/flock_simplemob/mobShouldSee(mob/M)
	return istype(M, /mob/living/simple_animal/flock)

// Shows an image to non-observer non-flock mobs.
/datum/atom_hud/alternate_appearance/basic/not_flock

/datum/atom_hud/alternate_appearance/basic/not_flock/mobShouldSee(mob/M)
	return !(isflockmob(M) || isobserver(M))
