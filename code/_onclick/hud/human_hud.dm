/atom/movable/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/atom/movable/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/atom/movable/screen/human/toggle/Click()
	if(usr.hud_used.inventory_shown)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= usr.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += usr.hud_used.toggleable_inventory

	usr.hud_used.hidden_inventory_update()

/atom/movable/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/atom/movable/screen/human/equip/Click()
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/atom/movable/screen/ling
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay

/atom/movable/screen/ling/sting/Click()
	var/datum/antagonist/changeling/cling = usr.mind.has_antag_datum(/datum/antagonist/changeling)
	cling?.chosen_sting?.unset_sting()

/atom/movable/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay


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
	owner.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/see_through_darkness)

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
	using.screen_loc = ui_movi
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = SLOT_HUD_JUMPSUIT
	inv_box.icon_state = "uniform"
	inv_box.screen_loc = ui_iclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = SLOT_HUD_OUTER_SUIT
	inv_box.icon_state = "suit"
	inv_box.screen_loc = ui_oclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = SLOT_HUD_RIGHT_HAND
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = SLOT_HUD_LEFT_HAND
	static_inventory += inv_box

	using = new /atom/movable/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = SLOT_HUD_WEAR_ID
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "pda"
	inv_box.icon = ui_style
	inv_box.icon_state = "pda"
	inv_box.screen_loc = ui_pda
	inv_box.slot_id = SLOT_HUD_WEAR_PDA
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = SLOT_HUD_WEAR_MASK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = SLOT_HUD_BACK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = SLOT_HUD_LEFT_STORE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = SLOT_HUD_RIGHT_STORE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = SLOT_HUD_SUIT_STORE
	static_inventory += inv_box

	using = new /atom/movable/screen/resist()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	using = new /atom/movable/screen/human/toggle()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /atom/movable/screen/human/equip()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_equip
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = SLOT_HUD_GLOVES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = SLOT_HUD_GLASSES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "l_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_l_ear
	inv_box.slot_id = SLOT_HUD_LEFT_EAR
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "r_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_r_ear
	inv_box.slot_id = SLOT_HUD_RIGHT_EAR
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = SLOT_HUD_HEAD
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = SLOT_HUD_SHOES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = SLOT_HUD_BELT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	mymob.throw_icon = new /atom/movable/screen/throw_catch()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.screen_loc = ui_drop_throw
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	hotkeybuttons += mymob.throw_icon

	mymob.healths = new /atom/movable/screen/healths()
	infodisplay += mymob.healths

	mymob.healthdoll = new()
	infodisplay += mymob.healthdoll

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_pull_resist
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
			inv_slots[inv.slot_id] = inv
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
			if(inv.slot_id in S.no_equip)
				inv.alpha = hud_alpha / 2
			else
				inv.alpha = hud_alpha
	for(var/atom/movable/screen/craft/crafting in static_inventory)
		if(!S.can_craft)
			crafting.invisibility = INVISIBILITY_ABSTRACT
			H.handcrafting?.close(H)
		else
			crafting.invisibility = initial(crafting.invisibility)

/datum/hud/human/hidden_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(inventory_shown && hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = ui_shoes
			H.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = ui_gloves
			H.client.screen += H.gloves
		if(H.l_ear)
			H.l_ear.screen_loc = ui_l_ear
			H.client.screen += H.l_ear
		if(H.r_ear)
			H.r_ear.screen_loc = ui_r_ear
			H.client.screen += H.r_ear
		if(H.glasses)
			H.glasses.screen_loc = ui_glasses
			H.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = ui_iclothing
			H.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = ui_oclothing
			H.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = ui_mask
			H.client.screen += H.wear_mask
		if(H.head)
			H.head.screen_loc = ui_head
			H.client.screen += H.head
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

/datum/hud/human/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(hud_shown)
		if(H.s_store)
			H.s_store.screen_loc = ui_sstore1
			H.client.screen += H.s_store
		if(H.wear_id)
			H.wear_id.screen_loc = ui_id
			H.client.screen += H.wear_id
		if(H.wear_pda)
			H.wear_pda.screen_loc = ui_pda
			H.client.screen += H.wear_pda
		if(H.belt)
			H.belt.screen_loc = ui_belt
			H.client.screen += H.belt
		if(H.back)
			H.back.screen_loc = ui_back
			H.client.screen += H.back
		if(H.l_store)
			H.l_store.screen_loc = ui_storage1
			H.client.screen += H.l_store
		if(H.r_store)
			H.r_store.screen_loc = ui_storage2
			H.client.screen += H.r_store
	else
		if(H.s_store)
			H.s_store.screen_loc = null
		if(H.wear_id)
			H.wear_id.screen_loc = null
		if(H.wear_pda)
			H.wear_pda.screen_loc = null
		if(H.belt)
			H.belt.screen_loc = null
		if(H.back)
			H.back.screen_loc = null
		if(H.l_store)
			H.l_store.screen_loc = null
		if(H.r_store)
			H.r_store.screen_loc = null

	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			H.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			H.client.screen += H.l_hand
	else
		if(H.r_hand)
			H.r_hand.screen_loc = null
		if(H.l_hand)
			H.l_hand.screen_loc = null


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle Hotkey Buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = FALSE
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = TRUE
