
//Soul counter is stored with the humans, it does weird when you place it here apparently...


/datum/hud/devil/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "right hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "left hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	static_inventory += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_LAYER
	static_inventory += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_LAYER
	static_inventory += using

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)

	lingchemdisplay = new /obj/screen/ling/chems()
	devilsouldisplay = new /obj/screen/devil/soul_counter
	infodisplay += devilsouldisplay


/datum/hud/devil/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/true_devil/D = mymob

	if(hud_version != HUD_STYLE_NOHUD)
		if(D.r_hand)
			D.r_hand.screen_loc = ui_rhand
			D.client.screen += D.r_hand
		if(D.l_hand)
			D.l_hand.screen_loc = ui_lhand
			D.client.screen += D.l_hand
	else
		if(D.r_hand)
			D.r_hand.screen_loc = null
		if(D.l_hand)
			D.l_hand.screen_loc = null

/mob/living/carbon/true_devil/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/devil(src, ui_style2icon(client.prefs.UI_style))
