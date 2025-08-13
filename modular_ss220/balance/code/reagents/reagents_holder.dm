/datum/reagents
	var/list/cycle_used = list()

/datum/reagents/metabolize(mob/living/M)
	for(var/datum/reagent/R as anything in cycle_used)
		if(has_reagent(initial(R.id)))
			continue
		cycle_used[R] -= initial(R.cycle_decay_rate)
		if(cycle_used[R] <= 0)
			cycle_used -= R
	return ..()
