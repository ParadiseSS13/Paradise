
// Linkage flags
	#define CROSSLINKED 2
	#define SELFLOOPING 1
	#define UNAFFECTED 0
// Attributes (In text for the convenience of those using VV)
	#define BLOCK_TELEPORT "Blocks Teleport"
	// Impedes with the casting of some spells
	#define IMPEDES_MAGIC "Impedes Magic"
	// A level the station exists on
	#define STATION_LEVEL "Station Level"
	// A level affected by Code Red announcements, cargo telepads, or similar
	#define STATION_CONTACT "Station Contact"
	// A level dedicated to admin use
	#define ADMIN_LEVEL "Admin Level"
	// For Z-levels dedicated to auto-spawning stuff in
	#define Z_FLAG_RESERVED "Reserved"
	// A level that can be navigated to by the crew without admin intervention or the emergency shuttle.
	#define REACHABLE_BY_CREW "Reachable"
	// For away missions - used by some consoles
	#define AWAY_LEVEL "Away"
	// Allows weather
	#define HAS_WEATHER "Weather"
	// Enhances telecomms signals
	#define BOOSTS_SIGNAL "Boosts signals"
	// Currently used for determining mining score
	#define ORE_LEVEL "Mining"
	// Levels the AI can control bots on
	#define AI_OK "AI Allowed"
	/// Ruins will spawn on this z-level
	#define SPAWN_RUINS "Spawn Ruins"
	/// A level that can be navigated to through space, but for real this time.
	#define REACHABLE_SPACE_ONLY "Reachable Space Only"
	/// A level used for spawning map areas in tests
	#define GAME_TEST_LEVEL "Game Test Level"
	/// Tcomms relays will always extend to this level.
	#define TCOMM_RELAY_ALWAYS "Tcomm Relay Always"

// Level names
	#define MAIN_STATION "Main Station"
	#define CENTCOMM "CentComm"
	#define TELECOMMS "Telecomms Satellite"
	#define DERELICT "Derelicted Station"
	#define EMPTY_AREA "Empty Area"
	#define EMPTY_AREA_2 "Empty Area 2"
	#define EMPTY_AREA_3 "Empty Area 3"
	#define AWAY_MISSION "Away Mission"

// Convenience define
	#define DECLARE_LEVEL(NAME,LINKS,TRAITS) list("name" = NAME, "linkage" = LINKS, "attributes" = TRAITS)

	#define AWAY_MISSION_LIST list(DECLARE_LEVEL(AWAY_MISSION,UNAFFECTED,list(BLOCK_TELEPORT, AWAY_LEVEL)))
