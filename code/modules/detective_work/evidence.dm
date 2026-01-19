//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "evidenceobj"
	w_class = WEIGHT_CLASS_TINY

/obj/item/evidencebag/afterattack__legacy__attackchain(obj/item/I, mob/user,proximity)
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/evidencebag/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(evidencebagEquip(I, user))
		return TRUE

/obj/item/evidencebag/proc/evidencebagEquip(obj/item/I, mob/user)
	if(!istype(I) || I.anchored)
		return

	if(istype(I, /obj/item/storage/box))
		to_chat(user, SPAN_NOTICE("This box is too big to fit in the evidence bag."))
		return

	if(istype(I, /obj/item/evidencebag))
		to_chat(user, SPAN_NOTICE("You find putting an evidence bag in another evidence bag to be slightly absurd."))
		return 1 //now this is podracing

	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, SPAN_NOTICE("[I] won't fit in [src]."))
		return

	if(length(contents))
		to_chat(user, SPAN_NOTICE("[src] already has something inside it."))
		return

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(isstorage(I.loc))	//in a container.
			var/obj/item/storage/U = I.loc
			U.remove_from_storage(I, src)
		else if(!user.is_holding(I) || !user.unequip(I))					//in a hand
			return

	user.visible_message(SPAN_NOTICE("[user] puts [I] into [src]."), SPAN_NOTICE("You put [I] inside [src]."),\
	SPAN_NOTICE("You hear a rustle as someone puts something into a plastic bag."))

	I.forceMove(src)
	w_class = I.w_class
	update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS|UPDATE_DESC)
	return TRUE

/obj/item/evidencebag/attack_self__legacy__attackchain(mob/user)
	if(!length(contents))
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"
		return
	var/obj/item/I = contents[1]
	user.visible_message(SPAN_NOTICE("[user] takes [I] out of [src]."), SPAN_NOTICE("You take [I] out of [src]."),\
	SPAN_NOTICE("You hear someone rustle around in a plastic bag, and remove something."))
	user.put_in_hands(I)
	I.pickup(user)
	w_class = WEIGHT_CLASS_TINY
	update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS|UPDATE_DESC)

/obj/item/evidencebag/update_icon_state()
	if(length(contents))
		icon_state = "evidence"
	else
		icon_state = "evidenceobj"

/obj/item/evidencebag/update_overlays()
	. = ..()
	if(!length(contents))
		return
	var/obj/item/I = contents[1]
	// var/xx = I.pixel_x	//save the offset of the item
	// var/yy = I.pixel_y
	// I.pixel_x = 0		//then remove it so it'll stay within the evidence bag
	// I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	img.plane = FLOAT_PLANE
	img.pixel_x = 0
	img.pixel_y = 0
	// I.pixel_x = xx		//and then return it
	// I.pixel_y = yy
	. += img
	. += "evidence"	//should look nicer for transparent stuff. not really that important, but hey.

/obj/item/evidencebag/update_desc(updates)
	. = ..()
	if(length(contents))
		var/obj/item/I = contents[1]
		desc = "An evidence bag containing [I]. [I.desc]"
	else
		desc = initial(desc)

/obj/item/sample
	name = "\improper Forensic sample"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/forensics/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
	var/list/evidence = list()

/obj/item/sample/Initialize(mapload, atom/supplied)
	. = ..()
	if(supplied)
		transfer_evidence(supplied)
		name = "[initial(name)] ([supplied])"
	update_icon(UPDATE_ICON_STATE)

/obj/item/sample/proc/report(obj/item/paper/report, obj/machinery/analyzer, report_num)
	report.name = "ERR. No Sample Found"
	report.info = "<b>[analyzer] was not able to finalize a report.</b>"
	return FALSE

/obj/item/sample/proc/transfer_evidence(atom/supplied)
	if(length(supplied.suit_fibers))
		evidence = supplied.suit_fibers.Copy()
		supplied.suit_fibers.Cut()

/obj/item/sample/proc/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!length(supplied.evidence))
		return FALSE
	evidence |= supplied.evidence
	name = "[initial(name)] (combined)"
	to_chat(user, SPAN_NOTICE("You add [supplied] to [src]."))
	return TRUE

/obj/item/sample/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, src.type))
		user.unequip(used)
		if(merge_evidence(used, user))
			qdel(used)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/sample/print
	name = "fingerprint card"
	desc = "A stiff paper card for preserving fingerprints. This one is unused."
	icon_state = "fingerprint"
	inhand_icon_state = "paper"
	/// if true, the print was pulled instead of being manually pressed.
	var/pulled = FALSE

/obj/item/sample/print/update_icon_state()
	if(!length(evidence))
		icon_state = "fingerprint"
		return
	if(pulled)
		icon_state = "fingerprint_pulled"
		return
	icon_state = "fingerprint_pressed"

/obj/item/sample/print/update_desc()
	. = ..()
	if(!length(evidence))
		desc = initial(desc)
		return
	if(pulled)
		desc = "A stiff paper card for preserving fingerprints. This one has been used for pulling prints with fingerprint powder."
		return
	desc = "A stiff paper card for preserving fingerprints. This one has been used manually printed."

/obj/item/sample/print/activate_self(mob/user)
	if(..() || length(evidence) || !ishuman(user))
		return FINISH_ATTACK

	var/mob/living/carbon/human/H = user
	if(H.gloves)
		to_chat(user, SPAN_WARNING("Take [H.gloves] off first."))
		return FINISH_ATTACK

	to_chat(user, SPAN_NOTICE("You press your fingertips firmly against the card."))
	var/fullprint = H.get_full_print()
	evidence[fullprint] = fullprint
	name = "[initial(name)] ([H])"
	update_icon(UPDATE_ICON_STATE|UPDATE_DESC)

/obj/item/sample/print/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ishuman(target))
		return ..()

	var/mob/living/carbon/human/H = target
	if(user.zone_selected != "r_hand" && user.zone_selected != "l_hand")
		to_chat(user, SPAN_WARNING("You need to target [H]'s hands to obtain fingerprints!"))
		return ITEM_INTERACT_COMPLETE

	if(length(evidence))
		return ITEM_INTERACT_COMPLETE

	if(H.gloves)
		to_chat(user, SPAN_WARNING("[H] is wearing gloves."))
		return ITEM_INTERACT_COMPLETE

	if(user != H && H.stat == CONSCIOUS && !H.restrained())
		user.visible_message(SPAN_DANGER("[user] tried to fingerprint [H], but he resists."))
		return ITEM_INTERACT_COMPLETE

	var/has_hand = (H.has_organ("r_hand") || H.has_organ("l_hand"))
	if(!has_hand)
		to_chat(user, SPAN_WARNING("[H] has no hands!"))
		return ITEM_INTERACT_COMPLETE
	if(!do_after(user, 2 SECONDS, target = H))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(SPAN_NOTICE("[user] makes a copy of [H]'s fingerprints'."))
	var/fullprint = H.get_full_print()
	evidence[fullprint] = fullprint
	transfer_evidence(src)
	name = "[initial(name)] ([H])"
	update_icon(UPDATE_ICON_STATE|UPDATE_DESC)
	return ITEM_INTERACT_COMPLETE

/obj/item/sample/print/transfer_evidence(atom/supplied)
	if(!length(supplied.fingerprints))
		return

	for(var/print in supplied.fingerprints)
		evidence[print] = supplied.fingerprints[print]
	supplied.fingerprints.Cut()

/obj/item/sample/print/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!supplied || !length(supplied.evidence))
		return FALSE
	for(var/print in supplied.evidence)
		if(evidence[print])
			evidence[print] = stringmerge(evidence[print], supplied.evidence[print])
		else
			evidence[print] = supplied.evidence[print]
	name = "[initial(name)] (combined)"
	to_chat(user, SPAN_NOTICE("You overlay [src] and [supplied], combining the print records."))
	return TRUE

/obj/item/sample/print/report(obj/item/paper/report, obj/machinery/analyzer, report_num)
	if(!istype(analyzer, /obj/machinery/microscope))
		return ..()
	report.name = "Fingerprint Analysis Report No. [report_num]: [name]"
	report.info = "<b>Report number: [report_num]</b><br>"
	report.info += "<b>Fingerprint Analysis Report No. [report_num]</b>: [name]<br>"
	if(length(evidence))
		report.info += "<br>Surface analysis identified the following unique fingerprints:<br>"
		for(var/prints in evidence)
			report.info += SPAN_NOTICE("Fingerprint: ")
			if(stringpercent(prints) > 6) // if theres 6 or more *, then the print is unreadable
				report.info += "INCOMPLETE PRINT<br>"
			else
				report.info += "[prints]<br>"
	else
		report.info += "No analysis information available."

/obj/item/sample/fibers
	name = "fiber bag"
	desc = "Used to store fiber evidence for forensic examianation."
	icon_state = "fiberbag"

/obj/item/sample/fibers/report(obj/item/paper/report, obj/machinery/analyzer, report_num)
	if(!istype(analyzer, /obj/machinery/microscope))
		return ..()
	report.name = "Report on fiber sample no. [report_num]: [name]"
	report.info = "<b>Report number: [report_num]</b><br>"
	report.info += "<b>Analyzed object:</b><br>[name]<br><br>"
	if(evidence)
		report.info += "Molecular analysis on the provided sample determined the presence of the following unique fiber strands:<br>"
		for(var/fiber in evidence)
			report.info += SPAN_NOTICE("Most Likely Match: [fiber]<br>")
	else
		report.info += "No fibers found."


/obj/item/forensics
	icon = 'icons/obj/forensics/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE

/obj/item/forensics/sample_kit
	name = "fiber collection kit"
	desc = "A magnifying glass and pair of tweezers. Used to lift fabric fibers from crime scene objects. Use on <b>harm intent</b> to collect samples without disturbing the scene."
	icon_state = "m_glass"
	w_class = WEIGHT_CLASS_SMALL
	/// naming for individual evidence items
	var/evidence_type = "fiber"
	var/evidence_path = /obj/item/sample/fibers

/obj/item/forensics/sample_kit/proc/can_take_sample(mob/user, atom/supplied)
	return length(supplied.suit_fibers)

/obj/item/forensics/sample_kit/proc/take_sample(mob/user, atom/supplied)
	var/obj/item/sample/S = new evidence_path(get_turf(user))
	S.transfer_evidence(supplied)
	to_chat(user, SPAN_NOTICE("You move [S.evidence.len] [evidence_type]\s into [S]."))
	return S

/obj/item/forensics/sample_kit/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HARM)
		return ..()

	if(can_take_sample(user, target))
		take_sample(user, target)
	else
		to_chat(user, SPAN_WARNING("You cannot find [evidence_type]s on [target]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/forensics/sample_kit/MouseDrop(atom/over)
	if(ismob(src.loc))
		interact_with_atom(over, loc)

/obj/item/forensics/sample_kit/powder
	name = "fingerprint powder"
	desc = "A jar of aluminum powder and a specialized brush. Use on <b>harm intent</b> to collect samples without leaving additional prints."
	icon_state = "dust"
	evidence_type = "print"
	evidence_path = /obj/item/sample/print

/obj/item/forensics/sample_kit/powder/can_take_sample(mob/user, atom/supplied)
	return length(supplied.fingerprints)

/obj/item/forensics/sample_kit/powder/take_sample(mob/user, atom/supplied)
	var/obj/item/sample/print/printcard = ..()
	if(!istype(printcard))
		return
	printcard.pulled = TRUE
	printcard.update_icon(UPDATE_ICON_STATE)

/obj/item/forensics/swab
	name = "sample collection kit"
	desc = "An unused sterile cotton swab and test tube for collecting DNA samples and gunpowder residue."
	icon_state = "swab"
	/// currently in machine
	var/dispenser = FALSE

/obj/item/forensics/swab/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isstorage(target)) // Storage handling. Maybe add an intent check?
		return ..()

	add_fingerprint(user)
	in_use = TRUE
	to_chat(user, SPAN_NOTICE("You start collecting evidence..."))
	if(!do_after(user, 2 SECONDS, target = user))
		in_use = FALSE
		return ITEM_INTERACT_COMPLETE

	var/list/found_blood = list()
	// This is utterly hateful, yes, but so is blood_DNA. - Chuga
	if(issimulatedturf(target))
		for(var/obj/effect/decal/cleanable/C in target.contents)
			if(istype(C, /obj/effect/decal/cleanable/blood) || istype(C, /obj/effect/decal/cleanable/trail_holder))
				found_blood |= C.blood_DNA
	else if(isliving(target))
		var/mob/living/L = target
		found_blood |= L.get_blood_dna_list()
	else
		if(target.blood_DNA)
			found_blood |= target.blood_DNA

	var/list/choices = list()
	if(length(found_blood))
		choices |= "Blood"
	if(istype(target, /obj/item/clothing/gloves))
		choices |= "Gunpowder residue"

	if(!length(choices))
		to_chat(user, SPAN_WARNING("There is no evidence on [target]."))
		in_use = FALSE
		return ITEM_INTERACT_COMPLETE

	var/choice
	if(length(choices) == 1)
		choice = choices[1]
	else
		choice = tgui_input_list(user, "What evidence are you looking for?", "Collection of evidence", choices)

	in_use = FALSE
	if(!choice || !(choice in choices))
		return ITEM_INTERACT_COMPLETE

	var/spawn_type
	var/spawn_data
	if(choice == "Blood")
		spawn_type = /obj/item/sample/swab/dna
		spawn_data = found_blood

	else if(choice == "Gunpowder residue")
		var/obj/item/clothing/B = target
		if(!istype(B) || !B.gunshot_residue)
			to_chat(user, SPAN_WARNING("There is not a hint of gunpowder on [target]."))
			in_use = FALSE
			return ITEM_INTERACT_COMPLETE
		spawn_type = /obj/item/sample/swab/gunpowder
		spawn_data = B.gunshot_residue

	if(spawn_type)
		user.visible_message(
			SPAN_NOTICE("[user] takes a swab from [target] for analysis."),
			SPAN_NOTICE("You take a swab from [target] for analysis."))
		if(!dispenser)
			qdel(src)
		var/obj/item/sample/swab/S = new spawn_type(get_turf(user))
		S.set_used(choice, target, spawn_data)
		user.put_in_hands(S)
	return ITEM_INTERACT_COMPLETE

/obj/item/forensics/swab/cyborg
	dispenser = TRUE

/obj/item/sample/swab
	name = "sample collection kit"
	desc = ABSTRACT_TYPE_DESC
	icon_state = "swab_used"

/obj/item/sample/swab/proc/set_used(sample_str, atom/source, data)
	name = "[initial(name)] ([sample_str] - [source])"
	desc = "[initial(desc)] The label on the bottle reads: 'Sample [sample_str] - [source]'."
	evidence = data

/obj/item/sample/swab/dna
	desc = "A sterile cotton swab that was used to collect a DNA sample."

/obj/item/sample/swab/dna/report(obj/item/paper/report, obj/machinery/analyzer, report_num)
	if(!istype(analyzer, /obj/machinery/dnaforensics))
		return ..()

	report.name = ("DNA scanner report no. [report_num]: [name]")
	// dna data itself
	var/data = "No analysis data available."
	if(!isnull(evidence))
		data = "Spectrometric analysis on the provided sample determined the presence of DNA. DNA String(s) found: [length(evidence)].<br><br>"
		for(var/blood in evidence)
			data += SPAN_NOTICE("Blood type: [evidence[blood]]<br>\nDNA: [blood]<br><br>")
	else
		data += "\nNo DNA found.<br>"
	report.info = "<b>Report number: [report_num]</b><br>"
	report.info += "<b>\nAnalyzed object:</b><br>[name]<br>[desc]<br><br>" + data

/obj/item/sample/swab/gunpowder
	desc = "A sterile cotton swab that was used to collect gunpowder residue."

/obj/item/sample/swab/gunpowder/report(obj/item/paper/report, obj/machinery/analyzer, report_num)
	if(!istype(analyzer, /obj/machinery/microscope))
		return ..()

	report.name = "Forensic report no. [report_num]: [name]"
	report.info = "<b>Report number: [report_num]</b><br>"
	report.info += "<b>Analyzed object:</b><br>[name]<br><br>"

	if(evidence)
		report.info += "Gunpowder residue found. Caliber: [evidence]."
	else
		report.info += "Powder residue from the bullet was not found."
