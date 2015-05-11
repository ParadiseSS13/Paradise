/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		var/obj/item/weapon/storage/S = H.get_inactive_hand()
		if(!I)
			H << "<span class='notice'>You are not holding anything to equip.</span>"
			return

		if(istype(I, /obj/item/clothing/head/helmet/space/rig)) // If the item to be equipped is a rigid suit helmet
			var/obj/item/clothing/head/helmet/space/rig/C = I
			if(C.rig_restrict_helmet)
				src << "\red You must fasten the helmet to a hardsuit first. (Target the head and use on a hardsuit)" // Stop eva helms equipping.
				return 0

		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else if(s_active && s_active.can_be_inserted(I,1))  //if storage active insert there
			s_active.handle_item_insertion(I)
		else if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))  //see if we have box in other hand
			S.handle_item_insertion(I)
		else
			S = H.get_item_by_slot(slot_belt)
			if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))    //else we put in belt
				S.handle_item_insertion(I)
			else
				S = H.get_item_by_slot(slot_back)  //else we put in backpack
				if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))
					S.handle_item_insertion(I)
				else
					H << "\red You are unable to equip that."


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		del(W)
	return null

/mob/living/carbon/human/proc/is_in_hands(var/typepath)
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return 0


/mob/living/carbon/human/proc/has_organ(name)
	var/obj/item/organ/external/O = organs_by_name[name]

	return (O && !(O.status & ORGAN_DESTROYED) )

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

/mob/living/carbon/human/unEquip(obj/item/I)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return

	var/obj/item/organ/O = I //Organs shouldn't be removed unless you call droplimb.
	if(istype(O) && O.owner == src)
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
		update_inv_glasses()
	else if(I == head)
		head = null
		if(I.flags & BLOCKHAIR || I.flags & BLOCKHEADHAIR)
			update_hair()	//rebuild hair
		update_inv_head()
	else if(I == r_ear)
		r_ear = null
		update_inv_ears()
	else if (I == l_ear)
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
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		update_inv_wear_mask()
	else if(I == wear_id)
		wear_id = null
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
	else if(I == handcuffed)
		handcuffed = null
		update_inv_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
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

	W.loc = src
	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			if((wear_mask.flags & BLOCKHAIR) || (wear_mask.flags & BLOCKHEADHAIR))
				update_hair(redraw_mob)	//rebuild hair
			W.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			src.belt = W
			W.equipped(src, slot)
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			src.wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id(redraw_mob)
		if(slot_wear_pda)
			src.wear_pda = W
			W.equipped(src, slot)
			update_inv_wear_pda(redraw_mob)
		if(slot_l_ear)
			src.l_ear = W
			if(l_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.r_ear = O
				O.layer = 20
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)
		if(slot_r_ear)
			src.r_ear = W
			if(r_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.l_ear = O
				O.layer = 20
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			W.equipped(src, slot)
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			src.gloves = W
			W.equipped(src, slot)
			update_inv_gloves(redraw_mob)
		if(slot_head)
			src.head = W
			if((head.flags & BLOCKHAIR) || (head.flags & BLOCKHEADHAIR))
				update_hair(redraw_mob)	//rebuild hair
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			update_inv_head(redraw_mob)
		if(slot_shoes)
			src.shoes = W
			W.equipped(src, slot)
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			W.equipped(src, slot)
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			src.w_uniform = W
			W.equipped(src, slot)
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			src.s_store = W
			W.equipped(src, slot)
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.unEquip(W)
			W.loc = src.back
		if(slot_tie)
			var/obj/item/clothing/under/uniform = src.w_uniform
			uniform.attackby(W,src)
		else
			src << "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"
			return

	W.layer = 20

	return

/mob/living/carbon/human/put_in_hands(obj/item/W)
	if(!W)		return 0
	if(put_in_active_hand(W))			return 1
	else if(put_in_inactive_hand(W))	return 1
	else
		..()

/obj/effect/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null	//source location
	var/t_loc = null	//target location
	var/obj/item/item = null
	var/place = null
	var/pickpocket = null

/obj/effect/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/effect/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/New()
	if (!ticker)
		del(src)
	spawn(100)
		del(src)
	..()
	return

/obj/effect/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	else
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					del(src)
			if("l_hand")
				if (!( target.l_hand ))
					del(src)
			if("r_hand")
				if (!( target.r_hand ))
					del(src)
			if("suit")
				if (!( target.wear_suit ))
					del(src)
			if("uniform")
				if (!( target.w_uniform ))
					del(src)
			if("back")
				if (!( target.back ))
					del(src)
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if (!( target.handcuffed ))
					del(src)
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					del(src)
			if("splints")
				var/count = 0
				for(var/organ in list("l_leg","r_leg","l_arm","r_arm"))
					var/obj/item/organ/external/o = target.organs_by_name[organ]
					if(o.status & ORGAN_SPLINTED)
						count = 1
						break
				if(count == 0)
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && (istype(target.back, /obj/item/weapon/tank) || istype(target.belt, /obj/item/weapon/tank) || istype(target.s_store, /obj/item/weapon/tank)) && !( target.internal )) ) && !( target.internal )))
					del(src)

	var/message=null
	if(target.frozen)
		source << "\red Do not attempt to strip frozen people."
		return


	switch(place)
		if("syringe")
			message = "\red <B>[source] is trying to inject [target]!</B>"
		if("pill")
			message = "\red <B>[source] is trying to force [target] to swallow [item]!</B>"
		if("drink")
			message = "\red <B>[source] is trying to force [target] to swallow a gulp of [item]!</B>"
		if("dnainjector")
			message = "\red <B>[source] is trying to inject [target] with the [item]!</B>"
		if("mask")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their mask removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) mask</font>")
			if(target.wear_mask && (target.wear_mask.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.wear_mask] from [target]'s head!</B>"
				return
			else if(target.wear_mask)
				message = "\red <B>[source] is trying to take off \a [target.wear_mask] from [target]'s head!</B>"
		if("l_hand")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left hand item ([target.l_hand]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left hand item ([target.l_hand])</font>")
			message = "\red <B>[source] is trying to take off \a [target.l_hand] from [target]'s left hand!</B>"
		if("r_hand")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right hand item ([target.r_hand]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right hand item ([target.r_hand])</font>")
			message = "\red <B>[source] is trying to take off \a [target.r_hand] from [target]'s right hand!</B>"
		if("gloves")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their gloves ([target.gloves]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) gloves ([target.gloves])</font>")
			if(target.gloves && (target.gloves.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.gloves] from [target]'s hands!</B>"
				return
			else if(target.gloves)
				message = "\red <B>[source] is trying to take off the [target.gloves] from [target]'s hands!</B>"
		if("eyes")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their eyewear ([target.glasses]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) eyewear ([target.glasses])</font>")
			if(target.glasses && (target.glasses.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.glasses] from [target]'s eyes!</B>"
				return
			else if(target.glasses)
				message = "\red <B>[source] is trying to take off the [target.glasses] from [target]'s eyes!</B>"
		if("l_ear")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left ear item ([target.l_ear]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left ear item ([target.l_ear])</font>")
			if(target.l_ear && (target.l_ear.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.l_ear] from [target]'s left ear!</B>"
				return
			else if(target.l_ear)
				message = "\red <B>[source] is trying to take off the [target.l_ear] from [target]'s left ear!</B>"
		if("r_ear")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right ear item ([target.r_ear]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right ear item ([target.r_ear])</font>")
			if(target.r_ear && (target.r_ear.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.r_ear] from [target]'s right ear!</B>"
				return
			else if(target.r_ear)
				message = "\red <B>[source] is trying to take off the [target.r_ear] from [target]'s right ear!</B>"
		if("head")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their hat ([target.head]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) hat ([target.head])</font>")
			if(target.head && (target.head.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.head] from [target]'s head!</B>"
				return
			else if(target.head)
				message = "\red <B>[source] is trying to take off the [target.head] from [target]'s head!</B>"
		if("shoes")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their shoes ([target.shoes]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) shoes ([target.shoes])</font>")
			if(target.shoes && (target.shoes.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.shoes] from [target]'s feet!</B>"
				return
			else if(target.shoes)
				message = "\red <B>[source] is trying to take off [target.shoes] from [target]'s feet!</B>"
		if("belt")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their belt item ([target.belt]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) belt item ([target.belt])</font>")
			if(!pickpocket && target.belt)
				message = "\red <B>[source] is trying to take off \a [target.belt] from [target]'s belt!</B>"
		if("suit")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit ([target.wear_suit]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit ([target.wear_suit])</font>")
			if(target.wear_suit && (target.wear_suit.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.wear_suit] from [target]'s body!</B>"
				return
			else if(target.wear_suit)
				message = "\red <B>[source] is trying to take off \a [target.wear_suit] from [target]'s body!</B>"
		if("back")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their back item ([target.back]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) back item ([target.back])</font>")
			message = "\red <B>[source] is trying to take off \a [target.back] from [target]'s back!</B>"
		if("handcuff")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unhandcuffed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unhandcuff [target.name]'s ([target.ckey])</font>")
			if(target.handcuffed)
				message = "\red <B>[source] is trying to unhandcuff [target]!</B>"
		if("legcuff")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unlegcuffed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unlegcuff [target.name]'s ([target.ckey])</font>")
			if(target.legcuffed)
				message = "\red <B>[source] is trying to unlegcuff [target]!</B>"
			else
				message = "\red <B>[source] is trying to legcuff [target]!</B>"
		if("uniform")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their uniform ([target.w_uniform]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) uniform ([target.w_uniform])</font>")
			for(var/obj/item/I in list(target.l_store, target.r_store))
				if(I.on_found(source))
					return
			if(target.w_uniform && (target.w_uniform.flags & NODROP))
				message = "\red <B>[source] fails to take off \a [target.w_uniform] from [target]'s body!</B>"
				return
			else
				message = "\red <B>[source] is trying to take off \a [target.w_uniform] from [target]'s body!</B>"
		if("tie")
			var/obj/item/clothing/under/suit = target.w_uniform
			if(suit.accessories.len)
				var/obj/item/clothing/accessory/A = suit.accessories[1]
				target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their accessory ([A]) removed by [source.name] ([source.ckey])</font>"
				source.attack_log += "\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) accessory ([A])</font>"
				if(istype(A, /obj/item/clothing/accessory/holobadge) || istype(A, /obj/item/clothing/accessory/medal))
					for(var/mob/M in viewers(target, null))
						M.show_message("\red <B>[source] tears off \the [A] from [target]'s [suit]!</B>" , 1)
					done()
					return
				else
					message = "\red <B>[source] is trying to take off \a [A] from [target]'s [suit]!</B>"
		if("s_store")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit storage item ([target.s_store]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit storage item ([target.s_store])</font>")
			message = "\red <B>[source] is trying to take off \a [target.s_store] from [target]'s suit!</B>"
		if("pockets")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their pockets emptied by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to empty [target.name]'s ([target.ckey]) pockets</font>")
			for(var/obj/item/I in list(target.l_store, target.r_store))
				if(I.on_found(source))
					return
			message = "\red <B>[source] is trying to empty [target]'s pockets!</B>"
		if("CPR")
			if (!target.cpr_time)
				del(src)
			target.cpr_time = 0
			message = "\red <B>[source] is trying perform CPR on [target]!</B>"
		if("id")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their ID ([target.wear_id]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) ID ([target.wear_id])</font>")
			if(!pickpocket)
				message = "\red <B>[source] is trying to take off [target.wear_id] from [target]'s uniform!</B>"
			else
				source << "\blue You try to take off [target.wear_id] from [target]'s uniform!"
		if("pda")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their PDA ([target.wear_pda]) removed by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) PDA ([target.wear_pda])</font>")
			message = "\red <B>[source] is trying to take off [target.wear_pda] from [target]'s uniform!</B>"
		if("internal")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
			if (target.internal)
				message = "\red <B>[source] is trying to remove [target]'s internals!</B>"
			else
				message = "\red <B>[source] is trying to set on [target]'s internals.</B>"
		if("splints")
			message = "\red <B>[source] is trying to remove [target]'s splints!</B>"
		if("sensor")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors toggled by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) sensors</font>")
			var/obj/item/clothing/under/suit = target.w_uniform
			if (suit.has_sensor >= 2)
				source << "The controls are locked."
				return
			message = "\red <B>[source] is trying to set [target]'s suit sensors!</B>"

	for(var/mob/M in viewers(target, null))
		if(findtext(message, "is trying to take off  from", 1, 0) > 0 || message == null)
			message = "\red <B>[source] is trying to put \a [item] on [target]!</B>"
			if(findtext(message, "is trying to put  on", 1, 0) > 0)
				return
			else
				M.show_message(message, 1)
		else
			M.show_message(message, 1)
	spawn( HUMAN_STRIP_DELAY )
		done()
		return
	return

/*
This proc equips stuff (or does something else) when removing stuff manually from the character window when you click and drag.
It works in conjuction with the process() above.
This proc works for humans only. Aliens stripping humans and the like will all use this proc. Stripping monkeys or somesuch will use their version of this proc.
The first if statement for "mask" and such refers to items that are already equipped and un-equipping them.
The else statement is for equipping stuff to empty slots.
The NODROP flag refers to variable of /obj/item/clothing which either allows or disallows that item to be removed.
It can still be worn/put on as normal.
*/
/obj/effect/equip_e/human/done()	//TODO: And rewrite this :< ~Carn
	target.cpr_time = 1
	if(isanimal(source)) return //animals cannot strip people
	if(!source || !target) return		//Target or source no longer exist
	if(source.loc != s_loc) return		//source has moved
	if(target.loc != t_loc) return		//target has moved
	if (LinkBlockedUnclimbable(t_loc, s_loc)) return
	if(item && source.get_active_hand() != item) return	//Swapped hands / removed item from the active one
	if ((source.restrained() || source.stat)) return //Source restrained or unconscious / dead
	if(target.frozen)
		source << "\red Do not attempt to strip frozen people."
		return


	var/slot_to_process
	var/strip_item //this will tell us which item we will be stripping - if any.

	switch(place)	//here we go again...
		if("mask")
			slot_to_process = slot_wear_mask
			if (target.wear_mask && !(target.wear_mask.flags & NODROP))
				strip_item = target.wear_mask
		if("gloves")
			slot_to_process = slot_gloves
			if (target.gloves && !(target.gloves.flags & NODROP))
				strip_item = target.gloves
		if("eyes")
			slot_to_process = slot_glasses
			if (target.glasses)
				strip_item = target.glasses
		if("belt")
			slot_to_process = slot_belt
			if (target.belt)
				strip_item = target.belt
		if("s_store")
			slot_to_process = slot_s_store
			if (target.s_store)
				strip_item = target.s_store
		if("head")
			slot_to_process = slot_head
			if (target.head && !(target.head.flags & NODROP))
				strip_item = target.head
		if("l_ear")
			slot_to_process = slot_l_ear
			if (target.l_ear)
				strip_item = target.l_ear
		if("r_ear")
			slot_to_process = slot_r_ear
			if (target.r_ear)
				strip_item = target.r_ear
		if("shoes")
			slot_to_process = slot_shoes
			if (target.shoes && !(target.shoes.flags & NODROP))
				strip_item = target.shoes
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				del(src)
			slot_to_process = slot_l_hand
			if (target.l_hand)
				strip_item = target.l_hand
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				del(src)
			slot_to_process = slot_r_hand
			if (target.r_hand)
				strip_item = target.r_hand
		if("uniform")
			slot_to_process = slot_w_uniform
			if(target.w_uniform && !(target.w_uniform.flags & NODROP))
				strip_item = target.w_uniform
		if("suit")
			slot_to_process = slot_wear_suit
			if (target.wear_suit && !(target.wear_suit.flags & NODROP))
				strip_item = target.wear_suit
		if("tie")
			var/obj/item/clothing/under/suit = target.w_uniform
			//var/obj/item/clothing/accessory/tie = suit.hastie
			/*if(tie)
				if (istype(tie,/obj/item/clothing/accessory/storage))
					var/obj/item/clothing/accessory/storage/W = tie
					if (W.hold)
						W.hold.close(usr)
				usr.put_in_hands(tie)
				suit.hastie = null*/
			if(suit && suit.accessories.len)
				var/obj/item/clothing/accessory/A = suit.accessories[1]
				A.on_removed(usr)
				suit.accessories -= A
				target.update_inv_w_uniform()
		if("id")
			slot_to_process = slot_wear_id
			if (target.wear_id)
				strip_item = target.wear_id
		if("pda")
			slot_to_process = slot_wear_pda
			if (target.wear_pda)
				strip_item = target.wear_pda
		if("back")
			slot_to_process = slot_back
			if (target.back)
				strip_item = target.back
		if("handcuff")
			slot_to_process = slot_handcuffed
			if (target.handcuffed)
				strip_item = target.handcuffed
		if("legcuff")
			slot_to_process = slot_legcuffed
			if (target.legcuffed)
				strip_item = target.legcuffed
		if("splints")
			for(var/organ in list("l_leg","r_leg","l_arm","r_arm"))
				var/obj/item/organ/external/o = target.get_organ(organ)
				if (o && o.status & ORGAN_SPLINTED)
					var/obj/item/W = new /obj/item/stack/medical/splint/single()
					o.status &= ~ORGAN_SPLINTED
					if (W)
						W.loc = target.loc
						W.layer = initial(W.layer)
						W.add_fingerprint(source)
		if("CPR")
			if ((target.health > config.health_threshold_dead && target.health <= config.health_threshold_crit))
				var/suff = min(target.getOxyLoss(), 7)
				target.adjustOxyLoss(-suff)
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message("\red [source] performs CPR on [target]!", 1)
				target << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
				source << "\red Repeat at least every 7 seconds."
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(S)
				S.add_fingerprint(source)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					S.inuse = 0
					del(src)
				S.inject(target, source)
				if (S.s_time >= world.time + 30)
					S.inuse = 0
					del(src)
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message("\red [source] injects [target] with the DNA Injector!", 1)
				S.inuse = 0
		if("pockets")
			slot_to_process = slot_l_store
			strip_item = target.l_store		//We'll do both
		if("sensor")
			var/obj/item/clothing/under/suit = target.w_uniform
			if (suit)
				if(suit.has_sensor >= 2)
					source << "The controls are locked."
				else
					suit.set_sensors(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
					else if (istype(target.s_store, /obj/item/weapon/tank))
						target.internal = target.s_store
					else if (istype(target.belt, /obj/item/weapon/tank))
						target.internal = target.belt
					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message("[target] is now running on internals.", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"
	if(slot_to_process)
		if(strip_item) //Stripping an item from the mob
			var/obj/item/W = strip_item
			if((W.flags & NODROP) || (W.flags & ABSTRACT)) //Just to be sure
				return
			target.unEquip(W)
			if (target.client)
				target.client.screen -= W
			if (W)
				W.loc = target.loc
				W.layer = initial(W.layer)
				W.dropped(target)
			W.add_fingerprint(source)
			if(slot_to_process == slot_l_store) //pockets! Needs to process the other one too. Snowflake code, wooo! It's not like anyone will rewrite this anytime soon. If I'm wrong then... CONGRATULATIONS! ;)
				if(target.r_store)
					target.unEquip(target.r_store) //At this stage l_store is already processed by the code above, we only need to process r_store.
		else
			if(item && target.has_organ_for_slot(slot_to_process)) //Placing an item on the mob
				if(item.mob_can_equip(target, slot_to_process, 0))
					source.unEquip(item)
					target.equip_to_slot_if_possible(item, slot_to_process, 0, 1, 1)
					item.dropped(source)
					source.update_icons()
					target.update_icons()

	if(source && target)
		if(source.machine == target)
			target.show_inv(source)
	del(src)


/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

/mob/living/carbon/get_item_by_slot(slot_id)
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
	return null

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
