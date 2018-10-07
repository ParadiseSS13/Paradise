/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of genetic traits upon the target."

	var/list/traits = list() //traits
	var/duration = 100 //deciseconds
	/*
		Disabilities
			1st bit - ?
			2nd bit - ?
			3rd bit - ?
			4th bit - ?
			5th bit - ?
			6th bit - ?
	*/

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets,mob/user = usr)
	playMagSound()
	for(var/mob/living/carbon/target in targets)
		if(!target.dna)
			continue
		for(var/A in traits)
			target.add_trait(A, GENETICS_SPELL)
		addtimer(CALLBACK(src, .proc/remove, target), duration)

/obj/effect/proc_holder/spell/targeted/genetic/proc/remove(mob/living/carbon/target)
	if(!QDELETED(target))
		for(var/A in traits)
			target.remove_trait(A, GENETICS_SPELL)