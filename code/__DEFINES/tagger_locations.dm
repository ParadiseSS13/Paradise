//List of possible tagger locations for junctions mail sorting
//I assume you, DON'T fuck with order, it'll break everything
#define TAGGER_LOCATION_DISPOSALS 1
#define TAGGER_LOCATION_CARGO_BAY 2
#define TAGGER_LOCATION_QM_OFFICE 3
#define TAGGER_LOCATION_ENGINEERING 4
#define TAGGER_LOCATION_CE_OFFICE 5
#define TAGGER_LOCATION_ATMOSPHERICS 6
#define TAGGER_LOCATION_HOS_OFFICE 7
#define TAGGER_LOCATION_SECURITY 8
#define TAGGER_LOCATION_MEDBAY 9
#define TAGGER_LOCATION_CMO_OFFICE 10
#define TAGGER_LOCATION_CHEMISTRY 11
#define TAGGER_LOCATION_RESEARCH 12
#define TAGGER_LOCATION_RD_OFFICE 13
#define TAGGER_LOCATION_ROBOTICS 14
#define TAGGER_LOCATION_HOP_OFFICE 15
#define TAGGER_LOCATION_LIBRARY 16
#define TAGGER_LOCATION_CHAPEL 17
#define TAGGER_LOCATION_CAPTAIN_OFFICE 18
#define TAGGER_LOCATION_BAR 19
#define TAGGER_LOCATION_KITCHEN 20
#define TAGGER_LOCATION_HYDROPONICS 21
#define TAGGER_LOCATION_JANITOR 22
#define TAGGER_LOCATION_GENETICS 23
#define TAGGER_LOCATION_DETECTIVE 24
#define TAGGER_LOCATION_MORGUE 25

//Again, if you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete
GLOBAL_LIST_INIT(TAGGERLOCATIONS, list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "HoS Office", "Security", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Captain's Office",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics", "Detective", "Morgue"))
