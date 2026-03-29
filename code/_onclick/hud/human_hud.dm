/atom/movable/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/atom/movable/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/atom/movable/screen/human/toggle/Click()

	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/M = usr.client.eye
			targetmob = M

	if(usr.hud_used.inventory_shown && targetmob.hud_used)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= targetmob.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += targetmob.hud_used.toggleable_inventory

	targetmob.hud_used.hidden_inventory_update(usr)

/atom/movable/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/atom/movable/screen/human/equip/Click()
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/atom/movable/screen/ling
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/ling/sting
	name = "current sting"
	screen_loc = UI_LINGSTINGDISPLAY

/atom/movable/screen/ling/sting/Click()
	if(isobserver(usr))
		return
	var/datum/antagonist/changeling/cling = usr.mind.has_antag_datum(/datum/antagonist/changeling)
	cling?.chosen_sting?.unset_sting()

/atom/movable/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = UI_LINGCHEMDISPLAY


/mob/living/carbon/human/proc/remake_hud() //used for preference changes mid-round; can't change hud icons without remaking the hud.
	QDEL_NULL(hud_used)
	create_mob_hud()
	update_action_buttons_icon()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

/mob/living/carbon/human/create_mob_hud()
	if(client && !hud_used)
		set_hud_used(new /datum/hud/human(src, ui_style2icon(client.prefs.UI_style), client.prefs.UI_style_color, client.prefs.UI_style_alpha))
		SEND_SIGNAL(src, COMSIG_HUMAN_CREATE_MOB_HUD)

/datum/hud/human
	var/hud_alpha = 255

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_white.dmi', ui_color = "#ffffff", ui_alpha = 255)
	..()
	owner.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/stretch/see_through_darkness)

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	hud_alpha = ui_alpha

	using = new /atom/movable/screen/craft
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/language_menu
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/act_intent()
	using.icon_state = mymob.a_intent
	using.alpha = ui_alpha
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	using.screen_loc = UI_MOVI
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	using.screen_loc = UI_DROP_THROW
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = ITEM_SLOT_JUMPSUIT
	inv_box.icon_state = "uniform"
	inv_box.screen_loc = UI_ICLOTHING
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = ITEM_SLOT_OUTER_SUIT
	inv_box.icon_state = "suit"
	inv_box.screen_loc = UI_OCLOTHING
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = UI_RHAND
	inv_box.slot_id = ITEM_SLOT_RIGHT_HAND
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = UI_LHAND
	inv_box.slot_id = ITEM_SLOT_LEFT_HAND
	static_inventory += inv_box

	using = new /atom/movable/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = UI_SWAPHAND1
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = UI_SWAPHAND2
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = UI_ID
	inv_box.slot_id = ITEM_SLOT_ID
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "pda"
	inv_box.icon = ui_style
	inv_box.icon_state = "pda"
	inv_box.screen_loc = UI_PDA
	inv_box.slot_id = ITEM_SLOT_PDA
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = UI_MASK
	inv_box.slot_id = ITEM_SLOT_MASK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "neck"
	inv_box.screen_loc = UI_NECK
	inv_box.slot_id = ITEM_SLOT_NECK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = UI_BACK
	inv_box.slot_id = ITEM_SLOT_BACK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "left_pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = UI_STORAGE1
	inv_box.slot_id = ITEM_SLOT_LEFT_POCKET
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "right_pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = UI_STORAGE2
	inv_box.slot_id = ITEM_SLOT_RIGHT_POCKET
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = UI_SSTORE1
	inv_box.slot_id = ITEM_SLOT_SUIT_STORE
	static_inventory += inv_box

	using = new /atom/movable/screen/resist()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = UI_PULL_RESIST
	hotkeybuttons += using

	using = new /atom/movable/screen/human/toggle()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = UI_INVENTORY
	static_inventory += using

	using = new /atom/movable/screen/human/equip()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = UI_EQUIP
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = UI_GLOVES
	inv_box.slot_id = ITEM_SLOT_GLOVES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = UI_GLASSES
	inv_box.slot_id = ITEM_SLOT_EYES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "l_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = UI_L_EAR
	inv_box.slot_id = ITEM_SLOT_LEFT_EAR
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "r_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = UI_R_EAR
	inv_box.slot_id = ITEM_SLOT_RIGHT_EAR
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = UI_HEAD
	inv_box.slot_id = ITEM_SLOT_HEAD
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = UI_SHOES
	inv_box.slot_id = ITEM_SLOT_SHOES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = UI_BELT
	inv_box.slot_id = ITEM_SLOT_BELT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	mymob.throw_icon = new /atom/movable/screen/throw_catch()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.screen_loc = UI_DROP_THROW
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	hotkeybuttons += mymob.throw_icon

	mymob.healths = new /atom/movable/screen/healths()
	infodisplay += mymob.healths

	mymob.staminas = new /atom/movable/screen/healths/stamina()
	infodisplay += mymob.staminas

	mymob.healthdoll = new()
	infodisplay += mymob.healthdoll

	mymob.nutrition_display = new()
	infodisplay += mymob.nutrition_display

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = UI_PULL_RESIST
	static_inventory += mymob.pullin

	lingchemdisplay = new /atom/movable/screen/ling/chems()
	infodisplay += lingchemdisplay

	lingstingdisplay = new /atom/movable/screen/ling/sting()
	infodisplay += lingstingdisplay

	zone_select =  new /atom/movable/screen/zone_sel()
	zone_select.color = ui_color
	zone_select.icon = ui_style
	zone_select.alpha = ui_alpha
	zone_select.hud = src
	zone_select.update_icon(UPDATE_OVERLAYS)
	static_inventory += zone_select

	inventory_shown = FALSE

	combo_display = new()
	infodisplay += combo_display

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[ITEM_SLOT_2_INDEX(inv.slot_id)] = inv
			inv.update_icon()

	update_locked_slots()

/datum/hud/human/update_locked_slots()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(!istype(H) || !H.dna.species)
		return
	var/datum/species/S = H.dna.species
	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			if(inv.slot_id & S.no_equip)
				inv.alpha = hud_alpha / 2
			else
				inv.alpha = hud_alpha
	for(var/atom/movable/screen/craft/crafting in static_inventory)
		if(!S.can_craft)
			crafting.invisibility = INVISIBILITY_ABSTRACT
			H.handcrafting?.close(H)
		else
			crafting.invisibility = initial(crafting.invisibility)

/datum/hud/human/hidden_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H
	if(screenmob.hud_used.inventory_shown && screenmob.hud_used.hud_shown && screenmob.hud_used.hud_version == HUD_STYLE_STANDARD)

		if(H.shoes)
			H.shoes.screen_loc = UI_SHOES
			screenmob.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = UI_GLOVES
			screenmob.client.screen += H.gloves
		if(H.l_ear)
			H.l_ear.screen_loc = UI_L_EAR
			screenmob.client.screen += H.l_ear
		if(H.r_ear)
			H.r_ear.screen_loc = UI_R_EAR
			screenmob.client.screen += H.r_ear
		if(H.glasses)
			H.glasses.screen_loc = UI_GLASSES
			screenmob.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = UI_ICLOTHING
			screenmob.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = UI_OCLOTHING
			screenmob.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = UI_MASK
			screenmob.client.screen += H.wear_mask
		if(H.neck)
			H.neck.screen_loc = UI_NECK
			screenmob.client.screen += H.neck
		if(H.head)
			H.head.screen_loc = UI_HEAD
			screenmob.client.screen += H.head
	else
		if(H.shoes)
			screenmob.client.screen -= H.shoes
		if(H.gloves)
			screenmob.client.screen -= H.gloves
		if(H.l_ear)
			screenmob.client.screen -= H.l_ear
		if(H.r_ear)
			screenmob.client.screen -= H.r_ear
		if(H.glasses)
			screenmob.client.screen -= H.glasses
		if(H.w_uniform)
			screenmob.client.screen -= H.w_uniform
		if(H.wear_suit)
			screenmob.client.screen -= H.wear_suit
		if(H.wear_mask)
			screenmob.client.screen -= H.wear_mask
		if(H.neck)
			screenmob.client.screen -= H.neck
		if(H.head)
			screenmob.client.screen -= H.head

/datum/hud/human/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	..()
	var/mob/living/carbon/human/H = mymob
	var/mob/screenmob = viewer || H

	if(screenmob.hud_used)
		if(screenmob.hud_used.hud_shown && screenmob.hud_used.hud_version == HUD_STYLE_STANDARD)
			if(H.s_store)
				H.s_store.screen_loc = UI_SSTORE1
				screenmob.client.screen += H.s_store
			if(H.wear_id)
				H.wear_id.screen_loc = UI_ID
				screenmob.client.screen += H.wear_id
			if(H.wear_pda)
				H.wear_pda.screen_loc = UI_PDA
				screenmob.client.screen += H.wear_pda
			if(H.belt)
				H.belt.screen_loc = UI_BELT
				screenmob.client.screen += H.belt
			if(H.back)
				H.back.screen_loc = UI_BACK
				screenmob.client.screen += H.back
			if(H.l_store)
				H.l_store.screen_loc = UI_STORAGE1
				screenmob.client.screen += H.l_store
			if(H.r_store)
				H.r_store.screen_loc = UI_STORAGE2
				screenmob.client.screen += H.r_store
		else
			if(H.s_store)
				screenmob.client.screen -= H.s_store
			if(H.wear_id)
				screenmob.client.screen -= H.wear_id
			if(H.wear_pda)
				screenmob.client.screen -= H.wear_pda
			if(H.belt)
				screenmob.client.screen -= H.belt
			if(H.back)
				screenmob.client.screen -= H.back
			if(H.l_store)
				screenmob.client.screen -= H.l_store
			if(H.r_store)
				screenmob.client.screen -= H.r_store

	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = UI_RHAND
			screenmob.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = UI_LHAND
			screenmob.client.screen += H.l_hand
	else
		if(H.r_hand)
			screenmob.r_hand.screen_loc = null
			screenmob.client.screen -= H.r_hand
		if(H.l_hand)
			screenmob.l_hand.screen_loc = null
			screenmob.client.screen -= H.l_hand
