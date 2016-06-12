//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

// Supply Groups
var/const/supply_emergency 	= 1
var/const/supply_security 	= 2
var/const/supply_engineer	= 3
var/const/supply_medical	= 4
var/const/supply_science	= 5
var/const/supply_organic	= 6
var/const/supply_materials 	= 7
var/const/supply_misc		= 8
var/const/supply_vend		= 9

var/list/all_supply_groups = list(supply_emergency,supply_security,supply_engineer,supply_medical,supply_science,supply_organic,supply_materials,supply_misc,supply_vend)

/proc/get_supply_group_name(var/cat)
	switch(cat)
		if(1)
			return "Emergency"
		if(2)
			return "Security"
		if(3)
			return "Engineering"
		if(4)
			return "Medical"
		if(5)
			return "Science"
		if(6)
			return "Food and Livestock"
		if(7)
			return "Raw Materials"
		if(8)
			return "Miscellaneous"
		if(9)
			return "Vending"


/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = /obj/structure/closet/crate
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = supply_misc
	var/list/announce_beacons = list() // Particular beacons that we'll notify the relevant department when we reach


/datum/supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = path
		manifest += "<li>[initial(AM.name)]</li>"
	manifest += "</ul>"

////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/emergency	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = supply_emergency


/datum/supply_packs/emergency/evac
	name = "Emergency Equipment Crate"
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	cost = 35
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"
	group = supply_emergency

/datum/supply_packs/emergency/internals
	name = "Internals Crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 10
	containername = "internals crate"

/datum/supply_packs/emergency/firefighting
	name = "Firefighting Crate"
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/device/flashlight,
					/obj/item/device/flashlight,
					/obj/item/weapon/tank/oxygen/red,
					/obj/item/weapon/tank/oxygen/red,
					/obj/item/weapon/extinguisher,
					/obj/item/weapon/extinguisher,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "firefighting crate"

/datum/supply_packs/emergency/atmostank
	name = "Firefighting Watertank Crate"
	contains = list(/obj/item/weapon/watertank/atmos)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "firefighting watertank crate"
	access = access_atmospherics

/datum/supply_packs/emergency/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = access_hydroponics
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/emergency/specialops
	name = "Special Ops Supplies"
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/pen/sleepy,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = 1

/datum/supply_packs/emergency/syndicate
	name = "ERROR_NULL_ENTRY"
	contains = list(/obj/item/weapon/storage/box/syndicate)
	cost = 140
	containertype = /obj/structure/closet/crate
	containername = "crate"
	hidden = 1

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/security
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/gear
	access = access_security
	group = supply_security
	announce_beacons = list("Security" = list("Head of Security's Desk", "Warden", "Security"))


/datum/supply_packs/security/supplies
	name = "Security Supplies Crate"
	contains = list(/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/storage/box/handcuffs)
	cost = 10
	containername = "security supply crate"

////// Armor: Basic

/datum/supply_packs/security/helmets
	name = "Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet)
	cost = 10
	containername = "helmet crate"

/datum/supply_packs/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/mask/gas/sechailer,
					/obj/item/clothing/mask/gas/sechailer)
	cost = 60 //justice comes at a price. An expensive, noisy price.
	containername = "justice enforcer crate"

/datum/supply_packs/security/armor
	name = "Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 10
	containername = "armor crate"

////// Weapons: Basic

/datum/supply_packs/security/baton
	name = "Stun Batons Crate"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded)
	cost = 10
	containername = "stun baton crate"

/datum/supply_packs/security/laser
	name = "Lasers Crate"
	contains = list(/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser)
	cost = 15
	containername = "laser crate"

/datum/supply_packs/security/taser
	name = "Stun Guns Crate"
	contains = list(/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser)
	cost = 15
	containername = "stun gun crate"

/datum/supply_packs/security/disabler
	name = "Disabler Crate"
	contains = list(/obj/item/weapon/gun/energy/disabler,
					/obj/item/weapon/gun/energy/disabler,
					/obj/item/weapon/gun/energy/disabler)
	cost = 10
	containername = "disabler crate"

///// Armory stuff

/datum/supply_packs/security/armory
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/weapon
	access = access_armory
	announce_beacons = list("Security" = list("Warden", "Head of Security's Desk"))

///// Armor: Specialist

/datum/supply_packs/security/armory/riothelmets
	name = "Riot Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	cost = 15
	containername = "riot helmets crate"

/datum/supply_packs/security/armory/riotarmor
	name = "Riot Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 15
	containername = "riot armor crate"

/datum/supply_packs/security/armory/riotshields
	name = "Riot Shields Crate"
	contains = list(/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot)
	cost = 20
	containername = "riot shields crate"

/datum/supply_packs/security/bullethelmets
	name = "Bulletproof Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt)
	cost = 10
	containername = "bulletproof helmet crate"

/datum/supply_packs/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof)
	cost = 15
	containername = "tactical armor crate"

/datum/supply_packs/security/armory/swat
	name = "SWAT gear crate"
	contains = list(/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/weapon/kitchen/knife/combat,
					/obj/item/weapon/kitchen/knife/combat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/weapon/storage/belt/military/assault,
					/obj/item/weapon/storage/belt/military/assault)
	cost = 60
	containername = "assault armor crate"

/datum/supply_packs/security/armory/laserarmor
	name = "Ablative Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)		// Only two vests to keep costs down for balance
	cost = 20
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ablative armor crate"

/////// Weapons: Specialist

/datum/supply_packs/security/armory/ballistic
	name = "Combat Shotguns Crate"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/automatic/combat,
					/obj/item/weapon/gun/projectile/shotgun/automatic/combat,
					/obj/item/weapon/gun/projectile/shotgun/automatic/combat,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier)
	cost = 20
	containername = "combat shotgun crate"

/datum/supply_packs/security/armory/expenergy
	name = "Energy Guns Crate"
	contains = list(/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)			// Only two guns to keep costs down
	cost = 25
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy gun crate"

/datum/supply_packs/security/armory/eweapons
	name = "Incendiary Weapons Crate"
	contains = list(/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 15	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "incendiary weapons crate"
	access = access_heads

/datum/supply_packs/security/armory/wt550
	name = "WT-550 Auto Rifle Crate"
	contains = list(/obj/item/weapon/gun/projectile/automatic/wt550,
					/obj/item/weapon/gun/projectile/automatic/wt550)
	cost = 35
	containername = "auto rifle crate"

/datum/supply_packs/security/armory/wt550ammo
	name = "WT-550 Rifle Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,)
	cost = 30
	containername = "auto rifle ammo crate"

/////// Implants & etc

/datum/supply_packs/security/armory/loyalty
	name = "Loyalty Implants Crate"
	contains = list (/obj/item/weapon/storage/lockbox/loyalty)
	cost = 40
	containername = "loyalty implant crate"

/datum/supply_packs/security/armory/trackingimp
	name = "Tracking Implants Crate"
	contains = list (/obj/item/weapon/storage/box/trackimp)
	cost = 20
	containername = "tracking implant crate"

/datum/supply_packs/security/armory/chemimp
	name = "Chemical Implants Crate"
	contains = list (/obj/item/weapon/storage/box/chemimp)
	cost = 20
	containername = "chemical implant crate"

/datum/supply_packs/security/armory/exileimp
	name = "Exile Implants Crate"
	contains = list (/obj/item/weapon/storage/box/exileimp)
	cost = 30
	containername = "exile implant crate"

/datum/supply_packs/security/securitybarriers
	name = "Security Barriers Crate"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier)
	cost = 20
	containername = "security barriers crate"

/datum/supply_packs/security/securityclothes
	name = "Security Clothing Crate"
	contains = list(/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/under/rank/warden/corp,
					/obj/item/clothing/head/beret/sec/warden,
					/obj/item/clothing/under/rank/head_of_security/corp,
					/obj/item/clothing/head/HoS/beret)
	cost = 30
	containername = "security clothing crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/engineering
	name = "HEADER"
	group = supply_engineer
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk"))


/datum/supply_packs/engineering/fueltank
	name = "Fuel Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"

/datum/supply_packs/engineering/tools		//the most robust crate
	name = "Toolbox Crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/mechanical)
	cost = 10
	containername = "electrical maintenance crate"

/datum/supply_packs/engineering/powergamermitts
	name = "Insulated Gloves Crate"
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	cost = 20	//Made of pure-grade bullshittinium
	containername = "insulated gloves crate"

/datum/supply_packs/engineering/power
	name = "Power Cell Crate"
	contains = list(/obj/item/weapon/stock_parts/cell/high,		//Changed to an extra high powercell because normal cells are useless
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	cost = 10
	containername = "electrical maintenance crate"

/datum/supply_packs/engineering/engiequipment
	name = "Engineering Gear Crate"
	contains = list(/obj/item/weapon/storage/belt/utility,
					/obj/item/weapon/storage/belt/utility,
					/obj/item/weapon/storage/belt/utility,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat)
	cost = 10
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
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	cost = 20
	containername = "solar pack crate"

/datum/supply_packs/engineering/engine
	name = "Emitter Crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "emitter crate"
	access = access_ce

/datum/supply_packs/engineering/engine/field_gen
	name = "Field Generator Crate"
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	cost = 10
	containername = "field generator crate"

/datum/supply_packs/engineering/engine/sing_gen
	name = "Singularity Generator Crate"
	contains = list(/obj/machinery/the_singularitygen)
	cost = 10
	containername = "singularity generator crate"

/datum/supply_packs/engineering/engine/tesla
	name = "Energy Ball Generator Crate"
	contains = list(/obj/machinery/the_singularitygen/tesla)
	cost = 10
	containername = "energy ball generator crate"

/datum/supply_packs/engineering/engine/coil
	name = "Tesla Coil Crate"
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	cost = 10
	containername = "tesla coil crate"

/datum/supply_packs/engineering/engine/grounding
	name = "Grounding Rod Crate"
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	cost = 10
	containername = "grounding rod crate"

/datum/supply_packs/engineering/engine/collector
	name = "Collector Crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	cost = 10
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
	cost = 25
	containername = "particle accelerator crate"

/datum/supply_packs/engineering/engine/spacesuit
	name = "Space Suit Crate"
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,)
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "space suit crate"
	access = access_eva

/datum/supply_packs/engineering/inflatable
	name = "Inflatable barriers Crate"
	contains = list(/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable)
	cost = 20
	containername = "inflatable barrier crate"

/datum/supply_packs/engineering/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	contains = list(/obj/machinery/power/supermatter_shard)
	cost = 50 //So cargo thinks twice before killing themselves with it
	containertype = /obj/structure/closet/crate/secure
	containername = "supermatter shard crate"
	access = access_ce

/datum/supply_packs/engineering/engine/teg
	name = "Thermo-Electric Generator Crate"
	contains = list(
		/obj/machinery/power/generator,
		/obj/machinery/atmospherics/binary/circulator,
		/obj/machinery/atmospherics/binary/circulator
	)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "thermo-electric generator crate"
	access = access_ce
	announce_beacons = list("Engineering" = list("Chief Engineer's Desk", "Atmospherics"))

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/medical
	name = "HEADER"
	containertype = /obj/structure/closet/crate/medical
	group = supply_medical
	announce_beacons = list("Medbay" = list("Medbay", "Chief Medical Officer's Desk"), "Security" = list("Brig Medbay"))


/datum/supply_packs/medical/supplies
	name = "Medical Supplies Crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
					/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
					/obj/item/weapon/reagent_containers/glass/bottle/epinephrine,
					/obj/item/weapon/reagent_containers/glass/bottle/epinephrine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/storage/box/syringes,
				    /obj/item/weapon/storage/box/bodybags)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "medical supplies crate"

/datum/supply_packs/medical/firstaid
	name = "First Aid Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular)
	cost = 10
	containername = "first aid kits crate"

/datum/supply_packs/medical/firstaidadv
	name = "Advanced First Aid Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv)
	cost = 10
	containername = "advanced first aid kits crate"

/datum/supply_packs/medical/firstaibrute
	name = "Brute Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/brute)
	cost = 10
	containername = "brute first aid kits crate"

/datum/supply_packs/medical/firstaidburns
	name = "Burns Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire)
	cost = 10
	containername = "fire first aid kits crate"

/datum/supply_packs/medical/firstaidtoxins
	name = "Toxin Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin)
	cost = 10
	containername = "toxin first aid kits crate"

/datum/supply_packs/medical/firstaidoxygen
	name = "Oxygen Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2)
	cost = 10
	containername = "oxygen first aid kits crate"

/datum/supply_packs/medical/virus
	name = "Virus Crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/flu_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/cold,
					/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/weapon/reagent_containers/glass/bottle/magnitis,
					/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/weapon/reagent_containers/glass/bottle/brainrot,
					/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/anxiety,
					/obj/item/weapon/reagent_containers/glass/bottle/beesease,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/reagent_containers/glass/bottle/mutagen)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "virus crate"
	access = access_cmo
	announce_beacons = list("Medbay" = list("Virology", "Chief Medical Officer's Desk"))


/datum/supply_packs/medical/bloodpacks
	name = "Blood Pack Variety Crate"
	contains = list(/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/APlus,
					/obj/item/weapon/reagent_containers/blood/AMinus,
					/obj/item/weapon/reagent_containers/blood/BPlus,
					/obj/item/weapon/reagent_containers/blood/BMinus,
					/obj/item/weapon/reagent_containers/blood/OPlus,
					/obj/item/weapon/reagent_containers/blood/OMinus)
	cost = 35
	containertype = /obj/structure/closet/crate/freezer
	containername = "blood pack crate"

/datum/supply_packs/medical/iv_drip
	name = "IV Drip Crate"
	contains = list(/obj/machinery/iv_drip)
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "IV drip crate"
	access = access_cmo

/datum/supply_packs/medical/surgery
	name = "Surgery Crate"
	contains = list(/obj/item/weapon/cautery,
					/obj/item/weapon/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/tank/anesthetic,
					/obj/item/weapon/FixOVein,
					/obj/item/weapon/hemostat,
					/obj/item/weapon/scalpel,
					/obj/item/weapon/bonegel,
					/obj/item/weapon/retractor,
					/obj/item/weapon/bonesetter,
					/obj/item/weapon/circular_saw)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "surgery crate"
	access = access_medical


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/science
	name = "HEADER"
	group = supply_science
	announce_beacons = list("Research Division" = list("Science", "Research Director's Desk"))

/datum/supply_packs/science/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "robotics assembly crate"
	access = access_robotics
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))


/datum/supply_packs/science/robotics/mecha_ripley
	name = "Circuit Crate (Ripley APLU)"
	contains = list(/obj/item/weapon/book/manual/ripley_build_and_repair,
					/obj/item/weapon/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper APLU \"Ripley\" circuit crate"
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))

/datum/supply_packs/science/robotics/mecha_odysseus
	name = "Circuit Crate (Odysseus)"
	contains = list(/obj/item/weapon/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper \"Odysseus\" circuit crate"
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))

/datum/supply_packs/science/plasma
	name = "Plasma Assembly Crate"
	contains = list(/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = access_tox_storage
	group = supply_science

/datum/supply_packs/science/shieldwalls
	name = "Shield Generators Crate"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "shield generators crate"
	access = access_teleporter


/datum/supply_packs/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	contains = list(/obj/item/device/transfer_valve,
					/obj/item/device/transfer_valve)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "tank transfer valves crate"
	access = access_rd


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/organic
	name = "HEADER"
	group = supply_organic
	containertype = /obj/structure/closet/crate/freezer


/datum/supply_packs/organic/food
	name = "Food Crate"
	contains = list(/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/condiment/rice,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/reagent_containers/food/drinks/soymilk,
					/obj/item/weapon/reagent_containers/food/condiment/saltshaker,
					/obj/item/weapon/reagent_containers/food/condiment/peppermill,
					/obj/item/weapon/storage/fancy/egg_box,
					/obj/item/weapon/reagent_containers/food/condiment/enzyme,
					/obj/item/weapon/reagent_containers/food/condiment/sugar,
					/obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	cost = 10
	containername = "food crate"
	announce_beacons = list("Kitchen" = list("Kitchen"))

/datum/supply_packs/organic/pizza
	name = "Pizza Crate"
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable)
	cost = 60
	containername = "Pizza crate"

/datum/supply_packs/organic/monkey
	name = "Monkey Crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	cost = 20
	containername = "monkey crate"

/datum/supply_packs/organic/farwa
	name = "Farwa Crate"
	contains = list (/obj/item/weapon/storage/box/farwacubes)
	cost = 30
	containername = "farwa crate"


/datum/supply_packs/organic/wolpin
	name = "Wolpin Crate"
	contains = list (/obj/item/weapon/storage/box/wolpincubes)
	cost = 30
	containername = "wolpin crate"


/datum/supply_packs/organic/skrell
	name = "Neaera Crate"
	contains = list (/obj/item/weapon/storage/box/neaeracubes)
	cost = 30
	containername = "neaera crate"

/datum/supply_packs/organic/stok
	name = "Stok Crate"
	contains = list (/obj/item/weapon/storage/box/stokcubes)
	cost = 30
	containername = "stok crate"

/datum/supply_packs/organic/party
	name = "Party Equipment Crate"
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/shaker,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/reagent_containers/food/drinks/cans/ale,
					/obj/item/weapon/reagent_containers/food/drinks/cans/ale,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/grenade/confetti,
					/obj/item/weapon/grenade/confetti)
	cost = 20
	containername = "party equipment"
	announce_beacons = list("Bar" = list("Bar"))

//////// livestock
/datum/supply_packs/organic/cow
	name = "Cow Crate"
	cost = 30
	containertype = /obj/structure/closet/critter/cow
	containername = "cow crate"

/datum/supply_packs/organic/goat
	name = "Goat Crate"
	cost = 25
	containertype = /obj/structure/closet/critter/goat
	containername = "goat crate"

/datum/supply_packs/organic/chicken
	name = "Chicken Crate"
	cost = 20
	containertype = /obj/structure/closet/critter/chick
	containername = "chicken crate"

/datum/supply_packs/organic/turkey
	name = "Turkey Crate"
	cost = 20
	containertype = /obj/structure/closet/critter/turkey
	containername = "turkey crate"

/datum/supply_packs/organic/corgi
	name = "Corgi Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/corgi
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "corgi crate"

/datum/supply_packs/organic/cat
	name = "Cat Crate"
	cost = 50 //Cats are worth as much as corgis.
	containertype = /obj/structure/closet/critter/cat
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "cat crate"

/datum/supply_packs/organic/pug
	name = "Pug Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/pug
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "pug crate"

/datum/supply_packs/organic/fox
	name = "Fox Crate"
	cost = 55 //Foxes are cool.
	containertype = /obj/structure/closet/critter/fox
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "fox crate"

/datum/supply_packs/organic/butterfly
	name = "Butterflies Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/butterfly
	containername = "butterflies crate"
	contraband = 1

/datum/supply_packs/organic/deer
	name = "Deer Crate"
	cost = 56 //Deer are best.
	containertype = /obj/structure/closet/critter/deer
	containername = "deer crate"

////// hippy gear

/datum/supply_packs/organic/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/hatchet,
					/obj/item/weapon/minihoe,
					/obj/item/device/analyzer/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/misc/hydroponics/hydrotank
	name = "Hydroponics Watertank Crate"
	contains = list(/obj/item/weapon/watertank)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "hydroponics watertank crate"
	access = access_hydroponics
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/hydroponics/seeds
	name = "Seeds Crate"
	contains = list(/obj/item/seeds/chiliseed,
					/obj/item/seeds/berryseed,
					/obj/item/seeds/cornseed,
					/obj/item/seeds/eggplantseed,
					/obj/item/seeds/tomatoseed,
					/obj/item/seeds/soyaseed,
					/obj/item/seeds/wheatseed,
					/obj/item/seeds/carrotseed,
					/obj/item/seeds/sunflowerseed,
					/obj/item/seeds/chantermycelium,
					/obj/item/seeds/potatoseed,
					/obj/item/seeds/sugarcaneseed)
	cost = 10
	containername = "seeds crate"

/datum/supply_packs/organic/hydroponics/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/seeds/nettleseed,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/plumpmycelium,
					/obj/item/seeds/libertymycelium,
					/obj/item/seeds/amanitamycelium,
					/obj/item/seeds/reishimycelium,
					/obj/item/seeds/bananaseed,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					)
	cost = 15
	containername = "exotic seeds crate"

/datum/supply_packs/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	contains = list(/obj/structure/beebox,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 15
	containername = "beekeeping starter kit"

/datum/supply_packs/organic/hydroponics/beekeeping_suits
	name = "2 Beekeeper suits"
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 10
	containername = "beekeeper suits"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/materials
	name = "HEADER"
	group = supply_materials
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk", "Atmospherics"))


/datum/supply_packs/materials/metal50
	name = "50 Metal Sheets Crate"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containername = "metal sheets crate"

/datum/supply_packs/materials/plasteel20
	name = "20 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 20
	cost = 30
	containername = "plasteel sheets crate"

/datum/supply_packs/materials/plasteel50
	name = "50 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 50
	cost = 50
	containername = "plasteel sheets crate"

/datum/supply_packs/materials/glass50
	name = "50 Glass Sheets Crate"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 10
	containername = "glass sheets crate"

/datum/supply_packs/materials/cardboard50
	name = "50 Cardboard Sheets Crate"
	contains = list(/obj/item/stack/sheet/cardboard)
	amount = 50
	cost = 10
	containername = "cardboard sheets crate"

/datum/supply_packs/materials/sandstone30
	name = "30 Sandstone Blocks Crate"
	contains = list(/obj/item/stack/sheet/mineral/sandstone)
	amount = 30
	cost = 20
	containername = "sandstone blocks crate"


/datum/supply_packs/materials/plastic30
	name = "30 Plastic Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/plastic)
	amount = 30
	cost = 25
	containername = "plastic sheets crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/misc
	name = "HEADER"
	group = supply_misc

/datum/supply_packs/misc/mule
	name = "MULEbot Crate"
	contains = list(/mob/living/simple_animal/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot crate"

/datum/supply_packs/misc/watertank
	name = "Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "water tank crate"

/datum/supply_packs/misc/lasertag
	name = "Laser Tag Crate"
	contains = list(/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	cost = 15
	containername = "laser tag crate"

/datum/supply_packs/misc/religious_supplies
	name = "Religious Supplies Crate"
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/storage/bible/booze,
					/obj/item/weapon/storage/bible/booze,
					/obj/item/clothing/suit/chaplain_hoodie,
					/obj/item/clothing/head/chaplain_hood,
					/obj/item/clothing/suit/chaplain_hoodie,
					/obj/item/clothing/head/chaplain_hood)
	cost = 40
	containername = "religious supplies crate"


///////////// Paper Work

/datum/supply_packs/misc/paper
	name = "Bureaucracy Crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer,
					/obj/item/device/camera_film,
					/obj/item/weapon/hand_labeler,
					/obj/item/stack/tape_roll,
					/obj/item/weapon/paper_bin,
					/obj/item/weapon/pen,
					/obj/item/weapon/pen/blue,
					/obj/item/weapon/pen/red,
					/obj/item/weapon/stamp/denied,
					/obj/item/weapon/stamp/granted,
					/obj/item/weapon/folder/blue,
					/obj/item/weapon/folder/red,
					/obj/item/weapon/folder/yellow,
					/obj/item/weapon/clipboard,
					/obj/item/weapon/clipboard)
	cost = 15
	containername = "bureaucracy crate"

/datum/supply_packs/misc/toner
	name = "Toner Cartridges Crate"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 10
	containername = "toner cartridges crate"

/datum/supply_packs/misc/artscrafts
	name = "Arts and Crafts Supplies Crate"
	contains = list(/obj/item/weapon/storage/fancy/crayons,
	/obj/item/device/camera,
	/obj/item/device/camera_film,
	/obj/item/device/camera_film,
	/obj/item/weapon/storage/photo_album,
	/obj/item/stack/packageWrap,
	/obj/item/weapon/reagent_containers/glass/paint/red,
	/obj/item/weapon/reagent_containers/glass/paint/green,
	/obj/item/weapon/reagent_containers/glass/paint/blue,
	/obj/item/weapon/reagent_containers/glass/paint/yellow,
	/obj/item/weapon/reagent_containers/glass/paint/violet,
	/obj/item/weapon/reagent_containers/glass/paint/black,
	/obj/item/weapon/reagent_containers/glass/paint/white,
	/obj/item/weapon/reagent_containers/glass/paint/remover,
	/obj/item/weapon/contraband/poster/legit,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper)
	cost = 10
	containername = "arts and crafts crate"

/datum/supply_packs/misc/posters
	name = "Corporate Posters Crate"
	contains = list(/obj/item/weapon/contraband/poster/legit,
					/obj/item/weapon/contraband/poster/legit,
					/obj/item/weapon/contraband/poster/legit,
					/obj/item/weapon/contraband/poster/legit,
					/obj/item/weapon/contraband/poster/legit)
	cost = 8
	containername = "corporate posters crate"

///////////// Janitor Supplies

/datum/supply_packs/misc/janitor
	name = "Janitorial Supplies Crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/mop,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/reagent_containers/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner)
	cost = 10
	containername = "janitorial supplies crate"
	announce_beacons = list("Janitor" = list("Janitorial"))

/datum/supply_packs/misc/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "janitorial cart crate"

/datum/supply_packs/misc/janitor/janitank
	name = "Janitor Watertank Backpack"
	contains = list(/obj/item/weapon/watertank/janitor)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "janitor watertank crate"
	access = access_janitor

/datum/supply_packs/misc/janitor/lightbulbs
	name = "Replacement Lights Crate"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 10
	containername = "replacement lights crate"

/datum/supply_packs/misc/noslipfloor
	name = "High-traction Floor Tiles"
	contains = list(/obj/item/stack/tile/noslip/loaded)
	cost = 20
	containername = "high-traction floor tiles"

///////////// Costumes

/datum/supply_packs/misc/costume
	name = "Standard Costume Crate"
	contains = list(/obj/item/weapon/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/weapon/bikehorn,
					/obj/item/weapon/storage/backpack/mime,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "standard costumes"
	access = access_theatre

/datum/supply_packs/misc/wizard
	name = "Wizard Costume Crate"
	contains = list(/obj/item/weapon/twohanded/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containername = "wizard costume crate"

/datum/supply_packs/misc/mafia
	name = "Mafia Supply Crate"
	contains = list(/obj/item/clothing/suit/browntrenchcoat,
					/obj/item/clothing/suit/blacktrenchcoat,
					/obj/item/clothing/head/fedora/whitefedora,
					/obj/item/clothing/head/fedora/brownfedora,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/under/flappers,
					/obj/item/clothing/under/mafia,
					/obj/item/clothing/under/mafia/vest,
					/obj/item/clothing/under/mafia/white,
					/obj/item/clothing/under/mafia/sue,
					/obj/item/clothing/under/mafia/tan,
					/obj/item/weapon/gun/projectile/shotgun/toy/tommygun,
					/obj/item/weapon/gun/projectile/shotgun/toy/tommygun)
	cost = 15
	containername = "mafia supply crate"

/datum/supply_packs/misc/randomised
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	name = "Collectible Hats Crate"
	cost = 200
	containername = "collectable hats crate! Brought to you by Bass.inc!"

/datum/supply_packs/misc/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()


/datum/supply_packs/misc/foamforce
	name = "Foam Force Crate"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy)
	cost = 10
	containername = "foam force crate"

/datum/supply_packs/misc/foamforce/bonus
	name = "Foam Force Pistols Crate"
	contains = list(/obj/item/weapon/gun/projectile/automatic/toy/pistol,
					/obj/item/weapon/gun/projectile/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	cost = 40
	containername = "foam force pistols crate"
	contraband = 1

/datum/supply_packs/misc/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/weapon/storage/pill_bottle/random_drug_bottle,
					/obj/item/weapon/contraband/poster,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_shadyjims)
	name = "Contraband Crate"
	cost = 30
	containername = "crate"	//let's keep it subtle, eh?
	contraband = 1

/datum/supply_packs/misc/formalwear //This is a very classy crate.
	name = "Formal Wear Crate"
	contains = list(/obj/item/clothing/under/blacktango,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/lawyer/bluesuit,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/under/lawyer/black,
					/obj/item/clothing/suit/storage/lawyer/blackjacket,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/accessory/blue,
					/obj/item/clothing/accessory/red,
					/obj/item/clothing/accessory/black,
					/obj/item/clothing/head/bowlerhat,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit_jacket/charcoal,
					/obj/item/clothing/under/suit_jacket/navy,
					/obj/item/clothing/under/suit_jacket/burgundy,
					/obj/item/clothing/under/suit_jacket/checkered,
					/obj/item/clothing/under/suit_jacket/tan,
					/obj/item/weapon/lipstick/random)
	cost = 30 //Lots of very expensive items. You gotta pay up to look good!
	containername = "formal-wear crate"

/datum/supply_packs/misc/teamcolors		//For team sports like space polo
	name = "Team Jerseys Crate"
	// 4 red jerseys, 4 blue jerseys, and 1 beach ball
	contains = list(/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/weapon/beach_ball)
	cost = 15
	containername = "team jerseys crate"

/datum/supply_packs/misc/polo			//For space polo! Or horsehead Quiditch
	name = "Polo Supply Crate"
	// 6 brooms, 6 horse masks for the brooms, and 1 beach ball
	contains = list(/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/weapon/beach_ball)
	cost = 20
	containername = "polo supply crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Vending /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/vending
	name = "HEADER"
	group = supply_vend

/datum/supply_packs/vending/autodrobe
	name = "Autodrobe Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/autodrobe,
					/obj/item/weapon/vending_refill/autodrobe)
	cost = 15
	containername = "autodrobe supply crate"

/datum/supply_packs/vending/clothes
	name = "Clothing Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/suitdispenser,
					/obj/item/weapon/vending_refill/shoedispenser,
					/obj/item/weapon/vending_refill/hatdispenser,
					/obj/item/weapon/vending_refill/clothing)
	cost = 15
	containername = "clothing supply crate"

/datum/supply_packs/vending/pets
	name = "Pet Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/crittercare,
					/obj/item/weapon/vending_refill/crittercare,
					/obj/item/weapon/vending_refill/crittercare)
	cost = 15
	containername = "pet supply crate"

/datum/supply_packs/vending/bar
	name = "Bar Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat)
	cost = 15
	containername = "bar supply crate"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/vending/coffee
	name = "Coffee Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee)
	cost = 15
	containername = "coffee supply crate"

/datum/supply_packs/vending/snack
	name = "Snack Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack)
	cost = 15
	containername = "snacks supply crate"

/datum/supply_packs/vending/cola
	name = "Softdrinks Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola)
	cost = 15
	containername = "softdrinks supply crate"

/datum/supply_packs/vending/cigarette
	name = "Cigarette Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette)
	cost = 15
	containername = "cigarette supply crate"
