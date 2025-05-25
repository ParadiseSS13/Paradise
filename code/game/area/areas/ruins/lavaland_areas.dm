//Lavaland Ruins

/area/ruin/powered/beach
	name = "Beach Bar"
	icon_state = "beach"

/area/ruin/powered/clownplanet
	icon_state = "yellow"
	ambientsounds = list('sound/music/clown.ogg')

/area/ruin/powered/snow_biodome
	icon_state = "yellow"

/area/ruin/powered/snow_cabin
	icon_state = "bar"

/area/ruin/powered/gluttony
	icon_state = "yellow"

/area/ruin/powered/golem_ship
	name = "Free Golem Ship"
	icon_state = "yellow"

/area/ruin/powered/greed
	icon_state = "yellow"

/area/ruin/powered/envy
	icon_state = "yellow"

/area/ruin/powered/sloth
	icon_state = "yellow"

/area/ruin/powered/fountain_hall
	icon_state = "yellow"

/area/ruin/powered/pizza_party
	icon_state = "yellow"

/area/ruin/unpowered/hierophant
	name = "Hierophant's Arena"
	icon_state = "yellow"

/area/ruin/powered/pride
	icon_state = "yellow"

/area/ruin/powered/seedvault
	icon_state = "yellow"


//Xeno Nest

/area/ruin/unpowered/xenonest
	name = "The Hive"
	always_unpowered = TRUE
	poweralm = FALSE

//ash walker nest
/area/ruin/unpowered/ash_walkers
	icon_state = "red"

/area/ruin/unpowered/althland_processing
	name = "Processing Facility"
	icon_state = "red"

/area/ruin/unpowered/althland_excavation
	name = "Excavation Pit"
	icon_state = "red"

/area/ruin/unpowered/althland_factory
	name = "Minebot Factory"
	icon_state = "red"

// This area exists so that lavaland ruins dont overwrite the baseturfs on regular space ruins
/area/ruin/unpowered/misc_lavaruin


/area/ruin/lavaland_relay
	name = "Nanotrasen Lavaland Relay"
	icon_state = "lava_relay"

/area/ruin/lavaland_relay/Initialize(mapload)
	name = "Nanotrasen Lavaland Relay #[rand(1, 1000)]" //Give it a random relay name
	return ..()
