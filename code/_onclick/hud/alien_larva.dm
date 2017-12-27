/mob/living/carbon/alien/larva/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/larva(src)

/datum/hud/larva/New(mob/owner)
	..()

	var/obj/screen/using

	using = new /obj/screen/act_intent/alien()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	mymob.healths = new /obj/screen/healths/alien()
	infodisplay += mymob.healths

	nightvisionicon = new /obj/screen/alien/nightvision()
	infodisplay += nightvisionicon

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	hotkeybuttons += mymob.pullin

	using = new /obj/screen/language_menu
	using.screen_loc = ui_alienlarva_language_menu
	static_inventory += using

	mymob.zone_sel = new /obj/screen/zone_sel/alien()
	mymob.zone_sel.update_icon(mymob)
	static_inventory += mymob.zone_sel
