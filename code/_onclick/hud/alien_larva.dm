/datum/hud/larva/New(mob/owner)
	..()

	var/atom/movable/screen/using

	using = new /atom/movable/screen/act_intent/alien()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/mov_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	mymob.healths = new /atom/movable/screen/healths/alien()
	infodisplay += mymob.healths

	nightvisionicon = new /atom/movable/screen/alien/nightvision()
	infodisplay += nightvisionicon

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = UI_PULL_RESIST
	hotkeybuttons += mymob.pullin

	using = new /atom/movable/screen/language_menu
	using.screen_loc = UI_ALIENLARVA_LANGUAGE_MENU
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel/alien()
	zone_select.hud = src
	zone_select.update_icon(UPDATE_OVERLAYS)
	static_inventory += zone_select
