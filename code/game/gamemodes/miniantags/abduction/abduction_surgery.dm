/datum/surgery_step/internal/manipulate_organs/abduct
	possible_locs = list("chest", "head")

/datum/surgery_step/internal/manipulate_organs/abduct/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(..() && (isabductor(user) || (locate(/obj/item/implant/abductor) in target)))
		return TRUE
	return FALSE

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ
	name = "remove heart"
	accept_hand = 1
	time = 32
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_OPEN_INCISION_BONES)
	next_surgery_stage = SURGERY_STAGE_SAME
	allowed_surgery_behaviour = SURGERY_EXTRACT_ORGAN_MANIP
	var/obj/item/organ/internal/IC = null

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/I in target.get_organs_zone(target_zone))
		// Allows for multiple subtypes of heart.
		if(istype(I, /obj/item/organ/internal/heart))
			IC = I
			break
	user.visible_message("[user] starts to remove [target]'s organs.", "<span class='notice'>You start to remove [target]'s organs...</span>")
	..()

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/AB = target
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		user.put_in_hands(IC)
		IC.remove(target, special = 1)
		return TRUE
	if(NO_INTORGANS in AB.dna.species.species_traits)
		user.visible_message("[user] prepares [target]'s [target_zone] for further dissection!", "<span class='notice'>You prepare [target]'s [target_zone] for further dissection.</span>")
		return TRUE
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")
		return TRUE

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to extract anything!</span>", "<span class='warning'>Your hand slips, failing to extract anything!</span>")
	return FALSE

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert
	name = "insert gland"
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_OPEN_INCISION_BONES)
	next_surgery_stage = SURGERY_STAGE_SAME
	allowed_surgery_behaviour = SURGERY_IMPLANT_ORGAN_MANIP
	time = 32

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return ..() && istype(tool, /obj/item/organ/internal/heart/gland)

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts to insert [tool] into [target].", "<span class ='notice'>You start to insert [tool] into [target]...</span>")
	..()

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] inserts [tool] into [target].", "<span class ='notice'>You insert [tool] into [target].</span>")
	user.drop_item()
	var/obj/item/organ/internal/heart/gland/gland = tool
	gland.insert(target, 2)
	return TRUE

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to insert the gland!</span>", "<span class='warning'>Your hand slips, failing to insert the gland!</span>")
	return FALSE

//IPC Gland Surgery//
/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/synth
	name = "remove cell"
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	possible_locs = list("chest")
	requires_organic_bodypart = 0

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/synth/can_use(mob/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!ishuman(user))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(target_zone)
		if(!affected)
			return FALSE
		if(!affected.is_robotic())
			return FALSE
	var/mob/living/carbon/human/H = user
	// You must either: Be of the abductor species, or contain an abductor implant
	if((isabductor(H) || (locate(/obj/item/implant/abductor) in H)))
		return TRUE
	return FALSE