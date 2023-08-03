/datum/supply_packs/engineering
	name = "HEADER"
	group = SUPPLY_ENGINEER
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk"))
	containertype = /obj/structure/closet/crate/engineering
	department_restrictions = list(DEPARTMENT_ENGINEERING)

/datum/supply_packs/engineering/fueltank
	name = "Fuel Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 100
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"

/datum/supply_packs/engineering/tools		//the most robust crate
	name = "Toolbox Crate"
	contains = list(/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical)
	cost = 500
	containername = "electrical maintenance crate"

/datum/supply_packs/vending/engivend
	name = "Engineering Vendor Supply Crate"
	cost = 50
	contains = list(/obj/item/vending_refill/engivend,
					/obj/item/vending_refill/youtool)
	containername = "engineering supply crate"

/datum/supply_packs/engineering/vending/clothingvendor
	name = "Engineering Clothing Vendors Crate"
	cost = 50
	contains = list(/obj/item/vending_refill/engidrobe,
					/obj/item/vending_refill/atmosdrobe)
	containername = "engineering clothing vendor crate"

/datum/supply_packs/engineering/powergamermitts
	name = "Insulated Gloves Crate"
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	cost = 500	//Made of pure-grade bullshittinium
	containername = "insulated gloves crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/power
	name = "Power Cell Crate"
	contains = list(/obj/item/stock_parts/cell/high,		//Changed to an extra high powercell because normal cells are useless
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	cost = 300
	containername = "electrical maintenance crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/engiequipment
	name = "Engineering Gear Crate"
	contains = list(/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/glasses/meson/engine,
					/obj/item/clothing/glasses/meson/engine)
	cost = 100
	containername = "engineering gear crate"

/datum/supply_packs/engineering/solar
	name = "Solar Pack Crate"
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/circuitboard/solar_control,
					/obj/item/tracker_electronics,
					/obj/item/paper/solar)
	cost = 100
	containername = "solar pack crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/engine
	name = "Emitter Crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 100
	containername = "emitter crate"
	access = ACCESS_CE
	containertype = /obj/structure/closet/crate/secure/engineering

/datum/supply_packs/engineering/engine/field_gen
	name = "Field Generator Crate"
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	cost = 100
	containername = "field generator crate"

/datum/supply_packs/engineering/engine/sing_gen
	name = "Singularity Generator Crate"
	contains = list(/obj/machinery/the_singularitygen)
	cost = 350
	containername = "singularity generator crate"

/datum/supply_packs/engineering/engine/tesla
	name = "Energy Ball Generator Crate"
	contains = list(/obj/machinery/the_singularitygen/tesla)
	cost = 350
	containername = "energy ball generator crate"

/datum/supply_packs/engineering/engine/coil
	name = "Tesla Coil Crate"
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	cost = 100
	containername = "tesla coil crate"

/datum/supply_packs/engineering/engine/grounding
	name = "Grounding Rod Crate"
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	cost = 100
	containername = "grounding rod crate"

/datum/supply_packs/engineering/engine/collector
	name = "Collector Crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	cost = 100
	containername = "collector crate"

/datum/supply_packs/engineering/engine/PA
	name = "Particle Accelerator Crate"
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	cost = 250
	containername = "particle accelerator crate"

/datum/supply_packs/engineering/radiation
	name = "Radiation Protection Crate"
	cost = 150
	contains = list(/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/geiger_counter,
					/obj/item/geiger_counter)
	containername = "radiation protection crate"
	containertype = /obj/structure/closet/crate/radiation
	department_restrictions = list(DEPARTMENT_ENGINEERING, DEPARTMENT_MEDICAL)

/datum/supply_packs/engineering/engine/spacesuit
	name = "Space Suit Crate"
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 300
	containertype = /obj/structure/closet/crate/secure
	containername = "space suit crate"
	access = ACCESS_EVA

/datum/supply_packs/engineering/inflatable
	name = "Inflatable Barriers Crate"
	contains = list(/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable)
	cost = 100
	containername = "inflatable barrier crate"

/datum/supply_packs/engineering/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	contains = list(/obj/machinery/atmospherics/supermatter_crystal/shard)
	cost = 750 //So cargo thinks twice before killing themselves with it
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "supermatter shard crate"
	access = ACCESS_CE

/datum/supply_packs/engineering/engine/teg
	name = "Thermo-Electric Generator Crate"
	contains = list(
		/obj/machinery/power/teg,
		/obj/item/pipe/circulator,
		/obj/item/pipe/circulator)
	cost = 250
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "thermo-electric generator crate"
	access = ACCESS_CE
	announce_beacons = list("Engineering" = list("Chief Engineer's Desk", "Atmospherics"))

/datum/supply_packs/engineering/canister/nitrogen
	name = "Nitrogen canister"
	contains = list(/obj/machinery/atmospherics/portable/canister/nitrogen)
	cost = 50
	containertype = /obj/structure/largecrate
	containername = "nitrogen canister crate"

/datum/supply_packs/engineering/canister/oxygen
	name = "Oxygen canister"
	contains = list(/obj/machinery/atmospherics/portable/canister/oxygen)
	cost = 50
	containertype = /obj/structure/largecrate
	containername = "oxygen canister crate"

/datum/supply_packs/engineering/canister/air
	name = "Air canister"
	contains = list(/obj/machinery/atmospherics/portable/canister/air)
	cost = 50
	containertype = /obj/structure/largecrate
	containername = "Air canister crate"

/datum/supply_packs/engineering/canister/sleeping_agent
	name = "Nitrous oxide canister"
	contains = list(/obj/machinery/atmospherics/portable/canister/sleeping_agent)
	cost = 250
	containertype = /obj/structure/largecrate
	containername = "Nitrous oxide canister crate"

/datum/supply_packs/engineering/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	contains = list(/obj/machinery/atmospherics/portable/canister/carbon_dioxide)
	cost = 250
	containertype = /obj/structure/largecrate
	containername = "Carbon dioxide canister crate"

/datum/supply_packs/engineering/canister/toxins
	name = "Plasma canister"
	contains = list(/obj/machinery/atmospherics/portable/canister/toxins)
	cost = 250
	containertype = /obj/structure/largecrate
	containername = "Plasma canister crate"
