//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY

/obj/item/evidencebag/afterattack(obj/item/I, mob/user,proximity)
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/evidencebag/attackby(obj/item/I, mob/user, params)
	if(evidencebagEquip(I, user))
		return 1

/obj/item/evidencebag/proc/evidencebagEquip(obj/item/I, mob/user)
	if(!istype(I) || I.anchored)
		return

	if(istype(I, /obj/item/storage/box))
		to_chat(user, "<span class='notice'>This box is too big to fit in the evidence bag.</span>")
		return

	if(istype(I, /obj/item/evidencebag))
		to_chat(user, "<span class='notice'>You find putting an evidence bag in another evidence bag to be slightly absurd.</span>")
		return 1 //now this is podracing

	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
		return

	if(length(contents))
		to_chat(user, "<span class='notice'>[src] already has something inside it.</span>")
		return

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(isstorage(I.loc))	//in a container.
			var/obj/item/storage/U = I.loc
			U.remove_from_storage(I, src)
		else if(!user.is_holding(I) || !user.unEquip(I))					//in a hand
			return

	user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>", "<span class='notice'>You put [I] inside [src].</span>",\
	"<span class='notice'>You hear a rustle as someone puts something into a plastic bag.</span>")

	icon_state = "evidence"

	var/xx = I.pixel_x	//save the offset of the item
	var/yy = I.pixel_y
	I.pixel_x = 0		//then remove it so it'll stay within the evidence bag
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	img.plane = FLOAT_PLANE
	I.pixel_x = xx		//and then return it
	I.pixel_y = yy
	overlays += img
	overlays += "evidence"	//should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [I]. [I.desc]"
	I.loc = src
	w_class = I.w_class
	return 1

/obj/item/evidencebag/attack_self(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message("<span class='notice'>[user] takes [I] out of [src].</span>", "<span class='notice'>You take [I] out of [src].</span>",\
		"<span class='notice'>You hear someone rustle around in a plastic bag, and remove something.</span>")
		overlays.Cut()	//remove the overlays
		user.put_in_hands(I)
		I.pickup(user)
		w_class = WEIGHT_CLASS_TINY
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"

/obj/item/forensics
	icon = 'icons/obj/forensics/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/sample
	name = "\improper Forensic sample"
	icon = 'icons/obj/forensics/forensics.dmi'
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
	to_chat(user, "<span class='notice'>You are moving \the [supplied] to \the [src].</span>")
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
	to_chat(user, "<span class='notice'>You overlay \the [src] and \the [supplied], combining the print records.</span>")
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
	name = "\improper fiber bag"
	desc = "Used to store fiber evidence for forensic examination."
	icon_state = "fiberbag"

/obj/item/sample/print
	name = "\improper fingerprint card"
	desc = "Preserves fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	item_state = "paper"

/obj/item/sample/print/attack_self(mob/user)
	if(evidence && evidence.len)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.gloves)
		to_chat(user, "<span class='warning'>Take [H.gloves] off first.</span>")
		return

	to_chat(user, "<span class='notice'>You press your fingertips firmly against the card.</span>")
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
		to_chat(user, "<span class='warning'>[H] is wearing gloves.</span>")
		return TRUE

	if(user != H && H.a_intent != INTENT_HELP && !IS_HORIZONTAL(H))
		user.visible_message("<span class='danger'>[user] tried to fingerprint [H], but he resists.</span>")
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
			to_chat(user, "<span class='warning'>But [H] has no hands.</span>")
			return FALSE
		if(!do_after(user, 2 SECONDS, target = user))
			return FALSE

		user.visible_message("<span class='notice'>[user] makes a copy of [H]'s fingerprints'.</span>")
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
	name = "\improper fiber collection kit"
	desc = "Magnifying glass and tweezers. Used to lift fabric fibers."
	icon_state = "m_glass"
	w_class = WEIGHT_CLASS_SMALL
	var/evidence_type = "fibers"
	var/evidence_path = /obj/item/sample/fibers

/obj/item/forensics/sample_kit/proc/can_take_sample(mob/user, atom/supplied)
	return (supplied.suit_fibers && supplied.suit_fibers.len)

/obj/item/forensics/sample_kit/proc/take_sample(mob/user, atom/supplied)
	var/obj/item/sample/S = new evidence_path(get_turf(user), supplied)
	to_chat(user, "<span class='notice'>You move [S.evidence.len] [S.evidence.len > 1 ? "[evidence_type]" : "[evidence_type]"] в \the [S].</span>")

/obj/item/forensics/sample_kit/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(can_take_sample(user, A))
		take_sample(user,A)
		. = TRUE
	else
		to_chat(user, "<span class='warning'>You cannot find [evidence_type] on [A].</span>")
		. = ..()

/obj/item/forensics/sample_kit/MouseDrop(atom/over)
	if(ismob(src.loc))
		afterattack(over, usr, TRUE)

/obj/item/forensics/sample_kit/powder
	name = "\improper Fingerprint Powder"
	desc = "A jar of aluminum powder and a specialized brush."
	icon_state = "dust"
	evidence_type = "prints"
	evidence_path = /obj/item/sample/print

/obj/item/forensics/sample_kit/powder/can_take_sample(mob/user, atom/supplied)
	return (supplied.fingerprints && supplied.fingerprints.len)
