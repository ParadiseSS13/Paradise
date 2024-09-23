/atom/movable/screen/bot
	icon = 'icons/mob/screen_bot.dmi'

/atom/movable/screen/bot/radio
	name = "radio"
	icon_state = "radio"
	screen_loc = ui_bot_radio

/atom/movable/screen/bot/radio/Click()
	if(isbot(usr))
		var/mob/living/simple_animal/bot/B = usr
		B.Radio.interact(usr)

/datum/hud/bot/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/bot/radio()
	static_inventory += using

	mymob.healths = new /atom/movable/screen/healths/bot()
	mymob.healths.screen_loc = ui_borg_health
	infodisplay += mymob.healths

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_bot.dmi'
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_bot_pull
	static_inventory += mymob.pullin
