/obj/screen/human
	icon = 'icons/mob/screen1_midnight.dmi'

/obj/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/obj/screen/human/toggle/Click()
	if(usr.hud_used.inventory_shown)
		usr.hud_used.inventory_shown = 0
		usr.client.screen -= usr.hud_used.other
	else
		usr.hud_used.inventory_shown = 1
		usr.client.screen += usr.hud_used.other

	usr.hud_used.hidden_inventory_update()

/obj/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/obj/screen/human/equip/Click()
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/datum/hud/proc/human_hud(var/ui_style='icons/mob/screen1_White.dmi', var/ui_color = "#ffffff", var/ui_alpha = 255)

	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent()
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = "intent_"+mymob.a_intent
	using.screen_loc = ui_acti
	using.color = ui_color
	using.alpha = ui_alpha
	using.layer = 20
	src.adding += using
	action_intent = using



	using = new /obj/screen/mov_intent()
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using
	move_intent = using

	using = new /obj/screen/drop()
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.dir = SOUTH
	inv_box.icon = ui_style
	inv_box.slot_id = slot_w_uniform
	inv_box.icon_state = "center"
	inv_box.screen_loc = ui_iclothing
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.dir = SOUTH
	inv_box.icon = ui_style
	inv_box.slot_id = slot_wear_suit
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_oclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.layer = 19
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.dir = WEST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.dir = EAST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "id"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = slot_wear_id
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "pda"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "pda"
	inv_box.screen_loc = ui_pda
	inv_box.slot_id = slot_wear_pda
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.dir = 8 //The sprite at dir=8 has the background whereas the others don't.
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = slot_s_store
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	using = new /obj/screen/resist()
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = 19
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	using = new /obj/screen/human/toggle()
	using.name = "toggle"
	using.icon = ui_style
	using.icon_state = "other"
	using.screen_loc = ui_inventory
	using.layer = 20
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /obj/screen/human/equip()
	using.name = "equip"
	using.icon = ui_style
	using.icon_state = "act_equip"
	using.screen_loc = ui_equip
	using.layer = 20
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = slot_gloves
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = slot_glasses
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_l_ear
	inv_box.slot_id = slot_l_ear
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_r_ear
	inv_box.slot_id = slot_r_ear
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = slot_shoes
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = slot_belt
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	mymob.throw_icon = new /obj/screen/throw_catch()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	src.hotkeybuttons += mymob.throw_icon

	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = ui_style
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.pressure = new /obj/screen()
	mymob.pressure.icon = ui_style
	mymob.pressure.icon_state = "pressure0"
	mymob.pressure.name = "pressure"
	mymob.pressure.screen_loc = ui_pressure

	mymob.toxin = new /obj/screen()
	mymob.toxin.icon = ui_style
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.internals = new /obj/screen/internals()
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.fire = new /obj/screen()
	mymob.fire.icon = ui_style
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.bodytemp = new /obj/screen()
	mymob.bodytemp.icon = ui_style
	mymob.bodytemp.icon_state = "temp1"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	mymob.healths = new /obj/screen()
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.healthdoll = new /obj/screen()
	mymob.healthdoll.icon = ui_style
	mymob.healthdoll.icon_state = "healthdoll_DEAD"
	mymob.healthdoll.name = "health doll"
	mymob.healthdoll.screen_loc = ui_healthdoll

	mymob.nutrition_icon = new /obj/screen()
	mymob.nutrition_icon.icon = ui_style
	mymob.nutrition_icon.icon_state = "nutrition0"
	mymob.nutrition_icon.name = "nutrition"
	mymob.nutrition_icon.screen_loc = ui_nutrition

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	src.hotkeybuttons += mymob.pullin

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = "blind"
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.mouse_opacity = 0
	mymob.blind.layer = 0

	mymob.damageoverlay = new /obj/screen()
	mymob.damageoverlay.icon = 'icons/mob/screen1_full.dmi'
	mymob.damageoverlay.icon_state = "oxydamageoverlay0"
	mymob.damageoverlay.name = "dmg"
	mymob.damageoverlay.screen_loc = "CENTER-7,CENTER-7"
	mymob.damageoverlay.mouse_opacity = 0
	mymob.damageoverlay.layer = 18.1 //The black screen overlay sets layer to 18 to display it, this one has to be just on top.

	mymob.flash = new /obj/screen()
	mymob.flash.icon = ui_style
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.pain = new /obj/screen( null )

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /obj/screen/gun/mode(null)
	//mymob.gun_setting_icon.color = ui_color
	mymob.gun_setting_icon.alpha = ui_alpha

	mymob.item_use_icon = new /obj/screen/gun/item(null)
	//mymob.item_use_icon.color = ui_color
	mymob.item_use_icon.alpha = ui_alpha

	/*mymob.gun_move_icon = new /obj/screen/gun/move(null)
	//mymob.gun_move_icon.color = ui_color
	mymob.gun_move_icon.alpha = ui_alpha

	mymob.gun_run_icon = new /obj/screen/gun/run(null)
	//mymob.gun_run_icon.color = ui_color
	mymob.gun_run_icon.alpha = ui_alpha*/

	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.dir = 2


	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.healthdoll, mymob.nutrition_icon, mymob.pullin, mymob.blind, mymob.flash, mymob.damageoverlay, mymob.gun_setting_icon) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	mymob.client.screen += mymob.client.void
	inventory_shown = 0;

	return


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