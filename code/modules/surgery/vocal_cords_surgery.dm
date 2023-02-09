/datum/surgery/vocal_cords_surgery
	name = "Vocal Cords Tuning Surgery"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/tune_vocal_cords, /datum/surgery_step/generic/cauterize)
	possible_locs = list("mouth")

/datum/surgery/vocal_cords_surgery/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!H.check_has_mouth())
		return FALSE

	return TRUE

/datum/surgery_step/tune_vocal_cords
	name = "tune vocal cords"
	allowed_tools = list(/obj/item/scalpel = 100, /obj/item/kitchen/knife = 50, /obj/item/wirecutters = 35)
	time = 64

/datum/surgery_step/tune_vocal_cords/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to tune [target]'s vocals.", "<span class='notice'>You begin to tune [target]'s vocals...</span>")
	..()

/datum/surgery_step/tune_vocal_cords/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.change_voice(user, TRUE)
	user.visible_message("[user] tunes [target]'s vocals completely!", "<span class='notice'>You tune [target]'s vocals completely.</span>")
	return TRUE

/datum/surgery_step/tune_vocal_cords/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, tearing vocal cords in [target]'s throat with [tool]!</span>", \
						 "<span class='warning'> Your hand slips, tearing vocal cords in [target]'s throat with [tool]!</span>")
	target.tts_seed = SStts.get_random_seed(target)
	target.apply_damage(10, BRUTE, head, sharp = TRUE)
	return FALSE
