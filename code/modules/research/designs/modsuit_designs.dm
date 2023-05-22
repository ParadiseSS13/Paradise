/////////////////////////////////////////
///////////////////MOD///////////////////
/////////////////////////////////////////

/datum/design/mod_shell
	name = "MOD Shell"
	desc = "A 'Nakamura Engineering' designed shell for a Modular Suit."
	id = "mod_shell"
	build_type = MECHFAB
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 5000)
	construction_time = 25 SECONDS
	build_path = /obj/item/mod/construction/shell
	category = list("Modsuit Construction")

/datum/design/mod_helmet
	name = "MOD Helmet"
	desc = "A 'Nakamura Engineering' designed helmet for a Modular Suit."
	id = "mod_helmet"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/helmet
	category = list("Modsuit Construction")

/datum/design/mod_chestplate
	name = "MOD Chestplate"
	desc = "A 'Nakamura Engineering' designed chestplate for a Modular Suit."
	id = "mod_chestplate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/chestplate
	category = list("Modsuit Construction")

/datum/design/mod_gauntlets
	name = "MOD Gauntlets"
	desc = "'Nakamura Engineering' designed gauntlets for a Modular Suit."
	id = "mod_gauntlets"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/gauntlets
	category = list("Modsuit Construction")

/datum/design/mod_boots
	name = "MOD Boots"
	desc = "'Nakamura Engineering' designed boots for a Modular Suit."
	id = "mod_boots"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/boots
	category = list("Modsuit Construction")

/datum/design/mod_plating
	name = "MOD External Plating"
	desc = "External plating for a MODsuit."
	id = "mod_plating_standard"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 15 SECONDS
	build_path = /obj/item/mod/construction/plating
	category = list("Modsuit Construction")

/datum/design/mod_plating/New()
	. = ..()
	var/obj/item/mod/construction/plating/armor_type = build_path
	var/datum/mod_theme/theme = GLOB.mod_themes[initial(armor_type.theme)]
	desc = "External plating for a MODsuit. [theme.desc]"

/datum/design/mod_plating/engineering
	name = "MOD Engineering Plating"
	id = "mod_plating_engineering"
	build_path = /obj/item/mod/construction/plating/engineering
	 materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_GOLD = 2000, MAT_PLASMA = 1000)


/datum/design/mod_plating/atmospheric
	name = "MOD Atmospheric Plating"
	id = "mod_plating_atmospheric"
	build_path = /obj/item/mod/construction/plating/atmospheric
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_TITANIUM = 2000, MAT_PLASMA = 1000)

/datum/design/mod_plating/medical
	name = "MOD Medical Plating"
	id = "mod_plating_medical"
	build_path = /obj/item/mod/construction/plating/medical
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_SILVER = 2000, MAT_PLASMA = 1000)

/datum/design/mod_plating/security
	name = "MOD Security Plating"
	id = "mod_plating_security"
	build_path = /obj/item/mod/construction/plating/security
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_URANIUM = 2000, MAT_PLASMA = 1000)

/datum/design/mod_plating/cosmohonk
	name = "MOD Cosmohonk Plating"
	id = "mod_plating_cosmohonk"
	build_path = /obj/item/mod/construction/plating/cosmohonk
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_BANANIUM = 2000, MAT_PLASMA = 1000)

/datum/design/module
	name = "MOD Module"
	build_type = MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/mod/module
	category = list("Modsuit Modules")

/datum/design/module/New()
	. = ..()
	var/obj/item/mod/module/module = build_path
	desc = "[initial(module.desc)] It uses [initial(module.complexity)] complexity."

/datum/design/module/mod_storage
	name = "Storage Module"
	id = "mod_storage"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 10000)
	build_path = /obj/item/mod/module/storage

/datum/design/module/mod_storage_expanded
	name = "Expanded Storage Module"
	id = "mod_storage_expanded"
	materials = list(MAT_METAL = 2500, MAT_URANIUM = 10000)
	build_path = /obj/item/mod/module/storage/large_capacity

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

/datum/design/module/mod_mag_harness
	name = "Magnetic Harness Module"
	id = "mod_mag_harness"
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/magnetic_harness

/datum/design/module/mod_rad_protection
	name = "Radiation Protection Module"
	id = "mod_rad_protection"
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/rad_protection

/datum/design/module/mod_emp_shield //TODO: Make this not work with the dna lock unless advanced
	name = "EMP Shield Module"
	id = "mod_emp_shield"
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //While you are not EMP proof with this, your modules / cell are, and that is quite strong.
	build_path = /obj/item/mod/module/emp_shield

/datum/design/module/mod_flashlight
	name = "Flashlight Module"
	id = "mod_flashlight"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/flashlight

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


/datum/design/module/mister_atmos
	name = "Resin Mister Module"
	id = "mod_mister_atmos"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/mister/atmos

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

///datum/design/module/defibrillator //TODO: ADD THIS DIPSHIT
//	name = "Defibrillator Module"
//	id = "mod_defib"
//	materials = list(/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/diamond =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
//	build_path = /obj/item/mod/module/defibrillator
//	category = list(
//		RND_CATEGORY_MODSUIT_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL
//	)

/datum/design/module/disposal
	name = "Disposal Connector Module"
	id = "mod_disposal"
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/disposal_connector

/datum/design/module/mod_teleporter
	name = "Teleporter Module"
	id = "mod_teleporter"
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires bluespace anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teleporter
