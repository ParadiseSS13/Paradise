/mob/living/carbon/true_devil/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_r_hand()
		update_inv_l_hand()
		return 1
	return 0

/mob/living/carbon/true_devil/update_inv_r_hand(var/update_icons=1)
	..()
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state

		var/image/I = image("icon" = r_hand.righthand_file, "icon_state" = "[t_state]")
		I = center_image(I, r_hand.inhand_x_dimension, r_hand.inhand_y_dimension)
		devil_overlays[DEVIL_R_HAND_LAYER] = I
	else
		devil_overlays[DEVIL_R_HAND_LAYER] = null
	if(update_icons)
		update_icons()


/mob/living/carbon/true_devil/update_inv_l_hand(var/update_icons=1)
	..()
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state

		var/image/I = image("icon" = l_hand.lefthand_file, "icon_state" = "[t_state]")
		I = center_image(I, l_hand.inhand_x_dimension, l_hand.inhand_y_dimension)
		devil_overlays[DEVIL_L_HAND_LAYER] = I
	else
		devil_overlays[DEVIL_L_HAND_LAYER] = null
	if(update_icons)
		update_icons()

/mob/living/carbon/true_devil/proc/remove_overlay(cache_index)
	if(devil_overlays[cache_index])
		overlays -= devil_overlays[cache_index]
		devil_overlays[cache_index] = null


/mob/living/carbon/true_devil/proc/apply_overlay(cache_index)
	var/image/I = devil_overlays[cache_index]
	if(I)
		if(I in overlays)
			return
		var/list/new_overlays = overlays.Copy()
		new_overlays += I
		overlays = new_overlays
