/datum/seed
	var/list/currently_querying // Used to avoid asking the same ghost repeatedly.

// The following procs are used to grab players for mobs produced by a seed (mostly for dionaea).
/datum/seed/proc/handle_living_product(var/mob/living/host)