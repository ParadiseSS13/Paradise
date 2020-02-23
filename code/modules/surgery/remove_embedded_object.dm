/datum/surgery_step/remove_object
	name = "Remove Embedded Objects"
	time = 32
	accept_hand = 1
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_ROBOTIC_HATCH_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	possible_locs = list("head", "chest", "l_arm", "l_hand", "r_arm", "r_hand","r_leg", "r_foot", "l_leg", "l_foot", "groin")
	requires_organic_bodypart = FALSE
	var/obj/item/organ/external/L = null

/datum/surgery_step/remove_object/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/remove_object/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.organ_ref
	if(L)
		user.visible_message("[user] looks for objects embedded in [target]'s [parse_zone(location)].", "<span class='notice'>You look for objects embedded in [target]'s [parse_zone(location)]...</span>")
	..()

/datum/surgery_step/remove_object/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	
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

	return TRUE