/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/lingstingdisplay

	var/obj/screen/guardianhealthdisplay

	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/vampire_blood_display
	var/obj/screen/alien_plasma_display
	var/obj/screen/nightvisionicon
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/obj/screen/module_store_icon

	var/list/static_inventory = list()		//the screen objects which are static
	var/list/toggleable_inventory = list()	//the screen objects which can be hidden
	var/list/hotkeybuttons = list()			//the buttons that can be used via hotkeys
	var/list/infodisplay = list()			//the screen objects that display mob info (health, alien plasma, etc...)
	var/list/inv_slots[slots_amt]			// /obj/screen/inventory objects, ordered by their slot ID.
	var/list/hand_slots						// /obj/screen/inventory/hand objects, assoc list of "[held_index]" = object

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

/mob/proc/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud(src)

/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new
	hide_actions_toggle.InitialiseIcon(mymob)
	hand_slots = list()

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	QDEL_NULL(hide_actions_toggle)

	QDEL_NULL(module_store_icon)

	QDEL_LIST(static_inventory)

	inv_slots.Cut()
	action_intent = null
	move_intent = null

	QDEL_LIST(toggleable_inventory)

	QDEL_LIST(hotkeybuttons)

	QDEL_LIST(infodisplay)

	//clear mob refs to screen objects
	mymob.throw_icon = null
	mymob.healths = null
	mymob.healthdoll = null
	mymob.pullin = null
	mymob.zone_sel = null

	//clear the rest of our reload_fullscreen
	lingchemdisplay = null
	lingstingdisplay = null
	blobpwrdisplay = null
	alien_plasma_display = null
	vampire_blood_display = null
	nightvisionicon = null

	mymob = null
	return ..()

/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	mymob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	if(mymob.client.view < world.view)
		if(mymob.client.view < ARBITRARY_VIEWRANGE_NOHUD)
			to_chat(mymob, "<span class='notice'>HUD is unavailable with this view range.</span>")
			display_hud_version = HUD_STYLE_NOHUD
		else
			if(display_hud_version == HUD_STYLE_STANDARD)
				to_chat(mymob, "<span class='notice'>Standard HUD mode is unavailable with a smaller-than-normal view range.</span>")
				display_hud_version = HUD_STYLE_REDUCED

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen += static_inventory
			if(toggleable_inventory.len && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			mymob.client.screen += hide_actions_toggle

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			for(var/h in hand_slots)
				var/obj/screen/hand = hand_slots[h]
				if(hand)
					mymob.client.screen += hand
			if(action_intent)
				mymob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistant_inventory_update()
	mymob.update_action_buttons(1)
	reorganize_alerts()
	reload_fullscreen()

/datum/hud/human/show_hud(version = 0)
	..()
	hidden_inventory_update()

/datum/hud/robot/show_hud(version = 0)
	..()
	update_robot_modules_display()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistant_inventory_update()
	return

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")

//builds hand ui slots, throwing away old ones
/datum/hud/proc/build_hand_slots(ui_style = 'icons/mob/screen_midnight.dmi')
	for(var/h in hand_slots)
		var/obj/screen/inventory/hand/H = hand_slots[h]
		if(H)
			static_inventory -= H

	hand_slots = list()
	var/obj/screen/inventory/hand/hand_box
	for(var/i in 1 to mymob.held_items.len)
		hand_box = new/obj/screen/inventory/hand()
		hand_box.name = mymob.get_held_index_name(i)
		hand_box.icon = ui_style
		hand_box.icon_state = "hand_[mymob.held_index_to_dir(i)]"
		hand_box.screen_loc = ui_hand_position(i)
		hand_box.held_index = i
		hand_slots["[i]"] = hand_box
		hand_box.hud = src
		static_inventory += hand_box
		hand_box.update_icon()

	var/i = 1
		for(var/obj/screen/swap_hand/SH in static_inventory)
			SH.screen_loc = ui_swaphand_position(mymob,!(i % 2) ? 2: 1)
			i++
	for(var/obj/screen/human/equip/E in static_inventory)
		E.screen_loc = ui_equip_position(mymob)

	show_hud(HUD_STYLE_STANDARD,mymob)
