// A bunch of empty procs for all the status procs in living/status_procs.dm, because
// I can't be bothered to deal with all the merge conflicts it would cause to
// typecast every mob in the codebase correctly // luckily I am mad enough to

/mob/proc/RestoreEars()
	return

/mob/proc/AdjustEarDamage()
	return

/mob/proc/adjust_bodytemperature(amount, min_temp = 0, max_temp = INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount, min_temp, max_temp)
