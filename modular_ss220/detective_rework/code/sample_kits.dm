/obj/item/forensics
	icon = 'modular_ss220/detective_rework/icons/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/sample
	name = "\improper образец для анализа"
	icon = 'modular_ss220/detective_rework/icons/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/evidence = list()

/obj/item/sample/New(newloc, atom/supplied)
	..(newloc)
	if(supplied)
		copy_evidence(supplied)
		name = "[initial(name)] (\the [supplied])"

/obj/item/sample/print/New(newloc, atom/supplied)
	..(newloc, supplied)
	if(evidence && evidence.len)
		icon_state = "fingerprint1"

/obj/item/sample/proc/copy_evidence(atom/supplied)
	if(supplied.suit_fibers && supplied.suit_fibers.len)
		evidence = supplied.suit_fibers.Copy()
		supplied.suit_fibers.Cut()

/obj/item/sample/proc/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!supplied.evidence || !supplied.evidence.len)
		return FALSE
	evidence |= supplied.evidence
	name = ("[initial(name)] (combined)")
	to_chat(user, span_notice("Вы перемещаете содержимое \the [supplied] в \the [src]."))
	return TRUE

/obj/item/sample/print/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!supplied.evidence || !supplied.evidence.len)
		return FALSE
	for(var/print in supplied.evidence)
		if(evidence[print])
			evidence[print] = stringmerge(evidence[print],supplied.evidence[print])
		else
			evidence[print] = supplied.evidence[print]
	name = ("[initial(name)] (combined)")
	to_chat(user, span_notice("You overlay \the [src] and \the [supplied], combining the print records."))
	return TRUE

/obj/item/sample/pre_attack(atom/A, mob/living/user, params)
	// Fingerprints will be handled in after_attack() to not mess up the samples taken
	return A.attackby(src, user, params)

/obj/item/sample/attackby(obj/O, mob/user)
	if(O.type == src.type)
		user.unEquip(O)
		if(merge_evidence(O, user))
			qdel(O)
		return TRUE
	return ..()

/obj/item/sample/fibers
	name = "\improper пакетик для волокн"
	desc = "Используется для хранения волоконных доказательств для детектива."
	icon_state = "fiberbag"

/obj/item/sample/print
	name = "\improper дактилоскопическая карта"
	desc = "Сохраняет отпечатки пальцев."
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "fingerprint0"
	item_state = "paper"

/obj/item/sample/print/attack_self(mob/user)
	if(evidence && evidence.len)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.gloves)
		to_chat(user, span_warning("Take [H.gloves] off first."))
		return

	to_chat(user, span_notice("Вы плотно прижимаете кончики своих пальцев к карте."))
	var/fullprint = H.get_full_print()
	evidence[fullprint] = fullprint
	name = ("[initial(name)] ([H])")
	icon_state = "fingerprint1"

/obj/item/sample/print/attack(mob/living/M, mob/user)

	if(!ishuman(M))
		return ..()

	if(evidence && evidence.len)
		return FALSE

	var/mob/living/carbon/human/H = M

	if(H.gloves)
		to_chat(user, span_warning("У [H] надеты перчатки."))
		return TRUE

	if(user != H && H.a_intent != INTENT_HELP && !IS_HORIZONTAL(H))
		user.visible_message(span_danger("[user] пытался снять отпечатки у [H], но он сопротивляется."))
		return TRUE

	if(user.zone_selected == "r_hand" || user.zone_selected == "l_hand")
		var/has_hand
		var/obj/item/organ/external/O = H.has_organ("r_hand")
		if(istype(O))
			has_hand = TRUE
		else
			O = H.has_organ("l_hand")
			if(istype(O))
				has_hand = TRUE
		if(!has_hand)
			to_chat(user, span_warning("А рук то у него нет."))
			return FALSE
		if(!do_after(user, 2 SECONDS, target = user))
			return FALSE

		user.visible_message(span_notice("[user] делает копию отмечатков [H]."))
		var/fullprint = H.get_full_print()
		evidence[fullprint] = fullprint
		copy_evidence(src)
		name = ("[initial(name)] (\the [H])")
		icon_state = "fingerprint1"
		return TRUE
	return FALSE

/obj/item/sample/print/copy_evidence(atom/supplied)
	if(supplied.fingerprints && supplied.fingerprints.len)
		for(var/print in supplied.fingerprints)
			evidence[print] = supplied.fingerprints[print]
		supplied.fingerprints.Cut()

/obj/item/forensics

/obj/item/forensics/sample_kit
	name = "\improper набор для сбора волокон"
	desc = "Увеличительное стекло и пинцет. Используется для поднятия волокон ткани."
	icon_state = "m_glass"
	w_class = WEIGHT_CLASS_SMALL
	var/evidence_type = "волокон"
	var/evidence_path = /obj/item/sample/fibers

/obj/item/forensics/sample_kit/proc/can_take_sample(mob/user, atom/supplied)
	return (supplied.suit_fibers && supplied.suit_fibers.len)

/obj/item/forensics/sample_kit/proc/take_sample(mob/user, atom/supplied)
	var/obj/item/sample/S = new evidence_path(get_turf(user), supplied)
	to_chat(user, span_notice("Вы перемещаете [S.evidence.len] [S.evidence.len > 1 ? "[evidence_type]" : "[evidence_type]"] в \the [S]."))

/obj/item/forensics/sample_kit/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(can_take_sample(user, A))
		take_sample(user,A)
		. = TRUE
	else
		to_chat(user, span_warning("Вы не можете найти [evidence_type] на [A]."))
		. = ..()

/obj/item/forensics/sample_kit/MouseDrop(atom/over)
	if(ismob(src.loc))
		afterattack(over, usr, TRUE)

/obj/item/forensics/sample_kit/powder
	name = "\improper дактилоскопический порошок"
	desc = "Баночка с алюминиевой пудрой и специализированная кисточка."
	icon_state = "dust"
	evidence_type = "отпечатки"
	evidence_path = /obj/item/sample/print

/obj/item/forensics/sample_kit/powder/can_take_sample(mob/user, atom/supplied)
	return (supplied.fingerprints && supplied.fingerprints.len)
