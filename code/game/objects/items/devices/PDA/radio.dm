/obj/item/radio/integrated
	name = "\improper PDA radio module"
	desc = "An electronic radio system of Nanotrasen origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	var/obj/item/device/pda/hostpda = null
	var/list/botlist = null		// list of bots
	var/obj/machinery/bot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot
	var/bot_type				//The type of bot it is.
	var/bot_filter				//Determines which radio filter to use.

	var/control_freq = 1447

	var/on = 0 //Are we currently active??
	var/menu_message = ""

/obj/item/radio/integrated/New()
	..()
	if (istype(loc.loc, /obj/item/device/pda))
		hostpda = loc.loc
	if (bot_filter)
		spawn(5)
			add_to_radio(bot_filter)

/obj/item/radio/integrated/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, control_freq)
	return ..()

/obj/item/radio/integrated/proc/post_signal(var/freq, var/key, var/value, var/key2, var/value2, var/key3, var/value3,var/key4, var/value4, s_filter)

	//world << "Post: [freq]: [key]=[value], [key2]=[value2]"
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

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

	return

/obj/item/radio/integrated/receive_signal(datum/signal/signal)
	/*var/obj/item/device/pda/P = src.loc


	world << "recvd:[P] : [signal.source]"
	for(var/d in signal.data)
		world << "- [d] = [signal.data[d]]"
		*/

	if (signal.data["type"] == bot_type)
		if(!botlist)
			botlist = new()

		if(!(signal.source in botlist))
			botlist += signal.source

		if(active == signal.source)
			var/list/b = signal.data
			botstatus = b.Copy()

/obj/item/radio/integrated/Topic(href, href_list)
	..()
	var/obj/item/device/pda/PDA = src.hostpda

	switch(href_list["op"])

		if("control")
			active = locate(href_list["bot"])
			post_signal(control_freq, "command", "bot_status", "active", active, s_filter = bot_filter)

		if("scanbots")		// find all bots
			botlist = null
			post_signal(control_freq, "command", "bot_status", s_filter = bot_filter)

		if("botlist")
			active = null

		if("stop", "go")
			post_signal(control_freq, "command", href_list["op"], "active", active, s_filter = bot_filter)
			post_signal(control_freq, "command", "bot_status", "active", active, s_filter = bot_filter)

		if("summon")
			post_signal(control_freq, "command", "summon", "active", active, "target", get_turf(PDA) , "useraccess", PDA.GetAccess(), s_filter = bot_filter)
			post_signal(control_freq, "command", "bot_status", "active", active, s_filter = bot_filter)

/obj/item/radio/integrated/proc/add_to_radio(bot_filter) //Master filter control for bots. Must be placed in the bot's local New() to support map spawned bots.
	if(radio_controller)
		radio_controller.add_object(src, control_freq, filter = bot_filter)


/obj/item/radio/integrated/beepsky
	bot_filter = RADIO_SECBOT
	bot_type = SEC_BOT

/obj/item/radio/integrated/medbot
	bot_filter = RADIO_MEDBOT
	bot_type = MED_BOT

/obj/item/radio/integrated/floorbot
	bot_filter = RADIO_FLOORBOT
	bot_type = FLOOR_BOT

/obj/item/radio/integrated/cleanbot
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT

/obj/item/radio/integrated/mule
	//var/list/botlist = null		// list of bots
	//var/obj/machinery/bot/mulebot/active 	// the active bot; if null, show bot list
	//var/list/botstatus			// the status signal sent by the bot
	var/list/beacons

	var/beacon_freq = 1400
	control_freq = 1447

// create a new QM cartridge, and register to receive bot control & beacon message
/obj/item/radio/integrated/mule/New()
	..()
	spawn(5)
		if(radio_controller)
			radio_controller.add_object(src, control_freq, filter = RADIO_MULEBOT)
			radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
			spawn(10)
				post_signal(beacon_freq, "findbeacon", "delivery", s_filter = RADIO_NAVBEACONS)

/obj/item/radio/integrated/mule/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,beacon_freq)
	return ..()

// receive radio signals
// can detect bot status signals
// and beacon locations
// create/populate lists as they are recvd

/obj/item/radio/integrated/mule/receive_signal(datum/signal/signal)
//	var/obj/item/device/pda/P = src.loc

	/*
	world << "recvd:[P] : [signal.source]"
	for(var/d in signal.data)
		world << "- [d] = [signal.data[d]]"
	*/
	if(signal.data["type"] == MULE_BOT)
		if(!botlist)
			botlist = new()

		if(!(signal.source in botlist))
			botlist += signal.source

		if(active == signal.source)
			var/list/b = signal.data
			botstatus = b.Copy()

	else if(signal.data["beacon"])
		if(!beacons)
			beacons = new()

		beacons[signal.data["beacon"] ] = signal.source


//		if(istype(P)) P.updateSelfDialog()

/obj/item/radio/integrated/mule/Topic(href, href_list)
	//..()
	//var/obj/item/device/pda/PDA = src.hostpda
	var/cmd = "command"
	if(active)
		cmd = "command [active.suffix]"

	switch(href_list["op"])

		if("control")
			active = locate(href_list["bot"])

		if("scanbots")		// find all bots
			botlist = null

		if("botlist")
			active = null

		if("unload")
			post_signal(control_freq, cmd, "unload", s_filter = RADIO_MULEBOT)
		if("setdest")
			if(beacons)
				var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active.destination) as null|anything in beacons
				if(dest)
					post_signal(control_freq, cmd, "target", "destination", dest, s_filter = RADIO_MULEBOT)

		if("retoff")
			post_signal(control_freq, cmd, "autoret", "value", 0, s_filter = RADIO_MULEBOT)
		if("reton")
			post_signal(control_freq, cmd, "autoret", "value", 1, s_filter = RADIO_MULEBOT)

		if("pickoff")
			post_signal(control_freq, cmd, "autopick", "value", 0, s_filter = RADIO_MULEBOT)

		if("pickon")
			post_signal(control_freq, cmd, "autopick", "value", 1, s_filter = RADIO_MULEBOT)

		if("stop", "go", "home")
			post_signal(control_freq, cmd, href_list["op"], s_filter = RADIO_MULEBOT)

	post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)



/*
 *	Radio Cartridge, essentially a signaler.
 */


/obj/item/radio/integrated/signal
	var/frequency = 1457
	var/code = 30.0
	var/last_transmission
	var/datum/radio_frequency/radio_connection

/obj/item/radio/integrated/signal/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	return ..()

/obj/item/radio/integrated/signal/initialize()
	if(!radio_controller)
		return
	if (src.frequency < 1441 || src.frequency > 1489)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/radio/integrated/signal/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/item/radio/integrated/signal/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return