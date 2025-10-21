//Right now just handles lying down, but could handle other cases later.
//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying_angle != lying_prev)
		changed++
		ntransform.TurnTo(lying_prev , lying_angle)
		if(!lying_angle) //Lying to standing
			final_pixel_y = pixel_y
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				final_pixel_y = pixel_y + PIXEL_Y_OFFSET_LYING
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		if(body_position == LYING_DOWN) // Manipulate the X axis when horizontal
			if(lying_angle == 270) // Depending on our lying angle, we need to add or remove from the offset.
				ntransform.Translate((resize - 1) * -16, 0)
			else
				ntransform.Translate((resize - 1) * 16, 0)
		else
			ntransform.Translate(0, (resize - 1) * 16) // Pixel Y shift: 1.25 = 4, 1.5 = 8, 2 -> 16, 3 -> 32, 4 -> 48, 5 -> 64
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		floating = FALSE
		animate(src, transform = ntransform, time = (lying_prev == 0 || lying_angle == 0) ? 2 : 0, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))

/mob/living/carbon/regenerate_icons()
	SEND_SIGNAL(src, COMSIG_CARBON_REGENERATE_ICONS, src)
	return ..()

/mob/living/carbon/proc/handle_transform_change()
	return

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hands_hud()
	if(!hud_used)
		return
	var/atom/movable/screen/inventory/R = hud_used.inv_slots[ITEM_SLOT_2_INDEX(ITEM_SLOT_RIGHT_HAND)]
	R?.update_icon()
	var/atom/movable/screen/inventory/L = hud_used.inv_slots[ITEM_SLOT_2_INDEX(ITEM_SLOT_LEFT_HAND)]
	L?.update_icon()

/mob/living/carbon/update_inv_r_hand(ignore_cuffs)
	if(handcuffed && !ignore_cuffs)
		drop_r_hand()
		return
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = UI_RHAND
			client.screen += r_hand

		update_observer_view(r_hand)

/mob/living/carbon/update_inv_l_hand(ignore_cuffs)
	if(handcuffed && !ignore_cuffs)
		drop_l_hand()
		return
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = UI_LHAND
			client.screen += l_hand
		update_observer_view(l_hand)

/mob/living/carbon/update_inv_wear_mask()
	if(!wear_mask)
		return
	update_hud_wear_mask(wear_mask)

/mob/living/carbon/update_inv_back()
	if(client)
		var/atom/movable/screen/inventory/inv = hud_used?.inv_slots[ITEM_SLOT_2_INDEX(ITEM_SLOT_BACK)]
		inv?.update_icon()

	if(back)
		update_hud_back(back)

/mob/living/carbon/update_inv_head()
	if(head)
		update_hud_head(head)

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return

/mob/living/carbon/proc/update_observer_view(obj/item/worn_item, inventory)
	if(!length(observers))
		return
	for(var/mob/dead/observe as anything in observers)
		if(observe.client && observe.client.eye == src)
			if(observe.hud_used)
				if(inventory && !observe.hud_used.inventory_shown)
					continue
				observe.client.screen += worn_item
		else
			observers -= observe
			if(!length(observers))
				observers.Cut()
				break
