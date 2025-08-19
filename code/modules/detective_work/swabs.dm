/obj/item/forensics/swab
	name = "sample collection kit"
	desc = "A sterile cotton swab and test tube for collecting samples."
	icon_state = "swab"
	/// currently in machine
	var/dispenser = FALSE
	/// gunshot residue data
	var/gsr = FALSE
	/// DNA sample data
	var/list/dna
	/// boolean, used or not
	var/used

/obj/item/forensics/swab/proc/is_used()
	return used

/obj/item/forensics/swab/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isstorage(target)) // Storage handling. Maybe add an intent check?
		return ..()

	if(is_used())
		to_chat(user, "<span class='warning'>This sample kit is already used.</span>")
		return ITEM_INTERACT_COMPLETE

	add_fingerprint(user)
	in_use = TRUE
	to_chat(user, "<span class='notice'>You start collecting evidence...</span>")
	if(do_after(user, 2 SECONDS, target = user))
		var/list/choices = list()
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

		if(length(found_blood))
			choices |= "Blood"
		if(istype(target, /obj/item/clothing/gloves))
			choices |= "Gunpowder particles"

		var/choice
		if(!length(choices))
			to_chat(user, "<span class='warning'>There is no evidence on [target].</span>")
			in_use = FALSE
			return ITEM_INTERACT_COMPLETE
		else if(length(choices) == 1)
			choice = choices[1]
		else
			choice = tgui_input_list(user, "What evidence are you looking for?", "Collection of evidence", choices)

		if(!choice)
			in_use = FALSE
			return ITEM_INTERACT_COMPLETE

		var/sample_type
		var/target_dna
		var/target_gsr
		if(choice == "Blood")
			target_dna = found_blood
			sample_type = "blood"

		else if(choice == "Gunpowder particles")
			var/obj/item/clothing/B = target
			if(!istype(B) || !B.gunshot_residue)
				to_chat(user, "<span class='warning'>There is not a hint of gunpowder on [target].</span>")
				in_use = FALSE
				return ITEM_INTERACT_COMPLETE
			target_gsr = B.gunshot_residue
			sample_type = "powder"

		if(sample_type)
			user.visible_message(
				"<span class='notice'>[user] takes a swab from [target] for analysis.</span>",
				"<span class='notice'>You take a swab from [target] for analysis.</span>")
			if(!dispenser)
				dna = target_dna
				gsr = target_gsr
				set_used(sample_type, target)
			else
				var/obj/item/forensics/swab/S = new(get_turf(user))
				S.dna = target_dna
				S.gsr = target_gsr
				S.set_used(sample_type, target)
	in_use = FALSE
	return ITEM_INTERACT_COMPLETE

/obj/item/forensics/swab/proc/set_used(sample_str, atom/source)
	name = "[initial(name)] ([sample_str] - [source])"
	desc = "[initial(desc)] The label on the bottle reads: 'Sample [sample_str] - [source].'."
	icon_state = "swab_used"
	used = TRUE

/obj/item/forensics/swab/cyborg
	dispenser = TRUE
