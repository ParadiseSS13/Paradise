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
