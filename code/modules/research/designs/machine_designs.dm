///////////////////////////////////
//////////Machine Boards///////////
///////////////////////////////////

/datum/design/thermomachine
	name = "Machine Board (Freezer/Heater)"
	desc = "The circuit board for a Freezer/Heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/thermomachine
	category = list ("Engineering Machinery")

/datum/design/smes
	name = "Machine Board (SMES)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "power" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes
	category = list ("Engineering Machinery")

/datum/design/telepad
	name = "Machine Board (Telepad Board)"
	desc = "Allows for the construction of circuit boards used to build a Telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 4, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")

/datum/design/teleport_hub
	name = "Machine Board (Teleportation Hub)"
	desc = "Allows for the construction of circuit boards used to build a Teleportation Hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub
	category = list ("Teleportation Machinery")

/datum/design/teleport_station
	name = "Machine Board (Teleportation Station)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Station."
	id = "tele_station"
	req_tech = list("programming" = 4, "bluespace" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station
	category = list ("Teleportation Machinery")

/datum/design/bodyscanner
	name = "Machine Board (Body Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Body Scanner."
	id = "bodyscanner"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/bodyscanner
	category = list("Medical Machinery")

/datum/design/bodyscanner_console
	name = "Machine Board (Body Scanner Console)"
	desc = "Allows for the construction of circuit boards used to build a Body Scanner Console."
	id = "bodyscanner_console"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/bodyscanner_console
	category = list("Medical Machinery")

/datum/design/clonepod
	name = "Machine Board (Cloning Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod
	category = list("Medical Machinery")

/datum/design/clonescanner
	name = "Machine Board (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner
	category = list("Medical Machinery")

/datum/design/cryotube
	name = "Machine Board (Cryotube Board)"
	desc = "Allows for the construction of circuit boards used to build a Cryotube."
	id = "cryotube"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube
	category = list("Medical Machinery")

/datum/design/chem_dispenser
	name = "Machine Board (Portable Chem Dispenser)"
	desc = "The circuit board for a Portable Chem Dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4, "materials" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser
	category = list("Medical Machinery")

/datum/design/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	desc = "The circuit board for a chemical heater."
	id = "chem_heater"
	req_tech = list("engineering" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_heater
	category = list ("Medical Machinery")

/datum/design/sleeper
	name = "Machine Board (Sleeper)"
	desc = "Allows for the construction of circuit boards used to build a Sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper
	category = list("Medical Machinery")

/datum/design/sleep_console
	name = "Machine Board (Sleeper Console)"
	desc = "Allows for the construction of circuit boards used to build a Sleeper Console."
	id = "sleeper_console"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleep_console
	category = list("Medical Machinery")

/datum/design/biogenerator
	name = "Machine Board (Biogenerator)"
	desc = "The circuit board for a Biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator
	category = list ("Hydroponics Machinery")

/datum/design/hydroponics
	name = "Machine Board (Hydroponics Tray)"
	desc = "The circuit board for a Hydroponics Tray."
	id = "hydro_tray"
	req_tech = list("programming" = 1, "biotech" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics
	category = list ("Hydroponics Machinery")

/datum/design/autolathe
	name = "Machine Board (Autolathe)"
	desc = "The circuit board for an Autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe
	category = list("Research Machinery")

/datum/design/circuit_imprinter
	name = "Machine Board (Circuit Imprinter)"
	desc = "The circuit board for a Circuit Imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter
	category = list("Research Machinery")

/datum/design/cyborgrecharger
	name = "Machine Board (Cyborg Recharger)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger
	category = list("Research Machinery")

/datum/design/destructive_analyzer
	name = "Machine Board (Destructive Analyzer)"
	desc = "The circuit board for a Destructive Analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer
	category = list("Research Machinery")

/datum/design/mechfab
	name = "Machine Board (Exosuit Fabricator)"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab
	category = list("Research Machinery")

/datum/design/mech_recharger
	name = "Machine Board (Mech Bay Recharger)"
	desc = "The circuit board for a Mech Bay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger
	category = list("Research Machinery")

/datum/design/protolathe
	name = "Machine Board (Protolathe)"
	desc = "The circuit board for a Protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe
	category = list("Research Machinery")

/datum/design/rdserver
	name = "Machine Board (R&D Server)"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver
	category = list("Research Machinery")

/datum/design/arcadebattle
	name = "Machine Board (Battle Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Arcade Machine."
	id = "arcademachinebattle"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/battle
	category = list("Misc. Machinery")

/datum/design/microwave
	name = "Machine Board (Microwave)"
	desc = "The circuit board for a Microwave."
	id = "microwave"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave
	category = list("Misc. Machinery")

/datum/design/oven
	name = "Machine Board (Oven)"
	desc = "The circuit board for an Oven."
	id = "oven"
	req_tech = list("programming" = 1, "plasmatech" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/oven
	category = list("Misc. Machinery")

/datum/design/grill
	name = "Machine Board (Grill)"
	desc = "The circuit board for a Grill."
	id = "grill"
	req_tech = list("programming" = 1, "plasmatech" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grill
	category = list("Misc. Machinery")

/datum/design/candy_maker
	name = "Machine Board (Candy Maker)"
	desc = "The circuit board for a Candy Maker."
	id = "candymaker"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/candy_maker
	category = list("Misc. Machinery")

/datum/design/orion_trail
	name = "Machine Board (Orion Trail Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Orion Trail machine."
	id = "arcademachineonion"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/orion_trail
	category = list("Misc. Machinery")

/datum/design/programmable
	name = "Machine Board (Programmable Unloader)"
	desc = "The circuit board for a Programmable Unloader."
	id = "selunload"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/programmable
	category = list("Misc. Machinery")

/datum/design/vendor
	name = "Machine Board (Vendor)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor
	category = list("Misc. Machinery")

/datum/design/pod
	name = "Machine Board (Mass Driver and Pod Doors Control)"
	desc = "Allows for the construction of circuit boards used to build a Mass Driver and Pod Doors Control."
	id = "pod"
	req_tech = list("programming" = 2,"engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pod
	category = list("Misc. Machinery")