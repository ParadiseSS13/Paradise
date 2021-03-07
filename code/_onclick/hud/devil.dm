
//Soul counter is stored with the humans, it does weird when you place it here apparently...


/datum/hud/devil/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	static_inventory += using

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	static_inventory += mymob.pullin

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

	using = new /obj/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	static_inventory += using

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)

	lingchemdisplay = new /obj/screen/ling/chems()
	devilsouldisplay = new /obj/screen/devil/soul_counter
	infodisplay += devilsouldisplay

	for(var/obj/screen/inventory/inv in static_inventory)
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()


/datum/hud/devil/persistent_inventory_update()
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
