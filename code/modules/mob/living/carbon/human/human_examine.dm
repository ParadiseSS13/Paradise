/mob/living/carbon/human/examine_visible_clothing(skip_gloves = FALSE, skip_suit_storage = FALSE, skip_jumpsuit = FALSE, skip_shoes = FALSE, skip_mask = FALSE, skip_ears = FALSE, skip_eyes = FALSE, skip_face = FALSE)
	var/list/message_parts = list(
		list("[p_are()] holding", l_hand, "in", "left hand"),
		list("[p_are()] holding", r_hand, "in", "right hand"),
		list("[p_are()] wearing", head, "on", "head"),
		list("[p_are()] wearing", !skip_jumpsuit && w_uniform, null, null, length(w_uniform?.accessories) && "[english_accessory_list(w_uniform)]"),
		list("[p_are()] wearing", wear_suit, null, null),
		list("[p_are()] carrying", !skip_suit_storage && s_store, "on", wear_suit && wear_suit.name),
		list("[p_have()]", back, "on", "back"),
		list("[p_have()]", !skip_gloves && gloves, "on", "hands"),
		list("[p_have()]", belt, "about", "waist"),
		list("[p_are()] wearing", !skip_shoes && shoes, "on", "feet"),
		list("[p_have()]", !skip_mask && wear_mask, "on", "face"),
		list("[p_have()]", glasses, "covering", "eyes"),
		list("[p_have()]", !skip_ears && l_ear, "on", "left ear"),
		list("[p_have()]", !skip_ears && r_ear, "on", "right ear"),
		list("[p_are()] wearing", wear_id, null, null),
	)

	return message_parts

/mob/living/carbon/human/examine_show_ssd()
	if(dna?.species.show_ssd)
		return ..()

/mob/living/carbon/human/examine_handle_individual_limb(limb_name)
	var/msg = ""
	switch(limb_name)
		if("hands")
			if(blood_DNA)
				return "<span class='warning'>[p_they(TRUE)] [p_have()] [hand_blood_color != "#030303" ? "blood-stained":"oil-stained"] hands!</span>\n"
		if("eyes")
			if(HAS_TRAIT(src, SCRYING))
				if(iscultist(src) && HAS_TRAIT(src, CULT_EYES))
					return "<span class='boldwarning'>[p_their(TRUE)] glowing red eyes are glazed over!</span>\n"
				return "<span class='boldwarning'>[p_their(TRUE)] eyes are glazed over.</span>\n"
			else
				if(iscultist(src) && HAS_TRAIT(src, CULT_EYES))
					return "<span class='boldwarning'>[p_their(TRUE)] eyes are glowing an unnatural red!</span>\n"

	return msg

/mob/living/carbon/human/examine_what_am_i(skip_gloves = FALSE, skip_suit_storage = FALSE, skip_jumpsuit = FALSE, skip_shoes = FALSE, skip_mask = FALSE, skip_ears = FALSE, skip_eyes = FALSE, skip_face = FALSE)
	if(!dna)
		return

	var/msg = ""

	var/displayed_species = dna?.species.name
	var/examine_color = dna.species.flesh_color
	for(var/obj/item/clothing/C in src)			//Disguise checks
		if(C == head || C == wear_suit || C == wear_mask || C == w_uniform || C == belt || C == back)
			if(C.species_disguise)
				displayed_species = C.species_disguise
	if(skip_jumpsuit && skip_face || HAS_TRAIT(src, TRAIT_NOEXAMINE)) //either obscured or on the nospecies list
		msg += "!\n"    //omit the species when examining
	else if(displayed_species == "Slime People") //snowflakey because Slime People are defined as a plural
		msg += ", a<b><font color='[examine_color]'> slime person</font></b>!\n"
	else if(displayed_species == "Unathi") //DAMN YOU, VOWELS
		msg += ", a<b><font color='[examine_color]'> unathi</font></b>!\n"
	else
		msg += ", a<b><font color='[examine_color]'> [lowertext(displayed_species)]</font></b>!\n"

/mob/living/carbon/human/examine_start_damage_block(skip_gloves = FALSE, skip_suit_storage = FALSE, skip_jumpsuit = FALSE, skip_shoes = FALSE, skip_mask = FALSE, skip_ears = FALSE, skip_eyes = FALSE, skip_face = FALSE)
	var/msg = ""
	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	for(var/organ_tag in dna.species.has_limbs)

		var/list/organ_data = dna.species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]
		is_destroyed["[organ_data["descriptor"]]"] = 1

		var/obj/item/organ/external/E = bodyparts_by_name[organ_tag]
		if(!E)
			wound_flavor_text["[organ_tag]"] = "<B>[p_they(TRUE)] [p_are()] missing [p_their()] [organ_descriptor].</B>\n"
		else
			if(!ismachineperson(src))
				if(E.is_robotic())
					wound_flavor_text["[E.limb_name]"] = "[p_they(TRUE)] [p_have()] a robotic [E.name]!\n"

				else if(E.status & ORGAN_SPLINTED)
					wound_flavor_text["[E.limb_name]"] = "[p_they(TRUE)] [p_have()] a splint on [p_their()] [E.name]!\n"

				else if(!E.properly_attached)
					wound_flavor_text["[E.limb_name]"] = "[p_their(TRUE)] [E.name] is barely attached!\n"

			if(E.open)
				if(E.is_robotic())
					msg += "<b>The maintenance hatch on [p_their()] [ignore_limb_branding(E.limb_name)] is open!</b>\n"
				else
					msg += "<b>[p_their(TRUE)] [ignore_limb_branding(E.limb_name)] has an open incision!</b>\n"

			for(var/obj/item/I in E.embedded_objects)
				msg += "<B>[p_they(TRUE)] [p_have()] \a [bicon(I)] [I] embedded in [p_their()] [E.name]!</B>\n"

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skip_mask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	if(wound_flavor_text["chest"] && !w_uniform && !skip_jumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	if(wound_flavor_text["l_arm"] && (is_destroyed["left arm"] || (!w_uniform && !skip_jumpsuit)))
		msg += wound_flavor_text["l_arm"]
	if(wound_flavor_text["l_hand"] && (is_destroyed["left hand"] || (!gloves && !skip_gloves)))
		msg += wound_flavor_text["l_hand"]
	if(wound_flavor_text["r_arm"] && (is_destroyed["right arm"] || (!w_uniform && !skip_jumpsuit)))
		msg += wound_flavor_text["r_arm"]
	if(wound_flavor_text["r_hand"] && (is_destroyed["right hand"] || (!gloves && !skip_gloves)))
		msg += wound_flavor_text["r_hand"]
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skip_jumpsuit)))
		msg += wound_flavor_text["groin"]
	if(wound_flavor_text["l_leg"] && (is_destroyed["left leg"] || (!w_uniform && !skip_jumpsuit)))
		msg += wound_flavor_text["l_leg"]
	if(wound_flavor_text["l_foot"]&& (is_destroyed["left foot"] || (!shoes && !skip_shoes)))
		msg += wound_flavor_text["l_foot"]
	if(wound_flavor_text["r_leg"] && (is_destroyed["right leg"] || (!w_uniform && !skip_jumpsuit)))
		msg += wound_flavor_text["r_leg"]
	if(wound_flavor_text["r_foot"]&& (is_destroyed["right foot"] || (!shoes  && !skip_shoes)))
		msg += wound_flavor_text["r_foot"]

	return msg

/mob/living/carbon/human/examine_extra_damage_flavor()
	var/msg = ""
	if(bleedsuppress)
		msg += "[p_they(TRUE)] [p_are()] bandaged with something.\n"
	else if(bleed_rate)
		msg += "<B>[p_they(TRUE)] [p_are()] bleeding!</B>\n"

	return msg

/mob/living/carbon/human/examine_extra_general_flavor()
	var/msg = ""
	switch(decaylevel)
		if(1)
			msg += "[p_they(TRUE)] [p_are()] starting to smell.\n"
		if(2)
			msg += "[p_they(TRUE)] [p_are()] bloated and smells disgusting.\n"
		if(3)
			msg += "[p_they(TRUE)] [p_are()] rotting and blackened, the skin sloughing off. The smell is indescribably foul.\n"
		if(4)
			msg += "[p_they(TRUE)] [p_are()] mostly desiccated now, with only bones remaining of what used to be a person.\n"

	return msg

/mob/living/carbon/human/examine_get_brute_message()
	return !ismachineperson(src) ? "bruising" : "denting"
