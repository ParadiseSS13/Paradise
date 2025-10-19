///////////////////////////////////
//////////Machine Boards///////////
///////////////////////////////////

/datum/design/thermomachine
	name = "Machine Board (Freezer/Heater)"
	desc = "The circuit board for a Freezer/Heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/thermomachine
	category = list ("Engineering Machinery")

/datum/design/laser_terminal
	name = "Machine Board (Laser Terminal)"
	desc = "The circuit board for a PTL terminal."
	id = "laser_terminal"
	req_tech = list("powerstorage" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/machine/laser_terminal
	category = list ("Engineering Machinery")

/datum/design/space_heater
	name = "Machine Board (Space Heater)"
	desc = "The circuit board for a space heater"
	id = "space_heater"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/space_heater
	category = list ("Engineering Machinery")

/datum/design/recharger
	name = "Machine Board (Weapon Recharger)"
	desc = "The circuit board for a weapon recharger."
	id = "recharger"
	build_path = /obj/item/circuitboard/recharger
	materials = list(MAT_GLASS = 1000)
	build_type = IMPRINTER
	req_tech = list("powerstorage" = 3, "materials" = 3)
	category = list("Misc. Machinery")

/datum/design/cell_charger
	name = "Machine Board (Cell Charger)"
	desc = "The circuit board for a cell charger."
	id = "cell_charger"
	build_path = /obj/item/circuitboard/cell_charger
	materials = list(MAT_GLASS = 1000)
	build_type = IMPRINTER
	req_tech = list("powerstorage" = 3, "materials" = 3)
	category = list("Misc. Machinery")

/datum/design/smes
	name = "Machine Board (SMES)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/smes
	category = list ("Engineering Machinery")

/datum/design/emitter
	name = "Machine Board (Emitter)"
	desc = "The circuit board for an emitter."
	id = "emitter"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/emitter
	category = list ("Engineering Machinery")

/datum/design/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/turbine_computer
	category = list ("Engineering Machinery")

/datum/design/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/power_compressor
	category = list ("Engineering Machinery")

/datum/design/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/power_turbine
	category = list ("Engineering Machinery")

/datum/design/suit_storage_unit
	name = "Machine Design (Suit Storage Unit)"
	desc = "The circuit board for a Suit Storage Unit."
	id = "ssu"
	req_tech = list("engineering" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/suit_storage_unit
	category = list("Engineering Machinery")

/datum/design/suit_storage_unit/industrial
	name = "Machine Design (Industrial Suit Storage Unit)"
	desc = "The circuit board for an Industrial Suit Storage Unit."
	id = "issu"
	req_tech = list("engineering" = 5, "materials" = 4)
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/suit_storage_unit/industrial
	category = list("Engineering Machinery")

/datum/design/quantumpad
	name = "Machine Board (Quantum Pad Board)"
	desc = "The circuit board for a quantum telepad."
	id = "quantumpad"
	req_tech = list("programming" = 4, "bluespace" = 4, "plasmatech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/quantumpad
	category = list ("Teleportation Machinery")

/datum/design/teleport_hub
	name = "Machine Board (Teleportation Hub)"
	desc = "Allows for the construction of circuit boards used to build a Teleportation Hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter_hub
	category = list ("Teleportation Machinery")

/datum/design/teleport_station
	name = "Machine Board (Teleportation Station)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Station."
	id = "tele_station"
	req_tech = list("programming" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter_station
	category = list ("Teleportation Machinery")

/datum/design/teleport_perma
	name = "Machine Board (Permanent Teleporter)"
	desc = "Allows for the construction of circuit boards used to build a Permanent Teleporter."
	id = "tele_perma"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter_perma
	category = list ("Teleportation Machinery")

/datum/design/bodyscanner
	name = "Machine Board (Body Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Body Scanner."
	id = "bodyscanner"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/bodyscanner
	category = list("Medical Machinery")

/datum/design/clonepod
	name = "Machine Board (Cloning Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/clonepod
	category = list("Medical Machinery")

/datum/design/clonescanner
	name = "Machine Board (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/clonescanner
	category = list("Medical Machinery")

/datum/design/dna_scanner
	name = "Machine Board (DNA Modifier)"
	desc = "Allows for the construction of circuit boards used to build a DNA Modifier."
	id = "dna_scanner"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/dna_scanner
	category = list("Medical Machinery")

/datum/design/cryotube
	name = "Machine Board (Cryotube Board)"
	desc = "Allows for the construction of circuit boards used to build a Cryotube."
	id = "cryotube"
	req_tech = list("programming" = 5, "biotech" = 3, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cryo_tube
	category = list("Medical Machinery")

/datum/design/chem_dispenser
	name = "Machine Board (Chem Dispenser)"
	desc = "The circuit board for a Chem Dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 5, "biotech" = 3, "materials" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_dispenser
	category = list("Medical Machinery")

/datum/design/chem_master
	name = "Machine Design (ChemMaster Board)"
	desc = "The circuit board for a ChemMaster 3000."
	id = "chem_master"
	req_tech = list("biotech" = 3, "materials" = 3, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_master
	category = list("Medical Machinery")

/datum/design/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	desc = "The circuit board for a chemical heater."
	id = "chem_heater"
	req_tech = list("engineering" = 2, "biotech" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_heater
	category = list ("Medical Machinery")

/datum/design/reagentgrinder
	name = "Machine Design (All-In-One Grinder)"
	desc = "The circuit board for an All-In-One Grinder."
	id = "reagentgrinder"
	req_tech = list("biotech" = 2, "materials" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/reagentgrinder
	category = list ("Medical Machinery")

/datum/design/sleeper
	name = "Machine Board (Sleeper)"
	desc = "Allows for the construction of circuit boards used to build a Sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/sleeper
	category = list("Medical Machinery")

/datum/design/biogenerator
	name = "Machine Board (Biogenerator)"
	desc = "The circuit board for a Biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 2, "biotech" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/biogenerator
	category = list ("Hydroponics Machinery")

/datum/design/hydroponics
	name = "Machine Board (Hydroponics Tray)"
	desc = "The circuit board for a Hydroponics Tray."
	id = "hydro_tray"
	req_tech = list("biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/hydroponics
	category = list ("Hydroponics Machinery")

/datum/design/autolathe
	name = "Machine Board (Autolathe)"
	desc = "The circuit board for an Autolathe."
	id = "autolathe"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/autolathe
	category = list("Research Machinery")

/datum/design/circuit_imprinter
	name = "Machine Board (Circuit Imprinter)"
	desc = "The circuit board for a Circuit Imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/circuit_imprinter
	category = list("Research Machinery")

/datum/design/cyborgrecharger
	name = "Machine Board (Cyborg Recharger)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cyborgrecharger
	category = list("Research Machinery")

/datum/design/anomaly_refinery
	name = "Machine Board (Anomaly Refinery)"
	desc = "The circuit board for an Anomaly Refinery."
	id = "anomalyrefinery"
	req_tech = list("powerstorage" = 5, "engineering" = 5, "toxins" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/anomaly_refinery
	category = list("Research Machinery")

/datum/design/scientific_analyzer
	name = "Machine Board (Scientific Analyzer)"
	desc = "The circuit board for a Scientific Analyzer."
	id = "scientific_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/scientific_analyzer
	category = list("Research Machinery")

/datum/design/mechfab
	name = "Machine Board (Exosuit Fabricator)"
	desc = "The circuit board for an Exosuit Fabricator."
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mechfab
	category = list("Research Machinery")

/datum/design/mech_recharger
	name = "Machine Board (Mech Bay Recharger)"
	desc = "The circuit board for a Mech Bay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mech_recharger
	category = list("Research Machinery")

/datum/design/protolathe
	name = "Machine Board (Protolathe)"
	desc = "The circuit board for a Protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/protolathe
	category = list("Research Machinery")

/datum/design/rdserver
	name = "Machine Board (R&D Server)"
	desc = "The circuit board for an R&D Server."
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/rdserver
	category = list("Research Machinery")

/datum/design/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/gibber
	category = list ("Misc. Machinery")

/datum/design/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "The circuit board for a smartfridge."
	id = "smartfridge"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/smartfridge
	category = list ("Misc. Machinery")

/datum/design/dish_drive
	name = "Machine Design (Dish Drive Board)"
	desc = "The circuit board for a dish drive."
	id = "dishdrive"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/dish_drive
	category = list("Misc. Machinery")

/datum/design/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "The circuit board for a monkey recycler."
	id = "monkey_recycler"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/monkey_recycler
	category = list ("Misc. Machinery")

/datum/design/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "The circuit board for a seed extractor."
	id = "seed_extractor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/seed_extractor
	category = list ("Hydroponics Machinery")

/datum/design/processor
	name = "Machine Design (Processor Board)"
	desc = "The circuit board for a processor."
	id = "processor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/processor
	category = list ("Misc. Machinery")

/datum/design/recycler
	name = "Machine Design (Recycler Board)"
	desc = "The circuit board for a recycler."
	id = "recycler"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/recycler
	category = list ("Misc. Machinery")

/datum/design/holopad
	name = "Machine Design (AI Holopad Board)"
	desc = "The circuit board for a holopad."
	id = "holopad"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/holopad
	category = list ("Misc. Machinery")

/datum/design/arcadebattle
	name = "Machine Board (Battle Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Arcade Machine."
	id = "arcademachinebattle"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/arcade/battle
	category = list("Misc. Machinery")

/datum/design/microwave
	name = "Machine Board (Microwave)"
	desc = "The circuit board for a Microwave."
	id = "microwave"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/microwave
	category = list("Misc. Machinery")

/datum/design/oven
	name = "Machine Board (Oven)"
	desc = "The circuit board for an Oven."
	id = "oven"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cooking/oven
	category = list("Misc. Machinery")

/datum/design/grill
	name = "Machine Board (Grill)"
	desc = "The circuit board for a Grill."
	id = "grill"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/grill
	category = list("Misc. Machinery")

/datum/design/ice_cream_mixer
	name = "Machine Board (Ice Cream Mixer)"
	desc = "The circuit board for an Ice Cream Mixer."
	id = "ice_cream_mixer"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cooking/ice_cream_mixer
	category = list("Misc. Machinery")

/datum/design/deepfryer
	name = "Machine Board (Deep Fryer)"
	desc = "The circuit board for a Deep Fryer."
	id = "deepfryer"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/deepfryer
	category = list("Misc. Machinery")

/datum/design/orion_trail
	name = "Machine Board (Orion Trail Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Orion Trail machine."
	id = "arcademachineonion"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/arcade/orion_trail
	category = list("Misc. Machinery")

/datum/design/nt_recruiter
	name = "Machine Board (NT Recruiter Simulator Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new NT Recruiter Simulator machine."
	id = "arcademachinerecruiter"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/arcade/recruiter
	category = list("Misc. Machinery")

/datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	req_tech = list("programming" = 2, "engineering" = 2, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/ore_redemption
	category = list ("Misc. Machinery")

/datum/design/salvage_redemption
	name = "Machine Design (Salvage Redemption)"
	desc = "The circuit board for a Salvage Redemption Machine."
	id = "salvage_redemption"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/salvage_redemption
	category = list ("Misc. Machinery")

/datum/design/smart_hopper
	name = "Machine Design (Smart Hopper)"
	desc = "The circuit board for a Smart Hopper."
	id = "smart_hopper"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/smart_hopper
	category = list ("Misc. Machinery")

/datum/design/magma_crucible
	name = "Machine Design (Magma Crucible)"
	desc = "The circuit board for a Magma Crucible."
	id = "magma_crucible"
	req_tech = list("programming" = 2, "engineering" = 5, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/magma_crucible
	category = list ("Misc. Machinery")

/datum/design/casting_basin
	name = "Machine Design (Casting Bench)"
	desc = "The circuit board for a Casting Bench."
	id = "casting_bench"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/casting_basin
	category = list ("Misc. Machinery")

/datum/design/power_hammer
	name = "Machine Design (Power Hammer)"
	desc = "The circuit board for a Power Hammer."
	id = "power_hammer"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/power_hammer
	category = list ("Misc. Machinery")

/datum/design/lava_furnace
	name = "Machine Design (Lava Furnace)"
	desc = "The circuit board for a Lava Furnace."
	id = "lava_furnace"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/lava_furnace
	category = list ("Misc. Machinery")

/datum/design/kinetic_assembler
	name = "Machine Design (Kinetic Assembler)"
	desc = "The circuit board for a Kinetic Assembler."
	id = "kinetic_assembler"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/kinetic_assembler
	category = list ("Misc. Machinery")

/datum/design/scientific_assembler
	name = "Machine Design (Scientific Assembler)"
	desc = "The circuit board for a Scientific Assembler."
	id = "scientific_assembler"
	req_tech = list("programming" = 2, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/scientific_assembler
	category = list ("Misc. Machinery")

/datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vendor Board)"
	desc = "The circuit board for a Mining Rewards Vendor."
	id = "mining_equipment_vendor"
	req_tech = list("engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mining_equipment_vendor
	category = list ("Misc. Machinery")

/datum/design/explorer_equipment_vendor
	name = "Machine Design (Explorer Rewards Vendor Board)"
	desc = "The circuit board for an Explorer Rewards Vendor."
	id = "explorer_equipment_vendor"
	req_tech = list("engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mining_equipment_vendor/explorer
	category = list ("Misc. Machinery")

/datum/design/clawgame
	name = "Machine Design (Claw Game Board)"
	desc = "The circuit board for a Claw Game."
	id = "clawgame"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/clawgame
	category = list ("Misc. Machinery")

/datum/design/prize_counter
	name = "Machine Design (Prize Counter)"
	desc = "The circuit board for an arcade Prize Counter."
	id = "prize_counter"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/prize_counter
	category = list("Misc. Machinery")

/datum/design/gameboard
	name = "Machine Design (Virtual Gameboard)"
	desc = "The circuit board for a Virtual Gameboard."
	id = "gameboard"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/gameboard
	category = list("Misc. Machinery")

/datum/design/plantgenes
	name = "Machine Design (Plant DNA Manipulator Board)"
	desc = "The circuit board for a plant DNA manipulator."
	id = "plantgenes"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/plantgenes
	category = list("Hydroponics Machinery")

/datum/design/slot_machine
	name = "Machine Design (Slot Machine Board)"
	desc = "The circuit board for a slot machine."
	id = "slotmachine"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/slot_machine
	category = list("Misc. Machinery")

/datum/design/bottler
	name = "Machine Design (Bottler Board)"
	desc = "The circuit board for a bottler."
	id = "bottlers"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/bottler
	category = list("Misc. Machinery")

/datum/design/merch
	name = "Machine Design (Nanotrasen Merch Board)"
	desc = "The circuit board for an NT Merch vendor."
	id = "merch"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/merch
	category = list("Misc. Machinery")

/datum/design/processing_node
	name =  "Machine Design (Processing Node)"
	desc = "The circuit board for a processing node."
	id = "processing_node"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 250)
	build_path = /obj/item/circuitboard/processing_node
	category = list("Misc. Machinery")

/datum/design/network_node
	name =  "Machine Design (Network Node)"
	desc = "The circuit board for a network node."
	id = "network_node"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 250)
	build_path = /obj/item/circuitboard/network_node
	category = list("Misc. Machinery")

/datum/design/ai_resource_console
	name =  "Computer Design (AI Resource Console)"
	desc = "The circuit board for an AI Resource Console."
	id = "ai_resource_console"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/ai_resource_console

/datum/design/autochef
	name = "Machine Design (Autochef)"
	desc = "The circuit board for an autochef."
	id = "autochef"
	req_tech = list("programming" = 3, "bluespace" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/autochef
	category = list("Misc. Machinery")

/datum/design/organ_analyzer
	name = "Machine Design (Organ Analyzer)"
	desc = "The circuit board for an organ analyzer."
	id = "organ_analyzer"
	req_tech = list("programming" = 3, "bluespace" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/organ_analyzer
	category = list("Research Machinery")

// Forensic Machines (DNA analyzer, microscope)
/datum/design/dnaforensics
	name = "Machine Design (DNA analyzer)"
	desc = "DNA analyzer for forensic DNA analysis of objects."
	id = "dnaforensics"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/dnaforensics
	category = list("Misc. Machinery")

/datum/design/microscope
	name = "Machine Design (Forensic Microscope)"
	desc = "Microscope capable of magnifying images 3000 times"
	id = "microscope"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/microscope
	category = list("Misc. Machinery")
