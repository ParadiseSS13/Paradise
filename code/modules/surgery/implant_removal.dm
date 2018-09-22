//////////////////////////////////////////////////////////////////
//					IMPLANT REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/implant_removal
	name = "Implant Removal"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin,/datum/surgery_step/extract_implant,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest")

/datum/surgery/implant_removal/synth
	name = "Implant Removal"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/extract_implant,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest")
	requires_organic_bodypart = 0

/datum/surgery/implant_removal/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(user.zone_sel.selecting)
	if(!affected)
		return 0
	if(affected.is_robotic())
		return 0
	return 1

/datum/surgery/implant_removal/synth/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(user.zone_sel.selecting)
	if(!affected)
		return 0
	if(!affected.is_robotic())
		return 0

	return 1

/datum/surgery_step/extract_implant
	name = "extract implant"
	allowed_tools = list(/obj/item/hemostat = 100, /obj/item/crowbar = 65)
	time = 64
	var/obj/item/implant/I = null

/datum/surgery_step/extract_implant/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/implant) in target
	user.visible_message("[user] starts poking around inside [target]'s [affected.name] with \the [tool].", \
	"You start poking around inside [target]'s [affected.name] with \the [tool]." )
	target.custom_pain("The pain in your [affected.name] is living hell!")
	..()

/datum/surgery_step/extract_implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/implant) in target
	if(I && (target_zone == "chest")) //implant removal only works on the chest.
		user.visible_message("<span class='notice'>[user] takes something out of [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'>You take [I] out of [target]'s [affected.name]s with \the [tool].</span>" )

		I.removed(target)

		var/obj/item/implantcase/case

		if(istype(user.get_item_by_slot(slot_l_hand), /obj/item/implantcase))
			case = user.get_item_by_slot(slot_l_hand)
		else if(istype(user.get_item_by_slot(slot_r_hand), /obj/item/implantcase))
			case = user.get_item_by_slot(slot_r_hand)
		else
			case = locate(/obj/item/implantcase) in get_turf(target)

		if(case && !case.imp)
			case.imp = I
			I.forceMove(case)
			case.update_icon()
			user.visible_message("[user] places [I] into [case]!", "<span class='notice'>You place [I] into [case].</span>")
		else
			qdel(I)
	else
		user.visible_message("<span class='notice'> [user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [affected.name].</span>")
	return 1