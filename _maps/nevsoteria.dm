#if !defined(MAP_FILE)

        #include "map_files\NEVSoteria\NEVSoteria.dmm"
        #include "map_files\NEVSoteria\z2.dmm"
        #include "map_files\NEVSoteria\z3.dmm"
        #include "map_files\NEVSoteria\z4.dmm"
        #include "map_files\NEVSoteria\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "NEVSoteria.dmm"
        #define MAP_NAME "NEVSoteria"
        #define MAP_TRANSITION_CONFIG list(\
DECLARE_LEVEL(MAIN_STATION, CROSSLINKED, list(STATION_LEVEL, STATION_CONTACT, REACHABLE, AI_OK)),\
DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC)),\
DECLARE_LEVEL(TELECOMMS, CROSSLINKED, list(REACHABLE, BOOSTS_SIGNAL, AI_OK)),\
DECLARE_LEVEL(DERELICT, CROSSLINKED, list(REACHABLE)),\
DECLARE_LEVEL(MINING, CROSSLINKED, list(REACHABLE, STATION_CONTACT, AI_OK, ORE_LEVEL, HAS_WEATHER)),\
DECLARE_LEVEL(EMPTY_AREA, CROSSLINKED, list(REACHABLE)),\
DECLARE_LEVEL(EMPTY_AREA_2, CROSSLINKED, list(REACHABLE)))

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring NEVSoteria.

#endif