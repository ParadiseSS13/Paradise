/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null

	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/move_delay		= 1
	var/moving			= null
	var/adminobs		= null
	var/area			= null
	var/time_died_as_mouse = null //when the client last died as a mouse

	var/adminhelped = 0

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


		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "--"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/list/related_accounts_ip = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/list/related_accounts_cid = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	preload_rsc = 1 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	var/global/obj/screen/click_catcher/void

	var/karma = 0
	var/karma_spent = 0
	var/karma_tab = 0
	/////////////////////////////////////////////
	// /vg/: MEDIAAAAAAAA
	// Set on login.
	var/datum/media_manager/media = null

	/////////////////////////////////////////////////////////////////////
	//adv. hotkey mode vars, code using them in /interface/interface.dm//
	/////////////////////////////////////////////////////////////////////

	var/hotkeytype = "QWERTY" //what set of hotkeys is in use(defaulting to QWERTY because I can't be bothered to make this save on SQL)
	var/hotkeyon = 0 //is the hotkey on?

	var/hotkeylist = list( //list defining hotkey types, look at lists in place for structure if adding any if the future
		"QWERTY" = list(
			"on" = "hotkeymode",
			"off" = "macro"),
		"AZERTY" = list(
			"on" = "AZERTYon",
			"off" = "AZERTYoff"),
		"Cyborg" = list(
			"on" = "borghotkeymode",
			"off" = "borgmacro")
	)

	var/reset_stretch = 0 //Used by things that fiddle with client's stretch-to-fit.

	var/topic_debugging = 0 //if set to true, allows client to see nanoUI errors -- yes i realize this is messy but it'll make live testing infinitely easier

	control_freak = CONTROL_FREAK_ALL | CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

	var/datum/click_intercept/click_intercept = null

	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput