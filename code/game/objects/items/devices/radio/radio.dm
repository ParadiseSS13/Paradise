GLOBAL_LIST_INIT(default_internal_channels, list(
	num2text(PUB_FREQ) = list(),
	num2text(AI_FREQ)  = list(ACCESS_CAPTAIN),
	num2text(ERT_FREQ) = list(ACCESS_CENT_SPECOPS),
	num2text(COMM_FREQ)= list(ACCESS_HEADS),
	num2text(ENG_FREQ) = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS),
	num2text(MED_FREQ) = list(ACCESS_MEDICAL),
	num2text(MED_I_FREQ)=list(ACCESS_MEDICAL),
	num2text(SEC_FREQ) = list(ACCESS_SECURITY),
	num2text(SEC_I_FREQ)=list(ACCESS_SECURITY),
	num2text(SCI_FREQ) = list(ACCESS_RESEARCH),
	num2text(SUP_FREQ) = list(ACCESS_CARGO),
	num2text(SRV_FREQ) = list(ACCESS_HOP, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CLOWN, ACCESS_MIME)
))

GLOBAL_LIST_INIT(default_medbay_channels, list(
	num2text(PUB_FREQ) = list(),
	num2text(MED_FREQ) = list(ACCESS_MEDICAL),
	num2text(MED_I_FREQ) = list(ACCESS_MEDICAL)
))

/obj/item/radio
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	dog_fashion = /datum/dog_fashion/back
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	var/on = 1 // 0 for off
	var/last_transmission
	var/frequency = PUB_FREQ //common chat
	var/traitor_frequency = 0 //tune to frequency to unlock traitor supplies
	var/canhear_range = 3 // the range which mobs can hear this radio from
	var/datum/wires/radio/wires = null
	var/b_stat = 0
	var/broadcasting = 0
	var/listening = 1
	var/list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
	var/subspace_transmission = 0
	var/obj/item/encryptionkey/syndicate/syndiekey = null //Holder for the syndicate encryption key if present
	var/disable_timer = 0 //How many times this is disabled by EMPs

	var/is_special = 0 //For electropacks mostly, skips Topic() checks

	flags = CONDUCT
	slot_flags = SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL

	materials = list(MAT_METAL=75)

	var/const/FREQ_LISTENING = 1
	var/atom/follow_target // Custom follow target for autosay-using bots

	var/list/internal_channels

	var/datum/radio_frequency/radio_connection
	var/list/datum/radio_frequency/secure_radio_connections = new

	var/requires_tcomms = FALSE // Does this device require tcomms to work.If TRUE it wont function at all without tcomms. If FALSE, it will work without tcomms, just slowly
	var/instant = FALSE // Should this device instantly communicate if there isnt tcomms


/obj/item/radio/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)


/obj/item/radio/New()
	..()
	wires = new(src)

	internal_channels = GLOB.default_internal_channels.Copy()
	GLOB.global_radios |= src

/obj/item/radio/Destroy()
	QDEL_NULL(wires)
	if(SSradio)
		SSradio.remove_object(src, frequency)
		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
	radio_connection = null
	GLOB.global_radios -= src
	follow_target = null
	return ..()


/obj/item/radio/Initialize()
	..()
	if(frequency < RADIO_LOW_FREQ || frequency > RADIO_HIGH_FREQ)
		frequency = sanitize_frequency(frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
	set_frequency(frequency)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)

/obj/item/radio/attack_ghost(mob/user)
	return interact(user)

/obj/item/radio/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/item/radio/interact(mob/user)
	if(!user)
		return 0

	if(b_stat)
		wires.Interact(user)

	return ui_interact(user)

/obj/item/radio/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "radio_basic.tmpl", "[name]", 400, 550)
		ui.open()
		ui.set_auto_update(1)

/obj/item/radio/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["mic_status"] = broadcasting
	data["speaker"] = listening
	data["freq"] = format_frequency(frequency)
	data["rawfreq"] = num2text(frequency)

	data["mic_cut"] = (wires.IsIndexCut(RADIO_WIRE_TRANSMIT) || wires.IsIndexCut(RADIO_WIRE_SIGNAL))
	data["spk_cut"] = (wires.IsIndexCut(RADIO_WIRE_RECEIVE) || wires.IsIndexCut(RADIO_WIRE_SIGNAL))

	var/list/chanlist = list_channels(user)
	if(islist(chanlist) && chanlist.len)
		data["chan_list"] = chanlist
		data["chan_list_len"] = chanlist.len

	if(syndiekey)
		data["useSyndMode"] = 1

	return data


/obj/item/radio/proc/list_channels(var/mob/user)
	return list_internal_channels(user)

/obj/item/radio/proc/list_secure_channels(var/mob/user)
	var/dat[0]

	for(var/ch_name in channels)
		var/chan_stat = channels[ch_name]
		var/listening = !!(chan_stat & FREQ_LISTENING) != 0

		dat.Add(list(list("chan" = ch_name, "display_name" = ch_name, "secure_channel" = 1, "sec_channel_listen" = !listening, "chan_span" = SSradio.frequency_span_class(SSradio.radiochannels[ch_name]))))

	return dat

/obj/item/radio/proc/list_internal_channels(var/mob/user)
	var/dat[0]
	for(var/internal_chan in internal_channels)
		if(has_channel_access(user, internal_chan))
			dat.Add(list(list("chan" = internal_chan, "display_name" = get_frequency_name(text2num(internal_chan)), "chan_span" = SSradio.frequency_span_class(text2num(internal_chan)))))

	return dat

/obj/item/radio/proc/has_channel_access(var/mob/user, var/freq)
	if(!user)
		return 0

	if(!(freq in internal_channels))
		return 0

	return user.has_internal_radio_channel_access(user, internal_channels[freq])

/mob/proc/has_internal_radio_channel_access(var/mob/user, var/list/req_one_accesses)
	var/obj/item/card/id/I = user.get_id_card()
	return has_access(list(), req_one_accesses, I ? I.GetAccess() : list())

/mob/living/silicon/has_internal_radio_channel_access(var/mob/user, var/list/req_one_accesses)
	var/list/access = get_all_accesses()
	return has_access(list(), req_one_accesses, access)

/mob/dead/observer/has_internal_radio_channel_access(var/mob/user, var/list/req_one_accesses)
	return can_admin_interact()

/obj/item/radio/proc/ToggleBroadcast()
	broadcasting = !broadcasting && !(wires.IsIndexCut(RADIO_WIRE_TRANSMIT) || wires.IsIndexCut(RADIO_WIRE_SIGNAL))

/obj/item/radio/proc/ToggleReception()
	listening = !listening && !(wires.IsIndexCut(RADIO_WIRE_RECEIVE) || wires.IsIndexCut(RADIO_WIRE_SIGNAL))

/obj/item/radio/Topic(href, href_list)
	if(..())
		return 1

	if(is_special)
		return 0

	if(href_list["track"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)
			A.ai_actual_track(target)
		. = 1

	else if(href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if((new_frequency < PUBLIC_LOW_FREQ || new_frequency > PUBLIC_HIGH_FREQ))
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)
		if(hidden_uplink)
			if(hidden_uplink.check_trigger(usr, frequency, traitor_frequency))
				usr << browse(null, "window=radio")
		. = 1
	else if(href_list["talk"])
		ToggleBroadcast()
		. = 1
	else if(href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if(!chan_name)
			ToggleReception()
		else
			if(channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
		. = 1
	else if(href_list["spec_freq"])
		var/freq = href_list["spec_freq"]
		if(has_channel_access(usr, freq))
			set_frequency(text2num(freq))
		. = 1

	if(href_list["nowindow"]) // here for pAIs, maybe others will want it, idk
		return 1

	add_fingerprint(usr)

/obj/item/radio/proc/autosay(message, from, channel, role = "Unknown") //BS12 EDIT
	var/datum/radio_frequency/connection = null
	if(channel && channels && channels.len > 0)
		if(channel == "department")
			channel = channels[1]
		connection = secure_radio_connections[channel]
	else
		connection = radio_connection
		channel = null
	if(!istype(connection))
		return
	if(!connection)
		return
	var/mob/living/automatedannouncer/A = new /mob/living/automatedannouncer(src)
	A.name = from
	A.role = role
	A.message = message
	var/jammed = FALSE
	for(var/obj/item/jammer/jammer in GLOB.active_jammers)
		if(get_dist(get_turf(src), get_turf(jammer)) < jammer.range)
			jammed = TRUE
			break
	if(jammed)
		message = Gibberish(message, 100)
	var/list/message_pieces = message_to_multilingual(message)

		// Make us a message datum!
	var/datum/tcomms_message/tcm = new
	tcm.connection = connection
	tcm.sender = A
	tcm.radio = src
	tcm.sender_name = from
	tcm.message_pieces = message_pieces
	tcm.sender_job = "Automated Announcement"
	tcm.vname = "synthesized voice"
	tcm.data = SIGNALTYPE_AINOTRACK
	// Datum radios dont have a location (obviously)
	if(loc && loc.z)
		tcm.source_level = loc.z // For anyone that reads this: This used to pull from a LIST from the CONFIG DATUM. WHYYYYYYYYY!!!!!!!! -aa
	else
		tcm.source_level = 1 // Assume Z1 if we dont have an actual Z level available to us.
	tcm.freq = connection.frequency
	tcm.follow_target = follow_target

	// Now put that through the stuff
	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.handle_message(tcm)
	qdel(tcm) // Delete the message datum
	qdel(A)

// Just a dummy mob used for making announcements, so we don't create AIs to do this
// I'm not sure who thought that was a good idea. -- Crazylemon
/mob/living/automatedannouncer
	var/role = ""
	var/lifetime_timer
	var/message = ""
	universal_speak = 1

/mob/living/automatedannouncer/New()
	lifetime_timer = addtimer(CALLBACK(src, .proc/autocleanup), 10 SECONDS, TIMER_STOPPABLE)
	..()

/mob/living/automatedannouncer/Destroy()
	if(lifetime_timer)
		deltimer(lifetime_timer)
		lifetime_timer = null
	return ..()

/mob/living/automatedannouncer/proc/autocleanup()
	log_runtime(EXCEPTION("An announcer somehow managed to outlive the radio! Deleting!"), src, list("Message: '[message]'"))
	qdel(src)

// Interprets the message mode when talking into a radio, possibly returning a connection datum
/obj/item/radio/proc/handle_message_mode(mob/living/M as mob, list/message_pieces, message_mode)
	// If a channel isn't specified, send to common.
	if(!message_mode || message_mode == "headset")
		return radio_connection

	// Otherwise, if a channel is specified, look for it.
	if(channels && channels.len > 0)
		if(message_mode == "department") // Department radio shortcut
			message_mode = channels[1]

		if(channels[message_mode]) // only broadcast if the channel is set on
			return secure_radio_connections[message_mode]

	// If we were to send to a channel we don't have, drop it.
	return RADIO_CONNECTION_FAIL

/obj/item/radio/talk_into(mob/living/M as mob, list/message_pieces, channel, verbage = "says")
	if(!on)
		return 0 // the device has to be on
	//  Fix for permacell radios, but kinda eh about actually fixing them.
	if(!M || !message_pieces)
		return 0

	//  Uncommenting this. To the above comment:
	// 	The permacell radios aren't suppose to be able to transmit, this isn't a bug and this "fix" is just making radio wires useless. -Giacom
	if(wires.IsIndexCut(RADIO_WIRE_TRANSMIT)) // The device has to have all its wires and shit intact
		return 0

	if(!M.IsVocal())
		return 0

	var/jammed = FALSE
	var/turf/position = get_turf(src)
	for(var/J in GLOB.active_jammers)
		var/obj/item/jammer/jammer = J
		if(get_dist(position, get_turf(jammer)) < jammer.range)
			jammed = TRUE
			break

	var/message_mode = handle_message_mode(M, message_pieces, channel)
	switch(message_mode) //special cases
		// This is if the connection fails
		if(RADIO_CONNECTION_FAIL)
			return 0
		// This is if were using either a binary key, or a hivemind through a headset somehow. Dont ask.
		if(RADIO_CONNECTION_NON_SUBSPACE)
			return 1

	if(!istype(message_mode, /datum/radio_frequency)) //if not a special case, it should be returning a radio connection
		return

	var/datum/radio_frequency/connection = message_mode


	// ||-- The mob's name identity --||
	var/displayname = M.name	// grab the display name (name you get when you hover over someone's icon)
	var/voicemask = 0 // the speaker is wearing a voice mask
	var/jobname // the mob's "job"

	if(jammed)
		Gibberish_all(message_pieces, 100)

	// --- Human: use their actual job ---
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		jobname = H.get_assignment()

	// --- Carbon Nonhuman ---
	else if(iscarbon(M)) // Nonhuman carbon mob
		jobname = "No id"

	// --- AI ---
	else if(isAI(M))
		jobname = "AI"

	// --- Cyborg ---
	else if(isrobot(M))
		jobname = "Cyborg"

	// --- Personal AI (pAI) ---
	else if(istype(M, /mob/living/silicon/pai))
		jobname = "Personal AI"

	// --- Unidentifiable mob ---
	else
		jobname = "Unknown"


	// --- Modifications to the mob's identity ---

	// The mob is disguising their identity:
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		displayname = H.voice
		if(H.voice != M.real_name)
			voicemask = TRUE

	if(syndiekey && syndiekey.change_voice && connection.frequency == SYND_FREQ)
		displayname = syndiekey.fake_name
		jobname = "Unknown"
		voicemask = TRUE

	// Copy the message pieces so we can safely edit comms line without affecting the actual line
	var/list/message_pieces_copy = list()
	for(var/datum/multilingual_say_piece/S in message_pieces)
		message_pieces_copy += new /datum/multilingual_say_piece(S.speaking, S.message)

	// Make us a message datum!
	var/datum/tcomms_message/tcm = new
	tcm.sender_name = displayname
	tcm.sender_job = jobname
	tcm.message_pieces = message_pieces_copy
	tcm.source_level = position.z
	tcm.freq = connection.frequency
	tcm.vmask = voicemask
	tcm.needs_tcomms = requires_tcomms
	tcm.connection = connection
	tcm.vname = M.voice_name
	tcm.sender = M
	tcm.verbage = verbage
	// Now put that through the stuff
	var/handled = FALSE
	if(connection)
		for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
			if(C.handle_message(tcm))
				handled = TRUE
				qdel(tcm) // Delete the message datum
				return TRUE

	// If we dont need tcomms and we have no connection
	if(!requires_tcomms && !handled)
		// If they dont need tcomms for their signal, set the type to intercoms
		tcm.data = SIGNALTYPE_INTERCOM_SBR
		tcm.zlevels = list(position.z)
		if(!instant)
			// Simulate two seconds of lag
			addtimer(CALLBACK(GLOBAL_PROC, .proc/broadcast_message, tcm), 20)
			QDEL_IN(tcm, 20)
		else
			// Nukeops + Deathsquad headsets are instant and should work the same, whether there is comms or not
			broadcast_message(tcm)
			qdel(tcm) // Delete the message datum
		return TRUE

	// If we didnt get here, oh fuck
	qdel(tcm) // Delete the message datum
	return FALSE


/obj/item/radio/hear_talk(mob/M as mob, list/message_pieces, var/verb = "says")
	if(broadcasting)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, message_pieces, null, verb)


/*
/obj/item/radio/proc/accept_rad(obj/item/radio/R as obj, message)

	if((R.frequency == frequency && message))
		return 1
	else if

	else
		return null
	return
*/


/obj/item/radio/proc/receive_range(freq, level)
	// check if this radio can receive on the given frequency, and if so,
	// what the range is in which mobs will hear the radio
	// returns: -1 if can't receive, range otherwise

	if(!is_listening())
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in level))
			return -1
	if(freq in SSradio.ANTAG_FREQS)
		if(!(syndiekey))//Checks to see if it's allowed on that frequency, based on the encryption keys
			return -1
	if(!freq) //recieved on main frequency
		if(!listening)
			return -1
	else
		var/accept = (freq==frequency && listening)
		if(!accept)
			for(var/ch_name in channels)
				var/datum/radio_frequency/RF = secure_radio_connections[ch_name]
				if(RF.frequency==freq && (channels[ch_name]&FREQ_LISTENING))
					accept = 1
					break
		if(!accept)
			return -1
	return canhear_range

/obj/item/radio/proc/send_hear(freq, level)
	var/range = receive_range(freq, level)
	if(range > -1)
		return get_mobs_in_view(canhear_range, src)

/obj/item/radio/proc/is_listening()
	var/is_listening = TRUE
	if(!on)
		is_listening = FALSE
	if(!wires || wires.IsIndexCut(RADIO_WIRE_RECEIVE))
		is_listening = FALSE
	if(!listening)
		is_listening = FALSE

	return is_listening

/obj/item/radio/proc/send_announcement()
	if(is_listening())
		return get_mobs_in_view(canhear_range, src)

	return null

/obj/item/radio/examine(mob/user)
	. = ..()
	if(in_range(src, user) || loc == user)
		if(b_stat)
			. += "<span class='notice'>\the [src] can be attached and modified!</span>"
		else
			. += "<span class='notice'>\the [src] can not be modified or attached!</span>"

/obj/item/radio/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	user.set_machine(src)
	b_stat = !b_stat
	if(!istype(src, /obj/item/radio/beacon))
		if(b_stat)
			user.show_message("<span class='notice'>The radio can now be attached and modified!</span>")
		else
			user.show_message("<span class='notice'>The radio can no longer be modified or attached!</span>")
		updateDialog()

/obj/item/radio/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	interact(user)

/obj/item/radio/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	interact(user)

/obj/item/radio/emp_act(severity)
	on = 0
	disable_timer++
	addtimer(CALLBACK(src, .proc/enable_radio), rand(100, 200))

	if(listening)
		visible_message("<span class='warning'>[src] buzzes violently!</span>")

	broadcasting = 0
	listening = 0
	for(var/ch_name in channels)
		channels[ch_name] = 0
	..()

/obj/item/radio/proc/enable_radio()
	if(disable_timer > 0)
		disable_timer--
	if(!disable_timer)
		on = 1

///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/radio/borg
	var/mob/living/silicon/robot/myborg = null // Cyborg which owns this radio. Used for power checks
	var/obj/item/encryptionkey/keyslot = null//Borg radios can handle a single encryption key
	var/shut_up = 1
	icon = 'icons/obj/robot_component.dmi' // Cyborgs radio icons should look like the component.
	icon_state = "radio"
	canhear_range = 0
	subspace_transmission = 1
	dog_fashion = null

/obj/item/radio/borg/syndicate
	keyslot = new /obj/item/encryptionkey/syndicate/nukeops

/obj/item/radio/borg/syndicate/CanUseTopic(mob/user, datum/topic_state/state)
	. = ..()
	if(. == STATUS_UPDATE && istype(user, /mob/living/silicon/robot/syndicate))
		. = STATUS_INTERACTIVE

/obj/item/radio/borg/Destroy()
	myborg = null
	return ..()

/obj/item/radio/borg/list_channels(var/mob/user)
	return list_secure_channels(user)

/obj/item/radio/borg/syndicate/New()
	..()
	syndiekey = keyslot
	set_frequency(SYND_FREQ)

/obj/item/radio/borg/deathsquad

/obj/item/radio/borg/deathsquad/New()
	..()
	set_frequency(DTH_FREQ)

/obj/item/radio/borg/ert
	keyslot = new /obj/item/encryptionkey/ert

/obj/item/radio/borg/ert/New()
	..()
	set_frequency(ERT_FREQ)

/obj/item/radio/borg/ert/specops
	keyslot = new /obj/item/encryptionkey/centcom

/obj/item/radio/borg/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/encryptionkey/))
		user.set_machine(src)
		if(keyslot)
			to_chat(user, "The radio can't hold another key!")
			return

		if(!keyslot)
			user.drop_item()
			W.loc = src
			keyslot = W

		recalculateChannels()
	else
		return ..()

/obj/item/radio/borg/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	user.set_machine(src)
	if(keyslot)
		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
			secure_radio_connections[ch_name] = null


		if(keyslot)
			var/turf/T = get_turf(user)
			if(T)
				keyslot.loc = T
				keyslot = null

		recalculateChannels()
		to_chat(user, "You pop out the encryption key in the radio!")
		I.play_tool_sound(user, I.tool_volume)

	else
		to_chat(user, "This radio doesn't have any encryption keys!")

/obj/item/radio/borg/proc/recalculateChannels()
	channels = list()
	syndiekey = null

	var/mob/living/silicon/robot/D = loc
	if(D.module)
		for(var/ch_name in D.module.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] += D.module.channels[ch_name]
	if(keyslot)
		for(var/ch_name in keyslot.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] += keyslot.channels[ch_name]

		if(keyslot.syndie)
			syndiekey = keyslot


	for(var/ch_name in channels)
		if(!SSradio)
			sleep(30) // Waiting for SSradio to be created.
		if(!SSradio)
			name = "broken radio"
			return

		secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)

	return

/obj/item/radio/borg/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["mode"])
		var/enable_subspace_transmission = text2num(href_list["mode"])
		if(enable_subspace_transmission != subspace_transmission)
			subspace_transmission = !subspace_transmission
			if(subspace_transmission)
				to_chat(usr, "<span class='notice'>Subspace Transmission is enabled.</span>")
			else
				to_chat(usr, "<span class='notice'>Subspace Transmission is disabled.</span>")

			if(subspace_transmission == 0)//Simple as fuck, clears the channel list to prevent talking/listening over them if subspace transmission is disabled
				channels = list()
			else
				recalculateChannels()
		. = 1
	if(href_list["shutup"]) // Toggle loudspeaker mode, AKA everyone around you hearing your radio.
		var/do_shut_up = text2num(href_list["shutup"])
		if(do_shut_up != shut_up)
			shut_up = !shut_up
			if(shut_up)
				canhear_range = 0
				to_chat(usr, "<span class='notice'>Loudspeaker disabled.</span>")
			else
				canhear_range = 3
				to_chat(usr, "<span class='notice'>Loudspeaker enabled.</span>")
		. = 1


/obj/item/radio/borg/interact(mob/user as mob)
	if(!on)
		return

	. = ..()

/obj/item/radio/borg/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "radio_basic.tmpl", "[name]", 430, 500)
		ui.open()
		ui.set_auto_update(1)

/obj/item/radio/borg/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["mic_status"] = broadcasting
	data["speaker"] = listening
	data["freq"] = format_frequency(frequency)
	data["rawfreq"] = num2text(frequency)

	var/list/chanlist = list_channels(user)
	if(islist(chanlist) && chanlist.len)
		data["chan_list"] = chanlist
		data["chan_list_len"] = chanlist.len

	if(syndiekey)
		data["useSyndMode"] = 1

	data["has_loudspeaker"] = 1
	data["loudspeaker"] = !shut_up
	data["has_subspace"] = 1
	data["subspace"] = subspace_transmission

	return data

/obj/item/radio/proc/config(op)
	if(SSradio)
		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
	secure_radio_connections = new
	channels = op
	if(SSradio)
		for(var/ch_name in op)
			secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)
	return

/obj/item/radio/off
	listening = 0
	dog_fashion = /datum/dog_fashion/back

/obj/item/radio/phone
	broadcasting = 0
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	listening = 1
	name = "phone"
	dog_fashion = null

/obj/item/radio/phone/medbay
	frequency = MED_I_FREQ

/obj/item/radio/phone/medbay/New()
	..()
	internal_channels = GLOB.default_medbay_channels.Copy()
