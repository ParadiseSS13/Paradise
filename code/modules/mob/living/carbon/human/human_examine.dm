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
				break
	if(skip_jumpsuit && skip_face || HAS_TRAIT(src, TRAIT_NOEXAMINE)) //either obscured or on the nospecies list
		msg += "!"    //omit the species when examining
	else if(displayed_species == "Slime People") //snowflakey because Slime People are defined as a plural
		msg += ", a<b><font color='[examine_color]'> slime person</font></b>!"
	else
		// do all this extra stuff because byond's text macros get confused by whatever comes between the species name and the article,
		// so we can't just do \a
		var/article_override = dna?.species.article_override
		var/article = article_override
		if(!article_override)
			article = starts_with_vowel(displayed_species) ? "an" : "a"

		msg += ", [article]<b><font color='[examine_color]'> [lowertext(displayed_species)]</font></b>!"

	return msg

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
			wound_flavor_text["[organ_tag]"] = "<b>[p_they(TRUE)] [p_are()] missing [p_their()] [organ_descriptor].</b>\n"
		else
			if(!ismachineperson(src))
				if(E.is_robotic())
					wound_flavor_text["[E.limb_name]"] = "[p_they(TRUE)] [p_have()] a robotic [E.name]!\n"

				else if(E.status & ORGAN_SPLINTED)
					wound_flavor_text["[E.limb_name]"] = "[p_they(TRUE)] [p_have()] a splint on [p_their()] [E.name]!\n"

				else if(!E.properly_attached)
					wound_flavor_text["[E.limb_name]"] = "[p_their(TRUE)] [E.name] is barely attached!\n"

				else if(E.status & ORGAN_BURNT)
					wound_flavor_text["[E.limb_name]"] = "[p_their(TRUE)] [E.name] is badly burnt!\n"

			if(E.open)
				if(E.is_robotic())
					msg += "<b>The maintenance hatch on [p_their()] [ignore_limb_branding(E.limb_name)] is open!</b>\n"
				else
					msg += "<b>[p_their(TRUE)] [ignore_limb_branding(E.limb_name)] has an open incision!</b>\n"

			for(var/obj/item/I in E.embedded_objects)
				msg += "<b>[p_they(TRUE)] [p_have()] \a [bicon(I)] [I] embedded in [p_their()] [E.name]!</b>\n"

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
		msg += "<b>[p_they(TRUE)] [p_are()] bleeding!</b>\n"

	return msg

/mob/living/carbon/human/examine_extra_general_flavor(mob/user)
	var/msg = ""
	switch(decaylevel)
		if(1)
			msg += "[p_they(TRUE)] [p_are()] starting to smell.\n"
		if(2)
			msg += "[p_they(TRUE)] [p_are()] bloated and smells disgusting.\n"
		if(3)
			msg += "[p_they(TRUE)] [p_are()] rotting and blackened, the skin sloughing off. The smell is indescribably foul.\n"
		if(4)
			msg += "[p_they(TRUE)] [p_are()] mostly desiccated now, with only [isslimeperson(src) ? "congealed slime" : "bones"] remaining of what used to be a person.\n"

	// only humans get employment records
	if(hasHUD(user, EXAMINE_HUD_SECURITY_READ))
		var/perpname = get_visible_name(TRUE)
		var/criminal = "None"
		var/commentLatest = "ERROR: Unable to locate a data core entry for this person." //If there is no datacore present, give this

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]
							if(LAZYLEN(R.fields["comments"])) //if the commentlist is present
								var/list/comments = R.fields["comments"]
								commentLatest = LAZYACCESS(comments, comments.len) //get the latest entry from the comment log
							else
								commentLatest = "No entries." //If present but without entries (=target is recognized crew)

			var/criminal_status = hasHUD(user, EXAMINE_HUD_SECURITY_WRITE) ? "<a href='?src=[UID()];criminal=1'>\[[criminal]\]</a>" : "\[[criminal]\]"
			msg += "<span class = 'deptradio'>Criminal status:</span> [criminal_status]\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='?src=[UID()];secrecordComment=`'>\[View comment log\]</a> <a href='?src=[UID()];secrecordadd=`'>\[Add comment\]</a>\n"
			msg += "<span class = 'deptradio'>Latest entry:</span> [commentLatest]\n"

	if(hasHUD(user, EXAMINE_HUD_SKILLS))
		var/perpname = get_visible_name(TRUE)
		var/skills

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					skills = E.fields["notes"]
			if(skills)
				var/char_limit = 40
				if(length(skills) <= char_limit)
					msg += "<span class='deptradio'>Employment records:</span> [skills]\n"
				else
					msg += "<span class='deptradio'>Employment records: [copytext_preserve_html(skills, 1, char_limit-3)]...</span><a href='byond://?src=[UID()];employment_more=1'>More...</a>\n"


	if(hasHUD(user,EXAMINE_HUD_MEDICAL))
		var/perpname = get_visible_name(TRUE)
		var/medical = "None"

		for(var/datum/data/record/E in GLOB.data_core.general)
			if(E.fields["name"] == perpname)
				for(var/datum/data/record/R in GLOB.data_core.general)
					if(R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='?src=[UID()];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='?src=[UID()];medrecord=`'>\[View\]</a> <a href='?src=[UID()];medrecordadd=`'>\[Add comment\]</a>\n"


	return msg

/mob/living/carbon/human/examine_get_brute_message()
	return !ismachineperson(src) ? "bruising" : "denting"
