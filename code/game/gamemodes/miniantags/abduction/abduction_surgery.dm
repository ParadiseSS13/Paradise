/datum/surgery/organ_extraction
	name = "experimental dissection"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw, /datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/extract_organ, /datum/surgery_step/internal/gland_insert, /datum/surgery_step/generic/cauterize)
	possible_locs = list("chest")

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!ishuman(user))
		return 0
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(target_zone)
		if(!affected)
			return 0
		if(affected.status & ORGAN_ROBOT)
			return 0
	var/mob/living/carbon/human/H = user
	// You must either: Be of the abductor species, or contain an abductor implant
	if((H.get_species() == "Abductor" || (locate(/obj/item/weapon/implant/abductor) in H)))
		return 1
	return 0


/datum/surgery_step/internal/extract_organ
	name = "remove heart"
	accept_hand = 1
	time = 32
	var/obj/item/organ/internal/IC = null
	var/list/organ_types = list(/obj/item/organ/internal/heart)

/datum/surgery_step/internal/extract_organ/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/I in target.internal_organs)
		if(I.type in organ_types)
			IC = I
			break
	user.visible_message("[user] starts to remove [target]'s organs.", "<span class='notice'>You start to remove [target]'s organs...</span>")
	..()

/datum/surgery_step/internal/extract_organ/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/AB = target
	if(NO_INTORGANS in AB.species.species_traits)
		user.visible_message("[user] prepares [target]'s [target_zone] for further dissection!", "<span class='notice'>You prepare [target]'s [target_zone] for further dissection.</span>")
		return 1
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		user.put_in_hands(IC)
		IC.remove(target, special = 1)
		return 1
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")
		return 1

/datum/surgery_step/internal/gland_insert
	name = "insert gland"
	allowed_tools = list(/obj/item/organ/internal/heart/gland = 100)
	time = 32

/datum/surgery_step/internal/gland_insert/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts to insert [tool] into [target].", "<span class ='notice'>You start to insert [tool] into [target]...</span>")
	..()

/datum/surgery_step/internal/gland_insert/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] inserts [tool] into [target].", "<span class ='notice'>You insert [tool] into [target].</span>")
	user.drop_item()
	var/obj/item/organ/internal/heart/gland/gland = tool
	gland.insert(target, 2)
	return 1

//IPC Gland Surgery//

/datum/surgery/organ_extraction/synth
	name = "experimental robotic dissection"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/extract_organ/synth,/datum/surgery_step/internal/gland_insert,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest")
	requires_organic_bodypart = 0

/datum/surgery/organ_extraction/synth/can_start(mob/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!ishuman(user))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(target_zone)
		if(!affected)
			return FALSE
		if(!(affected.status & ORGAN_ROBOT))
			return FALSE
	var/mob/living/carbon/human/H = user
	// You must either: Be of the abductor species, or contain an abductor implant
	if((H.get_species() == "Abductor" || (locate(/obj/item/weapon/implant/abductor) in H)))
		return TRUE
	return FALSE

/datum/surgery_step/internal/extract_organ/synth
	name = "remove cell"
	organ_types = list(/obj/item/organ/internal/cell)