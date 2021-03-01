/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/list/active_on = list()
	var/list/traits = list() // traits
	var/list/mutations = list() // mutation defines. Set these in Initialize. Refactor this nonsense one day
	var/duration = 100 // deciseconds

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets, mob/user = usr)
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
		if(duration < charge_max)
			addtimer(CALLBACK(src, .proc/remove, target), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/genetic/Destroy()
	for(var/V in active_on)
		remove(V)
	return ..()

/obj/effect/proc_holder/spell/targeted/genetic/proc/remove(mob/living/carbon/target)
	active_on -= target
	if(!QDELETED(target))
		for(var/A in mutations)
			target.dna.SetSEState(A, FALSE)
			singlemutcheck(target, A, MUTCHK_FORCED)
		for(var/A in traits)
			REMOVE_TRAIT(target, A, MAGIC_TRAIT)
		target.regenerate_icons()
