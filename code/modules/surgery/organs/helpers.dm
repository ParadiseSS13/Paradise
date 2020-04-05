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


/mob/living/carbon/get_organs_zone(zone, var/subzones = 0)
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

/proc/is_int_organ(atom/A)
	return istype(A, /obj/item/organ/internal)

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


//Limb numbers
/mob/proc/get_num_arms()
	return 2

/mob/living/carbon/human/get_num_arms()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/organ/external/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			.++
		if(affecting.body_part == ARM_LEFT)
			.++

//sometimes we want to ignore that we don't have the required amount of arms.
/mob/proc/get_arm_ignore()
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

//sometimes we want to ignore that we don't have the required amount of legs.
/mob/proc/get_leg_ignore()
	return FALSE


/mob/living/carbon/human/get_leg_ignore()

	if(flying == 1)
		return TRUE

	var/obj/item/tank/jetpack/J
	if(istype(back,/obj/item/tank/jetpack))
		J = back
		if(J.on == 1)
			return TRUE
	return FALSE

/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/human/get_missing_limbs()
	var/list/full = list("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg")
	for(var/zone in full)
		if(has_organ(zone))
			full -= zone
	return full
