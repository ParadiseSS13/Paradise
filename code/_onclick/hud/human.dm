/obj/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/obj/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/obj/screen/human/toggle/Click()
	if(usr.hud_used.inventory_shown)
		usr.hud_used.inventory_shown = 0
		usr.client.screen -= usr.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = 1
		usr.client.screen += usr.hud_used.toggleable_inventory

	usr.hud_used.hidden_inventory_update()

/obj/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/obj/screen/human/equip/Click()
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/obj/screen/ling
	invisibility = 101

/obj/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay

/obj/screen/ling/sting/Click()
	var/mob/living/carbon/U = usr
	U.unset_sting()

/obj/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay


/mob/living/carbon/human/proc/remake_hud() //used for preference changes mid-round; can't change hud icons without remaking the hud.
	if(hud_used)
		qdel(hud_used)
		hud_used = null
	create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

/mob/living/carbon/human/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/human(src, ui_style2icon(client.prefs.UI_style), client.prefs.UI_style_color, client.prefs.UI_style_alpha)

/datum/hud/human/New(mob/living/carbon/human/owner, var/ui_style = 'icons/mob/screen_white.dmi', var/ui_color = "#ffffff", var/ui_alpha = 255)
	..()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/inventory/craft
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /obj/screen/act_intent()
	using.icon_state = mymob.a_intent
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = slot_w_uniform
	inv_box.icon_state = "uniform"
	inv_box.screen_loc = ui_iclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = slot_wear_suit
	inv_box.icon_state = "suit"
	inv_box.screen_loc = ui_oclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = slot_wear_id
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "pda"
	inv_box.icon = ui_style
	inv_box.icon_state = "pda"
	inv_box.screen_loc = ui_pda
	inv_box.slot_id = slot_wear_pda
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = slot_s_store
	static_inventory += inv_box

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	using = new /obj/screen/human/toggle()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/human/equip()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_equip
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = slot_gloves
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = slot_glasses
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_l_ear
	inv_box.slot_id = slot_l_ear
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_r_ear
	inv_box.slot_id = slot_r_ear
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = slot_head
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = slot_shoes
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = slot_belt
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	mymob.throw_icon = new /obj/screen/throw_catch()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.screen_loc = ui_drop_throw
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	hotkeybuttons += mymob.throw_icon

	internals = new /obj/screen/internals()
	infodisplay += internals

	mymob.healths = new /obj/screen/healths()
	infodisplay += mymob.healths

	mymob.healthdoll = new()
	infodisplay += mymob.healthdoll

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	static_inventory += mymob.pullin

	lingchemdisplay = new /obj/screen/ling/chems()
	infodisplay += lingchemdisplay

	lingstingdisplay = new /obj/screen/ling/sting()
	infodisplay += lingstingdisplay

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.update_icon(mymob)
	static_inventory += mymob.zone_sel

	inventory_shown = 0

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

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

/datum/hud/human/persistant_inventory_update()
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
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1
