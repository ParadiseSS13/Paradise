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
