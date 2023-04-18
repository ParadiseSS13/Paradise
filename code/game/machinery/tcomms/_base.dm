/*

	ParadiseSS13 Telecommunications System

	Rewritten from the ground up because I was totally unhappy with how laggy and complicated the current implementation was
	The system is made up of two objects. A main core and relays.

	The main core is basically the same as all of the machines from the previous implementation, apart from the relay
	The core handles recieving and sending messages, logging messages, the NTTC configuration, and serves as the linkage hub for relays

	Relays function much in the same way as the old ones. They just expand the reach of tcomms from one z-level to another.

	This file contains extra datums and helper procs which the system utilises.
	Unlike old telecomms, everything in here **should** be well documented. If not, feel free to add your own
	-aa07

*/

/// Global list for all telecomms machines in the world
GLOBAL_LIST_EMPTY(tcomms_machines)

/**
  * # Telecommunications Device
  *
  * This is the base machine for both tcomms devices (core + relay)
  *
  * This holds a few base procs (Icon updates, enable/disable, etc)
  * It also has the initial overrides for Initialize() and Destroy()
  */
/obj/machinery/tcomms
	name = "Telecommunications Device"
	desc = "Someone forgot to say what this thingy does. Please yell at a coder"
	icon = 'icons/obj/machines/tcomms.dmi'
	icon_state = "error"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	/// Network ID used for names + auto linkage
	var/network_id = "None"
	/// Is the machine active
	var/active = TRUE
	/// Has the machine been hit by an ionospheric anomaly
	var/ion = FALSE

/**
  * Base Initializer
  *
  * Ensures that the machine is put into the global list of tcomms devices, and then its made sure that the icon is correct if the machine starts offline
  */
/obj/machinery/tcomms/Initialize(mapload)
	. = ..()
	GLOB.tcomms_machines += src
	update_icon()
	if((!mapload) && (usr))
		// To the person who asks "Hey affected, why are you using this massive operator when you can use AREACOORD?" Well, ill tell you
		// get_area_name is fucking broken and uses a for(x in world) search
		// It doesnt even work, is expensive, and returns 0
		// Im not refactoring one thing which could risk breaking all admin location logs
		// Fight me
		log_action(usr, "constructed a new [src] at [src ? "[get_location_name(src, TRUE)] [COORD(src)]" : "nonexistent location"] [ADMIN_JMP(src)]", adminmsg = TRUE)
	// Add in component parts for the sake of deconstruction
	component_parts = list()
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)

/**
  * Base Destructor
  *
  * Ensures that the machine is taken out of the global list when destroyed
  */
/obj/machinery/tcomms/Destroy()
	GLOB.tcomms_machines -= src
	if(usr)
		log_action(usr, "destroyed a [src] at [src ? "[get_location_name(src, TRUE)] [COORD(src)]" : "nonexistent location"] [ADMIN_JMP(src)]", adminmsg = TRUE)
	return ..()

/**
  * Icon Updater
  *
  * Ensures that the icon updates properly based on if the machine is active or not. This removes the need for this check in many other places.
  */
/obj/machinery/tcomms/update_icon()
	. = ..()
	// Show the off sprite if were inactive, ion'd or unpowered
	if(!active || (stat & NOPOWER) || ion)
		icon_state = "[initial(icon_state)]_off"
	else
		icon_state = initial(icon_state)


// Attack overrides. These are needed so the UIs can be opened up //
/obj/machinery/tcomms/attack_ai(mob/user)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/tcomms/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/tcomms/attack_hand(mob/user)
	if(..(user))
		return
	ui_interact(user)


// If we do not override the default process(), the machine defaults to not processing, meaning it uses no power.
/obj/machinery/tcomms/process()
	return

/**
  * Start of Ion Anomaly Event
  *
  * Proc to easily start an Ion Anomaly's effects, and update the icon
  */
/obj/machinery/tcomms/proc/start_ion()
	ion = TRUE
	update_icon()

/**
  * End of Ion Anomaly Event
  *
  * Proc to easily stop an Ion Anomaly's effects, and update the icon
  */
/obj/machinery/tcomms/proc/end_ion()
	ion = FALSE
	update_icon()

/**
  * Z-Level transit change helper
  *
  * Proc to make sure you cant have two of these active on a Z-level at once. It also makes sure to update the linkage
  */
/obj/machinery/tcomms/onTransitZ(old_z, new_z)
	. = ..()
	if(active)
		active = FALSE
		// This needs a timer because otherwise its on the shuttle Z and the message is missed
		addtimer(CALLBACK(src, /atom.proc/visible_message, "<span class='warning'>Radio equipment on [src] has been overloaded by heavy bluespace interference. Please restart the machine.</span>"), 5)
	update_icon()


/**
  * Logging helper
  *
  * Proc which allows easy logging of changs made to tcomms machines
  * Arguments:
  * * user - The user who did the action
  * * msg - The log message
  * * adminmsg - Should an admin log be sent when this happens
  */
/obj/machinery/tcomms/proc/log_action(user, msg, adminmsg = FALSE)
	add_misc_logs(user, "NTTC: [key_name(user)] [msg]")
	if(adminmsg)
		message_admins("[key_name_admin(user)] [msg]")
/**
  * Power Change Handler
  *
  * Proc which ensures icons are updated when machines lose power
  */
/obj/machinery/tcomms/power_change()
	..()
	update_icon()

/**
  * # Telecommunications Message
  *
  * Datum which holds all the data for a message being sent
  *
  * This used to be a single associative list with just keys and values
  * It had no typepath or presence checking, and was absolutely awful to work with
  * This fixes that
  *
  */
/datum/tcomms_message
	/// Who sent the message
	var/sender_name = "Error"
	/// What job are they
	var/sender_job = "Error"
	/// What rank are they
	var/sender_rank = "Error"
	/// Pieces of the message
	var/list/message_pieces = list()
	/// Source Z-level
	var/source_level = 0
	/// What frequency the message is sent on
	var/freq = 0
	/// Was it sent with a voice changer
	var/vmask = FALSE
	/// Did the signal come from a device that requires tcomms to function
	var/needs_tcomms = TRUE
	/// Origin of the signal
	var/datum/radio_frequency/connection
	/// Who sent it
	var/mob/sender
	/// The radio it was sent from
	var/obj/item/radio/radio
	/// The signal data (See defines/radio.dm)
	var/data
	/// Verbage used
	var/verbage = "says"
	/// Follow target for AI use
	var/atom/follow_target = null
	/// Is this signal meant to be rejected
	var/reject = FALSE
	/// Voice name if the person doesnt have a name (diona, alien, etc)
	var/vname
	/// List of all channels this can be sent or recieved on
	var/list/zlevels = list()
	/// Should this signal be re-broadcasted (Can be modified by NTTC, defaults to TRUE)
	var/pass = TRUE

/**
  * Destructor for the TCM datum.
  *
  * This needs to happen like this so that things dont keep references held in place
  */
/datum/tcomms_message/Destroy()
	connection = null
	radio = null
	follow_target = null
	return ..()


#define CREW_RADIO_TYPE 0
#define CENTCOMM_RADIO_TYPE 1
#define SYNDICATE_RADIO_TYPE 2

/**
  * Connection checker
  *
  * Checks the connection frequency against the intended frequency for the message
  * NOTE: I barely know what on earth this does, but it works and it scares me
  * Arguments:
  * * old_freq - Frequency of the connection
  * * new_freq - Frequency of the message
  */
/proc/is_bad_connection(old_freq, new_freq)
	var/old_type = CREW_RADIO_TYPE
	var/new_type = CREW_RADIO_TYPE
	for(var/antag_freq in SSradio.ANTAG_FREQS)
		if(old_freq == antag_freq)
			old_type = SYNDICATE_RADIO_TYPE
		if(new_freq == antag_freq)
			new_type = SYNDICATE_RADIO_TYPE

	for(var/cent_freq in SSradio.CENT_FREQS)
		if(old_freq == cent_freq)
			old_type = CENTCOMM_RADIO_TYPE
		if(new_freq == cent_freq)
			new_type = CENTCOMM_RADIO_TYPE

	return new_type > old_type

#undef CREW_RADIO_TYPE
#undef CENTCOMM_RADIO_TYPE
#undef SYNDICATE_RADIO_TYPE


/**
  * Message Broadcast Proc
  *
  * This big fat disaster is responsible for sending the message out to all headsets and radios on the station
  * It is absolutely disgusting, but used to take about 20 arguments before I slimmed it down to just one
  * Arguments:
  * * tcm - The tcomms message datum
  */
/proc/broadcast_message(datum/tcomms_message/tcm)


	/* ###### Prepare the radio connection ###### */

	var/display_freq = tcm.freq

	var/bad_connection = FALSE
	var/datum/radio_frequency/new_connection = tcm.connection

	if(tcm?.connection?.frequency != display_freq)
		bad_connection = is_bad_connection(tcm.connection.frequency, display_freq)
		new_connection = SSradio.return_frequency(display_freq)

	var/list/radios = list()

	// --- Broadcast only to intercom devices ---

	if(tcm.data == SIGNALTYPE_INTERCOM && !bad_connection)

		for(var/obj/item/radio/intercom/R in new_connection.devices["[RADIO_CHAT]"])
			if(R.receive_range(display_freq, tcm.zlevels) > -1)
				radios += R

	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(tcm.data == SIGNALTYPE_INTERCOM_SBR && !bad_connection)

		for(var/obj/item/radio/R in new_connection.devices["[RADIO_CHAT]"])

			if(istype(R, /obj/item/radio/headset))
				continue

			if(R.receive_range(display_freq, tcm.zlevels) > -1)
				radios += R

	// --- Broadcast to ALL radio devices ---

	else if(!bad_connection)

		for(var/obj/item/radio/R in new_connection.devices["[RADIO_CHAT]"])
			if(R.receive_range(display_freq, tcm.zlevels) > -1)
				radios += R

	// Add syndie radios for intercepts if its a regular department frequency
		for(var/antag_freq in SSradio.ANTAG_FREQS)
			var/datum/radio_frequency/antag_connection = SSradio.return_frequency(antag_freq)
			for(var/obj/item/radio/R in antag_connection.devices["[RADIO_CHAT]"])
				if(R.receive_range(display_freq, tcm.zlevels) > -1)
					// Only add if it wasnt there already
					radios |= R

	// Get a list of mobs who can hear from the radios we collected.
	var/list/receive = get_mobs_in_radio_ranges(radios)

  /* ###### Organize the receivers into categories for displaying the message ###### */

  	// Understood the message:
	var/list/heard_masked 	= list() // masked name or no real name
	var/list/heard_normal 	= list() // normal message

	// Did not understand the message:
	var/list/heard_voice 	= list() // voice message	(ie "chimpers")
	var/list/heard_garbled	= list() // garbled message (ie "f*c* **u, **i*er!")
	var/list/heard_gibberish= list() // completely screwed over message (ie "F%! (O*# *#!<>&**%!")

	for(var/M in receive)
		var/mob/R = M

	  /* --- Loop through the receivers and categorize them --- */

		if(is_admin(R) && !R.get_preference(PREFTOGGLE_CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			continue

		if(isnewplayer(R)) // we don't want new players to hear messages. rare but generates runtimes.
			continue

		// --- Can understand the speech ---
		if(!tcm.sender || R.say_understands(tcm.sender))

			// - Not human or wearing a voice mask -
			if(!tcm.sender || !ishuman(tcm.sender) || tcm.vmask)
				heard_masked += R

			// - Human and not wearing voice mask -
			else
				heard_normal += R

		// --- Can't understand the speech ---

		else
			// - Just display a garbled message -
			heard_garbled += R


  /* ###### Begin formatting and sending the message ###### */
	if(length(heard_masked) || length(heard_normal) || length(heard_voice) || length(heard_garbled) || length(heard_gibberish))

	  /* --- Some miscellaneous variables to format the string output --- */
		var/freq_text = get_frequency_name(display_freq)

		var/part_a = "<span class='[SSradio.frequency_span_class(display_freq)]'><b>\[[freq_text]\]</b> <span class='name'>" // goes in the actual output

		// --- Some more pre-message formatting ---
		var/part_b = "</span> <span class='message'>" // Tweaked for security headsets -- TLE

		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		SSblackbox.LogBroadcast(display_freq)

	 /* ###### Send the message ###### */


	  	/* --- Process all the mobs that heard a masked voice (understood) --- */

		if(length(heard_masked))
			for(var/M in heard_masked)
				var/mob/R = M
				R.hear_radio(tcm.message_pieces, tcm.verbage, part_a, part_b, tcm.sender, 0, tcm.sender_name, follow_target=tcm.follow_target)

		/* --- Process all the mobs that heard the voice normally (understood) --- */

		if(length(heard_normal))
			for(var/M in heard_normal)
				var/mob/R = M
				R.hear_radio(tcm.message_pieces, tcm.verbage, part_a, part_b, tcm.sender, 0, tcm.sender_name, follow_target=tcm.follow_target)

		/* --- Process all the mobs that heard the voice normally (did not understand) --- */

		if(length(heard_voice))
			for(var/M in heard_voice)
				var/mob/R = M
				R.hear_radio(tcm.message_pieces, tcm.verbage, part_a, part_b, tcm.sender,0, tcm.vname, follow_target=tcm.follow_target)

		/* --- Process all the mobs that heard a garbled voice (did not understand) --- */
			// Displays garbled message (ie "f*c* **u, **i*er!")

		if(length(heard_garbled))
			for(var/M in heard_garbled)
				var/mob/R = M
				R.hear_radio(tcm.message_pieces, tcm.verbage, part_a, part_b, tcm.sender, 1, tcm.vname, follow_target=tcm.follow_target)


		/* --- Complete gibberish. Usually happens when there's a compressed message --- */

		if(length(heard_gibberish))
			for(var/M in heard_gibberish)
				var/mob/R = M
				R.hear_radio(tcm.message_pieces, tcm.verbage, part_a, part_b, tcm.sender, 1, follow_target=tcm.follow_target)

	return TRUE


/**
  * # Telecommunications Password Paper
  *
  * Piece of paper that spawns with the default link password
  *
  * This is spawned in the CE office and has the default link password
  * While convenient, this is not necessary and doesnt matter if it gets lost or destroyed
  * Because you can view the password easily by just looking at the core link page
  */
/obj/item/paper/tcommskey
	name = "Telecommunications linkage password"

/**
  * Password Paper Initializer
  *
  * This paper MUST be LateInitialized so the core has a chance to initialize and setup its password
  * Otherwise shit breaks BADLY
  */
/obj/item/paper/tcommskey/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/**
  * Password Paper Late Initializer
  *
  * Since the core was regularly initialized, we can now use the LateInitialize here to grab its password, then put it on paper
  */
/obj/item/paper/tcommskey/LateInitialize(mapload)
	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		if(C.network_id == "STATION-CORE")
			info = "<center><h2>Telecommunications Key</h2></center>\n\t<br>The station core linkage password is '[C.link_password]'.<br>Should this paper be misplaced or destroyed, fear not, as the password is visible under the core linkage section. Should you wish to modify this password, it can be modified from the core."
			info_links = info
			update_icon()
			// Save time, even though there should only be one STATION-CORE in the world
			break
	return ..()

/**
  * Screwdriver Act Handler
  *
  * Handles the screwdriver action for all tcomms machines, so they can be open and closed to be deconstructed
  */
/obj/machinery/tcomms/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/**
  * Crowbar Act Handler
  *
  * Handles the crowbar action for all tcomms machines, so they can be deconstructed
  */
/obj/machinery/tcomms/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)
