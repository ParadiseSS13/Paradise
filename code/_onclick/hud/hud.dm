/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
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
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()


/datum/hud/proc/hidden_inventory_update()
	if(!mymob) return
	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(inventory_shown && hud_shown)
			if(H.shoes)		H.shoes.screen_loc = ui_shoes
			if(H.gloves)	H.gloves.screen_loc = ui_gloves
			if(H.l_ear)		H.l_ear.screen_loc = ui_l_ear
			if(H.r_ear)		H.r_ear.screen_loc = ui_r_ear
			if(H.glasses)	H.glasses.screen_loc = ui_glasses
			if(H.w_uniform)	H.w_uniform.screen_loc = ui_iclothing
			if(H.wear_suit)	H.wear_suit.screen_loc = ui_oclothing
			if(H.wear_mask)	H.wear_mask.screen_loc = ui_mask
			if(H.head)		H.head.screen_loc = ui_head
		else
			if(H.shoes)		H.shoes.screen_loc = null
			if(H.gloves)	H.gloves.screen_loc = null
			if(H.l_ear)		H.l_ear.screen_loc = null
			if(H.r_ear)		H.r_ear.screen_loc = null
			if(H.glasses)	H.glasses.screen_loc = null
			if(H.w_uniform)	H.w_uniform.screen_loc = null
			if(H.wear_suit)	H.wear_suit.screen_loc = null
			if(H.wear_mask)	H.wear_mask.screen_loc = null
			if(H.head)		H.head.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(hud_shown)
			if(H.s_store)	H.s_store.screen_loc = ui_sstore1
			if(H.wear_id)	H.wear_id.screen_loc = ui_id
			if(H.wear_pda)	H.wear_pda.screen_loc = ui_pda
			if(H.belt)		H.belt.screen_loc = ui_belt
			if(H.back)		H.back.screen_loc = ui_back
			if(H.l_store)	H.l_store.screen_loc = ui_storage1
			if(H.r_store)	H.r_store.screen_loc = ui_storage2
		else
			if(H.s_store)	H.s_store.screen_loc = null
			if(H.wear_id)	H.wear_id.screen_loc = null
			if(H.wear_pda)	H.wear_pda.screen_loc = null
			if(H.belt)		H.belt.screen_loc = null
			if(H.back)		H.back.screen_loc = null
			if(H.l_store)	H.l_store.screen_loc = null
			if(H.r_store)	H.r_store.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob)) return 0
	if(!mymob.client) return 0
	var/ui_style = ui_style2icon(mymob.client.prefs.UI_style)
	var/ui_color = mymob.client.prefs.UI_style_color
	var/ui_alpha = mymob.client.prefs.UI_style_alpha

	if(issmall(mymob))
		monkey_hud(ui_style, ui_color, ui_alpha)
	else if(ishuman(mymob))
		human_hud(ui_style, ui_color, ui_alpha) // Pass the player the UI style chosen in preferences
	else if( islarva(mymob) || isfacehugger(mymob) )
		larva_hud()
	else if (isembryo(mymob))
		embryo_hud()
	else if(isalien(mymob))
		alien_hud()
	else if(isAI(mymob))
		ai_hud()
	else if(isrobot(mymob))
		robot_hud()
	else if(isbot(mymob))
		bot_hud()
	else if(isobserver(mymob))
		ghost_hud()
	else if(isovermind(mymob))
		blob_hud()
	else if(mymob.mind && mymob.mind.vampire)
		vampire_hud()
	else if(isswarmer(mymob))
		swarmer_hud()
	else if(isguardian(mymob))
		guardian_hud()
	else if(ispet(mymob))
		corgi_hud()

	reload_fullscreen()
	create_parallax()

/client/var/list/spacebg = list()

var/list/parallax_on_clients = list()

var/area/global_space_area = null

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

/datum/hud/proc/create_parallax()
	var/client/C = mymob.client
	if (C.prefs.space_parallax)
		parallax_on_clients |= C
	else
		parallax_on_clients -= C
	for(var/area/A in all_areas)
		if(A.white_overlay)
			if (C.prefs.space_parallax)
				C.images |= A.white_overlay
			else
				C.images -= A.white_overlay
	if(C.prefs.space_parallax)
		for(var/obj/screen/spacebg/bgobj in C.spacebg)
			C.screen |= bgobj
	else
		for(var/obj/screen/spacebg/bgobj in C.spacebg)
			C.screen -= bgobj
			qdel(bgobj)
			C.spacebg -= bgobj
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
/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(hud_used)
		if(ishuman(src))
			if(!client) return
			if(client.view != world.view)
				return
			if(hud_used.hud_shown)
				hud_used.hud_shown = 0
				if(src.hud_used.adding)
					src.client.screen -= src.hud_used.adding
				if(src.hud_used.other)
					src.client.screen -= src.hud_used.other
				if(src.hud_used.hotkeybuttons)
					src.client.screen -= src.hud_used.hotkeybuttons

				//Due to some poor coding some things need special treatment:
				//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
				if(!full)
					src.client.screen += src.hud_used.l_hand_hud_object	//we want the hands to be visible
					src.client.screen += src.hud_used.r_hand_hud_object	//we want the hands to be visible
					src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
					src.hud_used.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
				else
					src.client.screen -= src.healths
					src.client.screen -= src.internals
					src.client.screen  -= src.healthdoll
					src.client.screen -= src.gun_setting_icon
					src.client.screen -= src.hud_used.lingstingdisplay
					src.client.screen -= src.hud_used.lingchemdisplay

				//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
				src.client.screen -= src.zone_sel	//zone_sel is a mob variable for some reason.

			else
				hud_used.hud_shown = 1
				if(src.hud_used.adding)
					src.client.screen += src.hud_used.adding
				if(src.hud_used.other && src.hud_used.inventory_shown)
					src.client.screen += src.hud_used.other
				if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
					src.client.screen += src.hud_used.hotkeybuttons
				if(src.healths)
					src.client.screen |= src.healths
				if(src.healthdoll)
					src.client.screen |= src.healthdoll
				if(src.internals)
					src.client.screen |= src.internals
				if(src.gun_setting_icon)
					src.client.screen |= src.gun_setting_icon
				if(src.hud_used.lingstingdisplay)
					src.client.screen |= src.hud_used.lingstingdisplay
				if(src.hud_used.lingchemdisplay)
					src.client.screen |= src.hud_used.lingchemdisplay

				src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
				src.client.screen += src.zone_sel				//This one is a special snowflake

			hud_used.hidden_inventory_update()
			hud_used.persistant_inventory_update()
			update_action_buttons()
			//hud_used.reorganize_alerts()

		else
			to_chat(usr, "\red Inventory hiding is currently only supported for human mobs, sorry.")
	else
		to_chat(usr, "\red This mob type does not use a HUD.")
