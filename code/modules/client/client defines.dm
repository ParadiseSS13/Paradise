/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null

	var/last_message	= "" //contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contains a number of how many times a message identical to last_message was sent.
	var/last_message_time = 0 //holds the last time (based on world.time) a message was sent
	var/datum/pm_tracker/pm_tracker = new()

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/skip_antag = FALSE //TRUE when a player declines to be included for the selection process of game mode antagonists.
	var/move_delay		= 1
	var/moving			= null
	var/adminobs		= null
	var/area			= null
	var/time_died_as_mouse = null //when the client last died as a mouse

	var/typing = FALSE // Prevents typing window stacking

	var/adminhelped = 0

	// var/gc_destroyed //Time when this object was destroyed. [Inherits from datum]

#ifdef TESTING
	var/running_find_references
	var/last_find_references = 0
#endif

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing = 0
	var/played			= 0

		////////////
		//SECURITY//
		////////////
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1

	var/received_irc_pm = -99999
	var/irc_admin			//IRC admin that spoke with them last.
	var/mute_irc = 0
	var/ssd_warning_acknowledged = FALSE

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "--"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/list/related_accounts_ip = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/list/related_accounts_cid = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	preload_rsc = 0 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	var/global/obj/screen/click_catcher/void

	var/karma = 0
	var/karma_spent = 0
	var/karma_tab = 0
	/////////////////////////////////////////////
	// /vg/: MEDIAAAAAAAA
	// Set on login.
	var/datum/media_manager/media = null

	var/topic_debugging = 0 //if set to true, allows client to see nanoUI errors -- yes i realize this is messy but it'll make live testing infinitely easier

	control_freak = CONTROL_FREAK_ALL | CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

	var/ip_intel = "Disabled"

	var/datum/click_intercept/click_intercept = null

	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput

	// Donator stuff.
	var/donator_level = 0

	// If set to true, this client can interact with atoms such as buttons and doors on top of regular machinery interaction
	var/advanced_admin_interaction = FALSE

	// Has the client been varedited by an admin? [Inherits from datum now]
	// var/var_edited = FALSE

	var/client_keysend_amount = 0
	var/next_keysend_reset = 0
	var/next_keysend_trip_reset = 0
	var/keysend_tripped = FALSE