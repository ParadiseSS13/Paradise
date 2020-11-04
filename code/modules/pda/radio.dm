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

	var/on = 0 //Are we currently active??
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

/obj/item/integrated_radio/proc/post_signal(var/freq, var/key, var/value, var/key2, var/value2, var/key3, var/value3,var/key4, var/value4, s_filter)

//	to_chat(world, "Post: [freq]: [key]=[value], [key2]=[value2]")
	var/datum/radio_frequency/frequency = SSradio.return_frequency(freq)

	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3
	if(key4)
		signal.data[key4] = value4

	frequency.post_signal(src, signal, filter = s_filter)

/obj/item/integrated_radio/receive_signal(datum/signal/signal)
	if(bot_type && istype(signal.source, /obj/machinery/bot_core) && signal.data["type"] == bot_type)
		if(!botlist)
			botlist = new()

		var/obj/machinery/bot_core/core = signal.source

		if(istype(core) && !(core.owner in botlist))
			botlist += core.owner

		if(active == core.owner)
			var/list/b = signal.data
			botstatus = b.Copy()

/obj/item/integrated_radio/Topic(href, href_list)
	..()
	switch(href_list["op"])
		if("control")
			active = locate(href_list["bot"])
			spawn(0)
				post_signal(control_freq, "command", "bot_status", "active", active, s_filter = bot_filter)

		if("scanbots")		// find all bots
			botlist = null
			spawn(0)
				post_signal(control_freq, "command", "bot_status", s_filter = bot_filter)

		if("botlist")
			active = null

		if("stop", "go", "home")
			spawn(0)
				post_signal(control_freq, "command", href_list["op"], "active", active, s_filter = bot_filter)
				post_signal(control_freq, "command", "bot_status", "active", active, s_filter = bot_filter)

		if("summon")
			spawn(0)
				post_signal(control_freq, "command", "summon", "active", active, "target", get_turf(hostpda), "useraccess", hostpda.GetAccess(), "user", usr, s_filter = bot_filter)
				post_signal(control_freq, "command", "bot_status", "active", active, s_filter = bot_filter)

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

/obj/item/integrated_radio/mule/Topic(href, href_list)
	..()
	switch(href_list["op"])
		if("start")
			spawn(0)
				post_signal(control_freq, "command", "start", "active", active, s_filter = RADIO_MULEBOT)

		if("unload")
			spawn(0)
				post_signal(control_freq, "command", "unload", "active", active, s_filter = RADIO_MULEBOT)

		if("setdest")
			if(GLOB.deliverybeacons)
				var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active.destination) as null|anything in GLOB.deliverybeacontags
				if(dest)
					spawn(0)
						post_signal(control_freq, "command", "target", "active", active, "destination", dest, s_filter = RADIO_MULEBOT)

		if("retoff")
			spawn(0)
				post_signal(control_freq, "command", "autoret", "active", active, "value", 0, s_filter = RADIO_MULEBOT)

		if("reton")
			spawn(0)
				post_signal(control_freq, "command", "autoret", "active", active, "value", 1, s_filter = RADIO_MULEBOT)

		if("pickoff")
			spawn(0)
				post_signal(control_freq, "command", "autopick", "active", active, "value", 0, s_filter = RADIO_MULEBOT)

		if("pickon")
			spawn(0)
				post_signal(control_freq, "command", "autopick", "active", active, "value", 1, s_filter = RADIO_MULEBOT)

	spawn(10)
		post_signal(control_freq, "command", "bot_status", "active", active, s_filter = RADIO_MULEBOT)



/*
 *	Radio Cartridge, essentially a signaler.
 */


/obj/item/integrated_radio/signal
	var/frequency = RSD_FREQ
	var/code = 30.0
	var/last_transmission
	var/datum/radio_frequency/radio_connection

/obj/item/integrated_radio/signal/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/item/integrated_radio/signal/Initialize(mapload)
	. = ..()
	if(!SSradio)
		return
	if(src.frequency < PUBLIC_LOW_FREQ || src.frequency > PUBLIC_HIGH_FREQ)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/integrated_radio/signal/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency)

/obj/item/integrated_radio/signal/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	spawn(0)
		radio_connection.post_signal(src, signal)
