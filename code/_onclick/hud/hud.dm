/*
	The global hud:
	Uses the same visual objects for all players.
*/
var/datum/global_hud/global_hud = new()

/datum/hud/var/obj/screen/grab_intent
/datum/hud/var/obj/screen/hurt_intent
/datum/hud/var/obj/screen/disarm_intent
/datum/hud/var/obj/screen/help_intent

/datum/global_hud
	var/obj/screen/druggy
	var/obj/screen/blurry
	var/list/vimpaired
	var/list/darkMask

/datum/global_hud/New()
	//420erryday psychedellic colours screen overlay for when you are high
	druggy = new /obj/screen()
	druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	druggy.icon_state = "druggy"
	druggy.layer = 17
	druggy.mouse_opacity = 0

	//that white blurry effect you get when you eyes are damaged
	blurry = new /obj/screen()
	blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blurry.icon_state = "blurry"
	blurry.layer = 17
	blurry.mouse_opacity = 0

	var/obj/screen/O
	var/i
	//that nasty looking dither you  get when you're short-sighted
	vimpaired = newlist(/obj/screen,/obj/screen,/obj/screen,/obj/screen)
	O = vimpaired[1]
	O.screen_loc = "1,1 to 6,17"
	O = vimpaired[2]
	O.screen_loc = "6,1 to 11,6"
	O = vimpaired[3]
	O.screen_loc = "7,12 to 11,17"
	O = vimpaired[4]
	O.screen_loc = "12,1 to 17,17"

	//welding mask overlay black/dither
	darkMask = newlist(/obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen)
	O = darkMask[1]
	O.screen_loc = "4,4 to 6,14"
	O = darkMask[2]
	O.screen_loc = "6,4 to 11,6"
	O = darkMask[3]
	O.screen_loc = "7,12 to 11,14"
	O = darkMask[4]
	O.screen_loc = "12,4 to 14,14"
	O = darkMask[5]
	O.screen_loc = "1,1 to 16,3"
	O = darkMask[6]
	O.screen_loc = "1,4 to 3,17"
	O = darkMask[7]
	O.screen_loc = "15,4 to 17,17"
	O = darkMask[8]
	O.screen_loc = "4,15 to 14,17"

	for(i = 1, i <= 4, i++)
		O = vimpaired[i]
		O.icon_state = "dither50"
		O.layer = 17
		O.mouse_opacity = 0

		O = darkMask[i]
		O.icon_state = "dither50"
		O.layer = 17
		O.mouse_opacity = 0

	for(i = 5, i <= 8, i++)
		O = darkMask[i]
		O.icon_state = "black"
		O.layer = 17
		O.mouse_opacity = 0

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
	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/vampire_blood_display
	var/obj/screen/alien_plasma_display
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/list/obj/screen/item_action/item_action_list = list()	//Used for the item action ui buttons.
	var/list/obj/screen/item_action/power_action_list = list()	//Used for the power action ui buttons.

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

	if(ishuman(mymob))
		human_hud(ui_style, ui_color, ui_alpha) // Pass the player the UI style chosen in preferences
	else if(ismonkey(mymob))
		monkey_hud(ui_style)
	else if(isbrain(mymob))
		brain_hud(ui_style)
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
	else if(isobserver(mymob))
		ghost_hud()
	else if(isovermind(mymob))
		blob_hud()
	else if(mymob.mind && mymob.mind.vampire)
		vampire_hud()
		human_hud('icons/mob/screen1_Vampire.dmi')

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
				if(src.hud_used.item_action_list)
					src.client.screen -= src.hud_used.item_action_list

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
					src.client.screen -= src.gun_setting_icon

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
				if(src.internals)
					src.client.screen |= src.internals
				if(src.gun_setting_icon)
					src.client.screen |= src.gun_setting_icon

				src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
				src.client.screen += src.zone_sel				//This one is a special snowflake

			hud_used.hidden_inventory_update()
			hud_used.persistant_inventory_update()
			update_action_buttons()
		else
			usr << "\red Inventory hiding is currently only supported for human mobs, sorry."
	else
		usr << "\red This mob type does not use a HUD."
