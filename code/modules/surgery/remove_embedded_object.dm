/datum/surgery/embedded_removal
	name = "Removal of Embedded Objects"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/remove_object,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/embedded_removal/synth
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/remove_object,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE


/datum/surgery/embedded_removal/can_start(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected)
		return FALSE
	if(!length(affected.embedded_objects))
		return FALSE
	return TRUE

/datum/surgery/embedded_removal/synth/can_start(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target))
		return FALSE

	return TRUE

/datum/surgery_step/remove_object
	name = "Remove Embedded Objects"
	time = 3.2 SECONDS
	accept_hand = TRUE
	var/obj/item/organ/external/L = null
	repeatable = TRUE


/datum/surgery_step/remove_object/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.organ_to_manipulate
	if(L)
		user.visible_message("[user] looks for objects embedded in [target]'s [parse_zone(user.zone_selected)].", "<span class='notice'>You look for objects embedded in [target]'s [parse_zone(user.zone_selected)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_selected)].", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")
	return ..()


/datum/surgery_step/remove_object/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		var/mob/living/carbon/human/H = target
		var/objects = 0
		for(var/obj/item/I in L.embedded_objects)
			objects++
			L.remove_embedded_object(I)
			I.forceMove(get_turf(H))
		if(!H.has_embedded_objects())
			H.clear_alert("embeddedobject")

		if(objects > 0)
			user.visible_message(
				"[user] successfully removes [objects] object\s from [H]'s [parse_zone(user.zone_selected)]!",
				"<span class='notice'>You successfully remove [objects] object\s from [H]'s [L.name].</span>",
				chat_message_type = MESSAGE_TYPE_COMBAT
				)
		else
			to_chat(user, "<span class='warning'>You find no objects embedded in [H]'s [parse_zone(user.zone_selected)]!</span>")

	else
		to_chat(user, "<span class='warning'>You can't find [target]'s [parse_zone(user.zone_selected)], let alone any objects embedded in it!</span>")

	return SURGERY_STEP_CONTINUE

// this could use a fail_step...
