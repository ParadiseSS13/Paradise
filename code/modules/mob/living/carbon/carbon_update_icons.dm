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
				final_pixel_y = PIXEL_Y_OFFSET_LYING
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
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
/mob/living/carbon/proc/update_hud_handcuffed()
	if(hud_used)
		var/obj/screen/inventory/R = hud_used.inv_slots[slot_r_hand]
		var/obj/screen/inventory/L = hud_used.inv_slots[slot_l_hand]
		if(R && L)
			R.update_icon()
			L.update_icon()

/mob/living/carbon/update_inv_r_hand(ignore_cuffs)
	if(handcuffed && !ignore_cuffs)
		drop_r_hand()
		return
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand

/mob/living/carbon/update_inv_l_hand(ignore_cuffs)
	if(handcuffed && !ignore_cuffs)
		drop_l_hand()
		return
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand

/mob/living/carbon/update_inv_wear_mask()
	if(istype(wear_mask, /obj/item/clothing/mask))
		update_hud_wear_mask(wear_mask)

/mob/living/carbon/update_inv_back()
	if(client && hud_used && hud_used.inv_slots[slot_back])
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_back]
		inv.update_icon()

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
