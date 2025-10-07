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
	num2text(PROC_FREQ)= list(ACCESS_MAGISTRATE, ACCESS_NTREP, ACCESS_INTERNAL_AFFAIRS)
))

GLOBAL_LIST_INIT(default_medbay_channels, list(
	num2text(PUB_FREQ) = list(),
	num2text(MED_FREQ) = list(ACCESS_MEDICAL),
	num2text(MED_I_FREQ) = list(ACCESS_MEDICAL)
))

GLOBAL_LIST_EMPTY(deadsay_radio_systems)

/obj/item/radio
	name = "station bounced radio"
	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"
	inhand_icon_state = "radio"
	dog_fashion = /datum/dog_fashion/back
	suffix = "\[3\]"
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
	/// Areas in which this radio cannot send messages
	var/static/list/blacklisted_areas = list(/area/adminconstruction, /area/tdome, /area/ruin/space/bubblegum_arena)

	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL

	materials = list(MAT_METAL = 200, MAT_GLASS = 100)

	var/const/FREQ_LISTENING = 1
	var/atom/follow_target // Custom follow target for autosay-using bots

	var/list/internal_channels

	var/datum/radio_frequency/radio_connection
	var/list/datum/radio_frequency/secure_radio_connections = list()

	var/requires_tcomms = FALSE // Does this device require tcomms to work.If TRUE it wont function at all without tcomms. If FALSE, it will work without tcomms, just slowly
	var/instant = FALSE // Should this device instantly communicate if there isnt tcomms

	/// A timer that, when going off, will turn this radio on again
	var/radio_enable_timer

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

/obj/item/radio/Initialize(mapload)
	. = ..()
	if(frequency < RADIO_LOW_FREQ || frequency > RADIO_HIGH_FREQ)
		frequency = sanitize_frequency(frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
	set_frequency(frequency)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)

/obj/item/radio/attack_ghost(mob/user)
	return interact(user)

/obj/item/radio/attack_self__legacy__attackchain(mob/user)
	interact(user)

/obj/item/radio/interact(mob/user)
	if(!user)
		return 0
	if(b_stat)
		wires.Interact(user)
		return
	ui_interact(user)

/obj/item/radio/AltClick(mob/user)
	if(!istype(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	ToggleBroadcast()
	to_chat(user, "<span class='notice'>You <b>[broadcasting ? "enable" : "disable"]</b> [src]'s hotmic.</span>")
	add_fingerprint(user)

/obj/item/radio/CtrlShiftClick(mob/user)
	if(!istype(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	ToggleReception()
	to_chat(user, "<span class='notice'>You <b>[listening ? "enable" : "disable"]</b> [src]'s speaker.</span>")
	add_fingerprint(user)

/obj/item/radio/ui_state(mob/user)
	return GLOB.default_state

/obj/item/radio/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Radio", name)
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
		if("frequency") // Available to both headsets and non-headset radios
			if(freqlock)
				return
			var/tune = isnum(params["tune"]) ? params["tune"] : text2num(params["tune"])
			var/adjust = isnum(params["adjust"]) ? params["adjust"] : text2num(params["adjust"])
			if(tune == "reset")
				tune = initial(frequency)
			else if(adjust)
				tune = frequency + adjust * 10
			else if(!isnull(tune))
				tune = tune * 10
			else
				. = FALSE
			if(hidden_uplink)
				if(hidden_uplink.check_trigger(usr, frequency, traitor_frequency))
					usr << browse(null, "window=radio")
			if(.)
				set_frequency(sanitize_frequency(tune, freerange))
		if("ichannel") // Change primary frequency to an internal channel authorized by access, for non-headset radios only
			if(freqlock)
				return
			var/freq = isnum(params["ichannel"]) ? params["ichannel"] : text2num(params["ichannel"])
			if(has_channel_access(usr, num2text(freq)))
				set_frequency(freq)
		if("listen")
			listening = !listening
		if("broadcast")
			broadcasting = !broadcasting
		if("channel") // For keyed channels on headset radios only
			var/channel = params["channel"]
			if(!(channel in channels))
				return
			if(channels[channel] & FREQ_LISTENING)
				channels[channel] &= ~FREQ_LISTENING
			else
				channels[channel] |= FREQ_LISTENING
		if("loudspeaker") // Toggle loudspeaker mode, AKA everyone around you hearing your radio.
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

/mob/proc/has_internal_radio_channel_access(mob/user, list/req_one_accesses)
	var/obj/item/card/id/I = user.get_id_card()
	return has_access(list(), req_one_accesses, I ? I.GetAccess() : list())

/mob/living/silicon/has_internal_radio_channel_access(mob/user, list/req_one_accesses)
	var/list/access = get_all_accesses()
	return has_access(list(), req_one_accesses, access)

/mob/dead/observer/has_internal_radio_channel_access(mob/user, list/req_one_accesses)
	return can_admin_interact()

/obj/item/radio/proc/ToggleBroadcast()
	broadcasting = !broadcasting && !(wires.is_cut(WIRE_RADIO_TRANSMIT) || wires.is_cut(WIRE_RADIO_SIGNAL))
	if(broadcasting)
		playsound(src, 'sound/items/radio_common.ogg', rand(4, 16) * 5, SOUND_RANGE_SET(3))

/obj/item/radio/proc/ToggleReception()
	listening = !listening && !(wires.is_cut(WIRE_RADIO_RECEIVER) || wires.is_cut(WIRE_RADIO_SIGNAL))

/obj/item/radio/proc/autosay(message, from, channel, follow_target_override) //BS12 EDIT
	var/datum/radio_frequency/connection = null
	if(channel && channels && length(channels) > 0)
		if(channel == "department")
			channel = channels[1]
		connection = secure_radio_connections[channel]
	else
		connection = radio_connection
		channel = null

	if(loc && is_type_in_list(get_area(src), blacklisted_areas))
		// add a debug log so people testing things won't be fighting against a "broken" radio for too long.
		log_debug("Radio message from [src] was used in restricted area [get_area(src)].")
		return
	if(!istype(connection))
		return
	if(!connection)
		return
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
	tcm.sender = src
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
	if(follow_target_override)
		tcm.follow_target = follow_target_override
	else
		tcm.follow_target = follow_target

	// Now put that through the stuff
	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.handle_message(tcm)
	qdel(tcm) // Delete the message datum

// Interprets the message mode when talking into a radio, possibly returning a connection datum
/obj/item/radio/proc/handle_message_mode(mob/living/M as mob, list/message_pieces, message_mode)
	// If a channel isn't specified, send to common.
	if(!message_mode || message_mode == "headset")
		return radio_connection

	// Otherwise, if a channel is specified, look for it.
	if(channels && length(channels) > 0)
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

	if(!M.IsVocal() || M.cannot_speak_loudly())
		return 0

	if(is_type_in_list(get_area(src), blacklisted_areas))
		// add a debug log so people testing things won't be fighting against a "broken" radio for too long.
		log_debug("Radio message from [src] was used in restricted area [get_area(src)].")
		return FALSE

	var/jammed = FALSE
	var/turf/position = get_turf(src)
	for(var/J in GLOB.active_jammers)
		var/obj/item/jammer/jammer = J
		var/position_jammer = get_turf(jammer)
		if(!atoms_share_level(position, position_jammer))
			continue
		if(get_dist(position, position_jammer) < jammer.range)
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
	var/rankname // the formatting to be used for the mob's job

	if(jammed && !syndiekey)
		Gibberish_all(message_pieces, 100, 70)

	// --- Human: use their actual job ---
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		jobname = H.get_assignment()
		rankname = H.get_authentification_rank()

	// --- Carbon Nonhuman ---
	else if(iscarbon(M)) // Nonhuman carbon mob
		jobname = "No id"

	// --- AI ---
	else if(is_ai(M))
		jobname = "AI"

	// --- Cyborg ---
	else if(isrobot(M))
		jobname = "Cyborg"

	// --- Personal AI (pAI) ---
	else if(ispAI(M))
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
		rankname = "Unknown"
		voicemask = TRUE

	// Copy the message pieces so we can safely edit comms line without affecting the actual line
	var/list/message_pieces_copy = list()
	for(var/datum/multilingual_say_piece/S in message_pieces)
		message_pieces_copy += new /datum/multilingual_say_piece(S.speaking, S.message)

	// Make us a message datum!
	var/datum/tcomms_message/tcm = new
	tcm.sender_name = displayname
	tcm.sender_job = jobname
	tcm.sender_rank = rankname
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
			addtimer(CALLBACK(src, PROC_REF(broadcast_callback), tcm), 2 SECONDS)
		else
			// Nukeops + Deathsquad headsets are instant and should work the same, whether there is comms or not, on all z levels
			for(var/z in 1 to world.maxz)
				tcm.zlevels |= z
			broadcast_message(tcm)
			qdel(tcm) // Delete the message datum
		return TRUE

	// If we didnt get here, oh fuck
	qdel(tcm) // Delete the message datum
	return FALSE


/obj/item/radio/hear_talk(mob/M as mob, list/message_pieces, verb = "says")
	if(broadcasting)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, message_pieces, null, verb)

// To the person who asks "Why is this in a callback?"
// You see, if you use QDEL_IN on the tcm and on broadcast_message()
// The timer SS races itself and the message can be deleted before its sent
// Having both in this callback removes that risk
/obj/item/radio/proc/broadcast_callback(datum/tcomms_message/tcm)
	broadcast_message(tcm)
	qdel(tcm) // Delete the message datum


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
	if(!freq) //received on main frequency
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
		return get_mobs_in_view(canhear_range, src, ai_eyes = AI_EYE_REQUIRE_HEAR)

	return null

/obj/item/radio/proc/show_examine_hotkeys()
	. = list()
	. += "<span class='notice'><b>Alt-Click</b> to toggle [src]'s hotmic.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> to toggle [src]'s speaker.</span>"

/obj/item/radio/examine(mob/user)
	. = ..()
	. += show_examine_hotkeys()

	if(in_range(src, user) || loc == user)
		if(b_stat)
			. += "<span class='notice'>\the [src] can be attached and modified!</span>"
		else
			. += "<span class='notice'>\the [src] can not be modified or attached!</span>"

/obj/item/radio/examine_more(mob/user)
	. = ..()
	. += "<span class='notice'>You can transmit messages from [src] without the hotmic by using <b>:l</b> or <b>:r</b> whilst holding it in your left or right hand.</span>"

/obj/item/radio/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	b_stat = !b_stat
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
	on = FALSE
	disable_timer++
	addtimer(CALLBACK(src, PROC_REF(enable_radio)), rand(100, 200))

	if(listening)
		visible_message("<span class='warning'>[src] buzzes violently!</span>")

	broadcasting = FALSE
	listening = FALSE
	for(var/ch_name in channels)
		channels[ch_name] = 0
	..()

/obj/item/radio/proc/enable_radio()
	if(disable_timer > 0)
		disable_timer--
	if(!disable_timer)
		on = TRUE

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
	canhear_range = 0
	dog_fashion = null
	freqlock = TRUE // don't let cyborgs change the default channel of their internal radio away from common

/obj/item/radio/borg/syndicate
	keyslot = new /obj/item/encryptionkey/syndicate/nukeops

/obj/item/radio/borg/syndicate/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == UI_UPDATE && istype(user, /mob/living/silicon/robot/syndicate))
		. = UI_INTERACTIVE

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

/obj/item/radio/borg/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/encryptionkey/))

		if(keyslot)
			to_chat(user, "The radio can't hold another key!")
			return

		if(!keyslot)
			user.drop_item()
			W.loc = src
			keyslot = W

		recalculateChannels()
		return

	return ..()

/obj/item/radio/borg/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return

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
	listening = FALSE

/obj/item/radio/phone
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	name = "phone"
	dog_fashion = null

/obj/item/radio/phone/medbay
	frequency = MED_I_FREQ

/obj/item/radio/phone/medbay/New()
	..()
	internal_channels = GLOB.default_medbay_channels.Copy()

/obj/item/radio/proc/attempt_send_deadsay_message(mob/subject, message)
	return

/obj/item/radio/headset/deadsay
	name = "spectral radio"
	ks2type = /obj/item/encryptionkey/centcom
	var/datum/action/item_action/chameleon_change/chameleon_action

/obj/item/radio/headset/deadsay/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()
	GLOB.deadsay_radio_systems.Add(src)
	make_syndie()

/obj/item/radio/headset/deadsay/Destroy()
	QDEL_NULL(chameleon_action)
	GLOB.deadsay_radio_systems.Remove(src)
	return ..()

/obj/item/radio/headset/deadsay/screwdriver_act(mob/user, obj/item/I)
	return

/obj/item/radio/headset/deadsay/attempt_send_deadsay_message(mob/subject, message)
	if(!listening)
		return
	var/mob/hearer = loc // if people want dchat to shut up, they shouldn't need to deal with other people's headsets
	if(!istype(hearer) || hearer.stat || !hearer.can_hear())
		return

	if(!hearer.get_preference(PREFTOGGLE_CHAT_DEAD))
		return

	var/speaker_name
	if(!subject || subject.client.prefs.toggles2 & PREFTOGGLE_2_ANON)
		subject ? (speaker_name = "<i>Anon</i> ([subject.mind.name])") : (speaker_name = "<i>Anon</i>")
	else
		speaker_name = "[subject.client.key] ([subject.mind.name])"

	to_chat(hearer, "<span class='deadsay'><b>[speaker_name]</b> ([ghost_follow_link(subject, hearer)]) [message]</span>")

/obj/item/radio/headset/deadsay/talk_into(mob/living/M, list/message_pieces, channel, verbage)
	var/message = copytext(multilingual_to_message(message_pieces), 1, MAX_MESSAGE_LEN)

	if(!message)
		return

	return M.say_dead(message)
