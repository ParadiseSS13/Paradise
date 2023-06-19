// Contains the public areas of the station, such has hallways and dorms


// Hallways

/area/station/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/station/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/station/hallway/primary/starboard/west
/area/station/hallway/primary/starboard/east

/area/station/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"


/area/station/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/station/hallway/primary/port/west
	name = "\improper Port West Hallway"

/area/station/hallway/primary/port/east
	name = "\improper Port East Hallway"

/area/station/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "hallC"

/area/station/hallway/primary/central/north
/area/station/hallway/primary/central/south
/area/station/hallway/primary/central/west
/area/station/hallway/primary/central/east
/area/station/hallway/primary/central/nw
/area/station/hallway/primary/central/ne
/area/station/hallway/primary/central/sw
/area/station/hallway/primary/central/se

/area/station/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/station/hallway/secondary/garden
	name = "\improper Garden"
	icon_state = "garden"

/area/station/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/station/hallway/secondary/entry/north

/area/station/hallway/secondary/entry/south

/area/station/hallway/secondary/entry/lounge
	name = "\improper Arrivals Lounge"


// Other public areas


/area/station/public/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"
	sound_environment = SOUND_AREA_STANDARD_STATION


/area/station/public/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"
	valid_territory = FALSE

/area/station/public/sleep_male
	name = "\improper Male Dorm"
	icon_state = "Sleep"

/area/station/public/sleep_female
	name = "\improper Female Dorm"
	icon_state = "Sleep"

/area/station/public/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/station/public/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/public/toilet/male
	name = "\improper Male Toilets"

/area/station/public/toilet/female
	name = "\improper Female Toilets"

/area/station/public/toilet/lockerroom
	name = "\improper Locker Toilets"

/area/station/public/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/station/public/arcade
	name = "\improper Arcade"
	icon_state = "arcade"

/area/station/public/mrchangs
	name = "\improper Mr Chang's"
	icon_state = "changs"

/area/station/public/clothing
	name = "\improper Clothing Shop"
	icon_state = "Theatre"

/area/station/public/pet_store
	name = "\improper Pet Store"
	icon_state = "pet_store"

/area/station/public/vacant_office
	name = "\improper Vacant Office"
	icon_state = "vacantoffice"

/area/station/public/vacant_office/secondary

//Storage
/area/station/public/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/public/storage/tools/auxiliary
	name = "Auxiliary Tool Storage"
	icon_state = "auxstorage"

/area/station/public/storage/tools
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/station/public/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/station/public/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

// /area/station/public/storage/auxillary
// 	name = "Auxillary Storage"
// 	icon_state = "auxstorage"

// /area/station/public/storage/eva
// 	name = "EVA Storage"
// 	icon_state = "eva"

/area/station/public/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/station/public/storage/emergency/port
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/station/public/storage/office
	name = "Office Supplies"
	icon_state = "office_supplies"
