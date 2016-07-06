/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/sdisabilities = 0 //bits
	var/list/mutations = list() //mutation strings
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

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets)

	for(var/mob/living/target in targets)
		for(var/x in mutations)
			target.mutations.Add(x)
		/*	if(x == HULK && ishuman(target))
				target:hulk_time=world.time + duration */
		target.sdisabilities |= sdisabilities
		target.update_mutations()	//update target's mutation overlays
		var/mob/living/carbon/human/H = target
		if(ishuman(target))
			H.update_body()
		spawn(duration)
			target.mutations.Remove(mutations)
			target.sdisabilities &= ~sdisabilities
			target.update_mutations()
			if(ishuman(target))
				H.update_body()

	return