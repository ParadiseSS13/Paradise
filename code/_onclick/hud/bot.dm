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

	mymob.healths = new /obj/screen/healths/bot()
	mymob.healths.screen_loc = ui_borg_health
	infodisplay += mymob.healths

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_bot.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_bot_pull
	static_inventory += mymob.pullin