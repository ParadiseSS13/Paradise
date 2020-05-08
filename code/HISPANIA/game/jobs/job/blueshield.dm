/datum/outfit/job/blueshield/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	var/datum/martial_art/bscqc/theowo = new
	theowo.teach(H)
