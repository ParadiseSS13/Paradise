/datum/supply_packs/science
	name = "HEADER"
	group = SUPPLY_SCIENCE
	announce_beacons = list("Research Division" = list("Science", "Research Director's Desk"))
	containertype = /obj/structure/closet/crate/sci
	department_restrictions = list(DEPARTMENT_SCIENCE)

/datum/supply_packs/science/rnd	// Everything you need to kick-start Science from scratch once the dust of the apocalypse has blown over.
	name = "Research & Development Crate"
	contains = list(/obj/item/storage/box/large/rnd_parts)
	cost = 1000
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "research & development crate"
	access = ACCESS_RESEARCH
	announce_beacons = list("Research Division" = list("Robotics", "Science", "Research Director's Desk"))

/datum/supply_packs/science/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/box/flashes,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "robotics assembly crate"
	access = ACCESS_ROBOTICS
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))

/datum/supply_packs/science/mod_core
	name = "MOD core Crate"
	contains = list(/obj/item/mod/core/standard,
					/obj/item/mod/core/standard,
					/obj/item/mod/core/standard)
	cost = 450
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "\improper MOD core crate"
	access = ACCESS_ROBOTICS
	announce_beacons = list("Research Division" = list("Robotics"))
	department_restrictions = list() //The crew can order modcores without RD requirement. As a treat.

/datum/supply_packs/science/mechcore
	name = "Mech Power Core Crate"
	contains = list(/obj/item/mecha_parts/core)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "mech power core crate"
	access = ACCESS_RD

/datum/supply_packs/science/robotics/mecha_ripley
	name = "Construction Crate (Ripley APLU)"
	contains = list(/obj/item/book/manual/ripley_build_and_repair,
					/obj/item/circuitboard/mecha/ripley/main,
					/obj/item/circuitboard/mecha/ripley/peripherals,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/stack/sheet/plasteel/fifteen)
	cost = 350
	containertype = /obj/structure/closet/crate/sci/robo
	containername = "\improper APLU \"Ripley\" construction crate"
	announce_beacons = list("Research Division" = list("Robotics"))
	department_restrictions = list(DEPARTMENT_ENGINEERING, DEPARTMENT_SCIENCE) // depending on module combinations, this is miner or engi mech

/datum/supply_packs/science/robotics/mecha_odysseus
	name = "Construction Crate (Odysseus)"
	contains = list(/obj/item/circuitboard/mecha/odysseus/peripherals,
					/obj/item/circuitboard/mecha/odysseus/main,
					/obj/item/mecha_parts/mecha_equipment/medical/sleeper,
					/obj/item/stack/sheet/plasteel/five)
	cost = 350
	containertype = /obj/structure/closet/crate/sci/robo
	containername = "\improper \"Odysseus\" construction crate"
	department_restrictions = list(DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE) // medical mech for medical shenanigans

/datum/supply_packs/science/plasma
	name = "Plasma Assembly Crate"
	contains = list(/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = ACCESS_TOX_STORAGE

/datum/supply_packs/science/shieldwalls
	name = "Shield Generators Crate"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 400
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "shield generators crate"
	access = ACCESS_TELEPORTER
	department_restrictions = list(DEPARTMENT_SCIENCE, DEPARTMENT_COMMAND, DEPARTMENT_ENGINEERING)

/datum/supply_packs/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	contains = list(/obj/item/transfer_valve,
					/obj/item/transfer_valve)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "tank transfer valves crate"
	access = ACCESS_RD

/datum/supply_packs/science/prototype
	name = "Machine Prototype Crate"
	contains = list(/obj/item/machineprototype)
	cost = 800
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "machine prototype crate"
	access = ACCESS_RESEARCH

/datum/supply_packs/science/raw_anomaly_core
	name = "Raw Anomaly Core Crate"
	contains = list(/obj/item/raw_anomaly_core)
	cost = 2000
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "raw anomaly core crate"
	access = ACCESS_RESEARCH

/datum/supply_packs/science/oil
	name = "Oil Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/oil,
					/obj/item/reagent_containers/drinks/oilcan)
	cost = 150
	containertype = /obj/structure/largecrate
	containername = "oil tank crate"
	department_restrictions = list(DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)

/datum/supply_packs/science/vending/clothingvendor
	name = "Science Clothing Vendors Crate"
	cost = 50
	contains = list(/obj/item/vending_refill/scidrobe,
					/obj/item/vending_refill/robodrobe,
					/obj/item/vending_refill/genedrobe,)
	containername = "science clothing vendor crate"
