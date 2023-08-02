/mob/living/carbon/swap_hand()
	var/obj/item/item_in_hand = get_active_hand()

	if(SEND_SIGNAL(src, COMSIG_MOB_SWAPPING_HANDS, item_in_hand) & COMPONENT_BLOCK_SWAP)
		to_chat(src, SPAN_WARNING("Ваши руки заняты удержанием [item_in_hand]."))
		return FALSE

	hand = !hand

	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()


/mob/living/carbon/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != hand)
		swap_hand()


/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE


/mob/living/carbon/proc/canBeHandcuffed()
	return FALSE


/mob/living/carbon/restrained()
	if(get_restraining_item())
		return TRUE
	return FALSE


/mob/living/carbon/get_restraining_item()
	return handcuffed


/mob/living/carbon/resist_restraints()
	spawn(0)
		resist_muzzle()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		cuff_resist(I)


//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed_status()
	if(handcuffed)
		drop_from_active_hand()
		drop_from_inactive_hand()
		stop_pulling()
		throw_alert("handcuffed", /obj/screen/alert/restrained/handcuffed, new_master = src.handcuffed)
	else
		clear_alert("handcuffed")

	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()

	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/hand
		hand = hud_used.inv_slots[slot_l_hand]
		hand.update_icon()
		hand = hud_used.inv_slots[slot_r_hand]
		hand.update_icon()


/**
 * Updates move intent, popup alert and human legcuffed overlay.
 */
/mob/living/carbon/proc/update_legcuffed_status()
	if(legcuffed)
		throw_alert("legcuffed", /obj/screen/alert/restrained/legcuffed, new_master = legcuffed)
		if(m_intent == MOVE_INTENT_RUN)
			toggle_move_intent()

	else
		clear_alert("legcuffed")
		if(m_intent == MOVE_INTENT_WALK)
			toggle_move_intent()

	update_inv_legcuffed()


/mob/living/carbon/proc/cuff_resist(obj/item/I, breakouttime = 600, cuff_break = FALSE)
	breakouttime = I.breakouttime

	var/displaytime = breakouttime / 10
	if(!cuff_break)
		visible_message("<span class='warning'>[src.name] пыта[pluralize_ru(src.gender,"ет","ют")]ся снять [I]!</span>")
		to_chat(src, "<span class='notice'>Вы пытаетесь снять [I]... (Это займет около [displaytime] секунд и вам не нужно двигаться.)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			if(I.loc != src || buckled)
				return
			visible_message("<span class='danger'>[src.name] удалось снять [I]!</span>")
			to_chat(src, "<span class='notice'>Вы успешно сняли [I].</span>")

			if(I == handcuffed)
				drop_item_ground(I, TRUE)
				return
			if(I == legcuffed)
				drop_item_ground(I, TRUE)
				return
			else
				drop_item_ground(I, TRUE)
				return
		else
			to_chat(src, "<span class='warning'>Вам не удалось снять [I]!</span>")

	else
		breakouttime = 50
		visible_message("<span class='warning'>[src.name] пыта[pluralize_ru(src.gender,"ет","ют")]ся сломать [I]!</span>")
		to_chat(src, "<span class='notice'>Вы пытаетесь сломать [I]... (Это займет у вас приблизительно 5 секунд и вам не нужно двигаться)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			if(!I.loc || buckled)
				return
			visible_message("<span class='danger'>[src.name] успешно сломал[genderize_ru(src.gender,"","а","о","и")] [I]!</span>")
			to_chat(src, "<span class='notice'>Вы успешно сломали [I].</span>")
			temporarily_remove_item_from_inventory(I, TRUE)
			qdel(I)
		else
			to_chat(src, "<span class='warning'>Вам не удалось сломать [I]!</span>")


/**
 * Pass any type of handcuffs as 'new type()'
 */
/mob/living/carbon/proc/set_handcuffed(new_value)
	if(!istype(new_value, /obj/item/restraints/handcuffs))
		stack_trace("[new_value] is not a valid handcuffs!")
		qdel(new_value)
		return

	if(handcuffed || handcuffed == new_value)
		drop_item_ground(new_value)
		return

	equip_to_slot(new_value, slot_handcuffed)


/mob/living/carbon/proc/uncuff()
	if(handcuffed)
		drop_item_ground(handcuffed, TRUE)

	if(legcuffed)
		drop_item_ground(legcuffed, TRUE)


/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))


/mob/living/carbon/resist_muzzle()
	if(!istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/obj/item/clothing/mask/muzzle/I = wear_mask
	var/time = I.resist_time
	if(I.resist_time == 0)//if it's 0, you can't get out of it
		to_chat(src, "[I] слишком хорошо зафиксирован, для него вам понадобятся руки!")
	else
		visible_message("<span class='warning'>[src.name] грыз[pluralize_ru(src.gender,"ет","ут")] [I], пытаясь избавиться от него!</span>")
		to_chat(src, "<span class='notice'>Вы пытаетесь избавиться от [I]... (Это займет около [time/10] секунд и вам не нужно двигаться.)</span>")
		if(do_after(src, time, 0, target = src))
			visible_message("<span class='warning'>[src.name] избавил[genderize_ru(src.gender,"ся","ась","ось","ись")] от [I]!</span>")
			to_chat(src, "<span class='notice'>Вы избавились от [I]!</span>")
			if(I.security_lock)
				I.do_break()
			drop_item_ground(I, TRUE)


/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)

	var/dat = {"<meta charset="UTF-8"><table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank))
		dat += "&nbsp;<A href='?src=[UID()];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[UID()];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		var/obj/item/clothing/mask/muzzle/M = wear_mask
		if(M.security_lock)
			dat += "&nbsp;<A href='?src=[M.UID()];locked=\ref[src]'>[M.locked ? "Disable Lock" : "Set Lock"]</A>"

		dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[slot_handcuffed]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[UID()];item=[slot_legcuffed]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()


/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))
		if(href_list["internal"])
			var/slot = text2num(href_list["internal"])
			var/obj/item/ITEM = get_item_by_slot(slot)
			if(ITEM && istype(ITEM, /obj/item/tank))
				visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>", \
								"<span class='userdanger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>")

				var/no_mask
				if(!get_organ_slot("breathing_tube"))
					if(!(wear_mask && wear_mask.flags & AIRTIGHT))
						if(!(head && head.flags & AIRTIGHT))
							no_mask = 1
				if(no_mask)
					to_chat(usr, "<span class='warning'>[src.name] не нос[pluralize_ru(src.gender,"ит","ят")] подходящую маску или шлем!</span>")
					return

				if(do_mob(usr, src, POCKET_STRIP_DELAY))
					if(internal)
						internal = null
						update_action_buttons_icon()
					else
						var/no_mask2
						if(!get_organ_slot("breathing_tube"))
							if(!(wear_mask && wear_mask.flags & AIRTIGHT))
								if(!(head && head.flags & AIRTIGHT))
									no_mask2 = 1
						if(no_mask2)
							to_chat(usr, "<span class='warning'>[src.name] не нос[pluralize_ru(src.gender,"ит","ят")] подходящую маску или шлем!</span>")
							return
						internal = ITEM
						update_action_buttons_icon()

					visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>", \
									"<span class='userdanger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>")


/mob/living/carbon/proc/has_organ()
	return


/mob/living/carbon/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	if(I == back)
		back = null
		if(!QDELETED(src))
			update_inv_back()

	else if(I == wear_mask)
		if(ishuman(src)) //If we don't do this hair won't be properly rebuilt.
			return
		wear_mask = null
		if(!QDELETED(src))
			update_inv_wear_mask()

	else if(I == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		if(!QDELETED(src))
			update_handcuffed_status()

	else if(I == legcuffed)
		legcuffed = null
		if(!QDELETED(src))
			update_legcuffed_status()


/**
 * All the necessary checks for carbon to put an item in hand
 */
/mob/living/carbon/put_in_hand_check(obj/item/I, hand_id)
	if(!istype(I))
		return FALSE

	if(I.flags & NOPICKUP)
		return FALSE

	if(incapacitated(ignore_lying = TRUE))
		return FALSE

	if(lying && !(I.flags & ABSTRACT))
		return FALSE

	if(hand_id == "HAND_LEFT" && !has_left_hand())
		return FALSE

	if(hand_id == "HAND_RIGHT" && !has_right_hand())
		return FALSE

	return hand_id == "HAND_LEFT" ? !l_hand : !r_hand


/**
 * Put item in our active hand if possible. Failing that it tries our inactive hand. Returns `TRUE` on success.
 * If both fail it drops item on the floor and returns `FALSE`
 * Just puts stuff on the floor for most mobs, since all mobs have hands but putting stuff in the AI/corgi/ghost hand is VERY BAD.
 *
 * Arguments
 * * 'force' overrides flag NODROP and clothing obscuration.
 * * 'qdel_on_fail' qdels item if failed to pick in both hands.
 * * 'merge_stacks' set to `TRUE` to allow stack auto-merging even when both hands are full.
 * * 'ignore_anim' set to `TRUE` to prevent pick up animation.
 */
/mob/living/carbon/put_in_hands(obj/item/I, force = FALSE, qdel_on_fail = FALSE, merge_stacks = TRUE, ignore_anim = TRUE)

	// Its always TRUE if there is no item, since we are using this proc in 'if()' statements
	if(!I)
		return TRUE

	if(QDELETED(I))
		return FALSE

	if(!real_human_being())	// Not a real hero :'(
		I.forceMove(drop_location())
		I.pixel_x = initial(I.pixel_x)
		I.pixel_y = initial(I.pixel_y)
		I.layer = initial(I.layer)
		I.plane = initial(I.plane)
		I.dropped(src)
		return TRUE

	// If the item is a stack and we're already holding a stack then merge
	if(isstack(I))
		var/obj/item/stack/item_stack = I
		var/obj/item/stack/active_stack = get_active_hand()

		if(item_stack.is_zero_amount(delete_if_zero = TRUE))
			return FALSE

		if(merge_stacks)
			if(istype(active_stack) && active_stack.can_merge(item_stack, inhand = TRUE))
				if(!ignore_anim)
					I.do_pickup_animation(src)
				if(item_stack.merge(active_stack))
					to_chat(src, SPAN_NOTICE("Your [active_stack.name] stack now contains [active_stack.get_amount()] [active_stack.singular_name]\s."))
					return TRUE
			else
				var/obj/item/stack/inactive_stack = get_inactive_hand()
				if(istype(inactive_stack) && inactive_stack.can_merge(item_stack, inhand = TRUE))
					if(!ignore_anim)
						I.do_pickup_animation(src)
					if(item_stack.merge(inactive_stack))
						to_chat(src, SPAN_NOTICE("Your [inactive_stack.name] stack now contains [inactive_stack.get_amount()] [inactive_stack.singular_name]\s."))
						return TRUE

	if(put_in_active_hand(I, force, ignore_anim))
		return TRUE
	if(put_in_inactive_hand(I, force, ignore_anim))
		return TRUE

	if(qdel_on_fail)
		qdel(I)
		return FALSE

	I.forceMove(drop_location())
	I.layer = initial(I.layer)
	I.plane = initial(I.plane)
	I.dropped(src)

	return FALSE


/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_wear_suit)
			return wear_suit
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
	return null


/mob/living/carbon/get_slot_by_item(item)
	if(item == back)
		return slot_back
	if(item == wear_mask)
		return slot_wear_mask
	if(item == wear_suit)
		return slot_wear_suit
	if(item == l_hand)
		return slot_l_hand
	if(item == r_hand)
		return slot_r_hand
	if(item == handcuffed)
		return slot_handcuffed
	if(item == legcuffed)
		return slot_legcuffed
	return null


/mob/living/carbon/get_all_slots()
	return list(l_hand,
				r_hand,
				handcuffed,
				legcuffed,
				back,
				wear_mask)


/mob/living/carbon/get_access_locations()
	. = ..()
	. |= list(get_active_hand(), get_inactive_hand())


/mob/living/carbon/get_equipped_items(include_pockets = FALSE, include_hands = FALSE)
	var/list/items = ..()
	if(wear_suit)
		items += wear_suit
	if(head)
		items += head
	return items
