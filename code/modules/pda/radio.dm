//TODO convert this crap over to proper radios or find a way to utilize regualr radios for this object, this thing needs to go.

/obj/item/integrated_radio
	name = "\improper PDA radio module"
	desc = "An electronic radio system of Nanotrasen origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	var/obj/item/pda/hostpda = null
	var/list/botlist = null		// list of bots
	var/mob/living/simple_animal/bot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot
	var/bot_type				//The type of bot it is.
	var/bot_filter				//Determines which radio filter to use.

	var/control_freq = 1447

	var/on = FALSE //Are we currently active??
	var/menu_message = ""

/obj/item/integrated_radio/Initialize(mapload)
	. = ..()
	if(istype(loc.loc, /obj/item/pda))
		hostpda = loc.loc
	if(bot_filter)
		add_to_radio(bot_filter)

/obj/item/integrated_radio/Destroy()
	if(SSradio)
		SSradio.remove_object(src, control_freq)
	hostpda = null
	return ..()

/obj/item/integrated_radio/proc/add_to_radio(bot_filter) //Master filter control for bots. Must be placed in the bot's local New() to support map spawned bots.
	if(SSradio)
		SSradio.add_object(src, control_freq, filter = bot_filter)

/obj/item/integrated_radio/honkbot
	bot_filter = RADIO_HONKBOT
	bot_type = HONK_BOT

/obj/item/integrated_radio/beepsky
	bot_filter = RADIO_SECBOT
	bot_type = SEC_BOT

/obj/item/integrated_radio/medbot
	bot_filter = RADIO_MEDBOT
	bot_type = MED_BOT

/obj/item/integrated_radio/floorbot
	bot_filter = RADIO_FLOORBOT
	bot_type = FLOOR_BOT

/obj/item/integrated_radio/cleanbot
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT

/obj/item/integrated_radio/mule
	bot_filter = RADIO_MULEBOT
	bot_type = MULE_BOT

/*
/obj/item/integrated_radio/mule/Topic(href, href_list)
	..()
	switch(href_list["op"])
		if("start")
			post_signal(control_freq, "command", "start", "active", active, s_filter = RADIO_MULEBOT)

		if("unload")
			post_signal(control_freq, "command", "unload", "active", active, s_filter = RADIO_MULEBOT)

		if("setdest")
			if(GLOB.deliverybeacons)
				var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active.destination) as null|anything in GLOB.deliverybeacontags
				if(dest)
					post_signal(control_freq, "command", "target", "active", active, "destination", dest, s_filter = RADIO_MULEBOT)

		if("retoff")
			post_signal(control_freq, "command", "autoret", "active", active, "value", 0, s_filter = RADIO_MULEBOT)

		if("reton")
			post_signal(control_freq, "command", "autoret", "active", active, "value", 1, s_filter = RADIO_MULEBOT)

		if("pickoff")
			post_signal(control_freq, "command", "autopick", "active", active, "value", 0, s_filter = RADIO_MULEBOT)

		if("pickon")
			post_signal(control_freq, "command", "autopick", "active", active, "value", 1, s_filter = RADIO_MULEBOT)

	post_signal(control_freq, "command", "bot_status", "active", active, s_filter = RADIO_MULEBOT)
*/
