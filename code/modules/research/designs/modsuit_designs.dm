/////////////////////////////////////////
///////////////////MOD///////////////////
/////////////////////////////////////////

/datum/design/mod_shell
	name = "MOD Shell"
	desc = "A 'Cybersun Industries' designed shell for a Modular Suit."
	id = "mod_shell"
	build_type = MECHFAB
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 5000)
	construction_time = 25 SECONDS
	build_path = /obj/item/mod/construction/shell
	category = list("MODsuit Construction")

/datum/design/mod_helmet
	name = "MOD Helmet"
	desc = "A 'Cybersun Industries' designed helmet for a Modular Suit."
	id = "mod_helmet"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/helmet
	category = list("MODsuit Construction")

/datum/design/mod_chestplate
	name = "MOD Chestplate"
	desc = "A 'Cybersun Industries' designed chestplate for a Modular Suit."
	id = "mod_chestplate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/chestplate
	category = list("MODsuit Construction")

/datum/design/mod_gauntlets
	name = "MOD Gauntlets"
	desc = "'Cybersun Industries' designed gauntlets for a Modular Suit."
	id = "mod_gauntlets"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/gauntlets
	category = list("MODsuit Construction")

/datum/design/mod_boots
	name = "MOD Boots"
	desc = "'Cybersun Industries' designed boots for a Modular Suit."
	id = "mod_boots"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/boots
	category = list("MODsuit Construction")

/datum/design/mod_scryer
	name = "MODlink Scryer"
	desc = "A neck-worn piece of gear that can call with another MODlink-compatible device."
	id = "mod_scryer"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_GOLD = 500)
	construction_time = 2 SECONDS
	build_path = /obj/item/clothing/neck/link_scryer
	category = list("MODsuit Construction", "Equipment")

/datum/design/mod_plating
	name = "MOD External Plating"
	desc = "External plating for a MODsuit."
	id = "mod_plating_standard"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 15 SECONDS
	build_path = /obj/item/mod/construction/plating
	category = list("MODsuit Construction")

/datum/design/mod_plating/engineering
	name = "MOD Engineering Plating"
	id = "mod_plating_engineering"
	build_path = /obj/item/mod/construction/plating/engineering
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_GOLD = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ENGINE)

/datum/design/mod_plating/atmospheric
	name = "MOD Atmospheric Plating"
	id = "mod_plating_atmospheric"
	build_path = /obj/item/mod/construction/plating/atmospheric
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_TITANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ATMOSPHERICS)

/datum/design/mod_plating/medical
	name = "MOD Medical Plating"
	id = "mod_plating_medical"
	build_path = /obj/item/mod/construction/plating/medical
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_SILVER = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_MEDICAL)

/datum/design/mod_plating/security
	name = "MOD Security Plating"
	id = "mod_plating_security"
	build_path = /obj/item/mod/construction/plating/security
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_URANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_SECURITY)

/datum/design/mod_plating/cosmohonk
	name = "MOD Cosmohonk Plating"
	id = "mod_plating_cosmohonk"
	build_path = /obj/item/mod/construction/plating/cosmohonk
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_BANANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_CLOWN)

/datum/design/mod_skin
	name = "MOD Civilian Skin"
	desc = "A skin applier for a modsuit."
	id = "mod_skin_civilian"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/mod/skin_applier
	category = list("MODsuit Construction")

/datum/design/mod_skin/corpsman
	name = "MOD Corpsman Skin"
	id = "mod_skin_corpsman"
	build_path = /obj/item/mod/skin_applier/corpsman

/datum/design/module
	name = "Storage Module"
	id = "mod_storage"
	build_type = MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 2500, MAT_GLASS = 10000)
	build_path = /obj/item/mod/module/storage
	category = list("MODsuit Modules")

/datum/design/module/mod_storage_expanded
	name = "Expanded Storage Module"
	id = "mod_storage_expanded"
	materials = list(MAT_METAL = 2500, MAT_URANIUM = 10000)
	build_path = /obj/item/mod/module/storage/large_capacity

/datum/design/module/mod_storage_syndicate
	name = "Syndicate Storage Module"
	id = "mod_storage_syndicate"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Evidence Raid  to function.
	build_path = /obj/item/mod/module/storage/syndicate

/datum/design/module/mod_visor_medhud
	name = "Medical Visor Module"
	id = "mod_visor_medhud"
	materials = list(MAT_SILVER = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/medhud

/datum/design/module/mod_visor_diaghud
	name = "Diagnostic Visor Module"
	id = "mod_visor_diaghud"
	materials = list(MAT_GOLD = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/diaghud

/datum/design/module/mod_visor_sechud
	name = "Security Visor Module"
	id = "mod_visor_sechud"
	materials = list(MAT_TITANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/sechud

/datum/design/module/mod_visor_meson
	name = "Meson Visor Module"
	id = "mod_visor_meson"
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/meson

/datum/design/module/mod_visor_welding
	name = "Welding Protection Module"
	id = "mod_welding"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/welding

/datum/design/module/mod_t_ray
	name = "T-Ray Scanner Module"
	id = "mod_t_ray"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/t_ray

/datum/design/module/mod_stealth
	name = "Cloak Module"
	id = "mod_stealth"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //It's a cloaking device, while not foolproof I am making it expencive
	build_path = /obj/item/mod/module/stealth

/datum/design/module/mod_jetpack
	name = "Ion Jetpack Module"
	id = "mod_jetpack"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //Jetpacks are rare, so might as well make it... sorta expencive, I guess.
	build_path = /obj/item/mod/module/jetpack

/datum/design/module/mod_magboot
	name = "Magnetic Stabilizator Module"
	id = "mod_magboot"
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/magboot

/datum/design/module/mod_rad_protection
	name = "Radiation Protection Module"
	id = "mod_rad_protection"
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/rad_protection

/datum/design/module/mod_emp_shield
	name = "EMP Shield Module"
	id = "mod_emp_shield"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //While you are not EMP proof with this, your modules / cell are, and that is quite strong.
	build_path = /obj/item/mod/module/emp_shield

/datum/design/module/mod_flashlight
	name = "Flashlight Module"
	id = "mod_flashlight"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/flashlight


/datum/design/module/mod_tether
	name = "Emergency Tether Module"
	id = "mod_tether"
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/tether


/datum/design/module/mod_reagent_scanner
	name = "Reagent Scanner Module"
	id = "mod_reagent_scanner"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/reagent_scanner

/datum/design/module/mod_gps
	name = "Internal GPS Module"
	id = "mod_gps"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/gps

/datum/design/module/mod_thermal_regulator
	name = "Thermal Regulator Module"
	id = "mod_thermal_regulator"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/thermal_regulator

/datum/design/module/mod_injector
	name = "Injector Module"
	id = "mod_injector"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/injector

/datum/design/module/mod_monitor
	name = "Crew Monitor Module"
	id = "mod_monitor"
	materials = list(MAT_METAL = 1500, MAT_GLASS = 3000)
	build_path = /obj/item/mod/module/monitor

/datum/design/module/defibrillator
	name = "Defibrillator Module"
	id = "mod_defib"
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/defibrillator

/datum/design/module/analyzer
	name = "Health Analyzer Module"
	id = "mod_analyzer"
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/analyzer

/datum/design/module/mod_bikehorn
	name = "Bike Horn Module"
	id = "mod_bikehorn"
	materials = list(MAT_METAL = 2500, MAT_BANANIUM = 2000)
	build_path = /obj/item/mod/module/bikehorn

/datum/design/module/mod_waddle
	name = "Waddle Module"
	id = "mod_waddle"
	materials = list(MAT_METAL = 2500, MAT_BANANIUM = 2000)
	build_path = /obj/item/mod/module/waddle

/datum/design/module/mod_clamp
	name = "Crate Clamp Module"
	id = "mod_clamp"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/clamp

/datum/design/module/mod_drill
	name = "Drill Module"
	id = "mod_drill"
	materials = list(MAT_METAL = 12500, MAT_DIAMOND = 4000) //This drills **really** fast
	build_path = /obj/item/mod/module/drill

/datum/design/module/mod_orebag
	name = "Ore Bag Module"
	id = "mod_orebag"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/orebag

/datum/design/module/mod_dna_lock
	name = "DNA Lock Module"
	id = "mod_dna_lock"
	materials = list(MAT_METAL = 12500, MAT_DIAMOND = 4000) //EMP beats it, but still, anti theft is a premium price in these here parts partner
	build_path = /obj/item/mod/module/dna_lock

/datum/design/module/mod_holster
	name = "Holster Module"
	id = "mod_holster"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/holster

/datum/design/module/mod_sonar
	name = "Active Sonar Module"
	id = "mod_sonar"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/active_sonar

/datum/design/module/pathfinder
	name = "Pathfinder Module"
	id = "mod_pathfinder"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/pathfinder

/datum/design/module/plasma_stabilizer
	name = "Plasma Stabilizer Module"
	id = "mod_plasmastable"
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/plasma_stabilizer

/datum/design/module/smoke_grenade
	name = "Smoke Grenade Module"
	id = "mod_smokegrenade"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12050, MAT_GOLD = 2000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/dispenser/smoke

/datum/design/module/plate_compression
	name = "Plate Compression Module"
	id = "mod_compression"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/plate_compression

/datum/design/module/status_readout
	name = "Status Readout Module"
	id = "mod_status_readout"
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/status_readout

/datum/design/module/mod_teleporter
	name = "Teleporter Module"
	id = "mod_teleporter"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires bluespace anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teleporter

/datum/design/module/mod_kinesis
	name = "Kinesis Module"
	id = "mod_kinesis"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Gravitational anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/kinesis

/datum/design/module/mod_firewall
	name = "Firewall Module"
	id = "mod_firewall"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Pyroclastic anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/firewall

/datum/design/module/mod_arcshield
	name = "Arc-Shield Module"
	id = "mod_arcshield"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Flux anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teslawall

/datum/design/module/mod_vortex
	name = "Vortex Shotgun Module"
	id = "mod_vortex"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Vortex anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/vortex_shotgun

/datum/design/module/mod_cryogrenade
	name = "Cryogrenade Module"
	id = "mod_cryo"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Cryonic anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/cryogrenade
