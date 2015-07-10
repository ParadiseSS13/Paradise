/obj/item/organ/external/stump
	name = "limb stump"
	icon_name = ""
	cannot_amputate = 0 //You need to remove stumps to attach new limbs, but you can't remove stumps... What the fuck?

/obj/item/organ/external/stump/New(var/mob/living/carbon/holder, var/internal, var/obj/item/organ/external/limb)
	if(istype(limb))
		limb_name = limb.limb_name
		body_part = limb.body_part
		amputation_point = limb.amputation_point
		parent_organ = limb.parent_organ
		wounds = limb.wounds
	..(holder, internal)
	if(istype(limb))
		max_damage = limb.max_damage

/obj/item/organ/external/stump/is_stump()
	return 1

/obj/item/organ/external/stump/removed()
	..()
	qdel(src)
