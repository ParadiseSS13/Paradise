/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1
current as of 2014/11/24
z1 = station, NSS Ragnarok
z2 = centcomm, NAS Odin
z3 = derelict telecomms satellite, NXS Hermoth
z4 = derelict station, Yggdrasil
z5 = mining, Jormungandr
z6 = empty space
z7 = empty space
*/

#if !defined(MAP_FILE)

        #include "map_files\Ragnarok\ragnarok.dmm"
        #include "map_files\Ragnarok\z2.dmm"
        #include "map_files\cyberiad\z3.dmm"
        #include "map_files\cyberiad\z4.dmm"
        #include "map_files\Ragnarok\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "ragnarok.dmm"
        #define MAP_NAME "NSS Ragnarok"
        #define MAP_TRANSITION_CONFIG list(\
DECLARE_LEVEL(MAIN_STATION, CROSSLINKED, list(STATION_LEVEL, STATION_CONTACT, REACHABLE, AI_OK)),\
DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)),\
DECLARE_LEVEL(TELECOMMS, CROSSLINKED, list(REACHABLE, BOOSTS_SIGNAL, AI_OK)),\
DECLARE_LEVEL(DERELICT, CROSSLINKED, list(REACHABLE)),\
DECLARE_LEVEL(MINING, CROSSLINKED, list(REACHABLE, STATION_CONTACT, AI_OK, ORE_LEVEL, HAS_WEATHER)),\
DECLARE_LEVEL(EMPTY_AREA, CROSSLINKED, list(REACHABLE)),\
DECLARE_LEVEL(EMPTY_AREA_2, CROSSLINKED, list(REACHABLE)))

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring Ragnarok.

#endif
