/obj/screen/bot
	icon = 'icons/mob/screen_bot.dmi'

/obj/screen/bot/radio
	name = "radio"
	icon_state = "radio"
	screen_loc = ui_bot_radio

/obj/screen/bot/radio/Click()
	if(isbot(usr))
		var/mob/living/simple_animal/bot/B = usr
		B.Radio.interact(usr)

/mob/living/simple_animal/bot/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/bot(src)

/datum/hud/bot/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/bot/radio()
	static_inventory += using

	healths = new /obj/screen/healths/bot()
	healths.screen_loc = ui_borg_health
	infodisplay += healths

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen_bot.dmi'
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_bot_pull
	static_inventory += pull_icon
