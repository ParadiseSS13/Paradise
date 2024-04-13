/mob
	var/gunshot_residue

/obj/item/clothing
	var/gunshot_residue

/obj/item/clothing/clean_blood(radiation_clean = FALSE)
	. = ..()
	gunshot_residue = null

/obj/item/forensics/swab
	name = "\improper набор для взятия образцов"
	desc = "Стерильная ватная палочка и пробирка, для взятия образцов."
	icon_state = "swab"
	var/dispenser = FALSE
	var/gsr = FALSE
	var/list/dna
	var/used
	var/inuse = FALSE

/obj/item/forensics/swab/proc/is_used()
	return used

/obj/item/forensics/swab/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return ..()
	if(is_used())
		to_chat(user, span_warning("Вы уже берёте образец."))
		return

	var/mob/living/carbon/human/H = M
	var/sample_type
	inuse = TRUE
	to_chat(user, span_notice("Вы начинаете собирать образцы."))
	if(do_after(user, 2 SECONDS, target = user))
		if(H.wear_mask)
			to_chat(user, span_warning("[H] носит маску."))
			inuse = FALSE
			return

		if(!H.dna || !H.dna.unique_enzymes)
			to_chat(user, span_warning("Похоже у него нет ДНК!"))
			inuse = FALSE
			return

		if(user != H && H.a_intent != INTENT_HELP && !IS_HORIZONTAL(H))
			user.visible_message(span_danger("[user] пытается взять образец у [H], но он сопротивляется."))
			inuse = FALSE
			return
		var/target_dna
		var/target_gsr
		if(user.zone_selected == "mouth")
			if(!H.has_organ("head"))
				to_chat(user, span_warning("У него нет головы."))
				inuse = FALSE
				return
			if(!H.check_has_mouth())
				to_chat(user, span_warning("У него нет рта."))
				inuse = FALSE
				return
			user.visible_message(span_notice("[user] берёт мазок изо рта [H] для анализа."))
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
				to_chat(user, span_warning("Он безрукий."))
				inuse = FALSE
				return
			user.visible_message(span_notice("[user] берёт мазок с ладони [H] для анализа."))
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

/obj/item/forensics/swab/afterattack(atom/A, mob/user, proximity)

	if(!proximity || istype(A, /obj/machinery/dnaforensics))
		return

	if(istype(A,/mob/living))
		return

	if(is_used())
		to_chat(user, span_warning("Этот образец уже используется."))
		return

	add_fingerprint(user)
	inuse = TRUE
	to_chat(user, span_notice("Вы начинаете собирать улики."))
	if(do_after(user, 2 SECONDS, target = user))
		var/list/choices = list()
		if(A.blood_DNA)
			choices |= "Кровь"
		if(istype(A, /obj/item/clothing))
			choices |= "Частицы пороха"

		var/choice
		if(!choices.len)
			to_chat(user, span_warning("На [A] нет улик."))
			inuse = FALSE
			return
		else if(choices.len == 1)
			choice = choices[1]
		else
			choice = tgui_input_list(user, "Какие доказательства вы ищете?", "Сбор доказательств", choices)

		if(!choice)
			inuse = FALSE
			return

		var/sample_type
		var/target_dna
		var/target_gsr
		if(choice == "Кровь")
			if(!A.blood_DNA || !A.blood_DNA.len)
				inuse = FALSE
				return
			target_dna = A.blood_DNA.Copy()
			sample_type = "крови"

		else if(choice == "Частицы пороха")
			var/obj/item/clothing/B = A
			if(!istype(B) || !B.gunshot_residue)
				to_chat(user, span_warning("На [A] нет ни намёка на порох."))
				inuse = FALSE
				return
			target_gsr = B.gunshot_residue
			sample_type = "порох"

		if(sample_type)
			user.visible_message(
				span_notice("[user] берёт мазок с [A] для анализа."),
				span_notice("Вы берёте мазок с [A] для анализа."))
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
	desc = "[initial(desc)] /Этикетка на флаконе гласит: 'Образец [sample_str] с [source].'."
	icon_state = "swab_used"
	used = TRUE

/obj/item/forensics/swab/cyborg
	dispenser = TRUE
