/****************************************************
			   ORGAN DEFINES
****************************************************/

/obj/item/organ/external/chest
	name = "upper body"
	limb_name = "chest"
	icon_name = "torso"
	max_damage = 100
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_HUGE
	body_part = UPPER_TORSO
	vital = TRUE
	amputation_point = "spine"
	gendered_icon = 1
	parent_organ = null
	encased = "ribcage"
	convertable_children = list(/obj/item/organ/external/groin)

/obj/item/organ/external/chest/emp_act(severity)
	..()
	if(!is_robotic() || emp_proof || !tough) // Augmented chest suffocates the user on EMP.
		return
	switch(severity)
		if(1)
			owner?.adjustStaminaLoss(20)
		if(2)
			owner?.adjustStaminaLoss(10)
	to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, вызывая усталость!</span>")

/obj/item/organ/external/groin
	name = "lower body"
	limb_name = "groin"
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 35
	w_class = WEIGHT_CLASS_BULKY // if you know what I mean ;)
	body_part = LOWER_TORSO
	vital = TRUE
	parent_organ = "chest"
	amputation_point = "lumbar"
	gendered_icon = 1

/obj/item/organ/external/arm
	limb_name = "l_arm"
	name = "left arm"
	icon_name = "l_arm"
	max_damage = 50
	min_broken_damage = 30
	w_class = WEIGHT_CLASS_NORMAL
	body_part = ARM_LEFT
	parent_organ = "chest"
	amputation_point = "left shoulder"
	can_grasp = 1
	convertable_children = list(/obj/item/organ/external/hand)

/obj/item/organ/external/arm/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented arms and hands drop whatever they are holding on EMP.
		return
	var/hand = (body_part == ARM_LEFT) ? owner.l_hand : owner.r_hand
	if(hand && owner.canUnEquip(hand))
		owner.unEquip(hand)
		to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, бросая то что держал!</span>")
		owner.custom_emote(1, "бросает [owner.p_they()] [owner.p_were()] держали, [owner.p_their()] [name] выходя из строя!")

/obj/item/organ/external/arm/right
	limb_name = "r_arm"
	name = "right arm"
	icon_name = "r_arm"
	body_part = ARM_RIGHT
	amputation_point = "right shoulder"
	convertable_children = list(/obj/item/organ/external/hand/right)

/obj/item/organ/external/leg
	limb_name = "l_leg"
	name = "left leg"
	icon_name = "l_leg"
	max_damage = 50
	min_broken_damage = 30
	w_class = WEIGHT_CLASS_NORMAL
	body_part = LEG_LEFT
	icon_position = LEFT
	parent_organ = "groin"
	amputation_point = "left hip"
	can_stand = 1
	convertable_children = list(/obj/item/organ/external/foot)

/obj/item/organ/external/leg/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented legs and feet make the user drop to the floor on EMP.
		return
	if(owner.weakened)
		to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, не давая вам встать!</span>")
		owner.custom_emote(1, "не может встать, [owner.p_their()] [name] выходя из строя!")
	else
		to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, заставив вас упасть на пол!</span>")
		owner.custom_emote(1, "упал на пол, [owner.p_their()] [name] выходя из строя!")
	switch(severity)
		if(1)
			owner.AdjustWeakened(4)
		if(2)
			owner.AdjustWeakened(2)

/obj/item/organ/external/leg/right
	limb_name = "r_leg"
	name = "right leg"
	icon_name = "r_leg"
	body_part = LEG_RIGHT
	icon_position = RIGHT
	amputation_point = "right hip"
	convertable_children = list(/obj/item/organ/external/foot/right)

/obj/item/organ/external/foot
	limb_name = "l_foot"
	name = "left foot"
	icon_name = "l_foot"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	body_part = FOOT_LEFT
	icon_position = LEFT
	parent_organ = "l_leg"
	amputation_point = "left ankle"
	can_stand = 1

/obj/item/organ/external/foot/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented legs and feet make the user drop to the floor on EMP.
		return
	if(owner.weakened)
		to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, не давая вам встать!</span>")
		owner.custom_emote(1, "не может встать, [owner.p_their()] [name] выходя из строя")
	else
		to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, падая на пол!</span>")
		owner.custom_emote(1, "падая на пол, [owner.p_their()] [name] выходя из строя")
	switch(severity)
		if(1)
			owner.AdjustWeakened(4)
		if(2)
			owner.AdjustWeakened(2)

/obj/item/organ/external/foot/remove()
	if(owner && owner.shoes) owner.unEquip(owner.shoes)
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
	w_class = WEIGHT_CLASS_SMALL
	body_part = HAND_LEFT
	parent_organ = "l_arm"
	amputation_point = "left wrist"
	can_grasp = 1

/obj/item/organ/external/hand/emp_act(severity)
	..()
	if(!owner || !is_robotic() || emp_proof || !tough) // Augmented arms and hands drop whatever they are holding on EMP.
		return
	var/hand = (body_part == HAND_LEFT) ? owner.l_hand : owner.r_hand
	if(hand && owner.canUnEquip(hand))
		owner.unEquip(hand)
		to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, dropping what it was holding!</span>")
		owner.custom_emote(1, "бросает [owner.p_they()] [owner.p_were()] держали, [owner.p_their()] [name] выходя из строя")

/obj/item/organ/external/hand/remove()
	if(owner)
		if(owner.gloves)
			owner.unEquip(owner.gloves)
		if(owner.l_hand)
			owner.unEquip(owner.l_hand, TRUE)
		if(owner.r_hand)
			owner.unEquip(owner.r_hand, TRUE)

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
	w_class = WEIGHT_CLASS_NORMAL
	body_part = HEAD
	parent_organ = "chest"
	amputation_point = "neck"
	gendered_icon = 1
	encased = "skull"
	var/can_intake_reagents = 1
	var/alt_head = "None"

	//Hair colour and style
	var/hair_colour = "#000000"
	var/sec_hair_colour = "#000000"
	var/h_style = "Bald"
	var/h_grad_style = "None"
	var/h_grad_offset_x = 0
	var/h_grad_offset_y = 0
	var/h_grad_colour = "#000000"
	var/h_grad_alpha = 200

	//Head accessory colour and style
	var/headacc_colour = "#000000"
	var/ha_style = "None"

	//Facial hair colour and style
	var/facial_colour = "#000000"
	var/sec_facial_colour = "#000000"
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
		owner.update_hair()
		owner.update_fhair()
		owner.update_head_accessory()
		owner.update_markings()
	. = ..()

/obj/item/organ/external/head/replaced()
	name = limb_name
	..()

/obj/item/organ/external/head/receive_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list(), ignore_resists = FALSE, updating_health = TRUE)
	..()
	if(!disfigured)
		if(brute_dam + burn_dam > 50)
			disfigure()

/obj/item/organ/external/head/examine(mob/user)
	. = ..()
	if(in_range(user, src) || istype(user, /mob/dead/observer))
		if(!contents.len)
			. += "<span class='notice'>Выглядит пустой.</span>"
		else
			. += "<span class='notice'>Выглядит относительно целой, внутри что-то есть.</span>"
	else
		. += "<span class='notice'>Вы должны подойти ближе, чтобы осмотреть это.</span>"

/obj/item/organ/external/head/proc/handle_alt_icon()
	if(alt_head && GLOB.alt_heads_list[alt_head])
		var/datum/sprite_accessory/alt_heads/alternate_head = GLOB.alt_heads_list[alt_head]
		if(alternate_head.icon_state)
			icon_name = alternate_head.icon_state
		else //If alternate_head.icon_state doesn't exist, that means alternate_head is "None", so default icon_name back to "head".
			icon_name = initial(icon_name)
	else //If alt_head is null, set it to "None" and default icon_name for sanity.
		alt_head = initial(alt_head)
		icon_name = initial(icon_name)

/obj/item/organ/external/head/robotize(company, make_tough = 0, convert_all = 1) //Undoes alt_head business to avoid getting in the way of robotization. Make sure we pass all args down the line...
	alt_head = initial(alt_head)
	icon_name = initial(icon_name)
	..()

/obj/item/organ/external/head/set_dna(datum/dna/new_dna)
	..()
	new_dna.write_head_attributes(src)

/obj/item/organ/external/head/emp_act(severity)
	..()
	if(!is_robotic() || emp_proof || !tough) // Augmented head confuses the user on EMP.
		return
	switch(severity)
		if(1)
			owner?.AdjustConfused(30)
		if(2)
			owner?.AdjustConfused(20)
	to_chat(owner, "<span class='userdanger'>Ваш [name] выходит из строя, перегружая ваше управление!</span>")

/obj/item/organ/external/tail
	limb_name = "tail"
	name = "tail"
	force_icon = "icons/effects/species.dmi"
	icon_name = "tail"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	body_part = TAIL
	parent_organ = "groin"
	amputation_point = "lower spine"
	var/datum/body_accessory/body_accessory
	var/list/m_styles = list("tail" = "None")
	var/list/m_colours = list("tail" = "#000000")
	s_col = "#000000"

/obj/item/organ/external/tail/New(var/mob/living/carbon/holder)
	..()
	var/mob/living/carbon/human/H = holder
	if(!H)
		var/icon/tempicon = new/icon("icon" = force_icon, "icon_state" = icon_name)
		var/icon/tempicon2 = new/icon(tempicon,dir=NORTH)
		tempicon2.Flip(SOUTH)
		tempicon.Insert(tempicon2,dir=SOUTH)
		force_icon = tempicon
		icon_name = null
		return

/obj/item/organ/external/tail/sync_colour_to_human(var/mob/living/carbon/human/H)
	..()
	var/datum/sprite_accessory/tail_marking_style = GLOB.marking_styles_list[H.m_styles["tail"]]
	if(body_accessory && (dna.species.name in body_accessory.allowed_species))
		body_accessory = body_accessory
	if(body_accessory)
		if(body_accessory.name in tail_marking_style.tails_allowed)
			m_styles["tail"] = H.m_styles["tail"]
	else
		if(dna.species.name in tail_marking_style.species_allowed)
			m_styles["tail"] = H.m_styles["tail"]
	if(dna.species.bodyflags & HAS_SKIN_COLOR)
		m_colours["tail"] = H.m_colours["tail"]

/obj/item/organ/external/tail/monkey
	species_type = /datum/species/monkey
	name = "monkey tail"
	icon_name = "chimptail_s"
	max_damage = 15
	min_broken_damage = 10

/obj/item/organ/external/tail/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa tail"
	icon_name = "farwatail_s"

/obj/item/organ/external/tail/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin tail"
	icon_name = "wolpintail_s"

/obj/item/organ/external/tail/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok tail"
	icon_name = "stoktail_s"

/obj/item/organ/external/wing
	limb_name = "wing"
	name = "wings"
	icon_name = "wing"
	max_damage = 30
	min_broken_damage = 15
	w_class = WEIGHT_CLASS_SMALL
	body_part = WING
	parent_organ = "chest"
	amputation_point = "spine"
	var/datum/body_accessory/body_accessory
	var/list/m_styles = list("wing" = "None")
	var/list/m_colours = list("wing" = "#000000")
	s_col = "#000000"

/obj/item/organ/external/wing/New(var/mob/living/carbon/holder)
	..()
	var/mob/living/carbon/human/H = holder
	if(!H)
		var/icon/tempicon = new/icon("icon" = force_icon, "icon_state" = icon_name)
		var/icon/tempicon2 = new/icon(tempicon,dir=NORTH)
		tempicon2.Flip(SOUTH)
		tempicon.Insert(tempicon2,dir=SOUTH)
		force_icon = tempicon
		icon_name = null
		return
