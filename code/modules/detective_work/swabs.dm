/obj/item/clothing/clean_blood(radiation_clean = FALSE)
	. = ..()
	gunshot_residue = null

/obj/item/forensics/swab
	name = "sample collection kit"
	desc = "Sterile cotton swab and test tube for collecting samples."
	icon_state = "swab"
	///currently in machine
	var/dispenser = FALSE
	///gunshot residue data
	var/gsr = FALSE
	///DNA samble data
	var/list/dna
	///boolean, used or not
	var/used
	///limits to one sample per item
	var/inuse = FALSE

/obj/item/forensics/swab/proc/is_used()
	return used

/obj/item/forensics/swab/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	return A.attackby__legacy__attackchain(src, user, params)

/obj/item/forensics/swab/attack__legacy__attackchain(mob/living/M, mob/user)
	if(!ishuman(M))
		return ..()
	if(is_used())
		to_chat(user, "<span class='warning'>You are already taking a sample.</span>")
		return

	var/mob/living/carbon/human/H = M
	var/sample_type
	inuse = TRUE
	to_chat(user, "<span class='notice'>You start collecting samples.</span>")
	if(H.wear_mask)
		to_chat(user, "<span class='warning'>[H] is wearing a mask.</span>")
		inuse = FALSE
		return
	if(do_after(user, 2 SECONDS, target = user))

		if(!H.dna || !H.dna.unique_enzymes)
			to_chat(user, "<span class='warning'>Looks like he has no DNA!</span>")
			inuse = FALSE
			return

		if(user != H && H.a_intent != INTENT_HELP && !IS_HORIZONTAL(H))
			user.visible_message("<span class='danger'>[user] trying to take a sample from [H], but they resist.</span>")
			inuse = FALSE
			return
		var/target_dna
		var/target_gsr
		if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
			if(!H.has_organ("head"))
				to_chat(user, "<span class='warning'>[H] has no head.</span>")
				inuse = FALSE
				return
			if(!H.check_has_mouth())
				to_chat(user, "<span class='warning'>[H] has no mouth.</span>")
				inuse = FALSE
				return
			user.visible_message("<span class='notice'>[user] swabs [H]'s mouth with \a [name].</span>")
			target_dna = list(H.dna.unique_enzymes)
			sample_type = "DNA"

		else if(user.zone_selected == "r_hand" || user.zone_selected == "l_hand")
			var/has_hand
			var/obj/item/organ/external/O = H.has_organ("r_hand")
			if(istype(O))
				has_hand = TRUE
			else
				O = H.has_organ("l_hand")
				if(istype(O))
					has_hand = TRUE
			if(!has_hand)
				to_chat(user, "<span class='warning'>[H] is missing that arm!</span>")
				inuse = FALSE
				return
			user.visible_message("<span class='notice'>[user] takes a swab from the palm of [H] for analysis.</span>")
			sample_type = "GSR"
			target_gsr = H.gunshot_residue
		else
			inuse = FALSE
			return

		if(sample_type)
			if(!dispenser)
				dna = target_dna
				gsr = target_gsr
				set_used(sample_type, H)
			else
				var/obj/item/forensics/swab/S = new(get_turf(user))
				S.dna = target_dna
				S.gsr = target_gsr
				S.set_used(sample_type, H)
			inuse = FALSE
			return
		inuse = FALSE
		return TRUE

/obj/item/forensics/swab/afterattack__legacy__attackchain(atom/A, mob/user, proximity)

	if(istype(A, /obj/machinery/dnaforensics))
		return

	if(is_used())
		to_chat(user, "<span class='warning'>This sample kit is already used</span>")
		return

	add_fingerprint(user)
	inuse = TRUE
	to_chat(user, "<span class='notice'>You start collecting evidence.</span>")
	if(do_after(user, 2 SECONDS, target = user))
		var/list/choices = list()
		var/list/found_blood = list()
		if(issimulatedturf(A))
			for(var/obj/effect/decal/cleanable/C in A.contents)
				if(istype(C, /obj/effect/decal/cleanable/blood) || istype(C, /obj/effect/decal/cleanable/trail_holder))
					found_blood |= C.blood_DNA
		else if(isliving(A))
			found_blood |= astype(A, /mob/living).get_blood_dna_list()
		else
			if(A.blood_DNA)
				found_blood |= A.blood_DNA

		if(length(found_blood))
			choices |= "Blood"
		if(istype(A, /obj/item/clothing/gloves))
			choices |= "Gunpowder particles"

		var/choice
		if(!length(choices))
			to_chat(user, "<span class='warning'>There is no evidence on [A].</span>")
			inuse = FALSE
			return
		else if(length(choices) == 1)
			choice = choices[1]
		else
			choice = tgui_input_list(user, "What evidence are you looking for?", "Collection of evidence", choices)

		if(!choice)
			inuse = FALSE
			return

		var/sample_type
		var/target_dna
		var/target_gsr
		if(choice == "Blood")
			target_dna = found_blood
			sample_type = "blood"

		else if(choice == "gunpowder particles")
			var/obj/item/clothing/B = A
			if(!istype(B) || !B.gunshot_residue)
				to_chat(user, "<span class='warning'>There is not a hint of gunpowder on [A].</span>")
				inuse = FALSE
				return
			target_gsr = B.gunshot_residue
			sample_type = "powder"

		if(sample_type)
			user.visible_message(
				"<span class='notice'>[user] takes a swab from [A] for analysis.</span>",
				"<span class='notice'>You take a swab from [A] for analysis.</span>")
			if(!dispenser)
				dna = target_dna
				gsr = target_gsr
				set_used(sample_type, A)
			else
				var/obj/item/forensics/swab/S = new(get_turf(user))
				S.dna = target_dna
				S.gsr = target_gsr
				S.set_used(sample_type, A)
		inuse = FALSE

/obj/item/forensics/swab/proc/set_used(sample_str, atom/source)
	name = ("[initial(name)] ([sample_str] - [source])")
	desc = "[initial(desc)] /The label on the bottle reads: 'Sample [sample_str] с [source].'."
	icon_state = "swab_used"
	used = TRUE

/obj/item/forensics/swab/cyborg
	dispenser = TRUE
