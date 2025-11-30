/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/proc/get_organs_zone(zone)
	return

/mob/proc/get_organ_slot(slot) //is it a brain, is it a brain_tumor?
	return

/mob/proc/get_int_organ_tag(tag) //is it a brain, is it a brain_tumor?
	return

/mob/living/proc/get_organ(zone)
	return

/mob/living/carbon/get_int_organ(typepath)
	return (locate(typepath) in internal_organs)

/mob/living/carbon/proc/get_int_organ_datum(tag_to_check)
	RETURN_TYPE(/datum/organ)
	return internal_organ_datums[tag_to_check]


/mob/living/carbon/get_organs_zone(zone, subzones = 0)
	var/list/returnorg = list()
	if(subzones)
		// Include subzones - groin for chest, eyes and mouth for head
		//Fethas note:We have check_zone, i may need to remove the below
		if(zone == "head")
			returnorg = get_organs_zone("eyes") + get_organs_zone("mouth")
		if(zone == "chest")
			returnorg = get_organs_zone("groin")

	for(var/obj/item/organ/internal/O in internal_organs)
		if(zone == O.parent_organ)
			returnorg += O
	return returnorg

/mob/living/carbon/get_organ_slot(slot)
	return internal_organs_slot[slot]

/mob/living/carbon/get_int_organ_tag(tag)
	for(var/obj/item/organ/internal/O in internal_organs)
		if(tag == O.organ_tag)
			return O

/mob/living/carbon/human/proc/get_limb_by_name(limb_name) //Look for a limb with the given limb name in the source mob, and return it if found.
	for(var/obj/item/organ/external/O in bodyparts)
		if(limb_name == O.limb_name)
			return O

/mob/proc/has_left_hand()
	return TRUE

/mob/living/carbon/human/has_left_hand()
	if(has_organ("l_hand"))
		return TRUE
	return FALSE


/mob/proc/has_right_hand()
	return TRUE

/mob/living/carbon/human/has_right_hand()
	if(has_organ("r_hand"))
		return TRUE
	return FALSE

/mob/proc/has_both_hands()
	return TRUE

/mob/living/carbon/human/has_both_hands()
	if(has_left_hand() && has_right_hand())
		return TRUE
	return FALSE

/mob/proc/get_num_legs()
	return 2

/mob/living/carbon/human/get_num_legs()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/organ/external/affecting = X
		if(affecting.body_part == LEG_RIGHT)
			.++
		if(affecting.body_part == LEG_LEFT)
			.++

/* Returns true if all the mob's vital organs are functional, otherwise returns false.
*  This proc is only used for checking if IPCs can revive from death, so calling it on a non IPC will always return false (right now)
*/
/mob/living/carbon/human/proc/ipc_vital_organ_check()
	var/has_battery = get_int_organ_datum(ORGAN_DATUM_BATTERY)
	if(!has_battery)
		return FALSE
	for(var/obj/item/organ/internal/organ in internal_organs)
		if(organ.vital && ((organ.damage >= organ.max_damage) || organ.status & ORGAN_DEAD))
			return FALSE
	return TRUE
