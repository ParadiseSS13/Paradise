/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	/// Used for the HUD toggle (F12)
	var/hud_shown = TRUE
	/// Current displayed version of the HUD
	var/hud_version = 1
	/// Whether or not their toggleable inventory
	var/inventory_shown = TRUE
	/// This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)
	var/hotkey_ui_hidden = FALSE

	var/atom/movable/screen/lingchemdisplay
	var/atom/movable/screen/lingstingdisplay

	var/atom/movable/screen/guardianhealthdisplay

	var/atom/movable/screen/blobpwrdisplay
	var/atom/movable/screen/blobhealthdisplay
	var/atom/movable/screen/vampire_blood_display
	var/atom/movable/screen/alien_plasma_display
	var/atom/movable/screen/nightvisionicon
	var/atom/movable/screen/action_intent
	var/atom/movable/screen/zone_select
	var/atom/movable/screen/move_intent
	var/atom/movable/screen/module_store_icon
	var/atom/movable/screen/combo/combo_display

	// Elements used for action buttons
	// -- the main clickable buttons
	var/atom/movable/screen/button_palette/toggle_palette
	var/atom/movable/screen/palette_scroll/down/palette_down
	var/atom/movable/screen/palette_scroll/up/palette_up
	/// the groups of actions, such as palette (previously normal) actions
	var/datum/action_group/palette/palette_actions
	/// action group for expanded actions, the normal action set
	var/datum/action_group/listed/listed_actions
	/// A list of action buttons which aren't owned by any action group, and are just floating somewhere on the hud.
	var/list/floating_actions

	// the screen objects which are static
	var/list/static_inventory = list()
	/// the screen objects which can be hidden (your human items on the left)
	var/list/toggleable_inventory = list()
	/// the buttons that can be used via hotkeys
	var/list/hotkeybuttons = list()
	//the screen objects that display mob info (health, alien plasma, etc...)
	var/list/infodisplay = list()
	/// /atom/movable/screen/inventory objects, ordered by their slot ID.
	var/list/inv_slots[SLOT_HUD_AMOUNT]

	var/list/atom/movable/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object
	///Assoc list of controller groups, associated with key string group name with value of the plane master controller ref
	var/list/atom/movable/plane_master_controller/plane_master_controllers = list()
	///UI for screentips that appear when you mouse over things
	var/atom/movable/screen/screentip/screentip_text

/mob/proc/create_mob_hud()
	if(client && !hud_used)
		if(!ispath(hud_type))
			CRASH("Hud type must be a type, was instead [hud_type]!")
		set_hud_used(new hud_type(src))
		update_sight()
		SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)

/mob/proc/set_hud_used(datum/hud/new_hud)
	hud_used = new_hud
	new_hud.build_action_groups()

/datum/hud/proc/get_all_action_buttons()
	var/list/all_action_buttons = list()
	all_action_buttons += palette_actions.actions
	all_action_buttons += listed_actions.actions
	return all_action_buttons

/datum/hud/New(mob/owner)
	mymob = owner

	toggle_palette = new()
	toggle_palette.set_hud(src)
	palette_down = new()
	palette_down.set_hud(src)
	palette_up = new()
	palette_up.set_hud(src)

	for(var/mytype in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
		instance.backdrop(mymob)

	for(var/mytype in subtypesof(/atom/movable/plane_master_controller))
		var/atom/movable/plane_master_controller/controller_instance = new mytype(src)
		plane_master_controllers[controller_instance.name] = controller_instance

	screentip_text = new(null, src)
	static_inventory += screentip_text

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	QDEL_NULL(toggle_palette)
	QDEL_NULL(palette_down)
	QDEL_NULL(palette_up)
	QDEL_NULL(palette_actions)
	QDEL_NULL(listed_actions)
	QDEL_LIST_CONTENTS(floating_actions)

	QDEL_NULL(module_store_icon)
	QDEL_LIST_CONTENTS(static_inventory)

	inv_slots.Cut()
	action_intent = null
	zone_select = null
	move_intent = null

	QDEL_LIST_CONTENTS(toggleable_inventory)

	QDEL_LIST_CONTENTS(hotkeybuttons)

	QDEL_LIST_CONTENTS(infodisplay)

	//clear mob refs to screen objects
	mymob.throw_icon = null
	mymob.healths = null
	mymob.healthdoll = null
	mymob.pullin = null

	//clear the rest of our reload_fullscreen
	lingchemdisplay = null
	lingstingdisplay = null
	blobpwrdisplay = null
	alien_plasma_display = null
	vampire_blood_display = null
	nightvisionicon = null

	QDEL_LIST_ASSOC_VAL(plane_masters)
	QDEL_LIST_ASSOC_VAL(plane_master_controllers)

	mymob = null
	QDEL_NULL(screentip_text)
	return ..()

/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return FALSE

	if(!mymob.client)
		return FALSE

	mymob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = TRUE	//Governs behavior of other procs
			if(length(static_inventory))
				mymob.client.screen += static_inventory
			if(length(toggleable_inventory) && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(length(hotkeybuttons) && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons
			if(length(infodisplay))
				mymob.client.screen += infodisplay

			mymob.client.screen += toggle_palette

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = FALSE	//Governs behavior of other procs
			if(length(static_inventory))
				mymob.client.screen -= static_inventory
			if(length(toggleable_inventory))
				mymob.client.screen -= toggleable_inventory
			if(length(hotkeybuttons))
				mymob.client.screen -= hotkeybuttons
			if(length(infodisplay))
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			if(inv_slots[SLOT_HUD_LEFT_HAND])
				mymob.client.screen += inv_slots[SLOT_HUD_LEFT_HAND]	//we want the hands to be visible
			if(inv_slots[SLOT_HUD_RIGHT_HAND])
				mymob.client.screen += inv_slots[SLOT_HUD_RIGHT_HAND]	//we want the hands to be visible
			if(action_intent)
				mymob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = FALSE	//Governs behavior of other procs
			if(length(static_inventory))
				mymob.client.screen -= static_inventory
			if(length(toggleable_inventory))
				mymob.client.screen -= toggleable_inventory
			if(length(hotkeybuttons))
				mymob.client.screen -= hotkeybuttons
			if(length(infodisplay))
				mymob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistent_inventory_update()
	mymob.update_action_buttons(1)
	reorganize_alerts()
	reload_fullscreen()
	update_parallax_pref(mymob)
	plane_masters_update()

/datum/hud/proc/plane_masters_update()
	// Plane masters are always shown to OUR mob, never to observers
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/PM = plane_masters[thing]
		PM.backdrop(mymob)
		mymob.client.screen += PM

/datum/hud/human/show_hud(version = 0)
	. = ..()
	if(!.)
		return
	hidden_inventory_update()

/datum/hud/robot/show_hud(version = 0)
	. = ..()
	if(!.)
		return
	update_robot_modules_display()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistent_inventory_update()
	return

/mob/proc/hide_hud()
	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(src, "<span class='info'>Switched HUD mode. Press the key you just pressed to toggle the HUD mode again.</span>")
	else
		to_chat(src, "<span class='warning'>This mob type does not use a HUD.</span>")

/datum/hud/proc/update_locked_slots()
	return

/datum/hud/proc/remove_vampire_hud()
	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)
