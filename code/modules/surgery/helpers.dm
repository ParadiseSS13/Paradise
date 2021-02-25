/proc/get_pain_modifier(mob/living/carbon/human/M) //returns modfier to make surgery harder if patient is conscious and feels pain
	if(M.stat) //stat=0 if CONSCIOUS, 1=UNCONSCIOUS and 2=DEAD. Operating on dead people is easy, too. Just sleeping won't work, though.
		return 1
	if(HAS_TRAIT(M, TRAIT_NOPAIN))//if you don't feel pain, you can hold still
		return 1
	if(M.reagents.has_reagent("hydrocodone"))//really good pain killer
		return 0.99
	if(M.reagents.has_reagent("morphine"))//Just as effective as Hydrocodone, but has an addiction chance
		return 0.99
	if(M.drunk >= 80)//really damn drunk
		return 0.95
	if(M.drunk >= 40)//pretty drunk
		return 0.9
	if(M.reagents.has_reagent("sal_acid")) //it's better than nothing, as far as painkillers go.
		return 0.85
	if(M.drunk >= 15)//a little drunk
		return 0.85
	return 0.8 //20% failure chance

/proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/machinery/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/bed, T))
		return 0.7
	else
		return 0.5

// Called when a limb containing this object is placed back on a body
/atom/movable/proc/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	return 0
