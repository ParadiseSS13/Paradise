//Lavaland Ruins

/area/ruin/powered/beach
	name = "Beach Bar"
	icon_state = "beach"

/area/ruin/powered/clownplanet
	area_icon_text = "CLOWN\nPLANET"
	area_icon_color = AREA_COLOR_AWAY4
	ambientsounds = list('sound/music/clown.ogg')

/area/ruin/powered/snow_biodome
	area_icon_text = "SNOW\nPLANET"
	area_icon_color = AREA_COLOR_AWAY5

/area/ruin/powered/snow_cabin
	icon_state = "bar"

/area/ruin/powered/gluttony

/area/ruin/powered/providence
	tele_proof = TRUE

/area/ruin/powered/golem_ship
	name = "Free Golem Ship"

/area/ruin/powered/greed

/area/ruin/powered/envy

/area/ruin/powered/sloth

/area/ruin/powered/fountain_hall

/area/ruin/powered/pizza_party

/area/ruin/unpowered/hierophant
	name = "Hierophant's Arena"

/area/ruin/powered/pride

/area/ruin/powered/seedvault

//Xeno Nest

/area/ruin/unpowered/xenonest
	name = "The Hive"
	always_unpowered = TRUE
	poweralm = FALSE

//ash walker nest
/area/ruin/unpowered/ash_walkers

/area/ruin/unpowered/althland_processing
	name = "Processing Facility"
	icon_state = "red"

/area/ruin/unpowered/althland_excavation
	name = "Excavation Pit"
	icon_state = "red"

/area/ruin/unpowered/althland_factory
	name = "Minebot Factory"
	icon_state = "red"

/area/ruin/unpowered/basalt_lab
	name = "Basalt Lab"
	icon_state = "red"

// This area exists so that lavaland ruins dont overwrite the baseturfs on regular space ruins
/area/ruin/unpowered/misc_lavaruin


/area/ruin/lavaland_relay
	name = "Nanotrasen Lavaland Relay"
	icon_state = "lava_relay"
	area_icon_text = "LAVA\nRELAY"
	area_icon_color = AREA_COLOR_AWAY4

/area/ruin/lavaland_relay/Initialize(mapload)
	name = "Nanotrasen Lavaland Relay #[rand(1, 1000)]" //Give it a random relay name
	return ..()
