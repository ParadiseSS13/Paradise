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

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

/mob/proc/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud(src)

/datum/hud/New(mob/owner)
	mymob = owner
	create_parallax()

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	qdel(hide_actions_toggle)
	hide_actions_toggle = null

	qdel(module_store_icon)
	module_store_icon = null

	if(static_inventory.len)
		for(var/thing in static_inventory)
			qdel(thing)
		static_inventory.Cut()

	inv_slots.Cut()
	action_intent = null
	move_intent = null

	if(toggleable_inventory.len)
		for(var/thing in toggleable_inventory)
			qdel(thing)
		toggleable_inventory.Cut()

	if(hotkeybuttons.len)
		for(var/thing in hotkeybuttons)
			qdel(thing)
		hotkeybuttons.Cut()

	if(infodisplay.len)
		for(var/thing in infodisplay)
			qdel(thing)
		infodisplay.Cut()

	//clear mob refs to screen objects
	mymob.throw_icon = null
	mymob.internals = null
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
			if(inv_slots[slot_l_hand])
				mymob.client.screen += inv_slots[slot_l_hand]	//we want the hands to be visible
			if(inv_slots[slot_r_hand])
				mymob.client.screen += inv_slots[slot_r_hand]	//we want the hands to be visible
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
	mymob.update_action_buttons()
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

/client/var/list/spacebg = list()
/client/var/obj/screen/pmaster_whitespace/pmaster_whitespace

var/list/parallax_on_clients = list()

/obj/screen/spacebg
	var/offset_x = 0
	var/offset_y = 0
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = 0
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "space"
	name = "space parallax"
	layer = AREA_LAYER
	plane = SPACE_LAYER_PLANE

/obj/screen/pmaster_whitespace
	plane = SPACE_TURF_PLANE
	color = list(0, 0, 0,
				0, 0, 0,
				0, 0, 0,
				1, 1, 1) // This will cause space to be solid white
	appearance_flags = PLANE_MASTER
	screen_loc = "WEST,SOUTH to EAST,NORTH"

/datum/hud/proc/create_parallax()
	var/client/C = mymob.client
	if(C.prefs.space_parallax)
		for(var/obj/screen/spacebg/bgobj in C.spacebg)
			C.screen |= bgobj
		if(C.pmaster_whitespace)
			C.screen |= C.pmaster_whitespace
	else
		for(var/obj/screen/spacebg/bgobj in C.spacebg)
			C.screen -= bgobj
			qdel(bgobj)
			C.spacebg -= bgobj
		if(C.pmaster_whitespace)
			C.screen -= C.pmaster_whitespace
			qdel(C.pmaster_whitespace)
			C.pmaster_whitespace = null
		return
	if(!C.spacebg.len)
		for(var/i in 0 to 3)
			var/obj/screen/spacebg/bgobj = new /obj/screen/spacebg()
			if(i & 1)
				bgobj.offset_x = 480
			if(i & 2)
				bgobj.offset_y = 480
			bgobj.screen_loc = "CENTER-7:[bgobj.offset_x],CENTER-7:[bgobj.offset_y]"
			C.spacebg += bgobj
			C.screen += bgobj
		C.pmaster_whitespace = new
		C.screen += C.pmaster_whitespace
	update_parallax()

/datum/hud/proc/update_parallax()
	var/atom/posobj = get_turf(mymob.client.eye)
	for(var/obj/screen/spacebg/bgobj in mymob.client.spacebg)
		bgobj.screen_loc = "CENTER-7:[bgobj.offset_x-posobj.x],CENTER-7:[bgobj.offset_y-posobj.y]"
		var/area/A = posobj.loc 
		if(A.parallax_icon_state)
			bgobj.icon_state = A.parallax_icon_state
		else
			bgobj.icon_state = "space"

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")

