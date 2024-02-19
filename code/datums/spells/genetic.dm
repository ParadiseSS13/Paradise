/datum/spell/genetic
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/list/active_on = list()
	var/list/traits = list() // traits
	var/list/mutations = list() // mutation defines. Set these in Initialize. Refactor this nonsense one day
	var/duration = 10 SECONDS

/datum/spell/genetic/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(!target.dna)
			continue
		for(var/A in mutations)
			target.dna.SetSEState(A, TRUE)
			singlemutcheck(target, A, MUTCHK_FORCED)
		for(var/A in traits)
			ADD_TRAIT(target, A, MAGIC_TRAIT)
		active_on += target
		target.regenerate_icons()
		do_additional_effects(target)
		if(duration < base_cooldown)
			addtimer(CALLBACK(src, PROC_REF(remove), target), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/datum/spell/genetic/proc/do_additional_effects(mob/target)
	return

/datum/spell/genetic/Destroy()
	for(var/V in active_on)
		remove(V)
	return ..()

/datum/spell/genetic/proc/remove(mob/living/carbon/target)
	active_on -= target
	if(!QDELETED(target))
		for(var/A in mutations)
			target.dna.SetSEState(A, FALSE)
			singlemutcheck(target, A, MUTCHK_FORCED)
		for(var/A in traits)
			REMOVE_TRAIT(target, A, MAGIC_TRAIT)
		target.regenerate_icons()
