/proc/attempt_initiate_surgery(obj/item/I, mob/living/target, mob/user, override)
	if(!istype(target))
		return FALSE
	var/mob/living/carbon/human/H
	var/obj/item/organ/external/affecting
	var/selected_zone = user.zone_selected
	var/list/cautery_tools = list(
							/obj/item/scalpel/laser = 100, \
							/obj/item/cautery = 100,			\
							/obj/item/clothing/mask/cigarette = 90,	\
							/obj/item/lighter = 60,			\
							/obj/item/weldingtool = 30
							)

	if(target == user)
		return // no self surgery

	if(target.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='notice'>You realise that a ghost probably doesn't have any useful organs.</span>")
		return //no cult ghost surgery please

	if(istype(target, /mob/living/carbon/human))
		H = target
		affecting = H.get_organ(check_zone(selected_zone))

	if(!can_operate(target) && !isslime(target))	//if they're prone or a slime
		return FALSE

	var/datum/surgery/current_surgery
	for(var/datum/surgery/S in target.surgeries)
		if(S.location == selected_zone)
			current_surgery = S

	if(!current_surgery)
		var/list/all_surgeries = GLOB.surgeries_list.Copy()
		var/list/available_surgeries = list()

		if(override)
			var/datum/surgery/S
			if(istype(I,/obj/item/robot_parts))
				S = available_surgeries["Apply Robotic Prosthetic"]
			if(istype(I,/obj/item/organ/external))
				var/obj/item/organ/external/E = I
				if(E.is_robotic())
					S = available_surgeries["Synthetic Limb Reattachment"]
			if(S)
				var/datum/surgery/procedure = new S.type
				if(procedure)
					procedure.location = selected_zone
					target.surgeries += procedure
					procedure.organ_ref = affecting
					procedure.next_step(user, target)

		else
			var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in available_surgeries
			if(P && user && user.Adjacent(target) && (I in user))
				var/datum/surgery/S = available_surgeries[P]
				var/datum/surgery/procedure = new S.type
				if(procedure)
					procedure.location = selected_zone
					target.surgeries += procedure
					procedure.organ_ref = affecting
					user.visible_message("[user] prepares to operate on [target]'s [parse_zone(selected_zone)].", \
					"<span class='notice'>You prepare to operate on [target]'s [parse_zone(selected_zone)].</span>")

	else if(!current_surgery.step_in_progress  && ishuman(target)) //early surgery cautery
		var/datum/surgery_step/generic/cauterize/C = new
		if(current_surgery.status == 1)
			target.surgeries -= current_surgery
			to_chat(user, "You stop the surgery.")
			qdel(current_surgery)

		else if(current_surgery.can_cancel)
			var/cautery_chance = 0
			var/obj/item/cautery_tool = null

			if(isrobot(user))
				if(istype(I, /obj/item/scalpel/laser))
					cautery_chance = 100
					cautery_tool = I

			else
				for(var/T in cautery_tools)
					if(istype(user.get_inactive_hand(), T))
						cautery_chance = cautery_tools[T]
						cautery_tool = user.get_inactive_hand()

			if(cautery_chance)
				C.begin_step(user, H, selected_zone, cautery_tool, current_surgery)
				if(do_after(user, C.time * cautery_tool.toolspeed, target = target))
					if(!isrobot(user))
						cautery_chance *= get_location_modifier(H)
						cautery_chance *= get_pain_modifier(H)
					if(prob(cautery_chance))
						C.end_step(user, H, selected_zone, cautery_tool, current_surgery)
						target.surgeries -= current_surgery
						qdel(current_surgery)
					else
						C.fail_step(user, H, selected_zone, cautery_tool, current_surgery)

			else if(!isrobot(user))
				to_chat(user, "<span class='notice'>You need to hold a cautery or equivalent in your inactive hand to stop the surgery in progress.</span>")

	return TRUE

/**
 * Get the surgeries that can be performed on a target, based on the currently targeted zone and organ.
 */
// /proc/get_available_surgeries(mob/user, mob/living/target, obj/item/I, obj/item/organ/external/affecting)
// 	var/list/all_surgeries = GLOB.surgeries_list.Copy()
// 	var/list/available_surgeries = list()
// 	var/selected_zone = user.zone_selected

// 	for(var/datum/surgery/S in all_surgeries)
// 		// performing it in the right spot
// 		if(!S.possible_locs.Find(selected_zone))
// 			continue
// 		if(affecting && !S.is_organ_compatible(affecting))
// 			continue

// 		if(!S.can_start(user, target))
// 			continue

// 		for(var/path in S.allowed_mob)
// 			if(istype(target, path))
// 				// If there are multiple surgeries with the same name,
// 				// prepare to cry
// 				available_surgeries[S.name] = S
// 				break

// 	return available_surgeries

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
