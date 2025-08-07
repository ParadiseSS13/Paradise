// Contains the public areas of the station, such has hallways and dorms


// Hallways

/area/station/hallway
	valid_territory = FALSE //too many areas with similar/same names, also not very interesting summon spots
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/station/hallway/primary/fore/west
	name = "\improper Fore West Hallway"

/area/station/hallway/primary/fore/east
	name = "\improper Fore East Hallway"

/area/station/hallway/primary/fore/north
	name = "\improper Fore North Hallway"

/area/station/hallway/primary/fore/south
	name = "\improper Fore South Hallway"

/area/station/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/station/hallway/primary/starboard/west
	name = "\improper Starboard West Hallway"

/area/station/hallway/primary/starboard/east
	name = "\improper Starboard East Hallway"

/area/station/hallway/primary/starboard/north
	name = "\improper Starboard North Hallway"

/area/station/hallway/primary/starboard/south
	name = "\improper Starboard South Hallway"

/area/station/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/station/hallway/primary/aft/west
	name = "\improper Aft West Hallway"

/area/station/hallway/primary/aft/east
	name = "\improper Aft East Hallway"

/area/station/hallway/primary/aft/north
	name = "\improper Aft North Hallway"

/area/station/hallway/primary/aft/south
	name = "\improper Aft South Hallway"


/area/station/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/station/hallway/primary/port/west
	name = "\improper Port West Hallway"

/area/station/hallway/primary/port/east
	name = "\improper Port East Hallway"

/area/station/hallway/primary/port/north
	name = "\improper Port North Hallway"

/area/station/hallway/primary/port/south
	name = "\improper Port South Hallway"

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

/area/station/hallway/spacebridge
	icon_state = "hall_space"

/area/station/hallway/spacebridge/security
	name = "\improper Security Space Bridge"

/area/station/hallway/spacebridge/security/west
	name = "\improper Security West Space Bridge"

/area/station/hallway/spacebridge/security/south
	name = "\improper Security South Space Bridge"

/area/station/hallway/spacebridge/dockmed
	name = "Docking-Medical Bridge"

/area/station/hallway/spacebridge/scidock
	name = "Science-Docking Bridge"

/area/station/hallway/spacebridge/servsci
	name = "Service-Science Bridge"

/area/station/hallway/spacebridge/serveng
	name = "Service-Engineering Bridge"

/area/station/hallway/spacebridge/engmed
	name = "Engineering-Medical Bridge"

/area/station/hallway/spacebridge/medcargo
	name = "Medical-Cargo Bridge"

/area/station/hallway/spacebridge/cargocom
	name = "Cargo-AI-Command Bridge"

/area/station/hallway/spacebridge/sercom
	name = "Command-Service Bridge"

/area/station/hallway/spacebridge/comeng
	name = "Command-Engineering Bridge"

/area/station/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/garden
	name = "\improper Garden"
	icon_state = "garden"

/area/station/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/station/hallway/secondary/entry/north

/area/station/hallway/secondary/entry/south

/area/station/hallway/secondary/entry/east

/area/station/hallway/secondary/entry/west

/area/station/hallway/secondary/entry/lounge
	name = "\improper Arrivals Lounge"

/area/station/hallway/secondary/bridge
	name = "\improper Command Hallway"
	icon_state = "hallC"

// Hallways for departments

/area/station/hallway/supply
	name = "\improper Cargo Hallway"
	icon_state = "cargo_hallway"

/area/station/hallway/supply/fore
	name = "\improper Fore Cargo Hallway"

/area/station/hallway/supply/starboard
	name = "\improper Starboard Cargo Hallway"

/area/station/hallway/supply/aft
	name = "\improper Aft Cargo Hallway"

/area/station/hallway/supply/port
	name = "\improper Port Cargo Hallway"


// Other public areas


/area/station/public/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"
	sound_environment = SOUND_AREA_STANDARD_STATION
	request_console_name = "Crew Quarters"

/area/station/public/sleep
	name = "\improper Primary Cryogenic Dormitories"
	icon_state = "Sleep"
	valid_territory = FALSE

/area/station/public/sleep/secondary
	name = "\improper Secondary Cryogenic Dormitories"

/area/station/public/locker
	name = "\improper Locker Room"
	icon_state = "locker"
	request_console_name = "Crew Quarters"

/area/station/public/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/public/toilet/unisex
	name = "\improper Unisex Restroom"

/area/station/public/toilet/lockerroom
	name = "\improper Locker Toilets"

/area/station/public/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"
	request_console_name = "Crew Quarters"

/area/station/public/arcade
	name = "\improper Arcade"
	icon_state = "arcade"

/area/station/public/mrchangs
	name = "\improper Mr Chang's"
	icon_state = "changs"

/area/station/public/pet_store
	name = "\improper Pet Store"
	icon_state = "pet_store"

/area/station/public/vacant_office
	name = "\improper Vacant Office"
	icon_state = "vacantoffice"

/area/station/public/storefront
	name = "\improper Storefront"
	icon_state = "vacantoffice"

//Storage
/area/station/public/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/public/storage/tools/auxiliary
	name = "Auxiliary Tool Storage"
	icon_state = "auxstorage"

/area/station/public/storage/tools
	name = "Primary Tool Storage"
	icon_state = "primarystorage"
	request_console_name = "Tool Storage"

/area/station/public/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/station/public/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/station/public/storage/emergency/port
	name = "Port Emergency Storage"

/area/station/public/storage/office
	name = "Office Supplies"
	icon_state = "office_supplies"

/area/station/public/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/public/quantum/security
	name = "Security Quantum Pad"

/area/station/public/quantum/engineering
	name = "Engineering Quantum Pad"

/area/station/public/quantum/docking
	name = "Docking Quantum Pad"

/area/station/public/quantum/science
	name = "Science Quantum Pad"

/area/station/public/quantum/cargo
	name = "Cargo Quantum Pad"

/area/station/public/quantum/service
	name = "Service Quantum Pad"

/area/station/public/quantum/medbay
	name = "Medbay Quantum Pad"

/area/station/public/park
	name = "Public Nature Reserve"
	icon_state = "park"

/area/station/public/shops
	name = "Dorms Public Storefront"
	icon_state = "shop"
