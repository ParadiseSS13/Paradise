///////////////////////////////////
//////////Machine Boards///////////
///////////////////////////////////

/datum/design/thermomachine
	name = "Machine Board (Freezer/Heater)"
	desc = "The circuit board for a Freezer/Heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/thermomachine
	category = list ("Engineering Machinery")

/datum/design/smes
	name = "Machine Board (SMES)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "power" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes
	category = list ("Engineering Machinery")

/datum/design/emitter
	name = "Machine Board (Emitter)"
	desc = "The circuit board for an emitter."
	id = "emitter"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/emitter
	category = list ("Engineering Machinery")

/datum/design/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/turbine_computer
	category = list ("Engineering Machinery")

/datum/design/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_compressor
	category = list ("Engineering Machinery")

/datum/design/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_turbine
	category = list ("Engineering Machinery")

/datum/design/telepad
	name = "Machine Board (Telepad Board)"
	desc = "Allows for the construction of circuit boards used to build a Telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 4, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")

/datum/design/teleport_hub
	name = "Machine Board (Teleportation Hub)"
	desc = "Allows for the construction of circuit boards used to build a Teleportation Hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub
	category = list ("Teleportation Machinery")

/datum/design/teleport_station
	name = "Machine Board (Teleportation Station)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Station."
	id = "tele_station"
	req_tech = list("programming" = 4, "bluespace" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station
	category = list ("Teleportation Machinery")

/datum/design/teleport_perma
	name = "Machine Board (Permanent Teleporter)"
	desc = "Allows for the construction of circuit boards used to build a Permanent Teleporter."
	id = "tele_perma"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_perma
	category = list ("Teleportation Machinery")

/datum/design/bodyscanner
	name = "Machine Board (Body Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Body Scanner."
	id = "bodyscanner"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/bodyscanner
	category = list("Medical Machinery")

/datum/design/bodyscanner_console
	name = "Machine Board (Body Scanner Console)"
	desc = "Allows for the construction of circuit boards used to build a Body Scanner Console."
	id = "bodyscanner_console"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/bodyscanner_console
	category = list("Medical Machinery")

/datum/design/clonepod
	name = "Machine Board (Cloning Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod
	category = list("Medical Machinery")

/datum/design/clonescanner
	name = "Machine Board (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner
	category = list("Medical Machinery")

/datum/design/cryotube
	name = "Machine Board (Cryotube Board)"
	desc = "Allows for the construction of circuit boards used to build a Cryotube."
	id = "cryotube"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube
	category = list("Medical Machinery")

/datum/design/chem_dispenser
	name = "Machine Board (Portable Chem Dispenser)"
	desc = "The circuit board for a Portable Chem Dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4, "materials" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser
	category = list("Medical Machinery")

/datum/design/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "The circuit board for a Chem Master 2999."
	id = "chem_master"
	req_tech = list("biotech" = 1, "materials" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_master
	category = list("Medical Machinery")

/datum/design/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	desc = "The circuit board for a chemical heater."
	id = "chem_heater"
	req_tech = list("engineering" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_heater
	category = list ("Medical Machinery")

/datum/design/sleeper
	name = "Machine Board (Sleeper)"
	desc = "Allows for the construction of circuit boards used to build a Sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper
	category = list("Medical Machinery")

/datum/design/biogenerator
	name = "Machine Board (Biogenerator)"
	desc = "The circuit board for a Biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator
	category = list ("Hydroponics Machinery")

/datum/design/hydroponics
	name = "Machine Board (Hydroponics Tray)"
	desc = "The circuit board for a Hydroponics Tray."
	id = "hydro_tray"
	req_tech = list("programming" = 1, "biotech" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics
	category = list ("Hydroponics Machinery")

/datum/design/autolathe
	name = "Machine Board (Autolathe)"
	desc = "The circuit board for an Autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe
	category = list("Research Machinery")

/datum/design/circuit_imprinter
	name = "Machine Board (Circuit Imprinter)"
	desc = "The circuit board for a Circuit Imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter
	category = list("Research Machinery")

/datum/design/cyborgrecharger
	name = "Machine Board (Cyborg Recharger)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger
	category = list("Research Machinery")

/datum/design/destructive_analyzer
	name = "Machine Board (Destructive Analyzer)"
	desc = "The circuit board for a Destructive Analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer
	category = list("Research Machinery")

/datum/design/mechfab
	name = "Machine Board (Exosuit Fabricator)"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab
	category = list("Research Machinery")

/datum/design/mech_recharger
	name = "Machine Board (Mech Bay Recharger)"
	desc = "The circuit board for a Mech Bay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger
	category = list("Research Machinery")

/datum/design/experimentor
	name = "Machine Design (E.X.P.E.R.I-MENTOR Board)"
	desc = "The circuit board for an E.X.P.E.R.I-MENTOR."
	id = "experimentor"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/experimentor
	category = list("Research Machinery")

/datum/design/protolathe
	name = "Machine Board (Protolathe)"
	desc = "The circuit board for a Protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe
	category = list("Research Machinery")

/datum/design/rdserver
	name = "Machine Board (R&D Server)"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver
	category = list("Research Machinery")

/datum/design/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/gibber
	category = list ("Misc. Machinery")

/datum/design/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "The circuit board for a smartfridge."
	id = "smartfridge"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smartfridge
	category = list ("Misc. Machinery")

/datum/design/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "The circuit board for a monkey recycler."
	id = "monkey_recycler"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/monkey_recycler
	category = list ("Misc. Machinery")

/datum/design/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "The circuit board for a seed extractor."
	id = "seed_extractor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/seed_extractor
	category = list ("Misc. Machinery")

/datum/design/processor
	name = "Machine Design (Processor Board)"
	desc = "The circuit board for a processor."
	id = "processor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/processor
	category = list ("Misc. Machinery")

/datum/design/recycler
	name = "Machine Design (Recycler Board)"
	desc = "The circuit board for a recycler."
	id = "recycler"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/recycler
	category = list ("Misc. Machinery")

/datum/design/holopad
	name = "Machine Design (AI Holopad Board)"
	desc = "The circuit board for a holopad."
	id = "holopad"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/holopad
	category = list ("Misc. Machinery")

/datum/design/arcadebattle
	name = "Machine Board (Battle Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Arcade Machine."
	id = "arcademachinebattle"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/battle
	category = list("Misc. Machinery")

/datum/design/microwave
	name = "Machine Board (Microwave)"
	desc = "The circuit board for a Microwave."
	id = "microwave"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave
	category = list("Misc. Machinery")

/datum/design/oven
	name = "Machine Board (Oven)"
	desc = "The circuit board for an Oven."
	id = "oven"
	req_tech = list("programming" = 1, "plasmatech" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/oven
	category = list("Misc. Machinery")

/datum/design/grill
	name = "Machine Board (Grill)"
	desc = "The circuit board for a Grill."
	id = "grill"
	req_tech = list("programming" = 1, "plasmatech" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grill
	category = list("Misc. Machinery")

/datum/design/candy_maker
	name = "Machine Board (Candy Maker)"
	desc = "The circuit board for a Candy Maker."
	id = "candymaker"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/candy_maker
	category = list("Misc. Machinery")

/datum/design/deepfryer
	name = "Machine Board (Deep Fryer)"
	desc = "The circuit board for a Deep Fryer."
	id = "deepfryer"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/deepfryer
	category = list("Misc. Machinery")

/datum/design/orion_trail
	name = "Machine Board (Orion Trail Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Orion Trail machine."
	id = "arcademachineonion"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/orion_trail
	category = list("Misc. Machinery")

/datum/design/programmable
	name = "Machine Board (Programmable Unloader)"
	desc = "The circuit board for a Programmable Unloader."
	id = "selunload"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/programmable
	category = list("Misc. Machinery")

/datum/design/pod
	name = "Machine Board (Mass Driver and Pod Doors Control)"
	desc = "Allows for the construction of circuit boards used to build a Mass Driver and Pod Doors Control."
	id = "pod"
	req_tech = list("programming" = 2,"engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pod
	category = list("Misc. Machinery")

/datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/ore_redemption
	category = list ("Misc. Machinery")

/datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vendor Board)"
	desc = "The circuit board for a Mining Rewards Vendor."
	id = "mining_equipment_vendor"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/mining_equipment_vendor
	category = list ("Misc. Machinery")

/datum/design/clawgame
	name = "Machine Design (Claw Game Board)"
	desc = "The circuit board for a Claw Game."
	id = "clawgame"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/clawgame
	category = list ("Misc. Machinery")

/datum/design/prize_counter
	name = "Machine Design (Prize Counter)"
	desc = "The circuit board for an arcade Prize Counter."
	id = "prize_counter"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/prize_counter
	category = list("Misc. Machinery")

/datum/design/gameboard
	name = "Machine Design (Virtual Gameboard)"
	desc = "The circuit board for a Virtual Gameboard."
	id = "gameboard"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/gameboard
	category = list("Misc. Machinery")


/datum/design/botany_extractor
	name = "Machine Design (Lysis-Isolation Centrifuge)"
	desc = "The circuit board for a lysis-isolation centrifuge."
	id = "botany_extractor"
	req_tech = list("biotech" = 3, "programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/botany_extractor
	category = list("Hydroponics Machinery")

/datum/design/botany_editor
	name = "Machine Design (Bioballistic Delivery System)"
	desc = "The circuit board for a bioballistic delivery system."
	id = "botany_editor"
	req_tech = list("biotech" = 3, "programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000, "sacid"=20)
	build_path = /obj/item/weapon/circuitboard/botany_editor
	category = list("Hydroponics Machinery")