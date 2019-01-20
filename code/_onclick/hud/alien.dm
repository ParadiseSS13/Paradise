/obj/screen/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/obj/screen/alien/leap/Click()
	if(istype(usr, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/alien/humanoid/hunter/AH = usr
		AH.toggle_leap()

/obj/screen/alien/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"

/obj/screen/alien/nightvision/Click()
	var/mob/living/carbon/alien/humanoid/A = usr
	A.nightvisiontoggle()


/obj/screen/alien/plasma_display
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_display2"
	name = "plasma stored"
	screen_loc = ui_alienplasmadisplay


/mob/living/carbon/alien/humanoid/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/alien(src)

/datum/hud/alien/New(mob/living/carbon/alien/humanoid/owner)
	..()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	static_inventory += using

	using = new /obj/screen/act_intent/alien()
	using.icon_state = (mymob.a_intent == "hurt" ? INTENT_HARM : mymob.a_intent)
	using.screen_loc = ui_acti
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	using.screen_loc = ui_movi
	static_inventory += using
	move_intent = using

	if(istype(mymob, /mob/living/carbon/alien/humanoid/hunter))
		mymob.leap_icon = new /obj/screen/alien/leap()
		mymob.leap_icon.icon = 'icons/mob/screen_alien.dmi'
		mymob.leap_icon.screen_loc = ui_alien_storage_r
		static_inventory += mymob.leap_icon

//equippable shit
	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "r_hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "l_hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.name = "hand"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.name = "hand"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	static_inventory += using

//end of equippable shit

	using = new /obj/screen/resist()
	using.name = "resist"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	static_inventory += using

	using = new /obj/screen/drop()
	using.name = "drop"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	static_inventory += using

	mymob.throw_icon = new /obj/screen/throw_catch()
	mymob.throw_icon.icon = 'icons/mob/screen_alien.dmi'
	mymob.throw_icon.screen_loc = ui_drop_throw
	static_inventory += mymob.throw_icon

	mymob.healths = new /obj/screen/healths/alien()
	infodisplay += mymob.healths

	nightvisionicon = new /obj/screen/alien/nightvision()
	infodisplay += nightvisionicon

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	hotkeybuttons += mymob.pullin

	alien_plasma_display = new /obj/screen/alien/plasma_display()
	infodisplay += alien_plasma_display

	mymob.zone_sel = new /obj/screen/zone_sel/alien()
	mymob.zone_sel.update_icon(mymob)
	static_inventory += mymob.zone_sel

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/alien/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/alien/humanoid/H = mymob
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
