// ADDING A NEW BOUNTY
// new /datum/supply_bounty(TYPE, IS_EXACT, QUANTITY, REWARD, EXTRA REWARD)
#define SUPPLY_BOUNTY_QUANTITY_ONE 1
#define SUPPLY_BOUNTY_QUANTITY_LOW 3
#define SUPPLY_BOUNTY_QUANTITY_MEDIUM 5
#define SUPPLY_BOUNTY_QUANTITY_HIGH 10
#define SUPPLY_BOUNTY_QUANTITY_BULK 25

#define SUPPLY_BOUNTY_REWARD_CHEAP 25
#define SUPPLY_BOUNTY_REWARD_LOW 50
#define SUPPLY_BOUNTY_REWARD_MEDIUM 75
#define SUPPLY_BOUNTY_REWARD_HIGH 100
#define SUPPLY_BOUNTY_REWARD_GRAND 200

/// List of all active bounties
GLOBAL_LIST_EMPTY(active_supply_bounties)

/// List of possible bonus rewards for bounties
GLOBAL_LIST_INIT(supply_bounty_bonuses, list(
	/// Bonus cash
	/obj/item/stack/spacecash/c500 = 1,
	/obj/item/stack/spacecash/c200 = 10,
	/obj/item/stack/spacecash/c100 = 50,
	/obj/item/stack/spacecash/c50 = 100,
	/obj/item/stack/spacecash/c20 = 200,
	/// Bonus minerals
	/obj/item/stack/sheet/mineral/gold/five = 10,
	/obj/item/stack/sheet/mineral/silver/five = 10,
	/obj/item/stack/sheet/mineral/bananium/five = 2,
	/obj/item/stack/sheet/mineral/tranquillite/five = 2,
	/obj/item/stack/sheet/mineral/titanium/five = 4,
	/obj/item/stack/sheet/mineral/iridium/two = 10,
	/obj/item/stack/sheet/mineral/palladium/two = 10,
	/obj/item/stack/sheet/mineral/platinum/two = 10,
	/// Bonus commodities
	/obj/item/soap/nanotrasen = 20,
	/obj/item/soap/deluxe = 15,
	/obj/item/soap/syndie = 5,
	/obj/item/clothing/mask/chameleon = 5,
	/obj/item/clothing/under/chameleon = 5,
	/obj/item/grenade/smokebomb = 5,
	/obj/item/grenade/clown_grenade = 5,
	/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 5,
	/obj/item/storage/fancy/cigars/cohiba = 5,
	/obj/item/storage/fancy/havana_cigar = 1,
	/obj/item/clothing/shoes/chameleon/noslip = 4,
	/obj/item/storage/firstaid/regular = 10,
	/obj/item/whetstone = 5,
	/obj/item/storage/box/enforcer_rubber = 3,
	/obj/item/clothing/gloves/combat = 5,
	/obj/item/clothing/glasses/meson/sunglasses = 3,
	/obj/item/clothing/suit/armor/vest/combat = 3,
	/obj/item/melee/energy/sword/pirate = 1,
	/obj/item/storage/box/characters = 20,
	/obj/item/storage/box/large/glowstick/emergency = 25,
	/obj/item/storage/box/glowstick/premium = 15,
	/obj/item/storage/fancy/shell/beanbag = 10,
	/obj/item/storage/fancy/shell/rubbershot = 10,
	/obj/item/storage/box/donkpockets = 25,
	/obj/item/storage/box/snappops = 25,
))

/// List of all bounty datums.
GLOBAL_LIST_INIT(supply_bounties, list(
	/// GENERAL
	new /datum/supply_bounty(/obj/item/folder, 													FALSE, 			SUPPLY_BOUNTY_QUANTITY_MEDIUM, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/pen, 													FALSE, 			SUPPLY_BOUNTY_QUANTITY_MEDIUM, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/paper_bin, 												FALSE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stamp/granted, 											FALSE, 			SUPPLY_BOUNTY_QUANTITY_ONE, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stamp/denied, 											FALSE, 			SUPPLY_BOUNTY_QUANTITY_ONE, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/toner, 													FALSE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_MEDIUM),

	// SUPPLY
	new /datum/supply_bounty(/obj/item/wrench, 													TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/crowbar, 												TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/screwdriver, 											TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/wirecutters, 											TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/multitool, 												TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/wrench,													TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),

	// SERVICE


	// SCIENCE


	// MEDICAL
	new /datum/supply_bounty(/obj/item/scalpel, 												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/scalpel/laser, 											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/scalpel/laser/manager, 									TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/cautery,													TRUE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/hemostat,												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/retractor,												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/fix_o_vein,												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/surgicaldrill,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/circular_saw,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/bonegel,													TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/bonesetter,												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/dissector,												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/surgical_drapes,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/stack/medical/bruise_pack,								FALSE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stack/medical/ointment,									FALSE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/reagent_containers/syringe/charcoal,						TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/reagent_containers/hypospray/autoinjector/epinephrine,	TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/stack/medical/splint,									TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/stack/medical/suture,									TRUE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/stack/medical/suture/emergency,							TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/stack/medical/suture/medicated, 							TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/stack/medical/suture/regen_mesh/advanced,				TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/stack/medical/suture/regen_mesh,							TRUE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/reagent_containers/syringe,								TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/reagent_containers/glass/beaker,							FALSE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/reagent_containers/glass/bottle,							TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/reagent_containers/dropper,								TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/reagent_containers/hypospray,							FALSE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/healthanalyzer,											FALSE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/sensor_device,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/pinpointer/crew,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),

	// SECURITY
	new /datum/supply_bounty(/obj/item/melee/baton,												TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/restraints/handcuffs,									TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/restraints/handcuffs/cable/zipties, 						TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/food/donut,												TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_LOW), // not filed under service because it's funny
	new /datum/supply_bounty(/obj/item/flash,													TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/reagent_containers/spray/pepper,							TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/flashlight/seclite,										TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/ammo_box/magazine/detective/speedcharger,				TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/flamethrower,											TRUE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_casing/shotgun/beanbag,								TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/ammo_casing/shotgun/rubbershot,							TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/ammo_casing/shotgun/dart,								TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/ammo_casing/shotgun/incendiary,							TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/ammo_casing/shotgun/laserslug,							TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/forensics/swab,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/forensics/sample_kit,									TRUE,			SUPPLY_BOUNTY_QUANTITY_ONE,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/forensics/sample_kit/powder,								TRUE,			SUPPLY_BOUNTY_QUANTITY_ONE,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/gun/projectile/shotgun/automatic/combat,					TRUE,			SUPPLY_BOUNTY_QUANTITY_ONE,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/gun/projectile/shotgun/riot,								TRUE,			SUPPLY_BOUNTY_QUANTITY_ONE,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/gun/energy/laser,										TRUE,			SUPPLY_BOUNTY_QUANTITY_ONE,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/gun/energy/gun,											TRUE,			SUPPLY_BOUNTY_QUANTITY_ONE,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/gun/energy/laser/practice,								TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/ammo_box/c45,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_box/c9mm,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_box/c10mm,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_box/b357,											TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_box/foambox/sniper/riot,							TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_box/foambox/riot,									TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_HIGH),
	new /datum/supply_bounty(/obj/item/ammo_casing/caseless/foam_dart/sniper/riot,				TRUE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/ammo_casing/caseless/foam_dart/riot,						TRUE,			SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_CHEAP),
))

#undef SUPPLY_BOUNTY_QUANTITY_ONE
#undef SUPPLY_BOUNTY_QUANTITY_LOW
#undef SUPPLY_BOUNTY_QUANTITY_MEDIUM
#undef SUPPLY_BOUNTY_QUANTITY_HIGH
#undef SUPPLY_BOUNTY_QUANTITY_BULK

#undef SUPPLY_BOUNTY_REWARD_CHEAP
#undef SUPPLY_BOUNTY_REWARD_LOW
#undef SUPPLY_BOUNTY_REWARD_MEDIUM
#undef SUPPLY_BOUNTY_REWARD_HIGH
#undef SUPPLY_BOUNTY_REWARD_GRAND
