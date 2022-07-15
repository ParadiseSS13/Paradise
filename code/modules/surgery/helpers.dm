/proc/get_pain_modifier(mob/living/carbon/human/target) //returns modfier to make surgery harder if patient is conscious and feels pain
	if(target.stat == DEAD) // Operating on dead people is easy
		return 1
	var/datum/status_effect/incapacitating/sleeping/S = target.IsSleeping()
	if(target.stat == UNCONSCIOUS && !(S?.voluntary))
		// Either unconscious due to something other than sleep,
		// or "sleeping" due to being hard knocked out (N2O or similar), rather than just napping.
		// Either way, not easily woken up.
		return 1
	if(HAS_TRAIT(target, TRAIT_NOPAIN))//if you don't feel pain, you can hold still
		return 1
	if(target.reagents.has_reagent("hydrocodone"))//really good pain killer
		return 0.99
	if(target.reagents.has_reagent("morphine"))//Just as effective as Hydrocodone, but has an addiction chance
		return 0.99
	var/drunk = target.get_drunkenness()
	if(drunk >= 80)//really damn drunk
		return 0.95
	if(drunk >= 40)//pretty drunk
		return 0.9
	if(target.reagents.has_reagent("sal_acid")) //it's better than nothing, as far as painkillers go.
		return 0.85
	if(drunk >= 15)//a little drunk
		return 0.85
	return 0.8 //20% failure chance

/proc/get_location_modifier(mob/target)
	var/turf/T = get_turf(target)
	if(locate(/obj/machinery/optable, T))
		return 1
	if(locate(/obj/structure/bed/roller/holo, T))
		return 0.9
	if(locate(/obj/structure/table, T) || locate(/obj/structure/bed/roller, T))
		return 0.8
	if(locate(/obj/structure/bed, T))
		return 0.7
	return 0.5

//check if mob is lying down on something we can operate him on.
// TODO this isn't referenced anymore, are we still able to perform surgery like this?
/proc/can_operate(mob/living/carbon/target)
	if(locate(/obj/machinery/optable, target.loc) && IS_HORIZONTAL(target))
		return TRUE
	if(locate(/obj/structure/bed, target.loc) && (IS_HORIZONTAL(target) || target.IsWeakened() || target.IsStunned() || target.IsParalyzed() || target.IsSleeping() || target.stat))
		return TRUE
	if(locate(/obj/structure/table, target.loc) && (IS_HORIZONTAL(target) || target.IsWeakened() || target.IsStunned() || target.IsParalyzed() || target.IsSleeping()  || target.stat))
		return TRUE
	return FALSE

// Called when a limb containing this object is placed back on a body
/atom/movable/proc/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	return 0
