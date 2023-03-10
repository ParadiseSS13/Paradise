/*
All z-levels should be identical in size. Their numbers should not matter.
The order of z-levels should not matter as long as their attributes are properly defined at MAP_TRANSITION_CONFIG.
Old code checked for the number of the z-level (for example whether there are any revheads on Z1),
currently it should check for the define (for example whether there are any revheads on any z-levels defined as STATION_LEVEL).
z1 = station
z2 = centcomm
z3 = engineering stuff (called Z4, dont question it)
z4 = lavaland
*/

#include "map_files\generic\CentComm.dmm"
#include "map_files\generic\Admin_Zone.dmm"

#define MAP_TRANSITION_CONFIG list(\
DECLARE_LEVEL(CENTCOMM, UNAFFECTED, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)),\
DECLARE_LEVEL(ADMIN_ZONE, UNAFFECTED, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)))
