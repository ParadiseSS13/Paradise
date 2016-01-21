var/global/obj/effect/datacore/data_core = null

var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.0005 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

var/list/powernets = list()

// this is not strictly unused although the whole modules datum thing is unused
// To remove this you need to remove that
var/datum/moduletypes/mods = new()

var/map_name = "Unknown"	//The name of the map that is loaded. Assigned in world/New()