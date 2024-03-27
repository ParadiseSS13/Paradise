/* Wild West */
/area/awaymission/wildwest
	name = "Wild West"
	report_alerts = FALSE
	icon_state = "away"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/wildwest/wildwest_mines
	name = "\improper Wild West Mines"
	icon_state = "awaycontent1"

/area/awaymission/wildwest/wildwest_vaultdoors
	name = "\improper Wild West Vault Doors"
	icon_state = "awaycontent2"

/area/awaymission/wildwest/wildwest_refine
	name = "\improper Wild West Refinery"
	icon_state = "awaycontent3"

/area/awaymission/wildwest/wildwest_vault
	name = "\improper Wild West Vault"
	icon_state = "awaycontent3"

/* Terror Spiders */
/area/awaymission/UO71
	name = "UO71"
	icon_state = "away"
	report_alerts = FALSE
	tele_proof = TRUE


/area/awaymission/UO71/plaza
	name = "UO71 Plaza"
	icon_state = "awaycontent1"
	fire = TRUE

/area/awaymission/UO71/centralhall
	name = "UO71 Central"
	icon_state = "awaycontent2"
	fire = TRUE

/area/awaymission/UO71/eng
	name = "UO71 Engineering"
	icon_state = "awaycontent3"
	fire = TRUE

/area/awaymission/UO71/mining
	name = "UO71 Mining"
	icon_state = "awaycontent4"
	fire = TRUE

/area/awaymission/UO71/science
	name = "UO71 Science"
	icon_state = "awaycontent5"
	fire = TRUE

/area/awaymission/UO71/medical
	name = "UO71 Medical"
	icon_state = "awaycontent6"
	fire = TRUE

/area/awaymission/UO71/gateway
	name = "UO71 Gateway"
	icon_state = "awaycontent7"
	fire = TRUE

/area/awaymission/UO71/outside
	name = "UO71 Outside"
	icon_state = "awaycontent8"

/area/awaymission/UO71/bridge
	name = "UO71 Bridge"
	icon_state = "awaycontent21"
	fire = TRUE
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/UO71/queen
	name = "UO71 Queen Lair"
	icon_state = "awaycontent9"
	fire = TRUE
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/UO71/prince
	name = "UO71 Prince Containment"
	icon_state = "awaycontent10"
	fire = TRUE
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/UO71/loot
	name = "UO71 Loot Vault"
	icon_state = "awaycontent11"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/* Black Market Packers */
/area/awaymission/BMPship
	name = "BMP Asteroids"
	icon_state = "away"
	report_alerts = FALSE
	requires_power = FALSE
	ambientsounds = list('sound/music/space.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambigen11.ogg', 'sound/ambience/ambispace.ogg', 'sound/ambience/ambispace2.ogg', 'modular_ss220/aesthetics_sounds/sound/music/Traitor.ogg')

/area/awaymission/BMPship/Engines
	name = "BMP Engine Block"
	icon_state = "awaycontent1"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/Containment
	name = "BMP Containment Block"
	icon_state = "awaycontent2"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambicave.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/Fore
	name = "BMP Fore Block"
	icon_state = "awaycontent3"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambigen12.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/Gate
	name = "BMP Gate"
	icon_state = "awaycontent4"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambidanger.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/Armory
	name = "BMP Armory"
	icon_state = "awaycontent5"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/CommonArea
	name = "BMP Common Area"
	icon_state = "awaycontent6"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambigen4.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/MedBay
	name = "BMP MedBay Block"
	icon_state = "awaycontent7"
	requires_power = TRUE
	ambientsounds = list('sound/ambience/ambigen6.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/ChemLab
	name = "BMP Chem Lab"
	icon_state = "awaycontent8"
	requires_power = TRUE
	ambientsounds = "sound/ambience/ambifailure.ogg"

/area/awaymission/BMPship/Shelter
	name = "BMP Shelter"
	icon_state = "awaycontent9"
	requires_power = TRUE
	ambientsounds = "sound/ambience/ambifailure.ogg"

/area/awaymission/BMPship/Dormitories
	name = "BMP Dormitories"
	icon_state = "awaycontent10"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambigen3.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/TurretsNorth
	name = "BMP Turrets North"
	icon_state = "awaycontent11"
	requires_power = TRUE

/area/awaymission/BMPship/TurretsSouth
	name = "BMP Turrets South"
	icon_state = "awaycontent12"
	requires_power = TRUE

/area/awaymission/BMPship/Bath
	name = "Bath"
	icon_state = "awaycontent13"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/Kitchen
	name = "BMP Kitchen"
	icon_state = "awaycontent14"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/Buffer
	name = "BMP Buffer"
	icon_state = "awaycontent15"
	requires_power = TRUE
	fire = TRUE
	ambientsounds = list('sound/ambience/ambigen5.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin3.ogg', 'sound/ambience/ambiruin4.ogg', 'sound/ambience/ambiruin5.ogg', 'sound/ambience/ambiruin6.ogg')

/area/awaymission/BMPship/TraderShuttle
	name = "BMP Trader Shuttle"
	icon_state = "awaycontent16"
	requires_power = TRUE
	ambientsounds = "sound/spookoween/ghost_whisper.ogg"

/area/awaymission/BMPship/Mining
	name = "BMP Mining"
	icon_state = "awaycontent17"
	requires_power = TRUE

/* Jungle Planet */
/area/awaymission/jungle_planet
	name = "Jungle"
	icon_state = "away"
	report_alerts = FALSE

/area/awaymission/jungle_planet/outside
	name = "Jungle"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	icon_state = "awaycontent1"
	always_unpowered = TRUE
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/jungle1.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/jungle2.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/jungle3.ogg')

/area/awaymission/jungle_planet/outside/abandoned
	name = "Abandoned"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	icon_state = "awaycontent5"

/area/awaymission/jungle_planet/outside/river
	name = "River"
	icon_state = "awaycontent2"
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/river.ogg')

/area/awaymission/jungle_planet/outside/waterfall
	name = "Waterfall"
	icon_state = "awaycontent3"
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/waterfall.ogg')

/area/awaymission/jungle_planet/outside/cave
	name = "Cave"
	icon_state = "awaycontent4"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/cave_ambient2.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/cave_ambient3.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/cave_waterdrops.ogg')

/area/awaymission/jungle_planet/outside/cave/small
	name = "Small Cave"
	icon_state = "awaycontent7"
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/cave_waterfall.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/cave_waterdrops.ogg')

/area/awaymission/jungle_planet/outside/cave/pirate
	name = "Pirate Cave"
	icon_state = "awaycontent6"
	always_unpowered = FALSE
	requires_power = FALSE
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/cave_waterdrops.ogg')

/area/awaymission/jungle_planet/inside
	name = "Hangar 2"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	icon_state = "awaycontent8"
	requires_power = TRUE

/area/awaymission/jungle_planet/inside/complex
	name = "MC-16"
	icon_state = "awaycontent9"
	ambientsounds = list('modular_ss220/aesthetics_sounds/sound/area_ambient/ambient_pulse1.ogg', 'modular_ss220/aesthetics_sounds/sound/area_ambient/ambient_pulse2.ogg')

/* Caves */
/area/awaymission/caves
	name = "Caves"
	icon_state = "away"
	report_alerts = FALSE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/caves/build
	name = "Abandoned building"
	icon_state = "awaycontent1"
	always_unpowered = FALSE
	requires_power = FALSE

/area/awaymission/caves/build/reqpower_build
	name = "Research Сomplex ''Mirror''"
	icon_state = "awaycontent2"
	requires_power = TRUE

/*Black Mesa*/
/area/awaymission/black_mesa
	name = "Black Mesa Inside"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/black_mesa/entrance
	name = "Black Mesa Entrance"
	icon_state = "awaycontent1"

/area/awaymission/black_mesa/servers
	name = "Black Mesa Server Room"
	icon_state = "awaycontent2"

/area/awaymission/black_mesa/entrance_lobby
	name = "Black Mesa Lobby"
	icon_state = "awaycontent3"

/area/awaymission/black_mesa/entrance_tunnel
	name = "Black Mesa Entrance Tunnels"
	icon_state = "awaycontent4"

/area/awaymission/black_mesa/offices
	name = "Black Mesa Offices"
	icon_state = "awaycontent5"

/area/awaymission/black_mesa/equipment_room
	name = "Black Mesa Equipment Room"
	icon_state = "awaycontent6"

/area/awaymission/black_mesa/genetics
	name = "Black Mesa Genetics"
	icon_state = "awaycontent7"

/area/awaymission/black_mesa/entrance_hall
	name = "Black Mesa Entrance Hallway"
	icon_state = "awaycontent8"

/area/awaymission/black_mesa/scientist_hall
	name = "Black Mesa Science Hallway"
	icon_state = "awaycontent9"

/area/awaymission/black_mesa/science_labs
	name = "Black Mesa Science Laboratories"
	icon_state = "awaycontent10"

/area/awaymission/black_mesa/resonant_chamber
	name = "Black Mesa Resonant Chamber"
	icon_state = "awaycontent11"

/area/awaymission/black_mesa/science_tunnel
	name = "Black Mesa Science Lab Tunnels"
	icon_state = "awaycontent12"

/area/awaymission/black_mesa/science_internal
	name = "Black Mesa Science Lab Internal"
	icon_state = "awaycontent13"

/area/awaymission/black_mesa/science_decon_room
	name = "Black Mesa Science Deconstruction Room"
	icon_state = "awaycontent14"

/area/awaymission/black_mesa/entrance_large_office
	name = "Black Mesa Entrance Large Office"
	icon_state = "awaycontent15"

/area/awaymission/black_mesa/entrance_internal_hall
	name = "Black Mesa Entrance Internal Halls"
	icon_state = "awaycontent16"

/area/awaymission/black_mesa/genetics_sec
	name = "Black Mesa Genetics Checkpoint"
	icon_state = "awaycontent17"

/area/awaymission/black_mesa/genetics_elevator
	name = "Black Mesa Genetics Elevator"
	icon_state = "awaycontent18"

/area/awaymission/black_mesa/cryo_room
	name = "Black Mesa Cryogenics Room"
	icon_state = "awaycontent19"

/area/awaymission/black_mesa/cryo_hallway
	name = "Black Mesa Cryogenics Hallway"
	icon_state = "awaycontent20"

/area/awaymission/black_mesa/cryo_storage
	name = "Black Mesa Cryogenics Storage"
	icon_state = "awaycontent21"

/area/awaymission/black_mesa/gas_emitter_chamber
	name = "Black Mesa Gas Testing Chamber"
	icon_state = "awaycontent22"

/area/awaymission/black_mesa/tram_room
	name = "Black Mesa Tram Room"
	icon_state = "awaycontent23"

/area/awaymission/black_mesa/security_outpost
	name = "Black Mesa Security Outpost"
	icon_state = "awaycontent24"

/area/awaymission/black_mesa/tram_tunnel
	name = "Black Mesa Tram Room Tunnels"
	icon_state = "awaycontent25"

/area/awaymission/black_mesa/employee_dorm_room
	name = "Black Mesa Employee Dorms"
	icon_state = "awaycontent26"

/area/awaymission/black_mesa/dorm_computers
	name = "Black Mesa Dorm Office Room"
	icon_state = "awaycontent27"

/area/awaymission/black_mesa/dorm_tunnel
	name = "Black Mesa Dorm Tunnels"
	icon_state = "awaycontent28"

/area/awaymission/black_mesa/deep_sci_storage
	name = "Black Mesa Deep Science Storage"
	icon_state = "awaycontent29"

/area/awaymission/black_mesa/to_cryo_room
	name = "Black Mesa Intrim Cryogenics Hallway" //look i couldn't think of anything better
	icon_state = "awaycontent1"

/area/awaymission/black_mesa/deep_sci_hall
	name = "Black Mesa Deep Science Hallway"
	icon_state = "awaycontent2"

/area/awaymission/black_mesa/deep_sci_medbay
	name = "Black Mesa Deep Science Medbay"
	icon_state = "awaycontent3"

/area/awaymission/black_mesa/deep_sci_feesh
	name = "Black Mesa Deep Science Fishtank"
	icon_state = "awaycontent4"

/area/awaymission/black_mesa/deep_sci_turret
	name = "Black Mesa Deep Science Turret Room"
	icon_state = "awaycontent5"

/area/awaymission/black_mesa/high_security_hallway
	name = "Black Mesa High-Security Hallway"
	icon_state = "awaycontent6"

/area/awaymission/black_mesa/high_security_emitter
	name = "Black Mesa High-Security Emitter Room"
	icon_state = "awaycontent7"

/area/awaymission/black_mesa/high_security_armory
	name = "Black Mesa High-Security Armory"
	icon_state = "awaycontent8"

/area/awaymission/black_mesa/high_security_surgery
	name = "Black Mesa High-Security Surgery Theatre"
	icon_state = "awaycontent9"

/area/awaymission/black_mesa/hecu_zone_external_hall
	name = "Black Mesa HECU Territory External Hall"
	icon_state = "awaycontent10"

/area/awaymission/black_mesa/hecu_zone_infirmary
	name = "Black Mesa HECU Territory Infirmary"
	icon_state = "awaycontent11"

/area/awaymission/black_mesa/hecu_zone_bathroom
	name = "Black Mesa HECU Territory Bathroom"
	icon_state = "awaycontent12"

/area/awaymission/black_mesa/hecu_zone_test_chambers
	name = "Black Mesa HECU Territory Testing Chambers"
	icon_state = "awaycontent13"

/area/awaymission/black_mesa/hecu_zone_tunnel
	name = "Black Mesa HECU Territory Tunnel"
	icon_state = "awaycontent14"

/area/awaymission/black_mesa/hecu_zone_atrium
	name = "Black Mesa HECU Territory Atrium"
	icon_state = "awaycontent15"

/area/awaymission/black_mesa/hecu_zone_camp
	name = "Black Mesa HECU Camp"
	icon_state = "awaycontent16"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/awaymission/black_mesa/hecu_zone_towards_facility
	name = "Black Mesa HECU North Zone"
	icon_state = "awaycontent17"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/awaymission/black_mesa/deep_sci_chem
	name = "Black Mesa Deep Science Chemistry"
	icon_state = "awaycontent18"

/area/awaymission/black_mesa/high_security_sec_point
	name = "Black Mesa High-Security Checkpoint"
	icon_state = "awaycontent19"

/area/awaymission/black_mesa/high_security_servers
	name = "Black Mesa High-Security Server Room"
	icon_state = "awaycontent20"

/area/awaymission/black_mesa/hecu_zone_external_sec
	name = "Black Mesa HECU Territory Hall Checkpoint"
	icon_state = "awaycontent21"

/area/awaymission/black_mesa/hecu_zone_external_cavein
	name = "Black Mesa HECU Territory Cave-in"
	icon_state = "awaycontent22"

/area/awaymission/black_mesa/black_ops_entrance
	name = "Black Mesa Spec-OP Entrance"
	icon_state = "awaycontent23"

/area/awaymission/black_mesa/black_ops_bus
	name = "Black Mesa Spec-OP Bus Stop"
	icon_state = "awaycontent24"

/area/awaymission/black_mesa/black_ops_eng_storage
	name = "Black Mesa Spec-OP Engineering Storage"
	icon_state = "awaycontent25"

/area/awaymission/black_mesa/black_ops_downstairs_atrium
	name = "Black Mesa Spec-OP Underground Atrium"
	icon_state = "awaycontent26"

/area/awaymission/black_mesa/black_ops_hall
	name = "Black Mesa Spec-OP Hallway"
	icon_state = "awaycontent27"

/area/awaymission/black_mesa/black_ops_button
	name = "Black Mesa Spec-OP Button Room"
	icon_state = "awaycontent29"

/area/awaymission/black_mesa/black_ops_server
	name = "Black Mesa Spec-OP Server Room"
	icon_state = "awaycontent1"

/area/awaymission/black_mesa/black_ops_turret_blockade
	name = "Black Mesa Spec-OP Turret Hallway"
	icon_state = "awaycontent2"

/area/awaymission/black_mesa/black_ops_science_room
	name = "Black Mesa Spec-OP Science Room"
	icon_state = "awaycontent3"

/area/awaymission/black_mesa/black_ops_armory
	name = "Black Mesa Spec-OP Armory"
	icon_state = "awaycontent4"

/area/awaymission/black_mesa/black_ops_hallway_two
	name = "Black Mesa Spec-OP Back Hallway"
	icon_state = "awaycontent5"

/area/awaymission/black_mesa/lambda_hallway
	name = "Black Mesa Lambda Hallway"
	icon_state = "awaycontent6"

/area/awaymission/black_mesa/lambda_teleporter
	name = "Black Mesa Lambda Teleporter"
	icon_state = "awaycontent7"

/area/awaymission/black_mesa/outside
	name = "Black Mesa Outside"

/area/awaymission/black_mesa/xen
	name = "Black Mesa Xen"

/area/awaymission/black_mesa/xen/entering_zone
	name = "Black Mesa Xen Entrance"
	icon_state = "awaycontent1"

/area/awaymission/black_mesa/xen/lost_camp
	name = "Black Mesa Xen Lost Camp"
	icon_state = "awaycontent2"

/area/awaymission/black_mesa/xen/lost_camp_hallway
	name = "Black Mesa Xen Lost Camp Hallway"
	icon_state = "awaycontent3"

/area/awaymission/black_mesa/xen/vortigaunt_village
	name = "Black Mesa Xen Vortigaunt Village One"
	icon_state = "awaycontent4"

/area/awaymission/black_mesa/xen/mp5_outpost
	name = "Black Mesa Xen MP5 Outpost"
	icon_state = "awaycontent5"

/area/awaymission/black_mesa/xen/village_hallway
	name = "Black Mesa Xen Village Hallway"
	icon_state = "awaycontent6"

/area/awaymission/black_mesa/xen/acid_lake
	name = "Black Mesa Xen Acid Lake"
	icon_state = "awaycontent7"

/area/awaymission/black_mesa/xen/acid_lake_building
	name = "Black Mesa Xen Acid Lake Building"
	icon_state = "awaycontent8"

/area/awaymission/black_mesa/xen/acid_lake_hallway
	name = "Black Mesa Xen Acid Lake Hallway"
	icon_state = "awaycontent9"

/area/awaymission/black_mesa/xen/freeman_puzzle
	name = "Black Mesa Xen Freeman Puzzle Room"
	icon_state = "awaycontent10"

/area/awaymission/black_mesa/xen/freeman_arena
	name = "Black Mesa Xen Freeman Chamber"
	icon_state = "awaycontent11"

/area/awaymission/black_mesa/xen/freeman_hallway
	name = "Black Mesa Xen Freeman Hallway"
	icon_state = "awaycontent12"

/area/awaymission/black_mesa/xen/hev_supply_nook
	name = "Black Mesa Xen HEV Supply Nest"
	icon_state = "awaycontent13"

/area/awaymission/black_mesa/xen/vortigaunt_village_nihilanth
	name = "Black Mesa Xen Vortigaunt Village Two"
	icon_state = "awaycontent14"

/area/awaymission/black_mesa/xen/antag_token_nook
	name = "Black Mesa Xen Antag Token Nook"
	icon_state = "awaycontent15"

/area/awaymission/black_mesa/xen/crowbar_nook
	name = "Black Mesa Xen Crowbar Nook"
	icon_state = "awaycontent16"

/area/awaymission/black_mesa/xen/nihilanth_computer
	name = "Black Mesa Xen Computer Room"
	icon_state = "awaycontent17"

/area/awaymission/black_mesa/xen/nihilanth_hallway
	name = "Black Mesa Xen Nihilanth Hallway"
	icon_state = "awaycontent18"

/area/awaymission/black_mesa/xen/nihilanth_arena
	name = "Black Mesa Xen Nihilanth Chamber"
	icon_state = "awaycontent19"

/*Space Battle*/
/area/awaymission/space_battle
	name = "\improper Space Battle"
	icon_state = "awaycontent1"
	requires_power = TRUE
	report_alerts = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/space_battle/cruiser
	name = "\improper Nanotrasen Cruiser"
	icon_state = "awaycontent2"

/area/awaymission/space_battle/prhallway1
	name = "\improper Port Primary Hallway"
	icon_state = "awaycontent10"

/area/awaymission/space_battle/prhallway2
	name = "\improper Central Primary Hallway"
	icon_state = "awaycontent11"

/area/awaymission/space_battle/prhallway3
	name = "\improper Starboard Primary Hallway"
	icon_state = "awaycontent12"

/area/awaymission/space_battle/kitchen
	name = "\improper Kitchen"
	icon_state = "awaycontent13"

/area/awaymission/space_battle/medbay
	name = "\improper MedBay"
	icon_state = "awaycontent14"

/area/awaymission/space_battle/server
	name = "\improper Server Room"
	icon_state = "awaycontent15"

/area/awaymission/space_battle/bridge
	name = "\improper Bridge"
	icon_state = "awaycontent16"

/area/awaymission/space_battle/hallway1
	name = "\improper Hallway"
	icon_state = "awaycontent17"

/area/awaymission/space_battle/hallway2
	name = "\improper Hallway"
	icon_state = "awaycontent18"

/area/awaymission/space_battle/hallway3
	name = "\improper Hallway"
	icon_state = "awaycontent19"

/area/awaymission/space_battle/hallway4
	name = "\improper Hallway"
	icon_state = "awaycontent20"

/area/awaymission/space_battle/hallway5
	name = "\improper Hallway"
	icon_state = "awaycontent21"

/area/awaymission/space_battle/hallway6
	name = "\improper Hallway"
	icon_state = "awaycontent22"

/area/awaymission/space_battle/hallway7
	name = "\improper Hallway"
	icon_state = "awaycontent23"

/area/awaymission/space_battle/hallway8
	name = "\improper Hallway"
	icon_state = "awaycontent24"

/area/awaymission/space_battle/hallway9
	name = "\improper Hallway"
	icon_state = "awaycontent25"

/area/awaymission/space_battle/hallway10
	name = "\improper Hallway"
	icon_state = "awaycontent26"

/area/awaymission/space_battle/hallway11
	name = "\improper Hallway"
	icon_state = "awaycontent27"

/area/awaymission/space_battle/engine
	name = "\improper Engine Room"
	icon_state = "awaycontent28"

/area/awaymission/space_battle/engineering
	name = "\improper Engineering"
	icon_state = "awaycontent29"

/area/awaymission/space_battle/storage
	name = "\improper Storage"
	icon_state = "awaycontent30"

/area/awaymission/space_battle/living
	name = "\improper Living Room"
	icon_state = "awaycontent1"

/area/awaymission/space_battle/turret1
	name = "\improper Turret Room"
	icon_state = "awaycontent2"

/area/awaymission/space_battle/turret2
	name = "\improper Turret Room"
	icon_state = "awaycontent3"

/area/awaymission/space_battle/turret3
	name = "\improper Turret Room"
	icon_state = "awaycontent4"

/area/awaymission/space_battle/turret4
	name = "\improper Turret Room"
	icon_state = "awaycontent5"

/area/awaymission/space_battle/turret5
	name = "\improper Turret Room"
	icon_state = "awaycontent6"

/area/awaymission/space_battle/turret6
	name = "\improper Turret Room"
	icon_state = "awaycontent7"

/area/awaymission/space_battle/turret7
	name = "\improper Turret Room"
	icon_state = "awaycontent8"

/area/awaymission/space_battle/turret8
	name = "\improper Turret Room"
	icon_state = "awaycontent9"

/area/awaymission/space_battle/syndicate
	name = "\improper Syndicate Assault Ship 1"
	icon_state = "awaycontent3"
	requires_power = FALSE

/area/awaymission/space_battle/syndicate/syndicate1
	name = "\improper Syndicate Assault Ship 2"
	icon_state = "awaycontent4"

/area/awaymission/space_battle/syndicate/syndicate2
	name = "\improper Syndicate Assault Ship 3"
	icon_state = "awaycontent5"

/area/awaymission/space_battle/syndicate/syndicate3
	name = "\improper Syndicate War Sphere 1"
	icon_state = "awaycontent6"

/area/awaymission/space_battle/syndicate/syndicate4
	name = "\improper Syndicate War Sphere 2"
	icon_state = "awaycontent7"

/area/awaymission/space_battle/syndicate/syndicate5
	name = "\improper Syndicate War Sphere 3"
	icon_state = "awaycontent8"

/area/awaymission/space_battle/syndicate/syndicate6
	name = "\improper Syndicate Fighter"
	icon_state = "awaycontent9"

/area/awaymission/space_battle/sec_storage
	name = "\improper Turret Room"
	icon_state = "awaycontent10"
