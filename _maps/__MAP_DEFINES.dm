
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
	// A level that can be navigated to through space
	#define REACHABLE "Reachable"
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

// Level names
	#define MAIN_STATION "Main Station"
	#define CENTCOMM "CentComm"
	#define TELECOMMS "Telecomms Satellite"
	#define DERELICT "Derelicted Station"
	#define MINING "Lavaland"
	#define CONSTRUCTION "Construction Area"
	#define EMPTY_AREA "Empty Area"
	#define EMPTY_AREA_2 "Empty Area 2"
	#define AWAY_MISSION "Away Mission"

// Convenience define
	#define DECLARE_LEVEL(NAME,LINKS,TRAITS) list("name" = NAME, "linkage" = LINKS, "attributes" = TRAITS)

	#define AWAY_MISSION_LIST list(DECLARE_LEVEL(AWAY_MISSION,UNAFFECTED,list(BLOCK_TELEPORT, AWAY_LEVEL)))
