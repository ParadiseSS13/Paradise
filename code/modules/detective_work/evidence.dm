//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	w_class = WEIGHT_CLASS_TINY

/obj/item/evidencebag/afterattack__legacy__attackchain(obj/item/I, mob/user,proximity)
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/evidencebag/attackby__legacy__attackchain(obj/item/I, mob/user, params)
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
		else if(!user.is_holding(I) || !user.unequip(I))					//in a hand
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

/obj/item/evidencebag/attack_self__legacy__attackchain(mob/user)
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

/obj/item/sample
	name = "\improper Forensic sample"
	icon = 'icons/obj/forensics/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/evidence = list()
	new_attack_chain = TRUE

/obj/item/sample/Initialize(mapload, atom/supplied)
	. = ..()
	if(supplied)
		transfer_evidence(supplied)
		name = "[initial(name)] ([supplied])"

/obj/item/sample/print/New(newloc, atom/supplied)
	. = ..()
	if(length(evidence))
		icon_state = "fingerprint1"

/obj/item/sample/proc/transfer_evidence(atom/supplied)
	if(length(supplied.suit_fibers))
		evidence = supplied.suit_fibers.Copy()
		supplied.suit_fibers.Cut()

/obj/item/sample/proc/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!length(supplied.evidence))
		return FALSE
	evidence |= supplied.evidence
	name = "[initial(name)] (combined)"
	to_chat(user, "<span class='notice'>You add [supplied] to [src].</span>")
	return TRUE

/obj/item/sample/print/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!supplied || !length(supplied.evidence))
		return FALSE
	for(var/print in supplied.evidence)
		if(evidence[print])
			evidence[print] = stringmerge(evidence[print], supplied.evidence[print])
		else
			evidence[print] = supplied.evidence[print]
	name = "[initial(name)] (combined)"
	to_chat(user, "<span class='notice'>You overlay [src] and [supplied], combining the print records.</span>")
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
	desc = "Preserves fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	inhand_icon_state = "paper"
	/// boolean variable, indicates if print card is in the used state
	var/used

/obj/item/sample/print/update_icon_state()
	. = ..()
	icon_state = "fingerprint0"
	if(used)
		icon_state = "fingerprint1"


/obj/item/sample/print/activate_self(mob/user)
	if(..() || length(evidence) || !ishuman(user))
		return FINISH_ATTACK

	var/mob/living/carbon/human/H = user
	if(H.gloves)
		to_chat(user, "<span class='warning'>Take [H.gloves] off first.</span>")
		return FINISH_ATTACK

	to_chat(user, "<span class='notice'>You press your fingertips firmly against the card.</span>")
	var/fullprint = H.get_full_print()
	evidence[fullprint] = fullprint
	name = "[initial(name)] ([H])"
	used = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/sample/print/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/mob/living/carbon/human/H = target
	if(user.zone_selected == "r_hand" || user.zone_selected == "l_hand")

		if(!ishuman(target))
			return ..()

		if(length(evidence))
			return ITEM_INTERACT_COMPLETE

		if(H.gloves)
			to_chat(user, "<span class='warning'>[H] is wearing gloves.</span>")
			return ITEM_INTERACT_COMPLETE

		if(user != H && H.stat == CONSCIOUS && !H.restrained())
			user.visible_message("<span class='danger'>[user] tried to fingerprint [H], but he resists.</span>")
			return ITEM_INTERACT_COMPLETE

		var/has_hand = (H.has_organ("r_hand") || H.has_organ("l_hand"))
		if(!has_hand)
			to_chat(user, "<span class='warning'>[H] has no hands!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!do_after(user, 2 SECONDS, target = H))
			return ITEM_INTERACT_COMPLETE

		user.visible_message("<span class='notice'>[user] makes a copy of [H]'s fingerprints'.</span>")
		var/fullprint = H.get_full_print()
		evidence[fullprint] = fullprint
		transfer_evidence(src)
		name = "[initial(name)] ([H])"
		used = TRUE
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE
	else
		to_chat(user, "<span class='warning'>You need to target [H]'s hands to obtain fingerprints!'.</span>")
		return ITEM_INTERACT_COMPLETE

/obj/item/sample/print/transfer_evidence(atom/supplied)
	if(length(supplied.fingerprints))
		for(var/print in supplied.fingerprints)
			evidence[print] = supplied.fingerprints[print]
		supplied.fingerprints.Cut()

/obj/item/sample/fibers
	name = "fiber bag"
	desc = "Used to store fiber evidence for forensic examianation."
	icon_state = "fiberbag"

/obj/item/forensics
	icon = 'icons/obj/forensics/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE

/obj/item/forensics/sample_kit
	name = "fiber collection kit"
	desc = "A magnifying glass and pair of tweezers. Used to lift fabric fibers from crime scene objects. Use on harm intent to collect samples without disturbing the scene."
	icon_state = "m_glass"
	w_class = WEIGHT_CLASS_SMALL
	/// naming for individual evidence items
	var/evidence_type = "fibers"
	var/evidence_path = /obj/item/sample/fibers
/obj/item/forensics/sample_kit/proc/can_take_sample(mob/user, atom/supplied)
	return length(supplied.suit_fibers)

/obj/item/forensics/sample_kit/proc/take_sample(mob/user, atom/supplied)
	var/obj/item/sample/S = new evidence_path(get_turf(user))
	S.transfer_evidence(supplied)
	to_chat(user, "<span class='notice'>You move [S.evidence.len] [S.evidence.len > 1 ? "[evidence_type]s" : "[evidence_type]"] into [S].</span>")

/obj/item/forensics/sample_kit/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HARM)
		return ..()

	if(can_take_sample(user, target))
		take_sample(user, target)
	else
		to_chat(user, "<span class='warning'>You cannot find [evidence_type] on [target].</span>")
	return ITEM_INTERACT_COMPLETE

/obj/item/forensics/sample_kit/MouseDrop(atom/over)
	if(ismob(src.loc))
		interact_with_atom(over, loc)

/obj/item/forensics/sample_kit/powder
	name = "fingerprint powder"
	desc = "A jar of aluminum powder and a specialized brush. Use on harm intent to collect samples without leaving additional prints."
	icon_state = "dust"
	evidence_type = "prints"
	evidence_path = /obj/item/sample/print

/obj/item/forensics/sample_kit/powder/can_take_sample(mob/user, atom/supplied)
	return length(supplied.fingerprints)
