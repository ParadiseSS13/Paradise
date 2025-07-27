/datum/surgery/organ_extraction
	name = "Experimental Dissection"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/internal/extract_organ,
		/datum/surgery_step/internal/gland_insert,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = user
	// You must either: Be of the abductor species, or contain an abductor implant
	if(!isabductor(H) && !(locate(/obj/item/bio_chip/abductor) in H))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_NO_BONES))
		return FALSE

	return TRUE

/datum/surgery/organ_extraction_boneless
	name = "Experimental Dissection"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/internal/extract_organ,
		/datum/surgery_step/internal/gland_insert,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/organ_extraction_boneless/can_start(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = user

	if(!isabductor(H) && !(locate(/obj/item/bio_chip/abductor) in H))
		return FALSE

	if(!HAS_TRAIT(target, TRAIT_NO_BONES))
		return FALSE

	return TRUE

/datum/surgery_step/internal/extract_organ
	name = "remove heart"
	accept_hand = 1
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	time = 32
	var/obj/item/organ/internal/IC = null

/datum/surgery_step/internal/extract_organ/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/I in target.internal_organs)
		// Allows for multiple subtypes of heart. Doesn't use the organ datum so that slimes dont get their brains pulled out of their head
		if(istype(I, /obj/item/organ/internal/heart))
			IC = I
			break
	user.visible_message("[user] starts to remove [target]'s organs.", "<span class='notice'>You start to remove [target]'s organs...</span>")
	..()

/datum/surgery_step/internal/extract_organ/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/AB = target
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		user.put_in_hands(IC)
		IC.remove(target, special = 1)
		return SURGERY_STEP_CONTINUE
	if(NO_INTORGANS in AB.dna.species.species_traits)
		user.visible_message("[user] prepares [target]'s [target_zone] for further dissection!", "<span class='notice'>You prepare [target]'s [target_zone] for further dissection.</span>")
		return SURGERY_STEP_CONTINUE
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/extract_organ/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to extract anything!</span>", "<span class='warning'>Your hand slips, failing to extract anything!</span>")
	return SURGERY_STEP_RETRY

/datum/surgery_step/internal/gland_insert
	name = "insert gland"
	allowed_tools = list(/obj/item/organ/internal/heart/gland = 100)
	preop_sound = 'sound/surgery/organ2.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	time = 32

/datum/surgery_step/internal/gland_insert/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts to insert [tool] into [target].", "<span class ='notice'>You start to insert [tool] into [target]...</span>")
	..()

/datum/surgery_step/internal/gland_insert/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] inserts [tool] into [target].", "<span class ='notice'>You insert [tool] into [target].</span>")
	user.drop_item()
	var/obj/item/organ/internal/heart/gland/gland = tool
	gland.insert(target, 2)
	affected.mend_fracture() // Look, any sufficiently advanced technology is indistinguishable from magic.
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/gland_insert/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to insert the gland!</span>", "<span class='warning'>Your hand slips, failing to insert the gland!</span>")
	return SURGERY_STEP_RETRY

//IPC Gland Surgery//

/datum/surgery/organ_extraction/synth
	name = "Experimental Robotic Dissection"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/internal/extract_organ/synth,
		/datum/surgery_step/internal/gland_insert,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_organic_bodypart = FALSE

/datum/surgery_step/internal/extract_organ/synth
	name = "remove cell"
