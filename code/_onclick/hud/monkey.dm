/datum/hud/proc/monkey_hud(var/ui_style='icons/mob/screen1_White.dmi', var/ui_color = "#ffffff", var/ui_alpha = 255)

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
	src.adding += using

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
	inv_box.name = "mask"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = 19
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.dir = NORTHEAST
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
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

	mymob.internals = new /obj/screen/internals()
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

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

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	src.hotkeybuttons += mymob.pullin

	lingchemdisplay = new /obj/screen/ling/chems()
	lingchemdisplay.screen_loc = ui_lingchemdisplay

	lingstingdisplay = new /obj/screen/ling/sting()
	lingstingdisplay.screen_loc = ui_lingstingdisplay

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

	mymob.client.screen += list(mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.healthdoll, mymob.pullin, mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	mymob.client.screen += mymob.client.void

	return