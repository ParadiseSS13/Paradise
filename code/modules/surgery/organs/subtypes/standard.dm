/****************************************************
			   ORGAN DEFINES
****************************************************/

/obj/item/organ/external/chest
	name = "upper body"
	limb_name = "chest"
	icon_name = "torso"
	max_damage = 100
	min_broken_damage = 35
	w_class = 5
	body_part = UPPER_TORSO
	vital = 1
	amputation_point = "spine"
	gendered_icon = 1
	cannot_amputate = 1
	parent_organ = null
	encased = "ribcage"
	var/fat = FALSE

/obj/item/organ/external/chest/proc/makeFat(update_body_icon = 1)
	fat = TRUE
	if(owner)
		owner.update_body(update_body_icon)
	else
		// get_icon updates the sprite icon, update_icon updates the injuries overlay.
		// Madness.
		get_icon()

/obj/item/organ/external/chest/proc/makeSlim(update_body_icon = 1)
	fat = FALSE
	if(owner)
		owner.update_body(update_body_icon)
	else
		// get_icon updates the sprite icon, update_icon updates the injuries overlay.
		// Madness.
		get_icon()

/obj/item/organ/external/groin
	name = "lower body"
	limb_name = "groin"
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 35
	w_class = 4
	body_part = LOWER_TORSO
	vital = 1
	parent_organ = "chest"
	amputation_point = "lumbar"
	gendered_icon = 1

/obj/item/organ/external/arm
	limb_name = "l_arm"
	name = "left arm"
	icon_name = "l_arm"
	max_damage = 50
	min_broken_damage = 30
	w_class = 3
	body_part = ARM_LEFT
	parent_organ = "chest"
	amputation_point = "left shoulder"
	can_grasp = 1

/obj/item/organ/external/arm/right
	limb_name = "r_arm"
	name = "right arm"
	icon_name = "r_arm"
	body_part = ARM_RIGHT
	amputation_point = "right shoulder"

/obj/item/organ/external/leg
	limb_name = "l_leg"
	name = "left leg"
	icon_name = "l_leg"
	max_damage = 50
	min_broken_damage = 30
	w_class = 3
	body_part = LEG_LEFT
	icon_position = LEFT
	parent_organ = "groin"
	amputation_point = "left hip"
	can_stand = 1

/obj/item/organ/external/leg/right
	limb_name = "r_leg"
	name = "right leg"
	icon_name = "r_leg"
	body_part = LEG_RIGHT
	icon_position = RIGHT
	amputation_point = "right hip"

/obj/item/organ/external/foot
	limb_name = "l_foot"
	name = "left foot"
	icon_name = "l_foot"
	max_damage = 30
	min_broken_damage = 15
	w_class = 2
	body_part = FOOT_LEFT
	icon_position = LEFT
	parent_organ = "l_leg"
	amputation_point = "left ankle"
	can_stand = 1

/obj/item/organ/external/foot/remove()
	if(owner.shoes) owner.unEquip(owner.shoes)
	. = ..()

/obj/item/organ/external/foot/right
	limb_name = "r_foot"
	name = "right foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ = "r_leg"
	amputation_point = "right ankle"

/obj/item/organ/external/hand
	limb_name = "l_hand"
	name = "left hand"
	icon_name = "l_hand"
	max_damage = 30
	min_broken_damage = 15
	w_class = 2
	body_part = HAND_LEFT
	parent_organ = "l_arm"
	amputation_point = "left wrist"
	can_grasp = 1

/obj/item/organ/external/hand/remove()
	if(owner.gloves)
		owner.unEquip(owner.gloves)
	if(owner.l_hand)
		owner.unEquip(owner.l_hand,1)
	if(owner.r_hand)
		owner.unEquip(owner.r_hand,1)

	. = ..()

/obj/item/organ/external/hand/right
	limb_name = "r_hand"
	name = "right hand"
	icon_name = "r_hand"
	body_part = HAND_RIGHT
	parent_organ = "r_arm"
	amputation_point = "right wrist"

/obj/item/organ/external/head
	limb_name = "head"
	icon_name = "head"
	name = "head"
	max_damage = 75
	min_broken_damage = 35
	w_class = 3
	body_part = HEAD
	vital = 1
	parent_organ = "chest"
	amputation_point = "neck"
	gendered_icon = 1
	encased = "skull"
	var/can_intake_reagents = 1

	//Hair colour and style
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0
	var/h_style = "Bald"

	//Head accessory colour and style
	var/r_headacc = 0
	var/g_headacc = 0
	var/b_headacc = 0
	var/ha_style = "None"

	//Facial hair colour and style
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0
	var/f_style = "Shaved"

/obj/item/organ/external/head/remove()
	if(owner)
		if(!istype(dna))
			dna = owner.dna.Clone()
		name = "[dna.real_name]'s head"
		if(owner.glasses)
			owner.unEquip(owner.glasses)
		if(owner.head)
			owner.unEquip(owner.head)
		if(owner.l_ear)
			owner.unEquip(owner.l_ear)
		if(owner.r_ear)
			owner.unEquip(owner.r_ear)
		if(owner.wear_mask)
			owner.unEquip(owner.wear_mask)
		spawn(1)
			if(owner)//runtimer no runtiming
				owner.update_hair()
				owner.update_fhair()
	. = ..()

/obj/item/organ/external/head/replaced()
	name = limb_name

	..()

/obj/item/organ/external/head/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	..(brute, burn, sharp, edge, used_weapon, forbidden_limbs)
	if(!disfigured)
		if(brute_dam > 40)
			if(prob(50))
				disfigure("brute")
		if(burn_dam > 40)
			disfigure("burn")

/obj/item/organ/external/head/set_dna(datum/dna/new_dna)
	..()
	new_dna.write_head_attributes(src)
