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
	num2text(SRV_FREQ) = list(ACCESS_HOP, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CLOWN, ACCESS_MIME),
	num2text(PROC_FREQ)= list(ACCESS_MAGISTRATE, ACCESS_NTREP, ACCESS_LAWYER)
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
	/// boolean for radio enabled or not
	var/on = TRUE
	var/last_transmission
	var/frequency = PUB_FREQ
	/// tune to frequency to unlock traitor supplies
	var/traitor_frequency = 0
	/// the range which mobs can hear this radio from
	var/canhear_range = 3
	var/datum/wires/radio/wires = null
	var/b_stat = 0

	/// Whether the radio will broadcast stuff it hears, out over the radio
	var/broadcasting = FALSE
	/// Whether the radio is currently receiving
	var/listening = TRUE
	/// Whether the radio can be re-tuned to restricted channels it has no key for
	var/freerange = FALSE
	/// Whether the radio is able to have its primary frequency changed. Used for radios with weird primary frequencies, like DS, syndi, etc
	var/freqlock = FALSE

	/// Whether the radio broadcasts to everyone within a few tiles, or not
	var/loudspeaker = FALSE
	/// Whether loudspeaker can be toggled by the user
	var/has_loudspeaker = FALSE

	/// see communications.dm for full list. First channes is a "default" for :h
	var/list/channels = list()
	/// Holder for the syndicate encryption key if present
	var/obj/item/encryptionkey/syndicate/syndiekey = null
	/// How many times this is disabled by EMPs
	var/disable_timer = 0

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
	SStgui.close_uis(wires)
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

/obj/item/radio/attack_self(mob/user)
	ui_interact(user)

/obj/item/radio/interact(mob/user)
	if(!user)
		return 0
	if(b_stat)
		wires.Interact(user)
	ui_interact(user)

/obj/item/radio/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/list/schannels = list_secure_channels(user)
		var/list/ichannels = list_internal_channels(user)
		var/calc_height = 150 + (schannels.len * 20) + (ichannels.len * 10)
		ui = new(user, src, ui_key, "Radio", name, 400, calc_height, master_ui, state)
		ui.open()

/obj/item/radio/ui_data(mob/user)
	var/list/data = list()

	data["broadcasting"] = broadcasting
	data["listening"] = listening
	data["frequency"] = frequency
	data["minFrequency"] = freerange ? RADIO_LOW_FREQ : PUBLIC_LOW_FREQ
	data["maxFrequency"] = freerange ? RADIO_HIGH_FREQ : PUBLIC_HIGH_FREQ
	data["canReset"] = frequency == initial(frequency) ? FALSE : TRUE
	data["freqlock"] = freqlock
	data["schannels"] = list_secure_channels(user)
	data["ichannels"] = list_internal_channels(user)

	data["has_loudspeaker"] = has_loudspeaker
	data["loudspeaker"] = loudspeaker
	return data

/obj/item/radio/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("frequency")
			if(freqlock)
				return
			var/tune = params["tune"]
			var/adjust = text2num(params["adjust"])
			if(tune == "reset")
				tune = initial(frequency)
			else if(adjust)
				tune = frequency + adjust * 10
			else if(text2num(tune) != null)
				tune = tune * 10
			else
				. = FALSE
			if(hidden_uplink)
				if(hidden_uplink.check_trigger(usr, frequency, traitor_frequency))
					usr << browse(null, "window=radio")
			if(.)
				set_frequency(sanitize_frequency(tune, freerange))
		if("ichannel") // change primary frequency to an internal channel authorized by access
			if(freqlock)
				return
			var/freq = params["ichannel"]
			if(has_channel_access(usr, freq))
				set_frequency(text2num(freq))
		if("listen")
			listening = !listening
		if("broadcast")
			broadcasting = !broadcasting
		if("channel")
			var/channel = params["channel"]
			if(!(channel in channels))
				return
			if(channels[channel] & FREQ_LISTENING)
				channels[channel] &= ~FREQ_LISTENING
			else
				channels[channel] |= FREQ_LISTENING
		if("loudspeaker")
			// Toggle loudspeaker mode, AKA everyone around you hearing your radio.
			if(has_loudspeaker)
				loudspeaker = !loudspeaker
				if(loudspeaker)
					canhear_range = 3
				else
					canhear_range = 0
		else
			. = FALSE
	if(.)
		add_fingerprint(usr)

/obj/item/radio/proc/list_secure_channels(mob/user)
	var/list/dat = list()
	for(var/channel in channels)
		dat[channel] = channels[channel] & FREQ_LISTENING
	return dat

/obj/item/radio/proc/list_internal_channels(mob/user)
	var/list/dat = list()
	if(freqlock)
		return dat
	for(var/internal_chan in internal_channels)
		var/freqnum = text2num(internal_chan)
		var/freqname = get_frequency_name(freqnum)
		if(has_channel_access(user, internal_chan))
			dat[freqname] = freqnum // unlike secure_channels, this is set to the freq number so Radio.js can use it as an arg
	return dat

/obj/item/radio/proc/has_channel_access(mob/user, freq)
	if(!user)
		return FALSE

	if(!(freq in internal_channels))
		return FALSE

	if(isrobot(user))
		return FALSE // cyborgs and drones are not allowed to remotely re-tune intercomms, etc

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
	broadcasting = !broadcasting && !(wires.is_cut(WIRE_RADIO_TRANSMIT) || wires.is_cut(WIRE_RADIO_SIGNAL))

/obj/item/radio/proc/ToggleReception()
	listening = !listening && !(wires.is_cut(WIRE_RADIO_RECEIVER) || wires.is_cut(WIRE_RADIO_SIGNAL))

/obj/item/radio/proc/autosay(message, from, channel, role = "Unknown") //BS12 EDIT
	var/datum/radio_frequency/connection = null
	if(channel && channels && channels.len)
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
		tcm.source_level = level_name_to_num(MAIN_STATION) // Assume station level if we dont have an actual Z level available to us.
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
	if(channels && channels.len)
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
	if(wires.is_cut(WIRE_RADIO_TRANSMIT)) // The device has to have all its wires and shit intact
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
	if(!wires || wires.is_cut(WIRE_RADIO_RECEIVER))
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

/obj/item/radio/proc/recalculateChannels()
	/// Exists so that borg radios and headsets can override it.
	stack_trace("recalculateChannels() called on a radio which does not implement the proc.")

///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/radio/borg
	name = "Cyborg Radio"
	var/mob/living/silicon/robot/myborg = null // Cyborg which owns this radio. Used for power checks
	var/obj/item/encryptionkey/keyslot // Borg radios can handle a single encryption key
	icon = 'icons/obj/robot_component.dmi' // Cyborgs radio icons should look like the component.
	icon_state = "radio"
	has_loudspeaker = TRUE
	loudspeaker = FALSE
	canhear_range = 0
	dog_fashion = null
	freqlock = TRUE // don't let cyborgs change the default channel of their internal radio away from common

/obj/item/radio/borg/syndicate
	keyslot = new /obj/item/encryptionkey/syndicate/nukeops

/obj/item/radio/borg/syndicate/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == STATUS_UPDATE && istype(user, /mob/living/silicon/robot/syndicate))
		. = STATUS_INTERACTIVE

/obj/item/radio/borg/Destroy()
	myborg = null
	return ..()

/obj/item/radio/borg/syndicate/New()
	..()
	syndiekey = keyslot
	set_frequency(SYND_FREQ)
	freqlock = TRUE

/obj/item/radio/borg/deathsquad

/obj/item/radio/borg/deathsquad/New()
	..()
	set_frequency(DTH_FREQ)
	freqlock = TRUE

/obj/item/radio/borg/ert
	keyslot = new /obj/item/encryptionkey/ert

/obj/item/radio/borg/ert/New()
	..()
	set_frequency(ERT_FREQ)
	freqlock = TRUE

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

/obj/item/radio/borg/recalculateChannels()
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


/obj/item/radio/borg/interact(mob/user)
	if(!on)
		return
	. = ..()

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
