/// Config holder for all general/misc things
/datum/configuration_section/general_configuration
	/// Server name for the BYOND hub
	var/server_name = "Paradise Station"
	/// Tagline for the hub entry
	var/server_tag_line = "The perfect mix of RP & action"
	/// Server features in a newline
	var/server_features = "Medium RP, varied species/jobs"
	/// Allow character OOC notes
	var/allow_character_metadata = TRUE
	/// Time in seconds for the pregame lobby. Measured in seconds
	var/lobby_time = 240
	/// Default timeout for world reboot. Measured in seconds
	var/restart_timeout = 75
	/// Ban all Guest BYOND accounts
	var/guest_ban = TRUE
	/// Allow players to use AntagHUD?
	var/allow_antag_hud = TRUE
	/// Forbid players from rejoining if they use AntagHUD?
	var/restrict_antag_hud_rejoin = TRUE
	/// Enable respawns by default?
	var/respawn_enabled = TRUE
	/// Enable CID randomiser buster?
	var/enabled_cid_randomiser_buster = FALSE
	/// Forbid admins from posessing and flying the singulo round
	var/forbid_singulo_possession = FALSE
	/// Force open a PM window when replied to? This is very annoying
	var/popup_admin_pm = FALSE
	/// Announce holidays (christmas, halloween, etc etc)
	var/allow_holidays = TRUE
	/// Enable auto muting in all chat channels
	var/enable_auto_mute = FALSE
	/// Show a warning to players to make them accept touching an SSD
	var/ssd_warning = TRUE
	/// Allow ghosts to spin chairs round
	var/ghost_interaction = FALSE
	/// Enable/disable starlight to light up space
	var/starlight = TRUE
	/// Disable lobby music?
	var/disable_lobby_music = FALSE
	/// Disable ambient sound and white noise
	var/disable_ambient_noise = FALSE
	/// Disable a popup if 2 users are on the same CID?
	var/disable_cid_warning_popup = FALSE
	/// Amount of loadout points non-donors should get
	var/base_loadout_points = 5
	/// Respawnability loss penalty for eary cryoing (minutes)
	var/cryo_penalty_period = 30
	/// Observers count as roundstart if they join from the main menu before this time (in minutes). Set to 0 to allow only-pregame start observers.
	var/roundstart_observer_period = 5
	/// Enable OOC emojis?
	var/enable_ooc_emoji = TRUE
	/// Auto start the game if on a local test server
	var/developer_express_start = FALSE
	/// Minimum client build. Keep above 1421 due to exploits
	var/minimum_client_build = 1421
	/// Give a confirm button for the "Start Now" verb
	var/start_now_confirmation = TRUE
	/// BYOND account age threshold for first join alerts
	var/byond_account_age_threshold = 3
	/// Max CIDs a client can have history of before a warning is thrown
	var/max_client_cid_history = 20
	/// Enable automatic profiling to profile.json
	var/enable_auto_profiler = TRUE
	/// Auto disable OOC on roundstart?
	var/auto_disable_ooc = TRUE
	/// Do we want to allow bones to break?
	var/breakable_bones = TRUE
	/// Enable/disable revival pod plants
	var/enable_revival_pod_plants = TRUE
	/// Enable/disable cloning
	var/enable_cloning = TRUE
	/// Randomise shift time instead of it always being 12:00?
	var/randomise_shift_time = TRUE
	/// Enable night-shift lighting?
	var/enable_night_shifts = TRUE
	/// Cap for monkey cube monkey spawns
	var/monkey_cube_cap = 32
	/// Enable to make explosions react to obstacles instead of ignoring them
	var/reactionary_explosions = TRUE
	/// Bomb cap (Devastation) Other values will be calculated around this
	var/bomb_cap = 20
	/// Time for a brain to keep its spark of life (deciseconds)
	var/revival_brain_life = 10 MINUTES
	/// Time to wait before you can respawn as a new character.
	var/respawn_delay = 10 MINUTES
	/// Enable random AI lawsets from the default=TRUE pool
	var/random_ai_lawset = TRUE
	/// Enable weather events initialized by SSweather. New weather events can still
	/// be added during the round if this is disabled.
	var/enable_default_weather_events = TRUE

/datum/configuration_section/general_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line

	// A lot of bools
	CONFIG_LOAD_BOOL(allow_character_metadata, data["allow_character_metadata"])
	CONFIG_LOAD_BOOL(guest_ban, data["guest_ban"])
	CONFIG_LOAD_BOOL(allow_antag_hud, data["allow_antag_hud"])
	CONFIG_LOAD_BOOL(restrict_antag_hud_rejoin, data["restrict_antag_hud_rejoin"])
	CONFIG_LOAD_BOOL(enabled_cid_randomiser_buster, data["enable_cid_randomiser_buster"])
	CONFIG_LOAD_BOOL(respawn_enabled, data["respawn_enabled"])
	CONFIG_LOAD_BOOL(forbid_singulo_possession, data["prevent_admin_singlo_possession"])
	CONFIG_LOAD_BOOL(popup_admin_pm, data["popup_admin_pm"])
	CONFIG_LOAD_BOOL(allow_holidays, data["allow_holidays"])
	CONFIG_LOAD_BOOL(enable_auto_mute, data["enable_auto_mute"])
	CONFIG_LOAD_BOOL(ssd_warning, data["ssd_warning"])
	CONFIG_LOAD_BOOL(ghost_interaction, data["ghost_interaction"])
	CONFIG_LOAD_BOOL(starlight, data["starlight"])
	CONFIG_LOAD_BOOL(disable_lobby_music, data["disable_lobby_music"])
	CONFIG_LOAD_BOOL(disable_ambient_noise, data["disable_ambient_noise"])
	CONFIG_LOAD_BOOL(disable_cid_warning_popup, data["disable_cid_warning_popup"])
	CONFIG_LOAD_BOOL(enable_ooc_emoji, data["enable_ooc_emoji"])
	CONFIG_LOAD_BOOL(developer_express_start, data["developer_express_start"])
	CONFIG_LOAD_BOOL(start_now_confirmation, data["start_now_confirmation"])
	CONFIG_LOAD_BOOL(enable_auto_profiler, data["enable_auto_profiler"])
	CONFIG_LOAD_BOOL(auto_disable_ooc, data["auto_disable_ooc"])
	CONFIG_LOAD_BOOL(breakable_bones, data["breakable_bones"])
	CONFIG_LOAD_BOOL(enable_revival_pod_plants, data["enable_revival_pod_plants"])
	CONFIG_LOAD_BOOL(enable_cloning, data["enable_cloning"])
	CONFIG_LOAD_BOOL(randomise_shift_time, data["randomise_shift_time"])
	CONFIG_LOAD_BOOL(enable_night_shifts, data["enable_night_shifts"])
	CONFIG_LOAD_BOOL(reactionary_explosions, data["reactionary_explosions"])
	CONFIG_LOAD_BOOL(random_ai_lawset, data["random_ai_lawset"])
	CONFIG_LOAD_BOOL(enable_default_weather_events, data["enable_default_weather_events"])

	// Numbers
	CONFIG_LOAD_NUM(lobby_time, data["lobby_time"])
	CONFIG_LOAD_NUM(restart_timeout, data["restart_timeout"])
	CONFIG_LOAD_NUM(base_loadout_points, data["base_loadout_points"])
	CONFIG_LOAD_NUM(cryo_penalty_period, data["cryo_penalty_period"])
	CONFIG_LOAD_NUM(roundstart_observer_period, data["roundstart_observer_period"])
	CONFIG_LOAD_NUM(minimum_client_build, data["minimum_client_build"])
	CONFIG_LOAD_NUM(byond_account_age_threshold, data["byond_account_age_threshold"])
	CONFIG_LOAD_NUM(max_client_cid_history, data["max_client_cid_history"])
	CONFIG_LOAD_NUM(monkey_cube_cap, data["monkey_cube_cap"])
	CONFIG_LOAD_NUM(bomb_cap, data["bomb_cap"])
	CONFIG_LOAD_NUM(revival_brain_life, data["revival_brain_life"])
	CONFIG_LOAD_NUM(respawn_delay, data["respawn_delay"])

	// Strings
	CONFIG_LOAD_STR(server_name, data["server_name"])
	CONFIG_LOAD_STR(server_tag_line, data["server_tag_line"])
	CONFIG_LOAD_STR(server_features, data["server_features"])
