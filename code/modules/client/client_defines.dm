/client
	/// Client is casted to /datum so that we're able to use datum variables, search for clients through datums, and not need to duplicate code for GCing
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	/// hides the byond verb panel as we use our own custom version
	show_verb_panel = FALSE

	var/datum/persistent_client/persistent

	var/datum/admins/holder = null

	var/last_message	= "" //contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contains a number of how many times a message identical to last_message was sent.
	var/last_message_time = 0 //holds the last time (based on world.time) a message was sent

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	///The visual delay to use for the current client.Move(), mostly used for making a client based move look like it came from some other slower source
	var/visual_delay = 0
	var/move_delay		= 1
	var/moving			= null
	var/area			= null

	var/typing = FALSE // Prevents typing window stacking

		///////////////
		//SOUND STUFF//
		///////////////

	var/ambience_playing = FALSE

		////////////
		//SECURITY//
		////////////

	/// Used for limiting the rate of topic sends by the client to avoid abuse
	var/list/topiclimiter

	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = CONTROL_FREAK_ALL

	var/ssd_warning_acknowledged = FALSE

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "--"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/list/related_accounts_ip = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/list/related_accounts_cid = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	preload_rsc = 0 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	var/atom/movable/screen/click_catcher/void

	var/ip_intel = "Disabled"

	var/datum/click_intercept/click_intercept = null

	/// Time when the click was intercepted
	var/click_intercept_time = 0

	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	// Overlay for showing debug info
	var/atom/movable/screen/debugtextholder/debug_text_overlay

	/// Persistent storage for the flavour text of examined atoms.
	var/list/description_holders = list()

	// Donator stuff.
	var/donator_level = 0

	// If set to true, this client can interact with atoms such as buttons and doors on top of regular machinery interaction
	var/advanced_admin_interaction = FALSE

	/// Messages currently seen by this client
	var/list/seen_messages

	/// list of tabs containing spells and abilities
	var/list/spell_tabs = list()

	/// our current tab
	var/stat_tab

	/// list of all tabs
	var/list/panel_tabs = list()

	// Last world.time that the player tried to request their resources.
	var/last_ui_resource_send = 0

	/// If true, client cannot ready up, late join, or observe. Used for players with EXTREMELY old byond versions.
	var/version_blocked = FALSE

	/// Date the client registered their BYOND account on
	var/byondacc_date
	/// Days since the client's BYOND account was created
	var/byondacc_age = 0


	// Do not attempt to merge these vars together. They are for different things
	/// Last world.time that a PM was send to discord by a player
	var/last_discord_pm_time = 0

	/// Last world/time that a PM was sent to the player by an admin
	var/received_discord_pm = -99999 // Yes this super low number is intentional

	///world.time they connected
	var/connection_time

	/// Has the client accepted the TOS about data collection and other stuff
	var/tos_consent = FALSE

	/// Is the client watchlisted
	var/watchlisted = FALSE

	/// Client's pAI save
	var/datum/pai_save/pai_save

	/// List of the clients CUIs
	var/list/datum/custom_user_item/cui_entries = list()

	/// The client's job ban holder
	var/datum/job_ban_holder/jbh = new()

	/// Input datum, what the client is pressing.
	var/datum/input_data/input_data = new()
	/// The client's active keybindings, depending on their active mob.
	var/list/active_keybindings = list()
	/// The client's movement keybindings to directions, which work regardless of modifiers.
	var/list/movement_kb_dirs = list()

	/// Autoclick list of two elements, first being the clicked thing, second being the parameters.
	var/list/atom/selected_target[2]
	/// Used in MouseDrag to preserve the original mouse click parameters
	var/mouseParams = ""
	/// Used in MouseDrag to preserve the last mouse-entered location.
	var/mouse_location_UID
	/// Used in MouseDrag to preserve the last mouse-entered object.
	var/mouse_object_UID
	/// When we started the currently active drag
	var/drag_start = 0
	/// The params we passed at the start of the drag, in list form
	var/list/drag_details

	/// The client's currently moused over datum, limited to movable and stored as UID
	var/atom/movable/moused_over

	/// A lazy list of atoms we've examined in the last RECENT_EXAMINE_MAX_WINDOW (default 2) seconds, so that we will call [/atom/proc/examine_more] instead of [/atom/proc/examine] on them when examining
	/// A lazy list of atoms we've examined in the last RECENT_EXAMINE_MAX_WINDOW (default 2) seconds, so that we will call [/atom/proc/examine_more] instead of [/atom/proc/examine] on them when examining
	var/list/recent_examines

	/// Used to throw an admin warning if someone used a mouse macro. Also stores the world time so we can send funny noises to them
	var/next_mouse_macro_warning

	/*
	DEPRECIATED VIEWMODS
	*/
	/// Was used to handle view modifications. Now only used for a mecha module. Please just edit the string in the future
	var/list/ViewMods = list()
	/// Stores the viewmod we set using this system. Only used for a mecha module
	var/ViewModsActive = FALSE
	/// Stores the icon size we use for skins. As the server has control freak enabled, this is always static
	var/ViewPreferedIconSize = 0

	/// Basically a local variable on a client datum. Used when setting macros and nowhere else
	var/list/macro_sets

	/// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()

	/*
	ASSET SENDING
	*/
	/// The ID of the last asset job
	var/last_asset_job = 0
	/// The ID of the last asset job that was properly finished
	var/last_completed_asset_job = 0

	/*
	PARALAX RELATED VARIABLES
	*/
	/// List of parallax layers a client is viewing. Accessed when paralax is updated
	var/list/parallax_layers
	/// A cached list of available parallax layers. This may potentially be changeable to a static variable. Updated upon changing parallax prefs
	var/list/parallax_layers_cached
	/// Added to parallax layers when parallax settings are changed
	var/static/list/parallax_static_layers_tail = newlist(/atom/movable/screen/parallax_pmaster, /atom/movable/screen/parallax_space_whitifier)
	/// Used with parallax to update the parallax offsets when the subsystem fires. Compared to the clients Eye variable
	var/atom/movable/movingmob
	/// Used with parallax to grab the offset needed. Uses the X and Y coords of the turf stored here
	var/turf/previous_turf
	/// Stored world.tim of the last parallax update. Used to make sure parallax isn't updated too often
	var/last_parallax_shift
	/// Deciseconds of added delay to parallax by client preferences
	var/parallax_throttle = 0
	/// The direction parallax will be moved it. References parallax_move_direction on areas
	var/parallax_movedir = 0
	/// The amount of parallax layers that will exist on your screen. Affected by the parallax preference
	var/parallax_layers_max = 4
	/// Handles how parallax loops in situations like shuttles leaving. Stores the timer that handles that
	var/parallax_animate_timer
	/// Used with the camera console to clear out the screen objects it adds to the client when the console is deleted
	var/list/screen_maps = list()


	/// Assigned say modal of the client
	var/datum/tgui_say/tgui_say

	/// Our object window datum. It stores info about and handles behavior for the object tab
	var/datum/object_window_info/obj_window

	/// The current fullscreen state for /client/toggle_fullscreen()
	var/fullscreen = FALSE

	/// Cache of MD5'd UIDs. This is to stop clients from poking at object UIDs and being exploity with them
	var/list/m5_uid_cache = list()

	/// If this client has any windows scaling applied
	var/window_scaling

/datum/persistent_client
	/// Holds admin/mentor PM history.
	var/datum/pm_tracker/pm_tracker
	/// The Global Antag Candidacy setting from the new player menu.
	var/skip_antag = FALSE
	/// Used to prevent rapid mouse spamming.
	var/time_died_as_mouse = null
	/// All of the minds this client has been associated with.
	var/list/minds = list()
	/// Ckeys that sent us kudos.
	var/list/kudos_received_from = list()
