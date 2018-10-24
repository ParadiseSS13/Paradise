/datum/surgery/embedded_removal
	name = "Removal of Embedded Objects"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/remove_object,/datum/surgery_step/generic/cauterize)
	possible_locs = list("head", "chest", "l_arm", "l_hand", "r_arm", "r_hand","r_leg", "r_foot", "l_leg", "l_foot", "groin")

/datum/surgery/embedded_removal/synth
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/remove_object,/datum/surgery_step/robotics/external/close_hatch)
	requires_organic_bodypart = 0

/datum/surgery/embedded_removal/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(user.zone_sel.selecting)
	if(!affected)
		return 0
	if(affected.is_robotic())
		return 0
	return 1

/datum/surgery/embedded_removal/synth/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(user.zone_sel.selecting)
	if(!affected)
		return 0
	if(!affected.is_robotic())
		return 0

	return 1

/datum/surgery_step/remove_object
	name = "Remove Embedded Objects"
	time = 32
	accept_hand = 1
	var/obj/item/organ/external/L = null


/datum/surgery_step/remove_object/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.organ_ref
	if(L)
		user.visible_message("[user] looks for objects embedded in [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class='notice'>You look for objects embedded in [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")


/datum/surgery_step/remove_object/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/objects = 0
			for(var/obj/item/I in L.embedded_objects)
				objects++
				I.forceMove(get_turf(H))
				L.embedded_objects -= I
			if(!H.has_embedded_objects())
				H.clear_alert("embeddedobject")

			if(objects > 0)
				user.visible_message("[user] sucessfully removes [objects] objects from [H]'s [L]!", "<span class='notice'>You successfully remove [objects] objects from [H]'s [L.name].</span>")
			else
				to_chat(user, "<span class='warning'>You find no objects embedded in [H]'s [L]!</span>")

	else
		to_chat(user, "<span class='warning'>You can't find [target]'s [parse_zone(user.zone_sel.selecting)], let alone any objects embedded in it!</span>")

	return 1