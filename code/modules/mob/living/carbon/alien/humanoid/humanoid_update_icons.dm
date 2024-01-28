//Xeno Overlays Indexes//////////
#define X_HEAD_LAYER			1
#define X_SUIT_LAYER			2
#define X_L_HAND_LAYER			3
#define X_R_HAND_LAYER			4
#define X_TARGETED_LAYER			5
#define X_FIRE_LAYER			6
#define X_TOTAL_LAYERS			6
/////////////////////////////////

/mob/living/carbon/alien/humanoid
	var/list/overlays_standing[X_TOTAL_LAYERS]

/mob/living/carbon/alien/humanoid/update_icons()
	overlays.Cut()
	for(var/image/I in overlays_standing)
		overlays += I

	if(stat == DEAD)
		//If we mostly took damage from fire
		if(getFireLoss() > 125)
			icon_state = "alien[caste]_husked"
			pixel_y = 0
		else
			icon_state = "alien[caste]_dead"
			pixel_y = 0

	else if(stat == UNCONSCIOUS || IsWeakened())
		icon_state = "alien[caste]_unconscious"
		pixel_y = 0
	else if(leap_on_click)
		icon_state = "alien[caste]_pounce"

	else if(IS_HORIZONTAL(src))
		icon_state = "alien[caste]_sleep"
	else if(m_intent == MOVE_INTENT_RUN)
		icon_state = "alien[caste]_running"
	else
		icon_state = "alien[caste]_s"

	if(leaping)
		if(alt_icon == initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		icon_state = "alien[caste]_leap"
		pixel_x = -32
		pixel_y = -32
	else
		if(alt_icon != initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		pixel_x = get_standard_pixel_x_offset()
		pixel_y = get_standard_pixel_y_offset()

/mob/living/carbon/alien/humanoid/regenerate_icons()
	..()
	if(notransform)
		return

	update_inv_head()
	update_inv_wear_suit()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_pockets()
	update_icons()
	update_fire()
	update_transform()

/mob/living/carbon/alien/humanoid/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	..()
	update_icons()

/mob/living/carbon/alien/humanoid/update_fire()
	overlays -= overlays_standing[X_FIRE_LAYER]
	if(on_fire)
		overlays_standing[X_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning", "layer"= -X_FIRE_LAYER)
		overlays += overlays_standing[X_FIRE_LAYER]
		return
	else
		overlays_standing[X_FIRE_LAYER] = null

/mob/living/carbon/alien/humanoid/update_inv_wear_suit()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_HUD_OUTER_SUIT]
		inv.update_icon()

	if(wear_suit)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)					//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//TODO	//...draw the item in the inventory screen
			client.screen += wear_suit						//Either way, add the item to the HUD

		var/t_state = wear_suit.item_state
		if(!t_state)	t_state = wear_suit.icon_state
		var/image/standing	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]")

		if(wear_suit.blood_DNA)
			var/t_suit = "suit"
			if(istype(wear_suit, /obj/item/clothing/suit/armor))
				t_suit = "armor"
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[t_suit]blood")

		if(wear_suit.breakouttime)
			drop_r_hand()
			drop_l_hand()

		overlays_standing[X_SUIT_LAYER]	= standing
	else
		overlays_standing[X_SUIT_LAYER]	= null
	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_head()
	if(head)
		var/t_state = head.item_state
		if(!t_state)	t_state = head.icon_state
		var/image/standing	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]")
		if(head.blood_DNA)
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
		head.screen_loc = ui_alien_head
		overlays_standing[X_HEAD_LAYER]	= standing
	else
		overlays_standing[X_HEAD_LAYER]	= null
	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_pockets()
	if(l_store)
		l_store.screen_loc = ui_storage1
	if(r_store)
		r_store.screen_loc = ui_storage2
	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_r_hand()
	..()
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		r_hand.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = r_hand.righthand_file, "icon_state" = t_state)
	else
		overlays_standing[X_R_HAND_LAYER]	= null
	update_icons()

/mob/living/carbon/alien/humanoid/update_inv_l_hand()
	..()
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state
		l_hand.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = l_hand.lefthand_file, "icon_state" = t_state)
	else
		overlays_standing[X_L_HAND_LAYER]	= null
	update_icons()


//Xeno Overlays Indexes//////////
#undef X_HEAD_LAYER
#undef X_SUIT_LAYER
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef X_TARGETED_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
