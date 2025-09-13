GLOBAL_LIST_INIT(maintenance_loot_tier_0, list(
	list(
		// Tools
		/obj/effect/spawner/random/engineering/tools = 4,
		// Materials
		/obj/effect/spawner/random/engineering/materials = 4,
		// Misc eng supplies
		/obj/effect/spawner/random/engineering/misc = 1,
		// Plushies
		/obj/effect/spawner/random/plushies = 1,
	) = 6,

	list(
		// Spawners for easily found items
		/obj/effect/spawner/random/bureaucracy,
		/obj/effect/spawner/random/dice,
		/obj/effect/spawner/random/book,

		// Other worthless/easily found items
		/obj/item/camera_film,
		/obj/item/camera,
		/obj/item/caution,
		/obj/item/clothing/head/cone,
		/obj/item/light/bulb,
		/obj/item/light/tube,
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_official,
		/obj/item/reagent_containers/drinks/drinkingglass,
		/obj/item/reagent_containers/glass/beaker/waterbottle,
		/obj/item/reagent_containers/glass/beaker/waterbottle/empty,
		/obj/item/scissors,
		/obj/item/storage/box,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/fancy/matches,
	) = 2,

	list(
		// Emergency items
		/obj/item/extinguisher,
		/obj/item/flashlight,
	) = 1,
))

GLOBAL_LIST_INIT(maintenance_loot_tier_1, list(
	list(
		// Sub-spawners
		/obj/effect/spawner/random/engineering/toolbox,
		/obj/effect/spawner/random/snacks,

		// Assemblies and cells
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/timer,
		/obj/item/assembly/signaler,
		/obj/item/assembly/voice,
		/obj/item/assembly/voice/noise,
		/obj/item/stock_parts/cell,

		// Clothing
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/gloves/color/fyellow,
		/obj/item/clothing/gloves/color/yellow/fake,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/hardhat/red,
		/obj/item/clothing/head/that,
		/obj/item/clothing/head/ushanka,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/under/misc/vice,

		// Medical supplies / chemistry items
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical/bruise_pack/advanced,
		/obj/item/stack/medical/ointment/advanced,

		// Common items
		/obj/item/bodybag,
		/obj/item/cultivator,
		/obj/item/flashlight/pen,
		/obj/item/radio/off,
		/obj/item/reagent_containers/drinks/mug,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/relic,
		/obj/item/restraints/handcuffs/toy,
		/obj/item/scratch,
		/obj/item/seeds/ambrosia,
		/obj/item/seeds/ambrosia/deus,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cloth,
		/obj/item/storage/bag/plasticbag,
		/obj/item/storage/box/cups,
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/lights/mixed,
		/obj/item/storage/fancy/cigarettes/dromedaryco,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/emergency_oxygen/engi,
		/obj/item/vending_refill/cola,
	) = 85,

	list(
		/obj/item/storage/wallet,
		/obj/item/storage/wallet/random,
	) = 5,

	list(
		// Small chance of tier 1 stock parts
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/scanning_module,

		// Coins
		/obj/item/coin/silver,
		/obj/item/coin/twoheaded,
	) = 2,
))

GLOBAL_LIST_INIT(maintenance_loot_tier_2, list(
	list(
		// Rarer items
		/obj/effect/spawner/random/mod_maint,
		/obj/item/clothing/glasses/meson,
		/obj/item/clothing/head/welding,
		/obj/item/crowbar/red,
		/obj/item/storage/belt/utility,
		/obj/item/dissector,
		/obj/effect/spawner/random/smithed_item/any,
	) = 45,

	list(
		// Contraband and Syndicate items
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/mask/chameleon/voice_change,
		/obj/item/clothing/mask/gas/voice_modulator,
		/obj/item/clothing/mask/gas/voice_modulator/chameleon,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/clothing/suit/jacket/bomber/syndicate,
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored,
		/obj/item/clothing/under/chameleon,
		/obj/item/deck/cards/syndicate,
		/obj/item/grenade/clown_grenade,
		/obj/item/grenade/smokebomb,
		/obj/item/gun/syringe/syndicate,
		/obj/item/melee/knuckleduster/syndie,
		/obj/item/mod/construction/broken_core,
		/obj/item/multitool/ai_detect,
		/obj/item/seeds/ambrosia/cruciatus,
		/obj/item/soap/syndie,
		/obj/item/stamp/chameleon,
		/obj/item/storage/backpack/duffel/syndie/med/surgery_fake,
		/obj/item/storage/backpack/satchel_flat,
		/obj/item/storage/belt/military/traitor,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/fancy/cigarettes/cigpack_carcinoma,
		/obj/item/storage/pill_bottle/fakedeath,
		/obj/item/storage/secure/briefcase/syndie,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/suppressor,
		/obj/item/weaponcrafting/receiver,
	) = 45,

	list(
		// Plausible Deniability items
		/obj/item/storage/box/syndie_kit/nuke,
		/obj/item/storage/box/syndie_kit/supermatter
	) = 1,

	list(
		// Health/repair kits
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/machine,

		// Rarer departmental items
		/obj/item/reagent_scanner/adv,
		/obj/item/robotanalyzer,
		/obj/item/stack/nanopaste,
		/obj/item/whetstone,

		// Other rare but useful items
		/obj/item/radio/headset,
		/obj/item/melee/knuckleduster,
	) = 3,
))

GLOBAL_LIST_INIT(maintenance_loot_tier_3, list(
	list(
		// Coveted items
		/obj/item/clothing/gloves/color/yellow,
	) = 7,

	list(
		// Rare Syndicate items
		/obj/item/gun/projectile/automatic/pistol,
		/obj/item/dnascrambler,
		/obj/item/bio_chip_implanter/storage,
		/obj/item/reagent_containers/spray/sticky_tar,
		/obj/item/storage/box/syndie_kit/space,
	) = 3,
))

GLOBAL_LIST_INIT(maintenance_loot_tables, list(
	list(
		GLOB.maintenance_loot_tier_0 = 490,
		GLOB.maintenance_loot_tier_1 = 390,
		GLOB.maintenance_loot_tier_2 = 114,
		GLOB.maintenance_loot_tier_3 =   6,
	) = 75,

	/obj/effect/spawner/random/trash = 25,
))
