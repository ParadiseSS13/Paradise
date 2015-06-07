/datum/hud/proc/embryo_hud()
	return

/datum/hud/proc/alien_hud()
	src.adding = list()
	src.other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen()
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	using = new /obj/screen()
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

	if(istype(mymob, /mob/living/carbon/alien/humanoid/hunter))
		mymob.leap_icon = new /obj/screen()
		mymob.leap_icon.icon = 'icons/mob/screen1_alien.dmi'
		mymob.leap_icon.name = "toggle leap"
		mymob.leap_icon.icon_state = "leap_off"
		mymob.leap_icon.screen_loc = ui_alien_storage_r
		src.adding += mymob.leap_icon

//equippable shit
	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.dir = WEST
	inv_box.icon = 'icons/mob/screen1_alien.dmi'
	inv_box.icon_state = "hand_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = 19
	src.r_hand_hud_object = inv_box
	inv_box.slot_id = slot_r_hand
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.dir = EAST
	inv_box.icon = 'icons/mob/screen1_alien.dmi'
	inv_box.icon_state = "hand_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_lhand
	inv_box.layer = 19
	inv_box.slot_id = slot_l_hand
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	src.adding += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	src.adding += using

//end of equippable shit

	using = new /obj/screen()
	using.name = "resist"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = 19
	src.adding += using

	using = new /obj/screen()
	using.name = "drop"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.adding += using

	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = 'icons/mob/screen1_alien.dmi'
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen1_alien.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_alien_oxygen

	mymob.toxin = new /obj/screen()
	mymob.toxin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_alien_toxin

	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_alien.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_alien_fire

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	nightvisionicon = new /obj/screen()
	nightvisionicon.icon = 'icons/mob/screen1_alien.dmi'
	nightvisionicon.icon_state = "nightvision1"
	nightvisionicon.name = "night vision"
	nightvisionicon.screen_loc = ui_alien_nightvision

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

	alien_plasma_display = new /obj/screen()
	alien_plasma_display.icon = 'icons/mob/screen_gen.dmi'
	alien_plasma_display.icon_state = "power_display"
	alien_plasma_display.name = "plasma stored"
	alien_plasma_display.screen_loc = ui_alienplasmadisplay

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen1_alien.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen1_alien.dmi'
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.toxin, mymob.fire, mymob.healths, nightvisionicon, mymob.pullin, alien_plasma_display, mymob.pullin, mymob.blind, mymob.flash) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other