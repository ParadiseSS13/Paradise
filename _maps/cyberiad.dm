/*
All z-levels should be identical in size. Their numbers should not matter.
The order of z-levels should not matter as long as their attributes are properly defined at MAP_TRANSITION_CONFIG.
Old code checked for the number of the z-level (for example whether there are any revheads on Z1),
currently it should check for the define (for example whether there are any revheads on any z-levels defined as STATION_LEVEL).
z1 = station
z2 = centcomm
z3 = telecommunications center
z4 = engineering ship
z5 = mining
z6 = russian derelict
z7 = empty
*/

#if !defined(USING_MAP_DATUM)
	#include "map_files\Cyberiad\Cyberiad.dmm" // Z1
	#include "map_files\Generic\admin_centcomm.dmm" // Z2
	#include "map_files\Generic\tcommsat.dmm" // Z3
	#include "map_files\Generic\engineering_outpost.dmm" // Z4
	#include "map_files\Generic\mining_asteroid.dmm" // Z5
	#include "map_files\Generic\derelict.dmm" // Z6
	#include "map_files\Generic\space.dmm" // Z7

	#define MAP_FILE "Cyberiad.dmm"
	#define MAP_NAME "Cyberiad"
	#define MAP_TRANSITION_CONFIG list(\
DECLARE_LEVEL(MAIN_STATION, CROSSLINKED, list(STATION_LEVEL,STATION_CONTACT,REACHABLE,AI_OK)),\
DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)),\
DECLARE_LEVEL(TELECOMMS, CROSSLINKED, list(REACHABLE, BOOSTS_SIGNAL, AI_OK)),\
DECLARE_LEVEL(CONSTRUCTION, CROSSLINKED, list(REACHABLE)),\
DECLARE_LEVEL(MINING, CROSSLINKED, list(REACHABLE, STATION_CONTACT, HAS_WEATHER, ORE_LEVEL, AI_OK)),\
DECLARE_LEVEL(DERELICT, CROSSLINKED, list(REACHABLE)),\
DECLARE_LEVEL(EMPTY_AREA, CROSSLINKED, list(REACHABLE)))

	#define USING_MAP_DATUM /datum/map/cyberiad

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Cyberiad.

#endif
