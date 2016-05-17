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
	..()

/obj/item/organ/external/foot/right
	limb_name = "r_foot"
	name = "right foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ = "r_leg"
	amputation_point = "right ankle"

/obj/item/organ/external/snake
	limb_name = BP_TAUR
	name = "lamia tail"
	icon_name = "s_tail"
	body_part = TAIL_SNAKE
	parent_organ = BP_GROIN
	max_damage = 120
	min_broken_damage = 60
	amputation_point = "groin"
	can_stand = 1
	no_blend = 1
	offset_x = -16
	var/list/t_col

/obj/item/organ/external/snake/robotize(var/company, var/skip_prosthetics, var/keep_organs)
	. = ..()
	force_icon = null

/obj/item/organ/external/snake/sync_colour_to_human(var/mob/living/carbon/human/human)
	if(!..(human))
		t_col = list(human.r_skin, human.g_skin, human.b_skin)

/obj/item/organ/external/snake/sync_colour_to_dna()
	..()
	t_col = list(dna.GetUIValue(DNA_UI_SKIN_R), dna.GetUIValue(DNA_UI_SKIN_G), dna.GetUIValue(DNA_UI_SKIN_B))

/obj/item/organ/external/snake/get_icon(var/skeletal)
	var/gender = "f"
	if(owner && owner.gender == MALE)
		gender = "m"

	if(dna)
		if(dna.GetUIState(DNA_UI_GENDER))
			gender = "f"
		else
			gender = "m"

	if(force_icon)
		mob_icon = new /icon(force_icon, "[icon_name][gendered_icon ? "_[gender]" : ""]")
		mob_icon_state = "[icon_name][gendered_icon ? "_[gender]" : ""]"
	else
		if(skeletal)
			mob_icon = new /icon('icons/mob/human_races/lamia_tail.dmi', "[icon_name][gendered_icon ? "_[gender]" : ""]_skele")
			mob_icon_state = "[icon_name][gendered_icon ? "_[gender]" : ""]_skele"
		else if(status & ORGAN_ROBOT)
			mob_icon = new /icon('icons/mob/human_races/lamia_tail.dmi', "[icon_name][gendered_icon ? "_[gender]" : ""]_[model ? lowertext(model) : "robot"]")
			mob_icon_state = "[icon_name][gendered_icon ? "_[gender]" : ""]_[model ? lowertext(model) : "robot"]"
		else
			if(status & ORGAN_MUTATED)
				mob_icon = new /icon('icons/mob/human_races/lamia_tail.dmi', "[icon_name][gender ? "_[gender]" : ""]_deform")
				mob_icon_state = "[icon_name][gender ? "_[gender]" : ""]_deform"
			else
				mob_icon = new /icon('icons/mob/human_races/lamia_tail.dmi', "[icon_name][gender ? "_[gender]" : ""]")
				mob_icon_state = "[icon_name][gendered_icon ? "_[gender]" : ""]"

			if(status & ORGAN_DEAD)
				mob_icon.ColorTone(rgb(10,50,0))
				mob_icon.SetIntensity(0.7)

			if(t_col && t_col.len >= 3)
				mob_icon.Blend(rgb(t_col[1], t_col[2], t_col[3]), ICON_MULTIPLY)

	dir = EAST
	icon = mob_icon
	icon_state = mob_icon_state

	return mob_icon

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

	..()

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
	..()

/obj/item/organ/external/head/replaced()
	name = limb_name

	..()

/obj/item/organ/external/head/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	..(brute, burn, sharp, edge, used_weapon, forbidden_limbs)
	if (!disfigured)
		if (brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if (burn_dam > 40)
			disfigure("burn")
