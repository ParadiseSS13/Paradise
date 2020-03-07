/proc/get_or_initiate_surgery(mob/living/M, mob/living/user)
	if(istype(M))
		var/selected_zone = user.zone_selected

		if(can_operate(M))
			for(var/datum/surgery/S in M.surgeries)
				if(S.location == selected_zone)
					return S

			var/datum/surgery/new_surgery = new()
			new_surgery.location = selected_zone
			M.surgeries += new_surgery

			return new_surgery


/proc/get_pain_modifier(mob/living/carbon/human/M) //returns modfier to make surgery harder if patient is conscious and feels pain
	if(M.stat) //stat=0 if CONSCIOUS, 1=UNCONSCIOUS and 2=DEAD. Operating on dead people is easy, too. Just sleeping won't work, though.
		return 1
	if(NO_PAIN in M.dna.species.species_traits)//if you don't feel pain, you can hold still
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

//check if mob is lying down on something we can operate him on.
/proc/can_operate(mob/living/carbon/M)
	if(locate(/obj/machinery/optable, M.loc) && (M.lying || M.resting))
		return TRUE
	if(locate(/obj/structure/bed, M.loc) && (M.buckled || M.lying || M.IsWeakened() || M.stunned || M.paralysis || M.sleeping || M.stat))
		return TRUE
	if(locate(/obj/structure/table, M.loc) && (M.lying || M.IsWeakened() || M.stunned || M.paralysis || M.sleeping || M.stat))
		return TRUE
	return FALSE

// Called when a limb containing this object is placed back on a body
/atom/movable/proc/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	return 0
