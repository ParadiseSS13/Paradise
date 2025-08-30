//Space Ruins

/area/ruin/space
	var/baseturf = /turf/space

/area/ruin/space/powered
	requires_power = FALSE

/area/ruin/space/unpowered

/area/ruin/space/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/space/abandtele
	name = "\improper Abandoned Teleporter"
	icon_state = "teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')

/area/ruin/space/unpowered/no_grav/way_home
	name = "\improper Salvation"

// Old tcommsat
/area/ruin/space/tcommsat
	name = "Telecommunications Satellite"
	icon_state = "tcomms"

// Ruins of "onehalf" ship
/area/ruin/space/onehalf/hallway
	name = "DK Excavator 453 Hallway"
	icon_state = "hallC"

/area/ruin/space/onehalf/drone_bay
	name = "DK Excavator 453 Mining Drone Bay"
	icon_state = "engine"

/area/ruin/space/onehalf/dorms_med
	name = "DK Excavator 453 Crew Quarters"
	icon_state = "Sleep"

/area/ruin/space/onehalf/abandonedbridge
	name = "DK Excavator 453 Abandoned Bridge"
	icon_state = "bridge"

// Ruins of the Unathi Breacher ship
/area/ruin/space/unathi_breacher/engineering
	name = "Breacher Engine Bay"

/area/ruin/space/unathi_breacher/dorms
	name = "Breacher Crew Quarters"

/area/ruin/space/unathi_breacher/bar
	name = "Breacher Bar"

/area/ruin/space/unathi_breacher/bridge
	name = "Breacher Bridge"

/area/ruin/space/unathi_breacher/hold
	name = "Breacher Hold"

//DJSTATION
/area/ruin/space/djstation
	name = "\improper Soviet DJ Station"
	icon_state = "DJ"

/area/ruin/space/djstation/solars
	name = "\improper Soviet DJ Station Solars"

//Methlab
/area/ruin/space/methlab
	name = "\improper Abandoned Drug Lab"
	icon_state = "green"

// Space Bar
/area/ruin/space/powered/bar
	name = "\improper Space Bar"

//DERELICT (USSP station and USSP Teleporter)
/area/ruin/space/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"

/area/ruin/space/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"

/area/ruin/space/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"

/area/ruin/space/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"

/area/ruin/space/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/ruin/space/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/ruin/space/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/ruin/space/derelict/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"

/area/ruin/space/derelict/secret
	name = "\improper Derelict Secret Room"
	icon_state = "library"

/area/ruin/space/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/ruin/space/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"
	icon_state = "ai"

/area/ruin/space/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "general_solar_control"

/area/ruin/space/derelict/se_solar
	name = "\improper Derelict South East Solars"
	icon_state = "general_solars"

/area/ruin/space/derelict/crew_quarters
	name = "\improper Derelict Crew Quarters"
	icon_state = "fitness"

/area/ruin/space/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/ruin/space/derelict/medical/morgue
	name = "\improper Derelict Morgue"
	icon_state = "morgue"
	is_haunted = TRUE

/area/ruin/space/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"
	is_haunted = TRUE

/area/ruin/space/derelict/teleporter
	name = "\improper Derelict Teleporter"
	icon_state = "teleporter"

/area/ruin/space/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/ruin/space/syndicate_druglab
	name = "Suspicious Station"
	icon_state = "red"

/area/ruin/space/syndicate_druglab/asteroid
	name = "Suspicious Asteroid"
	icon_state = "dark"
	requires_power = FALSE

/area/ruin/space/bubblegum_arena
	name = "Bubblegum Arena"

/area/ruin/space/wreck_cargoship
	name = "Faint Signal"
	icon_state = "yellow"

// Syndicate Listening Station

/area/ruin/space/syndicate_listening_station
	name = "Listening Post"
	icon_state = "red"

/area/ruin/space/syndicate_listening_station/asteroid
	name = "Listening Post Asteroid"
	icon_state = "dark"
	requires_power = FALSE

/area/ruin/space/turreted_outpost
	name = "Syndicate Interdiction Platform"
	icon_state = "red"

/area/ruin/space/turreted_outpost/vault
	name = "Syndicate Interdiction Platform Vault"
	icon_state = "storage"

/area/ruin/space/turreted_outpost/solars
	name = "Syndicate Interdiction Platform Solars"
	icon_state = "general_solars"

/area/ruin/space/abandoned_engi_sat
	name = "Abandoned NT Engineering Satellite"
	apc_starts_off = TRUE

/area/ruin/space/sieged_lab
	name = "Laboratory X-18"
	apc_starts_off = TRUE
	tele_proof = TRUE

/area/ruin/space/moonbase19
	name = "Moon Base 19"
	apc_starts_off = TRUE

/area/ruin/space/mech_transport
	name = "Cybersun Mobile Exosuit Factory"
	apc_starts_off = TRUE
	there_can_be_many = FALSE

/area/ruin/space/powered/casino
	name = "Dorian Casino"
	there_can_be_many = FALSE
	requires_power = TRUE

/area/ruin/space/powered/casino/docked_ships
	name = "Dorian Casino Shuttle"
	requires_power = FALSE

/area/ruin/space/powered/casino/arrivals
	name = "Dorian Casino Arrivals"

/area/ruin/space/powered/casino/kitchen
	name = "Dorian Casino Dining and Kitchen"

/area/ruin/space/powered/casino/floor
	name = "Dorian Casino Casino Floor"

/area/ruin/space/powered/casino/hall
	name = "Dorian Casino Main Hall"

/area/ruin/space/powered/casino/engine
	name = "Dorian Casino Engine Room"

/area/ruin/space/powered/casino/security
	name = "Dorian Casino Security"

/area/ruin/space/powered/casino/teleporter
	name = "Dorian Casino Teleporter"

/area/ruin/space/powered/casino/maints
	name = "Dorian Casino Service Tunnels"

/// telecomms: Alternative telecomms sat
/area/ruin/space/telecomms
	name = "\improper Telecommunications Sat"
	icon_state = "tcomms"
	tele_proof = TRUE // No patrick, you can not syndicate teleport or hand teleport instantly into or out of this ruin
	ambientsounds = list('sound/ambience/dvorak_ambience_final.ogg')
	min_ambience_cooldown = 110 SECONDS // 3 seconds longer than the length of the song
	max_ambience_cooldown = 170 SECONDS // A minute break at most
	airlock_wires = /datum/wires/airlock/secure // D.V.O.R.A.K says fuck you and has randomized all their wires. Have fun!

/area/ruin/space/telecomms/powercontrol
	name = "\improper Telecommunications Power Control"
	icon_state = "engine_smes"

/area/ruin/space/telecomms/tele
	name = "\improper Tel3coMMunic@tions-SS-S KILL_Welcoming Room" // If you teleport to it. With a name like that. Thats on you.
	icon_state = "teleporter"
	tele_proof = FALSE // Oh, right. The teleporter room. The teleporter room for Kuzco, the poison chosen especially to teleport Kuzco, Kuzco's teleporter room. That teleporter room?

/area/ruin/space/telecomms/foyer
	name = "\improper Telecommunications Foyer"
	icon_state = "entry"

/area/ruin/space/telecomms/computer
	name = "\improper Telecommunications Control Room"
	icon_state = "bridge"

/area/ruin/space/telecomms/chamber
	name = "\improper Telecommunications Central Compartment"
	icon_state = "ai_chamber"

/area/ruin/space/deepstorage
	name = "Derelict Facility"
	apc_starts_off = TRUE

/area/ruin/space/sec_shuttle
	name = "Abandoned Security Shuttle"
	apc_starts_off = TRUE

/area/ruin/space/syndicakefactory
	name = "Syndicake factory"

/area/ruin/space/clown_mime_ruin
	name = "\improper Derelict Transport Vessel"

/area/ruin/space/clockwork_monastery
	name = "\improper Abandoned Clockwork Monastery"
	there_can_be_many = FALSE
	requires_power = FALSE
	ambientsounds = list("sound/ambience/reebe_ambience_1.ogg", "sound/ambience/reebe_ambience_2.ogg", "sound/ambience/reebe_ambience_3.ogg")

/area/ruin/space/rocky_motel
	name = "\improper Rocky Motel"
	icon_state = "rocky_motel"
	there_can_be_many = FALSE

/area/ruin/space/rocky_motel/asteroid
	icon_state = "away"

/area/ruin/space/space_relay
	name = "Nanotrasen Bluespace Relay"
	icon_state = "space_relay"

/area/ruin/space/space_relay/Initialize(mapload)
	name = "Nanotrasen Bluespace Relay #[rand(1, 1000)]" //Give it a random relay name
	return ..()

