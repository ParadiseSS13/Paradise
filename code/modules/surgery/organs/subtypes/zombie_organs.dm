/obj/item/organ/internal/zombietumor
	name = "necrotic tumor"
	desc = "A tiny cluster of foul-smelling mushrooms which feed on and manipulate brain matter."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "chanterelle"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "head"
	slot = "brain_tumor"
	destroy_on_removal = TRUE

/obj/item/organ/internal/zombietumor/remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/zombie/D in M.viruses)
		D.cure()
	var/mob/living/carbon/human/H = M
	for(var/obj/item/organ/limb as anything in H.bodyparts)
		if(limb.status & ORGAN_DEAD && !limb.is_robotic())
			limb.status &= ~ORGAN_DEAD
	H.update_body()
	return ..()
