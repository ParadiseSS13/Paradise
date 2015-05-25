//Verbs after this point.
/mob/living/carbon/alien/diona/proc/merge()

	set category = "Abilities"
	set name = "Merge with gestalt"
	set desc = "Merge with another diona."

	if(stat == DEAD || paralysis || weakened || stunned || restrained())
		return

	if(istype(src.loc,/mob/living/carbon))
		src.verbs -= /mob/living/carbon/alien/diona/proc/merge
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))

		if(!(src.Adjacent(C)) || !(C.client)) continue

		if(istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/D = C
			if(D.species && D.species.name == "Diona")
				choices += C

	var/mob/living/M = input(src,"Who do you wish to merge with?") in null|choices

	if(!M)
		src << "There is nothing nearby to merge with."
	else if(!do_merge(M))
		src << "You fail to merge with \the [M]..."

/mob/living/carbon/alien/diona/proc/do_merge(var/mob/living/carbon/human/H)
	if(!istype(H) || !src || !(src.Adjacent(H)))
		return 0
	H << "You feel your being twine with that of \the [src] as it merges with your biomass."
	H.status_flags |= PASSEMOTES
	src << "You feel your being twine with that of \the [H] as you merge with its biomass."
	loc = H
	verbs += /mob/living/carbon/alien/diona/proc/split
	verbs -= /mob/living/carbon/alien/diona/proc/merge
	return 1

/mob/living/carbon/alien/diona/proc/split()

	set category = "Abilities"
	set name = "Split from gestalt"
	set desc = "Split away from your gestalt as a lone nymph."

	if(stat == DEAD || paralysis || weakened || stunned || restrained())
		return

	if(!(istype(src.loc,/mob/living/carbon)))
		src.verbs -= /mob/living/carbon/alien/diona/proc/split
		return

	src.loc << "You feel a pang of loss as [src] splits away from your biomass."
	src << "You wiggle out of the depths of [src.loc]'s biomass and plop to the ground."

	var/mob/living/M = src.loc

	src.loc = get_turf(src)
	src.verbs -= /mob/living/carbon/alien/diona/proc/split
	src.verbs += /mob/living/carbon/alien/diona/proc/merge

	if(istype(M))
		for(var/atom/A in M.contents)
			if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/weapon/holder))
				return
	M.status_flags &= ~PASSEMOTES