/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/proc/get_organs_zone(zone)
	return

/mob/proc/get_organ_slot(slot) //is it a brain, is it a brain_tumor?
	return

/mob/proc/get_int_organ_tag(tag) //is it a brain, is it a brain_tumor?
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
	for(var/obj/item/organ/internal/O in internal_organs)
		if(slot == O.slot)
			return O

/mob/living/carbon/get_int_organ_tag(tag)
	for(var/obj/item/organ/internal/O in internal_organs)
		if(tag == O.organ_tag)
			return O

/proc/is_int_organ(atom/A)
	return istype(A, /obj/item/organ/internal)

/mob/living/carbon/human/proc/get_limb_by_name(limb_name) //Look for a limb with the given limb name in the source mob, and return it if found.
	for(var/obj/item/organ/external/O in organs)
		if(limb_name == O.limb_name)
			return O
