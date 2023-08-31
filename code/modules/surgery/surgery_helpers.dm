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
	if(target.reagents.has_reagent("happiness")) // fuck yeah
		return 0.81
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

//check if mob is lying down on something we can operate on.
/proc/on_operable_surface(mob/living/carbon/target)
	if(locate(/obj/machinery/optable, target.loc) && IS_HORIZONTAL(target))
		return TRUE
	if(locate(/obj/structure/bed, target.loc) && (IS_HORIZONTAL(target)))
		return TRUE
	if(locate(/obj/structure/table, target.loc) && (IS_HORIZONTAL(target)))
		return TRUE
	return FALSE

// Called when a limb containing this object is placed back on a body
/atom/movable/proc/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	return 0

/// Check to see if a surgical operation proposed on ourselves is valid or not. We are the target of the surgery
/mob/living/proc/can_run_surgery(datum/surgery/surgery, mob/surgeon, obj/item/organ/external/affecting)
	if(!affecting)
		// try to pull it if it isn't passed in (it's a parameter mostly for optimization purposes)
		affecting = get_organ(check_zone(surgeon.zone_selected))

	if(!surgery.possible_locs.Find(surgeon.zone_selected))
		return
	if(affecting)
		if(!surgery.requires_bodypart)
			return
		if((surgery.requires_organic_bodypart && affecting.is_robotic()) || (!surgery.requires_organic_bodypart && !affecting.is_robotic()))
			return
		if(surgery.requires_real_bodypart && !affecting.is_primary_organ())
			return
	else if(surgery.requires_bodypart) //mob with no limb in surgery zone when we need a limb
		return
	if(surgery.lying_required && !IS_HORIZONTAL(src))
		return
	if(!surgery.self_operable && src == surgeon)
		return
	if(!surgery.can_start(surgeon, src))
		return

	return TRUE
