//////////////////////////////////////////////////////////////////
//					IMPLANT REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/implant_removal
	name = "Bio-chip Removal"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/extract_bio_chip,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/implant_removal/synth
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/robotics/repair_limb,
		/datum/surgery_step/extract_bio_chip/synth,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE

/datum/surgery_step/extract_bio_chip
	name = "extract bio-chip"
	allowed_tools = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 65)
	preop_sound = 'sound/surgery/hemostat1.ogg'
	time = 6.4 SECONDS
	repeatable = TRUE
	var/obj/item/bio_chip/I = null
	var/max_times_to_check = 5

/datum/surgery_step/extract_bio_chip/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)


	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(times_repeated >= max_times_to_check)
		user.visible_message(
				"<span class='notice'>[user] seems to have had enough and stops checking inside [target].</span>",
				"<span class='notice'>There doesn't seem to be anything inside, you've checked enough times.</span>",
				chat_message_type = MESSAGE_TYPE_COMBAT
		)
		return SURGERY_BEGINSTEP_SKIP

	I = locate(/obj/item/bio_chip) in target
	user.visible_message(
		"[user] starts poking around inside [target]'s [affected.name] with \the [tool].",
		"You start poking around inside [target]'s [affected.name] with \the [tool].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.custom_pain("The pain in your [affected.name] is living hell!")
	return ..()

/datum/surgery_step/extract_bio_chip/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user] grips onto [target]'s [affected.name] by mistake, tearing it!</span>",
		"<span class='warning'>You think you've found something, but you've grabbed onto [target]'s [affected.name] instead, damaging it!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.receive_damage(10)
	return SURGERY_STEP_RETRY

/datum/surgery_step/extract_bio_chip/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/bio_chip) in target
	if(I && prob(80)) //implant removal only works on the chest.
		user.visible_message(
			"<span class='notice'>[user] takes something out of [target]'s [affected.name] with \the [tool].</span>",
			"<span class='notice'>You take \an [I] out of [target]'s [affected.name]s with \the [tool].</span>",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		I.removed(target)

		var/obj/item/bio_chip_case/case

		if(istype(user.get_item_by_slot(ITEM_SLOT_LEFT_HAND), /obj/item/bio_chip_case))
			case = user.get_item_by_slot(ITEM_SLOT_LEFT_HAND)
		else if(istype(user.get_item_by_slot(ITEM_SLOT_RIGHT_HAND), /obj/item/bio_chip_case))
			case = user.get_item_by_slot(ITEM_SLOT_RIGHT_HAND)
		else
			case = locate(/obj/item/bio_chip_case) in get_turf(target)

		if(case && !case.imp)
			case.imp = I
			I.forceMove(case)
			case.update_state()
			user.visible_message("[user] places \the [I] into \the [case]!", "<span class='notice'>You place \the [I] into \the [case].</span>")
		else
			qdel(I)
	else
		user.visible_message(
			"<span class='notice'>[user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out.</span>",
			"<span class='notice'>You could not find anything inside [target]'s [affected.name].</span>",
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/extract_bio_chip/synth
	allowed_tools = list(TOOL_WIRECUTTER = 100, TOOL_HEMOSTAT = 60)

