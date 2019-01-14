/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	var/obj/item/I = get_active_hand()
	if(I)
		I.equip_to_best_slot(src)

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if(del_on_fail)
		qdel(W)
	return null

/mob/living/carbon/human/proc/is_in_hands(var/typepath)
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return 0


/mob/living/carbon/human/proc/has_organ(name)
	var/obj/item/organ/external/O = bodyparts_by_name[name]
	return O

/mob/living/carbon/human/proc/has_organ_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_organ("chest")
		if(slot_wear_mask)
			return has_organ("head")
		if(slot_handcuffed)
			return has_organ("l_hand") && has_organ("r_hand")
		if(slot_legcuffed)
			return has_organ("l_leg") && has_organ("r_leg")
		if(slot_l_hand)
			return has_organ("l_hand")
		if(slot_r_hand)
			return has_organ("r_hand")
		if(slot_belt)
			return has_organ("chest")
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return 1
		if(slot_wear_pda)
			return 1
		if(slot_l_ear)
			return has_organ("head")
		if(slot_r_ear)
			return has_organ("head")
		if(slot_glasses)
			return has_organ("head")
		if(slot_gloves)
			return has_organ("l_hand") && has_organ("r_hand")
		if(slot_head)
			return has_organ("head")
		if(slot_shoes)
			return has_organ("r_foot") && has_organ("l_foot")
		if(slot_wear_suit)
			return has_organ("chest")
		if(slot_w_uniform)
			return has_organ("chest")
		if(slot_l_store)
			return has_organ("chest")
		if(slot_r_store)
			return has_organ("chest")
		if(slot_s_store)
			return has_organ("chest")
		if(slot_in_backpack)
			return 1
		if(slot_tie)
			return 1

// The actual dropping happens at the mob level - checks to prevent drops should
// come here
/mob/living/carbon/human/canUnEquip(obj/item/I, force)
	. = ..()
	var/obj/item/organ/O = I
	if(istype(O) && O.owner == src)
		. = 0 // keep a good grip on your heart

/mob/living/carbon/human/unEquip(obj/item/I)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return

	if(I == wear_suit)
		if(s_store)
			unEquip(s_store, 1) //It makes no sense for your suit storage to stay on you if you drop your suit.
		wear_suit = null
		if(I.flags_inv & HIDEJUMPSUIT)
			update_inv_w_uniform()
		update_inv_wear_suit()
	else if(I == w_uniform)
		if(r_store)
			unEquip(r_store, 1) //Again, makes sense for pockets to drop.
		if(l_store)
			unEquip(l_store, 1)
		if(wear_id)
			unEquip(wear_id)
		if(belt)
			unEquip(belt)
		w_uniform = null
		update_inv_w_uniform()
	else if(I == gloves)
		gloves = null
		update_inv_gloves()
	else if(I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		if(G.tint)
			update_tint()
		if(G.prescription)
			update_nearsighted_effects()
		if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view)
			update_sight()
		update_inv_glasses()
		update_client_colour()
	else if(I == head)
		head = null
		if(I.flags & BLOCKHAIR || I.flags & BLOCKHEADHAIR)
			update_hair()	//rebuild hair
			update_fhair()
			update_head_accessory()
		// Bandanas and paper hats go on the head but are not head clothing
		if(istype(I,/obj/item/clothing/head))
			var/obj/item/clothing/head/hat = I
			if(hat.vision_flags || hat.darkness_view || hat.helmet_goggles_invis_view)
				update_sight()
		head_update(I)
		update_inv_head()
	else if(I == r_ear)
		r_ear = null
		update_inv_ears()
	else if(I == l_ear)
		l_ear = null
		update_inv_ears()
	else if(I == shoes)
		shoes = null
		update_inv_shoes()
	else if(I == belt)
		belt = null
		update_inv_belt()
	else if(I == wear_mask)
		wear_mask = null
		if(I.flags & BLOCKHAIR || I.flags & BLOCKHEADHAIR)
			update_hair()	//rebuild hair
			update_fhair()
			update_head_accessory()
		if(internal && !get_organ_slot("breathing_tube"))
			internal = null
			update_action_buttons_icon()
		wear_mask_update(I, toggle_off = FALSE)
		sec_hud_set_ID()
		update_inv_wear_mask()
	else if(I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		update_inv_wear_id()
	else if(I == wear_pda)
		wear_pda = null
		update_inv_wear_pda()
	else if(I == r_store)
		r_store = null
		update_inv_pockets()
	else if(I == l_store)
		l_store = null
		update_inv_pockets()
	else if(I == s_store)
		s_store = null
		update_inv_s_store()
	else if(I == back)
		back = null
		update_inv_back()
	else if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()




//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return
	if(!has_organ_for_slot(slot)) return

	if(W == src.l_hand)
		src.l_hand = null
		update_inv_l_hand() //So items actually disappear from hands.
	else if(W == src.r_hand)
		src.r_hand = null
		update_inv_r_hand()

	W.screen_loc = null
	W.loc = src
	W.equipped(src, slot)
	W.layer = 20
	W.plane = HUD_PLANE

	switch(slot)
		if(slot_back)
			back = W
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			wear_mask = W
			if((wear_mask.flags & BLOCKHAIR) || (wear_mask.flags & BLOCKHEADHAIR))
				update_hair(redraw_mob)	//rebuild hair
				update_fhair(redraw_mob)
				update_head_accessory(redraw_mob)
			if(hud_list.len)
				sec_hud_set_ID()
			wear_mask_update(W, toggle_off = TRUE)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			legcuffed = W
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			l_hand = W
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			r_hand = W
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			belt = W
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			wear_id = W
			if(hud_list.len)
				sec_hud_set_ID()
			update_inv_wear_id(redraw_mob)
		if(slot_wear_pda)
			wear_pda = W
			update_inv_wear_pda(redraw_mob)
		if(slot_l_ear)
			l_ear = W
			if(l_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				r_ear = O
				O.layer = 20
				O.plane = HUD_PLANE
			update_inv_ears(redraw_mob)
		if(slot_r_ear)
			r_ear = W
			if(r_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				l_ear = O
				O.layer = 20
				O.plane = HUD_PLANE
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			glasses = W
			var/obj/item/clothing/glasses/G = W
			if(G.tint)
				update_tint()
			if(G.prescription)
				update_nearsighted_effects()
			if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view)
				update_sight()
			update_inv_glasses(redraw_mob)
			update_client_colour()
		if(slot_gloves)
			gloves = W
			update_inv_gloves(redraw_mob)
		if(slot_head)
			head = W
			if((head.flags & BLOCKHAIR) || (head.flags & BLOCKHEADHAIR))
				update_hair(redraw_mob)	//rebuild hair
				update_fhair(redraw_mob)
				update_head_accessory(redraw_mob)
			// paper + bandanas
			if(istype(W, /obj/item/clothing/head))
				var/obj/item/clothing/head/hat = W
				if(hat.vision_flags || hat.darkness_view || hat.helmet_goggles_invis_view)
					update_sight()
			head_update(W)
			update_inv_head(redraw_mob)
		if(slot_shoes)
			shoes = W
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			wear_suit = W
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			w_uniform = W
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			l_store = W
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			r_store = W
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			s_store = W
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(get_active_hand() == W)
				unEquip(W)
			W.loc = back
		if(slot_tie)
			var/obj/item/clothing/under/uniform = src.w_uniform
			uniform.attackby(W,src)
		else
			to_chat(src, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")
			return

/mob/living/carbon/human/put_in_hands(obj/item/W)
	if(!W)		return 0
	if(put_in_active_hand(W))			return 1
	else if(put_in_inactive_hand(W))	return 1
	else
		. = ..()

// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_belt)
			return belt
		if(slot_wear_id)
			return wear_id
		if(slot_wear_pda)
			return wear_pda
		if(slot_l_ear)
			return l_ear
		if(slot_r_ear)
			return r_ear
		if(slot_glasses)
			return glasses
		if(slot_gloves)
			return gloves
		if(slot_head)
			return head
		if(slot_shoes)
			return shoes
		if(slot_wear_suit)
			return wear_suit
		if(slot_w_uniform)
			return w_uniform
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_s_store)
			return s_store
	return null

/mob/living/carbon/human/get_all_slots()
	. = get_head_slots() | get_body_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
		l_hand,
		r_hand,
		back,
		s_store,
		handcuffed,
		legcuffed,
		wear_suit,
		gloves,
		shoes,
		belt,
		wear_id,
		wear_pda,
		l_store,
		r_store,
		w_uniform
		)

/mob/living/carbon/human/proc/get_head_slots()
	return list(
		head,
		wear_mask,
		glasses,
		r_ear,
		l_ear,
		)

// humans have their pickpocket gloves, so they get no message when stealing things
/mob/living/carbon/human/stripPanelUnequip(obj/item/what, mob/who, where)
	var/is_silent = 0
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		is_silent = G.pickpocket

	..(what, who, where, silent = is_silent)

// humans have their pickpocket gloves, so they get no message when stealing things
/mob/living/carbon/human/stripPanelEquip(obj/item/what, mob/who, where)
	var/is_silent = 0
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		is_silent = G.pickpocket

	..(what, who, where, silent = is_silent)

/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = 0)
	switch(dna.species.handle_can_equip(I, slot, disable_warning, src))
		if(1)	return 1
		if(2)	return 0 //if it returns 2, it wants no normal handling

	if(istype(I, /obj/item/clothing/under) || istype(I, /obj/item/clothing/suit))
		if(FAT in mutations)
			//testing("[M] TOO FAT TO WEAR [src]!")
			if(!(I.flags_size & ONESIZEFITSALL))
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You're too fat to wear the [I].</span>")
				return 0

	switch(slot)
		if(slot_l_hand)
			if(l_hand)
				return 0
			return 1
		if(slot_r_hand)
			if(r_hand)
				return 0
			return 1
		if(slot_wear_mask)
			if(wear_mask)
				return 0
			if(!(I.slot_flags & SLOT_MASK))
				return 0
			return 1
		if(slot_back)
			if(back)
				return 0
			if(!(I.slot_flags & SLOT_BACK))
				return 0
			return 1
		if(slot_wear_suit)
			if(wear_suit)
				return 0
			if(!(I.slot_flags & SLOT_OCLOTHING))
				return 0
			return 1
		if(slot_gloves)
			if(gloves)
				return 0
			if(!(I.slot_flags & SLOT_GLOVES))
				return 0
			return 1
		if(slot_shoes)
			if(shoes)
				return 0
			if(!(I.slot_flags & SLOT_FEET))
				return 0
			return 1
		if(slot_belt)
			if(belt)
				return 0
			if(!w_uniform)
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(!(I.slot_flags & SLOT_BELT))
				return
			return 1
		if(slot_glasses)
			if(glasses)
				return 0
			if(!(I.slot_flags & SLOT_EYES))
				return 0
			return 1
		if(slot_head)
			if(head)
				return 0
			if(!(I.slot_flags & SLOT_HEAD))
				return 0
			return 1
		if(slot_l_ear)
			if(l_ear)
				return 0
			if(!(I.slot_flags & SLOT_EARS))
				return 0
			if((I.slot_flags & SLOT_TWOEARS) && r_ear )
				return 0
			return 1
		if(slot_r_ear)
			if(r_ear)
				return 0
			if(!(I.slot_flags & SLOT_EARS))
				return 0
			if((I.slot_flags & SLOT_TWOEARS) && l_ear)
				return 0
			return 1
		if(slot_w_uniform)
			if(w_uniform)
				return 0
			if(!(I.slot_flags & SLOT_ICLOTHING))
				return 0
			return 1
		if(slot_wear_id)
			if(wear_id)
				return 0
			if(!w_uniform)
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(!(I.slot_flags & SLOT_ID))
				return 0
			return 1
		if(slot_wear_pda)
			if(wear_pda)
				return 0
			if(!w_uniform)
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(!(I.slot_flags & SLOT_PDA))
				return 0
			return 1
		if(slot_l_store)
			if(I.flags & NODROP) //Pockets aren't visible, so you can't move NODROP items into them.
				return 0
			if(l_store)
				return 0
			if(!w_uniform)
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(I.slot_flags & SLOT_DENYPOCKET)
				return
			if(I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_POCKET))
				return 1
		if(slot_r_store)
			if(I.flags & NODROP)
				return 0
			if(r_store)
				return 0
			if(!w_uniform)
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(I.slot_flags & SLOT_DENYPOCKET)
				return 0
			if(I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_POCKET))
				return 1
			return 0
		if(slot_s_store)
			if(I.flags & NODROP) //Suit storage NODROP items drop if you take a suit off, this is to prevent people exploiting this.
				return 0
			if(s_store)
				return 0
			if(!wear_suit)
				if(!disable_warning)
					to_chat(src, "<span class='alert'>You need a suit before you can attach this [name].</span>")
				return 0
			if(!wear_suit.allowed)
				if(!disable_warning)
					to_chat(src, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return 0
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(src, "The [name] is too big to attach.")
				return 0
			if(istype(I, /obj/item/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, wear_suit.allowed))
				return 1
			return 0
		if(slot_handcuffed)
			if(handcuffed)
				return 0
			if(!istype(I, /obj/item/restraints/handcuffs))
				return 0
			return 1
		if(slot_legcuffed)
			if(legcuffed)
				return 0
			if(!istype(I, /obj/item/restraints/legcuffs))
				return 0
			return 1
		if(slot_in_backpack)
			if(back && istype(back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = back
				if(B.contents.len < B.storage_slots && I.w_class <= B.max_w_class)
					return 1
			return 0
		if(slot_tie)
			if(!w_uniform)
				if(!disable_warning)
					to_chat(src, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			var/obj/item/clothing/under/uniform = w_uniform
			if(uniform.accessories.len && !uniform.can_attach_accessory(src))
				if(!disable_warning)
					to_chat(src, "<span class='warning'>You already have an accessory of this type attached to your [uniform].</span>")
				return 0
			if(!(I.slot_flags & SLOT_TIE))
				return 0
			return 1

	return 0 //Unsupported slot

/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)
