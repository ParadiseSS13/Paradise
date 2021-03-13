/*
All z-levels should be identical in size. Their numbers should not matter.
The order of z-levels should not matter as long as their attributes are properly defined at MAP_TRANSITION_CONFIG.
Old code checked for the number of the z-level (for example whether there are any revheads on Z1),
currently it should check for the define (for example whether there are any revheads on any z-levels defined as STATION_LEVEL).
z1 = centcomm
z2 = station
z3 = lavaland
*/

#if !defined(USING_MAP_DATUM)
	#include "map_files\hispania\z2.dmm"
	#include "map_files\hispania\hispania.dmm"
	#include "map_files\hispania\Lavaland.dmm"

	#define MAP_TRANSITION_CONFIG list(\
DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)),\
DECLARE_LEVEL(MAIN_STATION, CROSSLINKED, list(STATION_LEVEL, STATION_CONTACT, REACHABLE, AI_OK)),\
DECLARE_LEVEL(MINING, SELFLOOPING, list(ORE_LEVEL, REACHABLE, STATION_CONTACT, HAS_WEATHER, AI_OK)))
	
	#define USING_MAP_DATUM /datum/map/hispania

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Cyberiad.

#endif
