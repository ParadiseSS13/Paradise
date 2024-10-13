/**
  * Map Datum
  *
  * Datum which holds all of the information for maps ingame
  * This is used for showing map information, as well as map loading
  *
  **/
/datum/map
	/// Name of the map to be shown in the statpanel
	var/fluff_name
	/// Name to be used when using the map from a technical standpoint. Used in TGUI Nanomaps among other things.
	var/technical_name
	/// Path to the map file
	var/map_path
	/// URL to the maps webmap
	var/webmap_url
	/// Is this map voteable?
	var/voteable = TRUE
	/// Minimum amount of players required for this map to be eligible in random map picks.
	var/min_players_random = 0
	/// Sound to play at the start of the game, aka the welcoming sound
	var/welcome_sound = 'sound/AI/welcome.ogg'
