//SUPPLY PACKS but SYNDIEPACKS!
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: any crate added here should cost more that 50 credits to prevent reselling of the crates to get money
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.

// Supply Groups
#define SYNDIE_SUPPLY_EMERGENCY 1
#define SYNDIE_SUPPLY_SECURITY 2
#define SYNDIE_SUPPLY_ENGINEER 3
#define SYNDIE_SUPPLY_MEDICAL 4
#define SYNDIE_SUPPLY_SCIENCE 5
#define SYNDIE_SUPPLY_ORGANIC 6
#define SYNDIE_SUPPLY_MATERIALS 7
#define SYNDIE_SUPPLY_MISC 8
#define SYNDIE_SUPPLY_VEND 9
#define SUPPLY_SYNDICATE_SPECIAL 10

GLOBAL_LIST_INIT(all_syndie_supply_groups, list(SYNDIE_SUPPLY_EMERGENCY,SYNDIE_SUPPLY_SECURITY,SYNDIE_SUPPLY_ENGINEER,SYNDIE_SUPPLY_MEDICAL,SYNDIE_SUPPLY_SCIENCE,SYNDIE_SUPPLY_ORGANIC,SYNDIE_SUPPLY_MATERIALS,SYNDIE_SUPPLY_MISC,SYNDIE_SUPPLY_VEND,SUPPLY_SYNDICATE_SPECIAL))

/proc/get_syndie_supply_group_name(var/cat)
	switch(cat)
		if(SYNDIE_SUPPLY_EMERGENCY)
			return "Emergency"
		if(SYNDIE_SUPPLY_SECURITY)
			return "Security"
		if(SYNDIE_SUPPLY_ENGINEER)
			return "Engineering"
		if(SYNDIE_SUPPLY_MEDICAL)
			return "Medical"
		if(SYNDIE_SUPPLY_SCIENCE)
			return "Science"
		if(SUPPLY_ORGANIC)
			return "Food and Livestock"
		if(SYNDIE_SUPPLY_MATERIALS)
			return "Raw Materials"
		if(SYNDIE_SUPPLY_MISC)
			return "Miscellaneous"
		if(SYNDIE_SUPPLY_VEND)
			return "Vending"
		if(SUPPLY_SYNDICATE_SPECIAL)
			return "Syndicate Special"


/datum/syndie_supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = /obj/structure/closet/crate
	var/containername = null
	var/access = null
	var/group = SYNDIE_SUPPLY_MISC
	var/list/ui_manifest = list()


/datum/syndie_supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = path //Получение переменной возможно лишь благодаря initial()
		manifest += "<li>[initial(AM.name)]</li>"
		// Add the name to the UI manifest
		ui_manifest += "[initial(AM.name)]"
	manifest += "</ul>"




////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/datum/syndie_supply_packs/emergency	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = SYNDIE_SUPPLY_EMERGENCY


/datum/syndie_supply_packs/emergency/evac
	name = "Emergency Equipment Crate"
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot/syndicate,
					/mob/living/simple_animal/bot/medbot/syndicate,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/gas/oxygen,
					/obj/item/grenade/gas/oxygen)
	cost = 350
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"

/datum/syndie_supply_packs/emergency/internals
	name = "Internals Crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air)
	cost = 100
	containername = "internals crate"

/datum/syndie_supply_packs/emergency/firefighting
	name = "Firefighting Crate"
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/extinguisher,
					/obj/item/extinguisher,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "firefighting crate"

/datum/syndie_supply_packs/emergency/atmostank
	name = "Firefighting Watertank Crate"
	contains = list(/obj/item/watertank/atmos)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "firefighting watertank crate"
	access = ACCESS_ATMOSPHERICS

/datum/syndie_supply_packs/emergency/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	cost = 150
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = ACCESS_HYDROPONICS

/datum/syndie_supply_packs/emergency/voxsupport
	name = "Vox Life Support Supplies"
	contains = list(/obj/item/clothing/mask/breath/vox,
					/obj/item/clothing/mask/breath/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox)
	cost = 500
	containertype = /obj/structure/closet/crate/medical
	containername = "vox life support supplies crate"

/datum/syndie_supply_packs/emergency/plasmamansupport
	name = "Plasmaman Supply Kit"
	contains = list(/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasmaman life support supplies crate"
	access = ACCESS_EVA

/datum/syndie_supply_packs/emergency/plasmamanextinguisher
	name = "Plasmaman Extinguisher Cartridges"
	contains = list(/obj/item/extinguisher_refill,
					/obj/item/extinguisher_refill,
					/obj/item/extinguisher_refill,
					/obj/item/extinguisher_refill)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasmaman extinguisher cartridges crate"
	access = ACCESS_CARGO

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



/datum/syndie_supply_packs/security
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/syndicate
	access = ACCESS_SYNDICATE_COMMS_OFFICER
	group = SYNDIE_SUPPLY_SECURITY

/datum/syndie_supply_packs/security/supplies
	name = "Security Supplies Crate"
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs)
	cost = 450
	containername = "security supply crate"

/datum/syndie_supply_packs/security/stechkin
	name = "FK-69 Pistol 'Stechkin' Crate"
	contains = list(/obj/item/gun/projectile/automatic/pistol,
					/obj/item/gun/projectile/automatic/pistol,
					/obj/item/gun/projectile/automatic/pistol,
					/obj/item/suppressor,
					/obj/item/suppressor,
					/obj/item/suppressor)
	cost = 2500
	containername = "FK-69 Pistol 'Stechkin' crate"

/datum/syndie_supply_packs/security/stechkin_ammo
	name = "Stechkin - 10mm Magazine"
	contains = list(/obj/item/ammo_box/magazine/m10mm,
					/obj/item/ammo_box/magazine/m10mm,
					/obj/item/ammo_box/magazine/m10mm,
					/obj/item/ammo_box/magazine/m10mm,
					/obj/item/ammo_box/magazine/m10mm,
					/obj/item/ammo_box/magazine/m10mm)
	cost = 500
	containername = "Stechkin - 10mm Magazine crate"

/datum/syndie_supply_packs/security/stechkin_ammo_ap
	name = "Stechkin - 10mm Armour Piercing Magazine"
	contains = list(/obj/item/ammo_box/magazine/m10mm/ap,
					/obj/item/ammo_box/magazine/m10mm/ap,
					/obj/item/ammo_box/magazine/m10mm/ap,
					/obj/item/ammo_box/magazine/m10mm/ap,
					/obj/item/ammo_box/magazine/m10mm/ap,
					/obj/item/ammo_box/magazine/m10mm/ap)
	cost = 500
	containername = "Stechkin - 10mm Armour Piercing Magazine crate"

/datum/syndie_supply_packs/security/stechkin_ammo_fire
	name = "Stechkin - 10mm Incendiary Magazine"
	contains = list(/obj/item/ammo_box/magazine/m10mm/fire,
					/obj/item/ammo_box/magazine/m10mm/fire,
					/obj/item/ammo_box/magazine/m10mm/fire,
					/obj/item/ammo_box/magazine/m10mm/fire,
					/obj/item/ammo_box/magazine/m10mm/fire,
					/obj/item/ammo_box/magazine/m10mm/fire)
	cost = 500
	containername = "Stechkin - 10mm Incendiary Magazine crate"

/datum/syndie_supply_packs/security/stechkin_ammo_hp
	name = "Stechkin - 10mm Hollow Point Magazine"
	contains = list(/obj/item/ammo_box/magazine/m10mm/hp,
					/obj/item/ammo_box/magazine/m10mm/hp,
					/obj/item/ammo_box/magazine/m10mm/hp,
					/obj/item/ammo_box/magazine/m10mm/hp,
					/obj/item/ammo_box/magazine/m10mm/hp,
					/obj/item/ammo_box/magazine/m10mm/hp)
	cost = 500
	containername = "Stechkin - 10mm Hollow Point Magazine crate"

////// Armor: Basic

/datum/syndie_supply_packs/security/armor
	name = "Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 500
	containername = "Armor crate"
	containertype = /obj/structure/closet/crate/secure/gear

/datum/syndie_supply_packs/security/helmets
	name = "Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet)
	cost = 500
	containername = "Helmet crate"
	containertype = /obj/structure/closet/crate/secure/gear

/datum/syndie_supply_packs/security/combat_webbing
	name = "Combat Webbing Crate"
	contains = list(/obj/item/clothing/accessory/storage/webbing,
					/obj/item/clothing/accessory/storage/webbing,
					/obj/item/clothing/accessory/storage/webbing)
	cost = 6000
	containername = "Combat Webbing Crate"
	containertype = /obj/structure/closet/crate/secure/gear

/datum/syndie_supply_packs/security/vest
	name = "Combat Vest Crate"
	contains = list(/obj/item/clothing/accessory/storage/black_vest,
					/obj/item/clothing/accessory/storage/black_vest,
					/obj/item/clothing/accessory/storage/brown_vest,
					/obj/item/clothing/accessory/storage/brown_vest)
	cost = 6000
	containername = "Combat Vest Crate"
	containertype = /obj/structure/closet/crate/secure/gear

/datum/syndie_supply_packs/security/bola
	name = "Tactical Bola's Crate"
	contains = list(/obj/item/restraints/legcuffs/bola/tactical,
					/obj/item/restraints/legcuffs/bola/tactical,
					/obj/item/restraints/legcuffs/bola/tactical,
					/obj/item/restraints/legcuffs/bola/tactical,
					/obj/item/restraints/legcuffs/bola/tactical,
					/obj/item/restraints/legcuffs/bola/tactical,)
	cost = 800
	containername = "Tactical Bola's crate"

/datum/syndie_supply_packs/security/forensics
	name = "Forensics Crate"
	contains = list(/obj/item/storage/box/evidence,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/det_hat,
					/obj/item/storage/box/swabs,
					/obj/item/storage/box/fingerprints,
					/obj/item/storage/briefcase/crimekit)
	cost = 300
	containername = "forensics crate"
	containertype = /obj/structure/closet/crate/secure/gear

///// Armory stuff

/datum/syndie_supply_packs/security/armory
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/syndicate
	access = ACCESS_SYNDICATE_COMMS_OFFICER

/datum/syndie_supply_packs/security/armory/red_hardsuit
	name = "Syndicate Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/syndi,
					/obj/item/tank/internals/emergency_oxygen/engi/syndi,
					/obj/item/clothing/mask/gas/syndicate)
	cost = 6000
	containername = "Syndicate Hardsuit crate"

/datum/syndie_supply_packs/security/armory/elite_hardsuit
	name = "Syndicate Elite Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/syndi/elite,
					/obj/item/tank/internals/emergency_oxygen/engi/syndi,
					/obj/item/clothing/mask/gas/syndicate)
	cost = 8000
	containername = "Syndicate Elite Hardsuit crate"

/datum/syndie_supply_packs/security/armory/shielded_hardsuit
	name = "Syndicate Shielded Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/syndi/shielded,
					/obj/item/tank/internals/emergency_oxygen/engi/syndi,
					/obj/item/clothing/mask/gas/syndicate)
	cost = 40000
	containername = "Syndicate Shielded Hardsuit crate"

/datum/syndie_supply_packs/security/armory/shield_and_sword
	name = "Syndicate Energy Combo Crate"
	contains = list(/obj/item/shield/energy/syndie,
					/obj/item/melee/energy/sword/saber,
					/obj/item/pen/edagger)
	cost = 20000
	containername = "Syndicate Energy Combo crate"

/datum/syndie_supply_packs/security/armory/deagle
	name = "Syndicate Desert Eagle Crate"
	contains = list(/obj/item/gun/projectile/automatic/pistol/deagle)
	cost = 15000
	containername = "Syndicate Desert Eagle crate"
/datum/syndie_supply_packs/security/armory/m50
	name = "Syndicate Handgun Magazine .50ae Crate"
	contains = list(/obj/item/ammo_box/magazine/m50,
					/obj/item/ammo_box/magazine/m50,
					/obj/item/ammo_box/magazine/m50)
	cost = 5000
	containername = "Syndicate Handgun Magazine .50ae crate"

/datum/syndie_supply_packs/security/armory/revolver
	name = "Syndicate .357 Revolver Crate"
	contains = list(/obj/item/gun/projectile/revolver,
					/obj/item/gun/projectile/revolver,
					/obj/item/gun/projectile/revolver)
	cost = 5000
	containername = "Syndicate .357 Revolver crate"

/datum/syndie_supply_packs/security/armory/a357
	name = "Syndicate .357 Revolver - Speedloader's"
	contains = list(/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357)
	cost = 1750
	containername = ".357 Revolver - Speedloader's crate"

/datum/syndie_supply_packs/security/armory/energy_crossbow
	name = "Syndicate Miniature Energy Crossbow"
	contains = list(/obj/item/gun/energy/kinetic_accelerator/crossbow)
	cost = 10000
	containername = "Syndicate Energy Crossbow crate"

/datum/syndie_supply_packs/security/armory/bulldog
	name = "Syndicate Bulldog Shotguns Crate"
	contains = list(/obj/item/gun/projectile/automatic/shotgun/bulldog,
					/obj/item/gun/projectile/automatic/shotgun/bulldog,
					/obj/item/gun/projectile/automatic/shotgun/bulldog)
	cost = 4000
	containername = "Bulldog shotguns crate"

/datum/syndie_supply_packs/security/armory/m12g_slugs
	name = "Syndicate Bulldog - 12g Slug Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/m12g,
					/obj/item/ammo_box/magazine/m12g,
					/obj/item/ammo_box/magazine/m12g,
					/obj/item/ammo_box/magazine/m12g,
					/obj/item/ammo_box/magazine/m12g,
					/obj/item/ammo_box/magazine/m12g)
	cost = 1000
	containername = "Bulldog - 12g Slug Magazine crate"

/datum/syndie_supply_packs/security/armory/m12g_stun_slugs
	name = "Syndicate Bulldog - 12g Stun Slug Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/m12g/stun,
					/obj/item/ammo_box/magazine/m12g/stun,
					/obj/item/ammo_box/magazine/m12g/stun,
					/obj/item/ammo_box/magazine/m12g/stun,
					/obj/item/ammo_box/magazine/m12g/stun,
					/obj/item/ammo_box/magazine/m12g/stun)
	cost = 1000
	containername = "Bulldog - 12g Stun Slug Magazine crate"

/datum/syndie_supply_packs/security/armory/m12g_buckshot_slugs
	name = "Syndicate Bulldog - 12g Buckshot Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/m12g/buckshot,
					/obj/item/ammo_box/magazine/m12g/buckshot,
					/obj/item/ammo_box/magazine/m12g/buckshot,
					/obj/item/ammo_box/magazine/m12g/buckshot,
					/obj/item/ammo_box/magazine/m12g/buckshot,
					/obj/item/ammo_box/magazine/m12g/buckshot)
	cost = 1000
	containername = "Bulldog - 12g Buckshot Magazine crate"

/datum/syndie_supply_packs/security/armory/m12g_dragon_slugs
	name = "Syndicate Bulldog - 12g Dragon's Breath Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/m12g/dragon,
					/obj/item/ammo_box/magazine/m12g/dragon,
					/obj/item/ammo_box/magazine/m12g/dragon,
					/obj/item/ammo_box/magazine/m12g/dragon,
					/obj/item/ammo_box/magazine/m12g/dragon,
					/obj/item/ammo_box/magazine/m12g/dragon)
	cost = 1000
	containername = "Bulldog - 12g Dragon's Breath Magazine crate"

/datum/syndie_supply_packs/security/armory/sniper_rifle
	name = "Syndicate Sniper Rifle Crate"
	contains = list(/obj/item/gun/projectile/automatic/sniper_rifle/syndicate)
	cost = 18000
	containername = "Sniper Rifle crate"

/datum/syndie_supply_packs/security/armory/sniper_rounds
	name = "Syndicate Sniper - .50 Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/sniper_rounds,
					/obj/item/ammo_box/magazine/sniper_rounds,
					/obj/item/ammo_box/magazine/sniper_rounds)
	cost = 4000
	containername = "Sniper - .50 Magazine crate"

/datum/syndie_supply_packs/security/armory/sniper_rounds_soporific
	name = "Syndicate Sniper - .50 Soporific Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/sniper_rounds/soporific,
					/obj/item/ammo_box/magazine/sniper_rounds/soporific,
					/obj/item/ammo_box/magazine/sniper_rounds/soporific)
	cost = 3000
	containername = "Sniper - .50 Soporific Magazine crate"

/datum/syndie_supply_packs/security/armory/sniper_rounds_haemorrhage
	name = "Syndicate Sniper - .50 Haemorrhage Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage,
					/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage,
					/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage)
	cost = 4000
	containername = "Sniper - .50 Haemorrhage Magazine crate"

/datum/syndie_supply_packs/security/armory/sniper_rounds_penetrator
	name = "Syndicate Sniper - .50 Penetrator Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/sniper_rounds/penetrator,
					/obj/item/ammo_box/magazine/sniper_rounds/penetrator,
					/obj/item/ammo_box/magazine/sniper_rounds/penetrator)
	cost = 5000
	containername = "Sniper - .50 Penetrator Magazine crate"

/datum/syndie_supply_packs/security/armory/carbine
	name = "Syndicate M-90gl Carbine Crate"
	contains = list(/obj/item/gun/projectile/automatic/m90)
	cost = 16000
	containername = "M-90gl Carbine crate"

/datum/syndie_supply_packs/security/armory/carbine_ammo
	name = "Syndicate Carbine - 5.56 Toploader Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/m556,
					/obj/item/ammo_box/magazine/m556,
					/obj/item/ammo_box/magazine/m556,)
	cost = 6000
	containername = "Carbine - 5.56 Toploader Magazine crate"

/datum/syndie_supply_packs/security/armory/carbine_a40mm
	name = "Syndicate Carbine - 40mm Grenade Ammo Box Crate"
	contains = list(/obj/item/ammo_box/a40mm,
					/obj/item/ammo_box/a40mm,
					/obj/item/ammo_box/a40mm,)
	cost = 12000
	containername = "Carbine - 40mm Grenade Ammo Box crate"

/datum/syndie_supply_packs/security/armory/l6_saw
	name = "Syndicate L6 Squad Automatic Weapon Crate"
	contains = list(/obj/item/gun/projectile/automatic/l6_saw)
	cost = 50000
	containername = "L6 Squad Automatic Weapon crate"

/datum/syndie_supply_packs/security/armory/l6_saw_ammo
	name = "Syndicate L6 SAW - 5.56x45mm Box Magazine Crate"
	contains = list(/obj/item/ammo_box/magazine/mm556x45,
					/obj/item/ammo_box/magazine/mm556x45,
					/obj/item/ammo_box/magazine/mm556x45)
	cost = 36000
	containername = "L6 SAW - 5.56x45mm Box Magazine crate"

/datum/syndie_supply_packs/security/armory/eweapons
	name = "Incendiary Weapons Crate"
	contains = list(/obj/item/flamethrower/full,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 150	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "incendiary weapons crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/engineering
	name = "HEADER"
	group = SYNDIE_SUPPLY_ENGINEER
	containertype = /obj/structure/closet/crate/engineering


/datum/syndie_supply_packs/engineering/fueltank
	name = "Fuel Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 80
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"

/datum/syndie_supply_packs/engineering/tools		//the most robust crate
	name = "Syndicate Toolbox Crate"
	contains = list(/obj/item/storage/toolbox/syndicate,
					/obj/item/storage/toolbox/syndicate,
					/obj/item/storage/toolbox/syndicate)
	cost = 100
	containername = "Syndicate Toolbox crate"

/datum/syndie_supply_packs/vending/engivend
	name = "EngiVend Supply Crate"
	cost = 150
	contains = list(/obj/item/vending_refill/engivend)
	containername = "engineering supply crate"

/datum/syndie_supply_packs/engineering/power
	name = "Power Cell Crate"
	contains = list(/obj/item/stock_parts/cell/high,		//Changed to an extra high powercell because normal cells are useless
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	cost = 100
	containername = "electrical maintenance crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/syndie_supply_packs/engineering/engiequipment
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
					/obj/item/clothing/head/hardhat)
	cost = 100
	containername = "engineering gear crate"

/datum/syndie_supply_packs/engineering/solar
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
	cost = 200
	containername = "solar pack crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/syndie_supply_packs/engineering/engine
	name = "Emitter Crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 100
	containername = "emitter crate"
	access = ACCESS_CE
	containertype = /obj/structure/closet/crate/secure/engineering

// у трёх ящиков ниже такая цена и требования по доступу нужны чтобы станция не посылала теслы в свободное плавание каждую вторую игру

/datum/syndie_supply_packs/engineering/engine/field_gen
	name = "Field Generator Crate"
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	cost = 15000
	containername = "field generator crate"
	containertype = /obj/structure/closet/crate/secure/syndicate
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/engineering/engine/sing_gen
	name = "Singularity Generator Crate"
	contains = list(/obj/machinery/the_singularitygen)
	cost = 15000
	containername = "singularity generator crate"
	containertype = /obj/structure/closet/crate/secure/syndicate
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/engineering/engine/tesla
	name = "Energy Ball Generator Crate"
	contains = list(/obj/machinery/the_singularitygen/tesla)
	cost = 15000
	containername = "energy ball generator crate"
	containertype = /obj/structure/closet/crate/secure/syndicate
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/engineering/engine/coil
	name = "Tesla Coil Crate"
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	cost = 100
	containername = "tesla coil crate"

/datum/syndie_supply_packs/engineering/engine/grounding
	name = "Grounding Rod Crate"
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	cost = 100
	containername = "grounding rod crate"

/datum/syndie_supply_packs/engineering/engine/collector
	name = "Collector Crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	cost = 100
	containername = "collector crate"

/datum/syndie_supply_packs/engineering/engine/PA
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

/datum/syndie_supply_packs/engineering/engine/spacesuit
	name = "Syndicate Space Suit Crate"
	contains = list(/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/mask/gas/syndicate)
	cost = 2500
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "syndicate space suit crate"

/datum/syndie_supply_packs/engineering/inflatable
	name = "Inflatable barriers Crate"
	contains = list(/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable)
	cost = 200
	containername = "inflatable barrier crate"

/datum/syndie_supply_packs/engineering/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	contains = list(/obj/machinery/power/supermatter_shard)
	cost = 50000 //So cargo thinks twice before killing themselves with it //the same reason but for syndies
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "supermatter shard crate"
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/engineering/engine/teg
	name = "Thermo-Electric Generator Crate"
	contains = list(
		/obj/machinery/power/generator,
		/obj/item/pipe/circulator,
		/obj/item/pipe/circulator)
	cost = 2500
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "thermo-electric generator crate"
	access = ACCESS_CE

/datum/syndie_supply_packs/engineering/conveyor
	name = "Conveyor Assembly Crate"
	contains = list(/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_switch_construct,
					/obj/item/paper/conveyor)
	cost = 150
	containername = "conveyor assembly crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/medical
	name = "HEADER"
	containertype = /obj/structure/closet/crate/medical
	group = SYNDIE_SUPPLY_MEDICAL


/datum/syndie_supply_packs/medical/supplies
	name = "Medical Supplies Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/reagent_containers/iv_bag/salglu,
					/obj/item/storage/box/beakers,
					/obj/item/storage/box/syringes,
				    /obj/item/storage/box/bodybags,
				    /obj/item/storage/box/iv_bags,
				    /obj/item/vending_refill/medical)
	cost = 200
	containertype = /obj/structure/closet/crate/medical
	containername = "medical supplies crate"

/datum/syndie_supply_packs/medical/firstaid
	name = "First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular)
	cost = 100
	containername = "first aid kits crate"

/datum/syndie_supply_packs/medical/firstaidadv
	name = "Advanced First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv)
	cost = 100
	containername = "advanced first aid kits crate"

/datum/syndie_supply_packs/medical/firstaidmachine
	name = "Machine First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine)
	cost = 100
	containername = "machine first aid kits crate"

/datum/syndie_supply_packs/medical/firstaibrute
	name = "Brute Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute)
	cost = 100
	containername = "brute first aid kits crate"

/datum/syndie_supply_packs/medical/firstaidburns
	name = "Burns Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire)
	cost = 100
	containername = "fire first aid kits crate"

/datum/syndie_supply_packs/medical/firstaidtoxins
	name = "Toxin Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin)
	cost = 100
	containername = "toxin first aid kits crate"

/datum/syndie_supply_packs/medical/firstaidoxygen
	name = "Oxygen Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2)
	cost = 100
	containername = "oxygen first aid kits crate"

/datum/syndie_supply_packs/medical/virus
	name = "Virus Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/flu_virion,
					/obj/item/reagent_containers/glass/bottle/cold,
					/obj/item/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/reagent_containers/glass/bottle/magnitis,
					/obj/item/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/reagent_containers/glass/bottle/brainrot,
					/obj/item/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/reagent_containers/glass/bottle/anxiety,
					/obj/item/reagent_containers/glass/bottle/beesease,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/beakers,
					/obj/item/reagent_containers/glass/bottle/mutagen)
	cost = 250
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "virus crate"
	access = ACCESS_CMO

/datum/syndie_supply_packs/medical/vending
	name = "Medical Vending Crate"
	cost = 200
	contains = list(/obj/item/vending_refill/medical,
					/obj/item/vending_refill/wallmed)
	containername = "medical vending crate"

/datum/syndie_supply_packs/medical/bloodpacks_syn_oxygenis
	name = "Synthetic Blood Pack Oxygenis"
	contains = list(/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis)
	cost = 3000
	containertype = /obj/structure/closet/crate/freezer
	containername = "synthetic blood pack oxygenis crate"

/datum/syndie_supply_packs/medical/bloodpacks_syn_nitrogenis
	name = "Synthetic Blood Pack Nitrogenis"
	contains = list(/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis)
	cost = 3000
	containertype = /obj/structure/closet/crate/freezer
	containername = "synthetic blood pack nitrogenis crate"

/datum/syndie_supply_packs/medical/iv_drip
	name = "IV Drip Crate"
	contains = list(/obj/machinery/iv_drip)
	cost = 300
	containertype = /obj/structure/closet/crate/secure
	containername = "IV drip crate"
	access = ACCESS_MEDICAL

/datum/syndie_supply_packs/medical/surgery
	name = "Surgery Crate"
	contains = list(/obj/item/cautery,
					/obj/item/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/internals/anesthetic,
					/obj/item/FixOVein,
					/obj/item/hemostat,
					/obj/item/scalpel,
					/obj/item/bonegel,
					/obj/item/retractor,
					/obj/item/bonesetter,
					/obj/item/circular_saw)
	cost = 250
	containertype = /obj/structure/closet/crate/secure
	containername = "surgery crate"
	access = ACCESS_MEDICAL


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/science
	name = "HEADER"
	group = SYNDIE_SUPPLY_SCIENCE
	containertype = /obj/structure/closet/crate/sci

/datum/syndie_supply_packs/science/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/box/flashes,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	cost = 100
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "robotics assembly crate"
	access = ACCESS_ROBOTICS

/datum/syndie_supply_packs/science/syndie_exosuit_fabricator_circuit
	name = "Syndicate Exosuit Fabricator Crate"
	contains = list(/obj/item/circuitboard/mechfab/syndicate)
	cost = 250000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "Syndicate Exosuit Fabricator Crate"
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/science/syndicate_teleporter
	name = "Syndicate Redspace Teleporter Circuit Crate"
	contains = list(/obj/item/circuitboard/syndicate_teleporter)
	cost = 100000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "Syndicate Redspace Teleporter Circuit Crate"
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/science/plasma
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
	cost = 100
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = ACCESS_TOX_STORAGE
	group = SYNDIE_SUPPLY_SCIENCE

/datum/syndie_supply_packs/science/shieldwalls
	name = "Shield Generators Crate"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "shield generators crate"
	access = ACCESS_TELEPORTER

/datum/syndie_supply_packs/science/syndiepad
	name = "Syndicate Quantumpad's Circuit Crate"
	contains = list(/obj/item/circuitboard/quantumpad/syndiepad,
					/obj/item/circuitboard/quantumpad/syndiepad,
					/obj/item/circuitboard/quantumpad/syndiepad)
	cost = 4500
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "Syndicate Quantumpad's Circuit crate"
	access = ACCESS_SYNDICATE_RESEARCH_DIRECTOR

/datum/syndie_supply_packs/science/syndiecargo
	name = "Syndicate Supply Console Circuit Crate"
	contains = list(/obj/item/circuitboard/syndicatesupplycomp,
					/obj/item/circuitboard/syndicatesupplycomp/public)
	cost = 2000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "Supply Console Circuit crate"
	access = ACCESS_SYNDICATE_CARGO

/datum/syndie_supply_packs/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	contains = list(/obj/item/transfer_valve,
					/obj/item/transfer_valve)
	cost = 600
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "tank transfer valves crate"
	access = ACCESS_RD

/datum/syndie_supply_packs/science/prototype
	name = "Machine Prototype Crate"
	contains = list(/obj/item/machineprototype)
	cost = 8000
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "machine prototype crate"
	access = ACCESS_RESEARCH

/datum/syndie_supply_packs/science/oil
    name = "Oil Tank Crate"
    contains = list(/obj/structure/reagent_dispensers/oil,
					/obj/item/reagent_containers/food/drinks/oilcan)
    cost = 100
    containertype = /obj/structure/largecrate
    containername = "oil tank crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/organic
	name = "HEADER"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer


/datum/syndie_supply_packs/organic/food
	name = "Food Crate"
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/kitchen/rollingpin,
					/obj/item/storage/fancy/egg_box,
					/obj/item/mixing_bowl,
					/obj/item/mixing_bowl,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/food/snacks/meat/monkey,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana)
	cost = 100
	containername = "food crate"

/datum/syndie_supply_packs/organic/pizza
	name = "Pizza Crate"
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/hawaiian)
	cost = 600
	containername = "Pizza crate"

/datum/syndie_supply_packs/organic/monkey
	name = "Monkey Crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 200
	containername = "monkey crate"

/datum/syndie_supply_packs/organic/farwa
	name = "Farwa Crate"
	contains = list (/obj/item/storage/box/monkeycubes/farwacubes)
	cost = 200
	containername = "farwa crate"

/datum/syndie_supply_packs/organic/wolpin
	name = "Wolpin Crate"
	contains = list (/obj/item/storage/box/monkeycubes/wolpincubes)
	cost = 200
	containername = "wolpin crate"

/datum/syndie_supply_packs/organic/skrell
	name = "Neaera Crate"
	contains = list (/obj/item/storage/box/monkeycubes/neaeracubes)
	cost = 200
	containername = "neaera crate"

/datum/syndie_supply_packs/organic/stok
	name = "Stok Crate"
	contains = list (/obj/item/storage/box/monkeycubes/stokcubes)
	cost = 200
	containername = "stok crate"

/datum/syndie_supply_packs/organic/party
	name = "Party Equipment Crate"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/reagent_containers/food/drinks/bottle/patron,
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/reagent_containers/food/drinks/cans/ale,
					/obj/item/reagent_containers/food/drinks/cans/ale,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/grenade/confetti,
					/obj/item/grenade/confetti)
	cost = 200
	containername = "party equipment"

/datum/syndie_supply_packs/organic/bar
	name = "Bar Starter Kit"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/circuitboard/chem_dispenser/soda,
					/obj/item/circuitboard/chem_dispenser/beer)
	cost = 200
	containername = "beer starter kit"

//////// livestock
/datum/syndie_supply_packs/organic/cow
	name = "Cow Crate"
	cost = 300
	containertype = /obj/structure/closet/critter/cow
	containername = "cow crate"

/datum/syndie_supply_packs/organic/pig
	name = "Pig Crate"
	cost = 250
	containertype = /obj/structure/closet/critter/pig
	containername = "pig crate"

/datum/syndie_supply_packs/organic/goat
	name = "Goat Crate"
	cost = 250
	containertype = /obj/structure/closet/critter/goat
	containername = "goat crate"

/datum/syndie_supply_packs/organic/chicken
	name = "Chicken Crate"
	cost = 200
	containertype = /obj/structure/closet/critter/chick
	containername = "chicken crate"

/datum/syndie_supply_packs/organic/turkey
	name = "Turkey Crate"
	cost = 200
	containertype = /obj/structure/closet/critter/turkey
	containername = "turkey crate"

/datum/syndie_supply_packs/organic/corgi
	name = "Corgi Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/corgi
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "corgi crate"


/datum/syndie_supply_packs/organic/dog_pug
	name = "Dog Pug Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/dog_pug
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog pug crate"

/datum/syndie_supply_packs/organic/dog_bullterrier
	name = "Dog Bullterrie Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/dog_bullterrier
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog bullterrie crate"

/datum/syndie_supply_packs/organic/dog_tamaskan
	name = "Dog Tamaskan Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/dog_tamaskan
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog tamaskan crate"

/datum/syndie_supply_packs/organic/dog_german
	name = "Dog German Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/dog_german
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog german crate"

/datum/syndie_supply_packs/organic/dog_brittany
	name = "Dog Brittany Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/dog_brittany
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog brittany crate"

/datum/syndie_supply_packs/organic/cat
	name = "Cat Crate"
	cost = 500 //Cats are worth as much as corgis.
	containertype = /obj/structure/closet/critter/cat
	contains = list(/obj/item/clothing/accessory/petcollar,
					/obj/item/toy/cattoy)
	containername = "cat crate"

/datum/syndie_supply_packs/organic/cat/white
	name = "White Cat Crate"
	containername = "white crate"
	containertype = /obj/structure/closet/critter/cat_white

/datum/syndie_supply_packs/organic/cat/birman
	name = "Birman Cat Crate"
	containername = "birman crate"
	containertype = /obj/structure/closet/critter/cat_birman

/datum/syndie_supply_packs/organic/fox
	name = "Fox Crate"
	cost = 550 //Foxes are cool.
	containertype = /obj/structure/closet/critter/fox
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "fox crate"

/datum/syndie_supply_packs/organic/fennec
	name = "Fennec Crate"
	cost = 800
	containertype = /obj/structure/closet/critter/fennec
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "fennec crate"

/datum/syndie_supply_packs/organic/butterfly
	name = "Butterfly Crate"
	cost = 500
	containertype = /obj/structure/closet/critter/butterfly
	containername = "butterfly crate"

/datum/syndie_supply_packs/organic/deer
	name = "Deer Crate"
	cost = 560 //Deer are best.
	containertype = /obj/structure/closet/critter/deer
	containername = "deer crate"

/datum/syndie_supply_packs/organic/sloth
	name = "Sloth Crate"
	cost = 600
	containertype = /obj/structure/closet/critter/sloth
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "sloth crate"

/datum/syndie_supply_packs/organic/goose
	name = "Goose Crate"
	cost = 300
	containertype = /obj/structure/closet/critter/goose
	containername = "goose crate"

/datum/syndie_supply_packs/organic/gosling
	name = "Gosling Crate"
	cost = 300
	containertype = /obj/structure/closet/critter/gosling
	containername = "gosling crate"

/datum/syndie_supply_packs/organic/frog
	name = "Frog Crate"
	cost = 600
	containertype = /obj/structure/closet/critter/frog
	containername = "frog crate"

/datum/syndie_supply_packs/organic/frog/toxic
	name = "Toxic Frog Crate"
	cost = 1200
	containertype = /obj/structure/closet/critter/frog/toxic
	containername = "toxic frog crate"

/datum/syndie_supply_packs/organic/snail
	name = "Snail Crate"
	cost = 600
	containertype = /obj/structure/closet/critter/snail
	containername = "snail crate"

/datum/syndie_supply_packs/organic/turtle
	name = "Turtle Crate"
	cost = 700
	containertype = /obj/structure/closet/critter/turtle
	containername = "turtle crate"

/datum/syndie_supply_packs/organic/iguana
	name = "Iguana Crate"
	cost = 800
	containertype = /obj/structure/closet/critter/iguana
	containername = "iguana crate"

/datum/syndie_supply_packs/organic/gator
	name = "Gator Crate"
	cost = 1500	//most dangerous
	containertype = /obj/structure/closet/critter/gator
	containername = "gator crate"

/datum/syndie_supply_packs/organic/croco
	name = "Croco Crate"
	cost = 1000
	containertype = /obj/structure/closet/critter/croco
	containername = "croco crate"

////// hippy gear

/datum/syndie_supply_packs/organic/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/hatchet,
					/obj/item/cultivator,
					/obj/item/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with things
	cost = 150
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"

/datum/syndie_supply_packs/organic/hydroponics/hydrotank
	name = "Hydroponics Watertank Crate"
	contains = list(/obj/item/watertank)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "hydroponics watertank crate"
	access = ACCESS_HYDROPONICS

/datum/syndie_supply_packs/organic/hydroponics/seeds
	name = "Seeds Crate"
	contains = list(/obj/item/seeds/chili,
					/obj/item/seeds/cotton,
					/obj/item/seeds/berry,
					/obj/item/seeds/corn,
					/obj/item/seeds/eggplant,
					/obj/item/seeds/tomato,
					/obj/item/seeds/soya,
					/obj/item/seeds/wheat,
					/obj/item/seeds/wheat/rice,
					/obj/item/seeds/carrot,
					/obj/item/seeds/sunflower,
					/obj/item/seeds/chanter,
					/obj/item/seeds/potato,
					/obj/item/seeds/sugarcane)
	cost = 100
	containername = "seeds crate"

/datum/syndie_supply_packs/organic/vending/hydro_refills
	name = "Hydroponics Vending Machines Refills"
	cost = 200
	containertype = /obj/structure/closet/crate
	contains = list(/obj/item/vending_refill/hydroseeds,
					/obj/item/vending_refill/hydronutrients)
	containername = "hydroponics supply crate"

/datum/syndie_supply_packs/organic/hydroponics/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/seeds/nettle,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/plump,
					/obj/item/seeds/liberty,
					/obj/item/seeds/amanita,
					/obj/item/seeds/reishi,
					/obj/item/seeds/banana,
					/obj/item/seeds/bamboo,
					/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/random,
					/obj/item/seeds/random)
	cost = 150
	containername = "exotic seeds crate"

/datum/syndie_supply_packs/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	contains = list(/obj/structure/beebox/unwrenched,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/melee/flyswatter)
	cost = 150
	containername = "beekeeping starter kit"

/datum/syndie_supply_packs/organic/hydroponics/beekeeping_suits
	name = "2 Beekeeper suits"
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 100
	containername = "beekeeper suits"

//Bottler
/datum/syndie_supply_packs/organic/bottler
	name = "Brewing Buddy Bottler Unit"
	contains = list(/obj/machinery/bottler,
					/obj/item/wrench)
	cost = 350
	containername = "bottler crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/materials
	name = "HEADER"
	group = SYNDIE_SUPPLY_MATERIALS


/datum/syndie_supply_packs/materials/metal50
	name = "50 Metal Sheets Crate"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 1000
	containername = "metal sheets crate"

/datum/syndie_supply_packs/materials/plasteel20
	name = "20 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel/lowplasma)
	amount = 20
	cost = 3000
	containername = "plasteel sheets crate"

/datum/syndie_supply_packs/materials/plasteel50
	name = "50 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel/lowplasma)
	amount = 50
	cost = 6000
	containername = "plasteel sheets crate"

/datum/syndie_supply_packs/materials/plasma50
	name = "50 Plasma Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/plasma)
	amount = 50
	cost = 6000
	containername = "plasma sheets crate"

/datum/syndie_supply_packs/materials/uranium50
	name = "50 Uranium Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/uranium)
	amount = 50
	cost = 2500
	containername = "uranium sheets crate"

/datum/syndie_supply_packs/materials/titanium50
	name = "50 Titanium Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/titanium)
	amount = 50
	cost = 6000
	containername = "titanium sheets crate"

/datum/syndie_supply_packs/materials/plastitanium50
	name = "50 Plastitanium Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/plastitanium)
	amount = 50
	cost = 8000
	containername = "plastitanium sheets crate"

/datum/syndie_supply_packs/materials/plastitanium_glass50
	name = "50 Plastitanium Glass Sheets Crate"
	contains = list(/obj/item/stack/sheet/plastitaniumglass)
	amount = 50
	cost = 6000
	containername = "plastitanium glass sheets crate"

/datum/syndie_supply_packs/materials/gold50
	name = "50 Gold Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/gold)
	amount = 50
	cost = 5000
	containername = "gold sheets crate"

/datum/syndie_supply_packs/materials/silver50
	name = "50 Silver Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/silver)
	amount = 50
	cost = 4000
	containername = "silver sheets crate"

/datum/syndie_supply_packs/materials/diamond10
	name = "10 Diamonds Crate"
	contains = list(/obj/item/stack/sheet/mineral/diamond)
	amount = 10
	cost = 5000
	containername = "diamond sheets crate"

/datum/syndie_supply_packs/materials/bcrystal10
	name = "10 Bluespace Crystal's Crate"
	contains = list(/obj/item/stack/sheet/bluespace_crystal)
	amount = 10
	cost = 10000
	containername = "bluspace crystal's crate"

/datum/syndie_supply_packs/materials/glass50
	name = "50 Glass Sheets Crate"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 1000
	containername = "glass sheets crate"

/datum/syndie_supply_packs/materials/wood30
	name = "30 Wood Planks Crate"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 30
	cost = 1500
	containername = "wood planks crate"

/datum/syndie_supply_packs/materials/cardboard50
	name = "50 Cardboard Sheets Crate"
	contains = list(/obj/item/stack/sheet/cardboard)
	amount = 50
	cost = 1000
	containername = "cardboard sheets crate"

/datum/syndie_supply_packs/materials/sandstone30
	name = "30 Sandstone Blocks Crate"
	contains = list(/obj/item/stack/sheet/mineral/sandstone)
	amount = 30
	cost = 2000
	containername = "sandstone blocks crate"

/datum/syndie_supply_packs/materials/plastic30
	name = "30 Plastic Sheets Crate"
	contains = list(/obj/item/stack/sheet/plastic)
	amount = 30
	cost = 2000
	containername = "plastic sheets crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/misc
	name = "HEADER"
	group = SYNDIE_SUPPLY_MISC

/datum/syndie_supply_packs/misc/watertank
	name = "Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 80
	containertype = /obj/structure/largecrate
	containername = "water tank crate"

/datum/syndie_supply_packs/misc/hightank
	name = "High-Capacity Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	cost = 120
	containertype = /obj/structure/largecrate
	containername = "high-capacity water tank crate"

/datum/syndie_supply_packs/misc/lasertag
	name = "Laser Tag Crate"
	contains = list(/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	cost = 150
	containername = "laser tag crate"

/datum/syndie_supply_packs/misc/religious_supplies
	name = "Religious Supplies Crate"
	contains = list(/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/storage/bible/booze,
					/obj/item/storage/bible/booze,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/under/burial,
					/obj/item/clothing/under/burial)
	cost = 400
	containername = "religious supplies crate"

/datum/syndie_supply_packs/misc/minerkit
	name = "Shaft Miner Starter Kit"
	cost = 300
	access = ACCESS_QM
	contains = list(/obj/item/storage/backpack/duffel/mining_conscript)
	containertype = /obj/structure/closet/crate/secure
	containername = "shaft miner starter kit"


///////////// Paper Work

/datum/syndie_supply_packs/misc/paper
	name = "Bureaucracy Crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer,
					/obj/item/camera_film,
					/obj/item/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/stack/tape_roll,
					/obj/item/paper_bin,
					/obj/item/pen,
					/obj/item/pen/blue,
					/obj/item/pen/red,
					/obj/item/stamp/denied,
					/obj/item/stamp/granted,
					/obj/item/folder/blue,
					/obj/item/folder/red,
					/obj/item/folder/yellow,
					/obj/item/clipboard,
					/obj/item/clipboard)
	cost = 150
	containername = "bureaucracy crate"

/datum/syndie_supply_packs/misc/book_crate
	name = "Research Crate"
	contains = list(/obj/item/book/codex_gigas)
	cost = 150
	containername = "book crate"

/datum/syndie_supply_packs/misc/book_crate/New()
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	..()

/datum/syndie_supply_packs/misc/tape
	name = "Sticky Tape Crate"
	contains = list(/obj/item/stack/tape_roll,
	/obj/item/stack/tape_roll,
	/obj/item/stack/tape_roll)
	cost = 100
	containername = "sticky tape crate"
	containertype = /obj/structure/closet/crate/tape

/datum/syndie_supply_packs/misc/toner
	name = "Toner Cartridges Crate"
	contains = list(/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner)
	cost = 100
	containername = "toner cartridges crate"

/datum/syndie_supply_packs/misc/artscrafts
	name = "Arts and Crafts Supplies Crate"
	contains = list(/obj/item/storage/fancy/crayons,
	/obj/item/camera,
	/obj/item/camera_film,
	/obj/item/camera_film,
	/obj/item/storage/photo_album,
	/obj/item/stack/packageWrap,
	/obj/item/reagent_containers/glass/paint/red,
	/obj/item/reagent_containers/glass/paint/green,
	/obj/item/reagent_containers/glass/paint/blue,
	/obj/item/reagent_containers/glass/paint/yellow,
	/obj/item/reagent_containers/glass/paint/violet,
	/obj/item/reagent_containers/glass/paint/black,
	/obj/item/reagent_containers/glass/paint/white,
	/obj/item/reagent_containers/glass/paint/remover,
	/obj/item/poster/random_official,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper)
	cost = 100
	containername = "arts and crafts crate"

///////////// Janitor Supplies

/datum/syndie_supply_packs/misc/janitor
	name = "Janitorial Supplies Crate"
	contains = list(/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/mop,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner)
	cost = 360
	containername = "janitorial supplies crate"

/datum/syndie_supply_packs/misc/soap
	name = "Syndicate SOAP Crate"
	contains = list(/obj/item/soap/syndie,
					/obj/item/soap/syndie,
					/obj/item/soap/syndie)
	cost = 1000
	containername = "Syndicate SOAP crate"

/datum/syndie_supply_packs/misc/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	cost = 100
	containertype = /obj/structure/largecrate
	containername = "janitorial cart crate"

/datum/syndie_supply_packs/misc/janitor/janitank
	name = "Janitor Watertank Backpack"
	contains = list(/obj/item/watertank/janitor)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "janitor watertank crate"
	access = ACCESS_JANITOR

/datum/syndie_supply_packs/misc/janitor/lightbulbs
	name = "Replacement Lights Crate"
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	cost = 100
	containername = "replacement lights crate"

/datum/syndie_supply_packs/misc/noslipfloor
	name = "High-traction Floor Tiles"
	contains = list(/obj/item/stack/tile/noslip/loaded)
	cost = 200
	containername = "high-traction floor tiles"

///////////// Costumes

/datum/syndie_supply_packs/misc/costume
	name = "Standard Costume Crate"
	contains = list(/obj/item/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/bikehorn,
					/obj/item/storage/backpack/mime,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana
					)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "standard costumes"
	access = ACCESS_THEATRE

/datum/syndie_supply_packs/misc/wizard
	name = "Wizard Costume Crate"
	contains = list(/obj/item/twohanded/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 200
	containername = "wizard costume crate"

/datum/syndie_supply_packs/misc/mafia
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
					/obj/item/gun/projectile/shotgun/toy/tommygun,
					/obj/item/gun/projectile/shotgun/toy/tommygun)
	cost = 150
	containername = "mafia supply crate"

/datum/syndie_supply_packs/misc/sunglasses
	name = "Sunglasses Crate"
	contains = list(/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/glasses/sunglasses)
	cost = 300
	containername = "sunglasses crate"
/datum/syndie_supply_packs/misc/randomised
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
					/obj/item/clothing/head/crown/fancy,
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
	cost = 2000
	containername = "collectable hats crate! Brought to you by Bass.inc!"

/datum/syndie_supply_packs/misc/foamforce
	name = "Foam Force Crate"
	contains = list(/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy)
	cost = 100
	containername = "foam force crate"

/datum/syndie_supply_packs/misc/foamforce/bonus
	name = "Foam Force Pistols Crate"
	contains = list(/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	cost = 400
	containername = "foam force pistols crate"

/datum/syndie_supply_packs/misc/bigband
	name = "Big band instrument collection"
	contains = list(/obj/item/instrument/violin,
					/obj/item/instrument/guitar,
					/obj/item/instrument/eguitar,
					/obj/item/instrument/glockenspiel,
					/obj/item/instrument/accordion,
					/obj/item/instrument/saxophone,
					/obj/item/instrument/trombone,
					/obj/item/instrument/recorder,
					/obj/item/instrument/harmonica,
					/obj/item/instrument/xylophone,
					/obj/structure/piano)
	cost = 500
	containername = "Big band musical instruments collection"

/datum/syndie_supply_packs/misc/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/storage/pill_bottle/random_drug_bottle,
					/obj/item/poster/random_contraband,
					/obj/item/storage/fancy/cigarettes/dromedaryco,
					/obj/item/storage/fancy/cigarettes/cigpack_shadyjims)
	name = "Contraband Crate"
	cost = 300
	containername = "crate"	//let's keep it subtle, eh?

/datum/syndie_supply_packs/misc/formalwear //This is a very classy crate.
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
					/obj/item/lipstick/random)
	cost = 300 //Lots of very expensive items. You gotta pay up to look good!
	containername = "formal-wear crate"

/datum/syndie_supply_packs/misc/teamcolors		//For team sports like space polo
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
					/obj/item/beach_ball)
	cost = 150
	containername = "team jerseys crate"

/datum/syndie_supply_packs/misc/polo			//For space polo! Or horsehead Quiditch
	name = "Polo Supply Crate"
	// 6 brooms, 6 horse masks for the brooms, and 1 beach ball
	contains = list(/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/beach_ball)
	cost = 200
	containername = "polo supply crate"

/datum/syndie_supply_packs/misc/boxing			//For non log spamming cargo brawls!
	name = "Boxing Supply Crate"
	// 4 boxing gloves
	contains = list(/obj/item/clothing/gloves/boxing/blue,
					/obj/item/clothing/gloves/boxing/green,
					/obj/item/clothing/gloves/boxing/yellow,
					/obj/item/clothing/gloves/boxing)
	cost = 150
	containername = "boxing supply crate"

///////////// Bathroom Fixtures

/datum/syndie_supply_packs/misc/toilet
	name = "Lavatory Crate"
	cost = 100
	contains = list(
					/obj/item/bathroom_parts,
					/obj/item/bathroom_parts/urinal
					)
	containername = "lavatory crate"

/datum/syndie_supply_packs/misc/hygiene
	name = "Hygiene Station Crate"
	cost = 100
	contains = list(
					/obj/item/bathroom_parts/sink,
					/obj/item/mounted/shower
					)
	containername = "hygiene station crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Vending /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/vending
	name = "HEADER"
	group = SYNDIE_SUPPLY_VEND

/datum/syndie_supply_packs/vending/autodrobe
	name = "Autodrobe Supply Crate"
	contains = list(/obj/item/vending_refill/autodrobe)
	cost = 150
	containername = "autodrobe supply crate"

/datum/syndie_supply_packs/vending/clothes
	name = "ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing)
	cost = 150
	containername = "clothesmate supply crate"

/datum/syndie_supply_packs/vending/suit
	name = "Suitlord Supply Crate"
	contains = list(/obj/item/vending_refill/suitdispenser)
	cost = 150
	containername = "suitlord supply crate"

/datum/syndie_supply_packs/vending/hat
	name = "Hatlord Supply Crate"
	contains = list(/obj/item/vending_refill/hatdispenser)
	cost = 150
	containername = "hatlord supply crate"

/datum/syndie_supply_packs/vending/shoes
	name = "Shoelord Supply Crate"
	contains = list(/obj/item/vending_refill/shoedispenser)
	cost = 150
	containername = "shoelord supply crate"

/datum/syndie_supply_packs/vending/pets
	name = "Pet Supply Crate"
	contains = list(/obj/item/vending_refill/crittercare)
	cost = 150
	containername = "pet supply crate"

/datum/syndie_supply_packs/vending/bartending
	name = "Booze-o-mat and Coffee Supply Crate"
	cost = 200
	contains = list(/obj/item/vending_refill/boozeomat,
					/obj/item/vending_refill/coffee)
	containername = "bartending supply crate"

/datum/syndie_supply_packs/vending/cigarette
	name = "Cigarette Supply Crate"
	contains = list(/obj/item/vending_refill/cigarette)
	cost = 150
	containername = "cigarette supply crate"
	containertype = /obj/structure/closet/crate

/datum/syndie_supply_packs/vending/dinnerware
	name = "Dinnerware Supply Crate"
	cost = 100
	contains = list(/obj/item/vending_refill/dinnerware)
	containername = "dinnerware supply crate"

/datum/syndie_supply_packs/vending/imported
	name = "Imported Vending Machines"
	cost = 60
	contains = list(/obj/item/vending_refill/sustenance,
					/obj/item/vending_refill/robotics,
					/obj/item/vending_refill/sovietsoda,
					/obj/item/vending_refill/engineering)
	containername = "unlabeled supply crate"

/datum/syndie_supply_packs/vending/ptech
	name = "PTech Supply Crate"
	cost = 150
	contains = list(/obj/item/vending_refill/cart)
	containername = "ptech supply crate"

/datum/syndie_supply_packs/vending/snack
	name = "Snack Supply Crate"
	contains = list(/obj/item/vending_refill/snack)
	cost = 150
	containername = "snacks supply crate"

/datum/syndie_supply_packs/vending/cola
	name = "Softdrinks Supply Crate"
	contains = list(/obj/item/vending_refill/cola)
	cost = 150
	containername = "softdrinks supply crate"

/datum/syndie_supply_packs/vending/vendomat
	name = "Vendomat Supply Crate"
	cost = 100
	contains = list(/obj/item/vending_refill/assist)
	containername = "vendomat supply crate"

/datum/syndie_supply_packs/vending/chinese
	name = "Chinese Supply Crate"
	contains = list(/obj/item/vending_refill/chinese)
	cost = 150
	containername = "chinese supply crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Syndicate Special /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/syndie_supply_packs/syndicate_special
	name = "HEADER"
	group = SUPPLY_SYNDICATE_SPECIAL
	access = ACCESS_SYNDICATE_COMMS_OFFICER

/datum/syndie_supply_packs/syndicate_special/specialops // Возможно нахуй удалю оба или один из них
	name = "Special Ops Supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 2000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "special ops crate"

/datum/syndie_supply_packs/syndicate_special/bloody_spy
	name = "Syndicate 'Bloody Spy' Bundle"
	contains = list(/obj/item/clothing/under/chameleon, // 2TC
					/obj/item/clothing/mask/chameleon, // 0TC
					/obj/item/card/id/syndicate, // 2TC
					/obj/item/clothing/shoes/chameleon/noslip, // 2TC
					/obj/item/camera_bug, // 1TC
					/obj/item/multitool/ai_detect, // 1TC
					/obj/item/encryptionkey/syndicate, // 2TC
					/obj/item/twohanded/garrote, // 10TC
					/obj/item/pinpointer/advpinpointer, // 4TC
					/obj/item/storage/fancy/cigarettes/cigpack_syndicate, // 2TC
					/obj/item/flashlight/emp, // 2TC
					/obj/item/clothing/glasses/hud/security/chameleon, // 2TC
					/obj/item/chameleon // 7TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/thief
	name = "Syndicate 'Thief' Bundle"
	contains = list(/obj/item/gun/energy/kinetic_accelerator/crossbow, // 12TC
					/obj/item/chameleon, // 7TC
					/obj/item/clothing/glasses/chameleon/thermal, // 6TC
					/obj/item/clothing/gloves/color/black/thief, // 6TC
					/obj/item/card/id/syndicate, // 2TC
					/obj/item/clothing/shoes/chameleon/noslip, // 2TC
					/obj/item/storage/backpack/satchel_flat, // 2TC
					/obj/item/encryptionkey/syndicate // 2TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/bond
	name = "Syndicate 'Bond' Bundle"
	contains = list(/obj/item/gun/projectile/automatic/pistol, // 4TC
					/obj/item/suppressor, // 1TC
					/obj/item/ammo_box/magazine/m10mm/hp , // 3TC
					/obj/item/ammo_box/magazine/m10mm/ap, // 2TC
					/obj/item/clothing/under/suit_jacket/really_black, // 0TC
					/obj/item/card/id/syndicate, // 2TC
					/obj/item/clothing/suit/storage/lawyer/blackjacket/armored, // 0TC
					/obj/item/encryptionkey/syndicate, // 2TC
					/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail,	// 0TC
					/obj/item/dnascrambler, // 4TC
					/obj/item/storage/box/syndie_kit/emp, // 2TC
					/obj/item/CQC_manual // 13TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/sabotage
	name = "Syndicate 'Sabotage' Bundle"
	contains = list(/obj/item/grenade/plastic/c4, // 1TC
					/obj/item/grenade/plastic/c4, // 1TC
					/obj/item/camera_bug, // 1TC
					/obj/item/powersink, // 10TC
					/obj/item/cartridge/syndicate, // 6TC
					/obj/item/rcd/preloaded, // 0TC
					/obj/item/card/emag, // 6TC
					/obj/item/clothing/gloves/color/yellow, // 0TC
					/obj/item/grenade/syndieminibomb, // 6TC
					/obj/item/grenade/clusterbuster/n2o, // 4TC
					/obj/item/storage/box/syndie_kit/space, // 4TC
					/obj/item/encryptionkey/syndicate
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/payday
	name = "Syndicate 'PayDay' Bundle"
	contains = list(/obj/item/gun/projectile/revolver, // 13TC
					/obj/item/ammo_box/a357, // 3TC
					/obj/item/ammo_box/a357, // 3TC
					/obj/item/card/emag, // 6TC
					/obj/item/jammer, // 5TC
					/obj/item/card/id/syndicate, // 2TC
					/obj/item/clothing/under/suit_jacket/really_black, //0TC
					/obj/item/clothing/suit/storage/lawyer/blackjacket/armored, //0TC
					/obj/item/clothing/gloves/color/latex/nitrile, //0 TC
					/obj/item/clothing/mask/gas/clown_hat, // 0TC
					/obj/item/thermal_drill/diamond_drill, // 1TC
					/obj/item/encryptionkey/syndicate// 2TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/implanter
	name = "Syndicate 'Implanter' Bundle"
	contains = list(/obj/item/implanter/freedom, // 5TC
					/obj/item/autoimplanter, // Никаких аплинков синдибазе, это в качестве компенсации.
					/obj/item/organ/internal/cyberimp/arm/esword, // Никаких аплинков синдибазе, это в качестве компенсации.
					/obj/item/implanter/emp, // 0TC
					/obj/item/implanter/adrenalin, // 8TC
					/obj/item/implanter/explosive, // 2TC
					/obj/item/implanter/storage, // 8TC
					/obj/item/encryptionkey/syndicate // 2TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/hacker
	name = "Syndicate 'Hacker' Bundle"
	contains = list(/obj/item/aiModule/syndicate, // 12TC
					/obj/item/card/emag, // 6TC
					/obj/item/encryptionkey/syndicate, // 2TC
					/obj/item/encryptionkey/binary, // 5TC
					/obj/item/aiModule/toyAI, // 0TC
					/obj/item/clothing/glasses/chameleon/thermal, // 6TC
					/obj/item/storage/belt/military/traitor/hacker, // 3TC
					/obj/item/clothing/gloves/combat, // 0TC
					/obj/item/multitool/ai_detect, // 1TC
					/obj/item/flashlight/emp // 2TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/darklord
	name = "Syndicate 'Darklord' Bundle"
	contains = list(/obj/item/melee/energy/sword/saber/red, // 8TC
					/obj/item/melee/energy/sword/saber/red, // 8TC
					/obj/item/dnainjector/telemut/darkbundle, // 0TC
					/obj/item/clothing/suit/hooded/chaplain_hoodie, // 0TC
					/obj/item/card/id/syndicate, // 2TC
					/obj/item/clothing/shoes/chameleon/noslip, // 2TC
					/obj/item/clothing/mask/chameleon, // 2TC
					/obj/item/encryptionkey/syndicate // 2TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"

/datum/syndie_supply_packs/syndicate_special/professional
	name = "Syndicate 'Professional' Bundle"
	contains = list(/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator, // 16TC
					/obj/item/ammo_box/magazine/sniper_rounds/penetrator, // 5TC
					/obj/item/ammo_box/magazine/sniper_rounds/soporific, // 3TC
					/obj/item/clothing/glasses/chameleon/thermal, // 6TC
					/obj/item/clothing/gloves/combat, // 0 TC
					/obj/item/clothing/under/suit_jacket/really_black, // 0 TC
					/obj/item/clothing/suit/storage/lawyer/blackjacket/armored, // 0TC
					/obj/item/pen/edagger, // 2TC
					/obj/item/encryptionkey/syndicate // 2TC
					)
	cost = 30000
	containertype = /obj/structure/closet/crate/secure/syndicate
	containername = "crate"



