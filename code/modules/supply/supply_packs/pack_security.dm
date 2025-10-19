/datum/supply_packs/security
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/gear
	access = ACCESS_SECURITY
	group = SUPPLY_SECURITY
	announce_beacons = list("Security" = list("Head of Security's Desk", "Warden", "Security"))
	department_restrictions = list(DEPARTMENT_SECURITY)


/datum/supply_packs/security/supplies
	name = "Security Supplies Crate"
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs)
	cost = 600
	containername = "security supply crate"

/datum/supply_packs/security/vending/security
	name = "SecTech Supply Crate"
	cost = 600
	contains = list(/obj/item/vending_refill/security)
	containername = "SecTech supply crate"

/datum/supply_packs/security/vending/clothingvendor
	name = "Security Clothing Vendors Crate"
	cost = 200
	contains = list(/obj/item/vending_refill/secdrobe,
					/obj/item/vending_refill/detdrobe)
	containername = "security clothing vendor crate"

////// Armor: Basic

/datum/supply_packs/security/helmets
	name = "Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet)
	cost = 250
	containername = "helmet crate"

/datum/supply_packs/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/head/helmet/justice/escape,
					/obj/item/clothing/mask/gas/sechailer,
					/obj/item/clothing/mask/gas/sechailer)
	cost = 400 //justice comes at a price. An expensive, noisy price.
	containername = "justice enforcer crate"

/datum/supply_packs/security/armor
	name = "Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 250
	containername = "armor crate"

/datum/supply_packs/security/armor/bonus
	name = "Bloody Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/vest/bloody,
					/obj/item/clothing/suit/armor/vest/bloody,
					/obj/item/clothing/suit/armor/vest/bloody)
	cost = 400
	containername = "bloody armor crate"
	contraband = TRUE

////// Weapons: Basic

/datum/supply_packs/security/baton
	name = "Stun Batons Crate"
	contains = list(/obj/item/melee/baton/loaded,
					/obj/item/melee/baton/loaded,
					/obj/item/melee/baton/loaded)
	cost = 400
	containername = "stun baton crate"

/datum/supply_packs/security/laser
	name = "Lasers Crate"
	contains = list(/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser)
	cost = 500
	containername = "laser crate"

/datum/supply_packs/security/disabler
	name = "Disabler Crate"
	contains = list(/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler)
	cost = 300
	containername = "disabler crate"

/datum/supply_packs/security/forensics
	name = "Forensics Resupply Crate"
	contains = list(/obj/item/storage/briefcase/crimekit,
					/obj/item/storage/briefcase/crimekit)
	cost = 250
	containername = "forensics resupply crate"

///// Armory stuff

/datum/supply_packs/security/armory
	containertype = /obj/structure/closet/crate/secure/weapon
	access = ACCESS_ARMORY
	announce_beacons = list("Security" = list("Warden", "Head of Security's Desk"))

///// Armor: Specialist

/datum/supply_packs/security/armory/riothelmets
	name = "Riot Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	cost = 400
	containername = "riot helmets crate"

/datum/supply_packs/security/armory/riotarmor
	name = "Riot Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 400
	containername = "riot armor crate"

/datum/supply_packs/security/armory/riotshields
	name = "Riot Shields Crate"
	contains = list(/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/shield/riot)
	cost = 500
	containername = "riot shields crate"

/datum/supply_packs/security/bullethelmets
	name = "Bulletproof Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt)
	cost = 300
	containername = "bulletproof helmet crate"

/datum/supply_packs/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof)
	cost = 300
	containername = "tactical armor crate"

/datum/supply_packs/security/armory/webbing
	name = "Webbing Crate"
	contains = list(/obj/item/storage/belt/security/webbing,
					/obj/item/storage/belt/security/webbing,
					/obj/item/storage/belt/security/webbing)
	cost = 400
	containername = "tactical webbing crate"

/datum/supply_packs/security/armory/swat
	name = "SWAT Gear Crate"
	contains = list(/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/suit/armor/swat,
					/obj/item/clothing/suit/armor/swat,
					/obj/item/kitchen/knife/combat,
					/obj/item/kitchen/knife/combat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/storage/belt/military/assault,
					/obj/item/storage/belt/military/assault,
					/obj/item/clothing/shoes/combat,
					/obj/item/clothing/shoes/combat)
	cost = 900
	containername = "assault armor crate"

/datum/supply_packs/security/armory/laserarmor
	name = "Ablative Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)		// Only two vests to keep costs down for balance
	cost = 500
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ablative armor crate"

/////// Weapons: Specialist

/datum/supply_packs/security/armory/ballistic
	name = "Riot Shotguns Crate"
	contains = list(/obj/item/gun/projectile/shotgun/riot,
					/obj/item/gun/projectile/shotgun/riot,
					/obj/item/gun/projectile/shotgun/riot,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier)
	cost = 800
	containername = "riot shotgun crate"

/datum/supply_packs/security/armory/ballisticauto
	name = "Combat Shotguns Crate"
	contains = list(/obj/item/gun/projectile/shotgun/automatic/combat,
					/obj/item/gun/projectile/shotgun/automatic/combat,
					/obj/item/gun/projectile/shotgun/automatic/combat,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier)
	cost = 1000
	containername = "combat shotgun crate"

/datum/supply_packs/security/armory/expenergy
	name = "Energy Guns Crate"
	contains = list(/obj/item/gun/energy/gun,
					/obj/item/gun/energy/gun)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy gun crate"

/datum/supply_packs/security/armory/eshotguns
	name = "Energy Shotguns Crate"
	contains = list(/obj/item/gun/energy/gun/shotgun,
					/obj/item/gun/energy/gun/shotgun)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy shotgun crate"

/datum/supply_packs/security/armory/securiblades
	name = "Securiblade Crate"
	contains = list(/obj/item/storage/belt/sheath/secsword,
		/obj/item/storage/belt/sheath/secsword)
	cost = 600
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "securiblade crate"

/datum/supply_packs/security/armory/stingers
	name = "Stinger Grenade Crate"
	contains = list(/obj/item/storage/box/stingers,
					/obj/item/storage/box/stingers)
	cost = 300
	containername = "stingball grenade crate"

/// costs 3/5ths of the normal e-guns for 3/4ths the total ammo, making it cheaper to arm more people, but less convient for any one person
/datum/supply_packs/security/armory/epistol
	name = "Energy Pistol Crate"
	contains = list(/obj/item/gun/energy/gun/mini,
					/obj/item/gun/energy/gun/mini,
					/obj/item/gun/energy/gun/mini)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy gun crate"

/datum/supply_packs/security/armory/eweapons
	name = "Incendiary Weapons Crate"
	contains = list(/obj/item/flamethrower/full,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 200	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "incendiary weapons crate"
	access = ACCESS_HEADS

/datum/supply_packs/security/armory/wt550
	name = "WT-550 PDW Crate"
	contains = list(/obj/item/gun/projectile/automatic/wt550,
					/obj/item/gun/projectile/automatic/wt550)
	cost = 625
	containername = "auto rifle crate"

/datum/supply_packs/security/armory/wt550ammo
	name = "WT-550 PDW Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,)
	cost = 500
	containername = "auto rifle ammo crate"

/datum/supply_packs/security/armory/laserrifle
	name = "IK-M1 Laser Rifle Crate"
	contains = list(/obj/item/gun/projectile/automatic/laserrifle,
					/obj/item/gun/projectile/automatic/laserrifle)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "laser rifle crate"

/datum/supply_packs/security/armory/laserammo
	name = "IK-M1 Laser Rifle Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/laser,
					/obj/item/ammo_box/magazine/laser,
					/obj/item/ammo_box/magazine/laser,
					/obj/item/ammo_box/magazine/laser)
	cost = 300
	containername = "laser rifle ammo crate"

/datum/supply_packs/security/armory/lever_action
	name = "Model 2495 Laser Rifle Crate"
	contains = list(/obj/item/gun/energy/laser/lever_action,
					/obj/item/gun/energy/laser/lever_action)
	cost = 250
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "lever action rifle crate"

/datum/supply_packs/security/armory/tranqammo
	name = "Tranquilizer Shell Crate"
	contains = list(/obj/item/storage/fancy/shell/tranquilizer,
					/obj/item/storage/fancy/shell/tranquilizer)
	cost = 400
	containername = "tranquilizer shell crate"

/datum/supply_packs/security/armory/holyammo
	name = "Holy Water Shell Crate"
	contains = list(/obj/item/storage/fancy/shell/holy,
					/obj/item/storage/fancy/shell/holy)
	cost = 400
	containername = "holy water shell crate"

/datum/supply_packs/security/armory/disablersmg
	name = "WT-450 Disabler SMG Crate"
	contains = list(/obj/item/gun/energy/disabler/smg,
					/obj/item/gun/energy/disabler/smg)
	cost = 550
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "disabler smg crate"

/////// Implants & etc

/datum/supply_packs/security/armory/mindshield
	name = "Mindshield Bio-chips Crate"
	contains = list (/obj/item/storage/lockbox/mindshield)
	cost = 750
	containername = "mindshield bio-chip crate"

/datum/supply_packs/security/armory/trackingimp
	name = "Tracking Bio-chips Crate"
	contains = list (/obj/item/storage/box/trackimp)
	cost = 500
	containername = "tracking bio-chip crate"

/datum/supply_packs/security/armory/chemimp
	name = "Chemical Bio-chips Crate"
	contains = list (/obj/item/storage/box/chemimp)
	cost = 500
	containername = "chemical bio-chip crate"

/datum/supply_packs/security/armory/flayer_nullifer
	name = "Mindflayer Containment Kit"
	contains = list(/obj/item/organ/internal/cyberimp/chest/ipc_joints/flayer_pacification,
					/obj/item/storage/box/handcuffs,
					/obj/item/toy/plushie/ipcplushie) // For practicing takedowns
	cost = 250
	containername = "mindflayer containment kit"

/datum/supply_packs/security/armory/bluespace_anchor
	name = "Bluespace Anchor Crate"
	contains = list(/obj/item/organ/internal/cyberimp/chest/bluespace_anchor)
	cost = 250
	containername = "bluespace anchor crate"

/datum/supply_packs/security/securitybarriers
	name = "Security Barriers Crate"
	contains = list(/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier)
	cost = 200
	containername = "security barriers crate"

/datum/supply_packs/security/securityclothes
	name = "Security Clothing Crate"
	contains = list(/obj/item/clothing/under/rank/security/officer/corporate,
					/obj/item/clothing/under/rank/security/officer/corporate,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/under/rank/security/warden/corporate,
					/obj/item/clothing/head/beret/warden,
					/obj/item/clothing/under/rank/security/head_of_security/corporate,
					/obj/item/clothing/head/beret/hos)
	cost = 200
	containername = "security clothing crate"

/// Starter pack for an officer. Contains everything in a locker but backpack (officer already start with one). Convenient way to equip new officer on highpop.
/datum/supply_packs/security/officerpack
	name = "Officer Starter Pack"
	contains = list(/obj/item/clothing/suit/armor/vest/security,
				/obj/item/radio/headset/headset_sec/alt,
				/obj/item/clothing/head/soft/sec,
				/obj/item/reagent_containers/spray/pepper,
				/obj/item/flash,
				/obj/item/grenade/flashbang,
				/obj/item/storage/belt/security,
				/obj/item/holosign_creator/security,
				/obj/item/clothing/mask/gas/sechailer,
				/obj/item/clothing/glasses/hud/security/sunglasses,
				/obj/item/clothing/head/helmet,
				/obj/item/melee/baton/loaded,
				/obj/item/clothing/suit/armor/secjacket)
	cost = 500 // Convenience has a price and this pack is genuinely loaded
	containername = "officer starter crate"

/datum/supply_packs/security/secway
	name = "Secway Crate"
	contains_special = list(
		"Secway"
	)
	cost = 800
	containertype = /obj/structure/largecrate/secway
	containername = "secway crate"
	access = ACCESS_HEADS

/datum/supply_packs/security/party_ammo
	name = "Party Ammunition Crate"
	contains = list(
		/obj/item/grenade/confetti,
		/obj/item/grenade/confetti,
		/obj/item/grenade/confetti,
		/obj/item/storage/fancy/shell/confetti,
		/obj/item/storage/fancy/shell/confetti,
		/obj/item/storage/fancy/shell/confetti
	)
	cost = 300
	containername = "party ammunition crate"
