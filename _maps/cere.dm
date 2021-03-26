/*
Original design by MMMiracles of TG Station
Ported by S34N to Paradise
*/

#if !defined(USING_MAP_DATUM)
	#include "map_files\generic\centcomm.dmm"
	#include "map_files\cerestation\cerestation.dmm"
	#include "map_files\generic\Lavaland.dmm"

	#define MAP_TRANSITION_CONFIG list(\
DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)),\
DECLARE_LEVEL(MAIN_STATION, CROSSLINKED, list(STATION_LEVEL, STATION_CONTACT, REACHABLE, AI_OK)),\
DECLARE_LEVEL(MINING, SELFLOOPING, list(ORE_LEVEL, REACHABLE, STATION_CONTACT, HAS_WEATHER, AI_OK)))

	#define USING_MAP_DATUM /datum/map/cerestation

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Cerestation.

#endif
