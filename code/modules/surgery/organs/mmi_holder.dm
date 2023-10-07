// Used for an MMI or robotic brain being installed into a human.
/obj/item/organ/internal/brain/mmi_holder
	name = "Man-Machine Interface"
	parent_organ = "chest"
	status = ORGAN_ROBOT
	destroy_on_removal = TRUE

	var/obj/item/mmi/stored_mmi

/obj/item/organ/internal/brain/mmi_holder/Destroy()
	QDEL_NULL(stored_mmi)
	return ..()

/obj/item/organ/internal/brain/mmi_holder/insert(mob/living/target, special = 0)
	..()
	// To supersede the over-writing of the MMI's name from `insert`
	update_from_mmi()
	target.thought_bubble_image = "thought_bubble_machine"
	if(ishuman(target) && istype(stored_mmi?.held_brain, /obj/item/organ/internal/brain/cluwne))
		var/mob/living/carbon/human/H = target
		H.makeCluwne() //No matter where you go, no matter what you do, you cannot escape

/obj/item/organ/internal/brain/mmi_holder/remove(mob/living/user, special = 0)
	if(!special)
		if(stored_mmi)
			. = stored_mmi
			if(owner.mind)
				owner.mind.transfer_to(stored_mmi.brainmob)
			stored_mmi.forceMove(get_turf(owner))
			stored_mmi = null
	return ..()

/obj/item/organ/internal/brain/mmi_holder/proc/update_from_mmi()
	if(!stored_mmi)
		return
	name = initial(stored_mmi.name)
	desc = stored_mmi.desc
	icon = stored_mmi.icon
	icon_state = stored_mmi.icon_state
	set_dna(stored_mmi.brainmob.dna)
