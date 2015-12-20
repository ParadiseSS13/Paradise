/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/proc/get_organs_zone(zone)
	return

/mob/proc/get_organ_slot(slot) //is it a brain, is it a brain_tumor?
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
		if(parent_organ == O.parent_organ)
			returnorg += O
	return returnorg

/mob/living/carbon/get_organ_slot(slot)
	for(var/obj/item/organ/internal/O in internal_organs)
		if(slot == O.slot)
			return O

/proc/is_int_organ(atom/A)
	return istype(A, /obj/item/organ/internal)