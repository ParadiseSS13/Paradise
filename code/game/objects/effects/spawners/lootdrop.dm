/obj/effect/spawner/lootdrop
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = TRUE		//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)

/obj/effect/spawner/lootdrop/Initialize(mapload)
	. = ..()
	while(lootcount)
		var/lootspawn = pickweight(loot)
		if(!lootdoubles)
			loot.Remove(lootspawn)
		if(lootspawn)
			new lootspawn(get_turf(src))
		lootcount--
	qdel(src)

/obj/effect/spawner/lootdrop/armory_contraband
	name = "armory contraband gun spawner"
	lootdoubles = FALSE

	loot = list(
				/obj/item/gun/projectile/automatic/pistol = 8,
				/obj/item/gun/projectile/shotgun/automatic/combat = 5,
				/obj/item/gun/projectile/revolver/mateba,
				/obj/item/gun/projectile/automatic/pistol/deagle
				)

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner (1 item)"
	icon_state = "loot"

	//How to balance this table
	//-------------------------
	//The total added weight of all the entries should be (roughly) equal to the total number of lootdrops
	//(take in account those that spawn more than one object!)
	//
	//While this is random, probabilities tells us that item distribution will have a tendency to look like
	//the content of the weighted table that created them.
	//The less lootdrops, the less even the distribution.
	//
	//If you want to give items a weight <1 you can multiply all the weights by 10
	//
	//the "" entry will spawn nothing, if you increase this value,
	//ensure that you balance it with more spawn points

	//table data:
	//-----------
	//aft maintenance: 		24 items, 18 spots 2 extra (28/08/2014)
	//asmaint: 				16 items, 11 spots 0 extra (08/08/2014)
	//asmaint2:			 	36 items, 26 spots 2 extra (28/08/2014)
	//fpmaint:				5  items,  4 spots 0 extra (08/08/2014)
	//fpmaint2:				12 items, 11 spots 2 extra (28/08/2014)
	//fsmaint:				0  items,  0 spots 0 extra (08/08/2014)
	//fsmaint2:				40 items, 27 spots 5 extra (28/08/2014)
	//maintcentral:			2  items,  2 spots 0 extra (08/08/2014)
	//port:					5  items,  5 spots 0 extra (08/08/2014)
	loot = list(
				/obj/item/bodybag = 10,
				/obj/item/clothing/glasses/meson = 20,
				/obj/item/clothing/glasses/sunglasses = 10,
				/obj/item/clothing/gloves/color/yellow/fake = 15,
				/obj/item/clothing/gloves/color/fyellow = 10,
				/obj/item/clothing/gloves/color/yellow = 5,
				/obj/item/clothing/gloves/color/black = 20,
				/obj/item/clothing/head/hardhat = 10,
				/obj/item/clothing/head/hardhat/red = 10,
				/obj/item/clothing/head/that = 10,
				/obj/item/clothing/head/ushanka = 10,
				/obj/item/clothing/head/welding = 10,
				/obj/item/clothing/mask/gas = 10,
				/obj/item/clothing/suit/storage/hazardvest = 10,
				/obj/item/clothing/under/misc/vice = 10,
				/obj/item/assembly/prox_sensor = 40,
				/obj/item/assembly/timer = 30,
				/obj/item/flashlight = 40,
				/obj/item/flashlight/pen = 10,
				/obj/item/multitool = 20,
				/obj/item/radio/off = 20,
				/obj/item/t_scanner = 60,
				/obj/item/stack/cable_coil = 40,
				/obj/item/stack/cable_coil{amount = 5} = 60,
				/obj/item/stack/medical/bruise_pack/advanced = 10,
				/obj/item/stack/medical/ointment/advanced = 10,
				/obj/item/stack/rods{amount = 10} = 80,
				/obj/item/stack/rods{amount = 23} = 20,
				/obj/item/stack/rods{amount = 50} = 10,
				/obj/item/stack/sheet/cardboard = 20,
				/obj/item/stack/sheet/metal{amount = 20} = 10,
				/obj/item/stack/sheet/mineral/plasma = 10,
				/obj/item/stack/sheet/rglass = 10,
				/obj/item/stack/sheet/cloth{amount = 3} = 40,
				/obj/item/book/manual/wiki/engineering_construction = 10,
				/obj/item/book/manual/wiki/hacking = 10,
				/obj/item/clothing/head/cone = 10,
				/obj/item/geiger_counter = 30,
				/obj/item/coin/silver = 10,
				/obj/item/coin/twoheaded = 10,
				/obj/item/poster/random_contraband = 10,
				/obj/item/crowbar = 10,
				/obj/item/crowbar/red = 10,
				/obj/item/restraints/handcuffs/toy = 5,
				/obj/item/extinguisher = 90,
				/obj/item/hand_labeler = 10,
				/obj/item/paper/crumpled = 10,
				/obj/item/pen = 10,
				/obj/item/cultivator = 10,
				/obj/item/reagent_containers/spray/pestspray = 10,
				/obj/item/stock_parts/cell = 30,
				/obj/item/storage/belt/utility = 20,
				/obj/item/storage/box = 20,
				/obj/item/storage/box/cups = 10,
				/obj/item/storage/box/donkpockets = 10,
				/obj/item/storage/box/lights/mixed = 30,
				/obj/item/storage/fancy/cigarettes/dromedaryco = 10,
				/obj/item/storage/toolbox/mechanical = 10,
				/obj/item/screwdriver = 30,
				/obj/item/tank/internals/emergency_oxygen = 20,
				/obj/item/tank/internals/emergency_oxygen/engi = 10,
				/obj/item/vending_refill/cola = 10,
				/obj/item/weldingtool = 30,
				/obj/item/wirecutters = 10,
				/obj/item/wrench = 40,
				/obj/item/relic = 35,
				/obj/item/weaponcrafting/receiver = 2,
				/obj/item/clothing/shoes/black = 30,
				/obj/item/seeds/ambrosia/deus = 10,
				/obj/item/seeds/ambrosia = 20,
				/obj/item/clothing/under/color/black = 30,
				/obj/item/stack/tape_roll = 10,
				/obj/item/storage/bag/plasticbag = 20,
				/obj/item/storage/wallet = 20,
				/obj/item/storage/wallet/random = 5,
				/obj/item/scratch = 10,
				/obj/item/caution = 10,
				/obj/item/mod/construction/broken_core = 4,
				/obj/effect/spawner/random_spawners/mod/maint = 10,
				////////////////CONTRABAND STUFF//////////////////
				/obj/item/grenade/clown_grenade = 3,
				/obj/item/grenade/smokebomb = 3,
				/obj/item/seeds/ambrosia/cruciatus = 3,
				/obj/item/gun/projectile/automatic/pistol = 1,
				/obj/item/ammo_box/magazine/m10mm = 4,
				/obj/item/soap/syndie = 7,
				/obj/item/gun/syringe/syndicate = 2,
				/obj/item/suppressor = 4,
				/obj/item/clothing/under/chameleon = 2,
				/obj/item/stamp/chameleon = 2,
				/obj/item/clothing/shoes/chameleon/noslip = 5,
				/obj/item/clothing/mask/chameleon = 2,
				/obj/item/clothing/mask/gas/voice_modulator = 2,
				/obj/item/clothing/mask/gas/voice_modulator/chameleon = 2,
				/obj/item/dnascrambler = 1,
				/obj/item/storage/backpack/satchel_flat = 2,
				/obj/item/storage/toolbox/syndicate = 2,
				/obj/item/storage/backpack/duffel/syndie/med/surgery_fake = 2,
				/obj/item/storage/belt/military/traitor = 2,
				/obj/item/storage/box/syndie_kit/space = 2,
				/obj/item/multitool/ai_detect = 2,
				/obj/item/implanter/storage = 1,
				/obj/item/deck/cards/syndicate = 2,
				/obj/item/storage/secure/briefcase/syndie = 2,
				/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 2,
				/obj/item/storage/pill_bottle/fakedeath = 2,
				/obj/item/clothing/suit/jacket/syndicatebomber = 5,
				/obj/item/clothing/suit/storage/iaa/blackjacket/armored = 2, // More armored than bomber and has pockets, so it is rarer
				"" = 61 // This should be a decently high number for chances where no loot will spawn
				)

/obj/effect/spawner/lootdrop/maintenance/two
	name = "maintenance loot spawner (2 items)"
	icon_state = "doubleloot"
	lootcount = 2

/obj/effect/spawner/lootdrop/maintenance/three
	name = "maintenance loot spawner (3 items)"
	icon_state = "moreloot"
	lootcount = 3

/obj/effect/spawner/lootdrop/maintenance/eight
	name = "maintenance loot spawner (8 items)"
	icon_state = "megaloot"
	lootcount = 8


/obj/effect/spawner/lootdrop/crate_spawner // for ruins
	name = "lootcrate spawner"
	lootdoubles = FALSE
	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80,
				)



/obj/effect/spawner/lootdrop/trade_sol/
	name = "trader item spawner"
	lootcount = 6

/obj/effect/spawner/lootdrop/trade_sol/civ
	name = "1. civilian gear"
	loot = list(
				// General utility gear
				/obj/item/clothing/gloves/combat = 100,
				/obj/item/reagent_containers/spray/cleaner/advanced = 100,
				/obj/item/soap = 50,
				/obj/item/clothing/under/syndicate/combat = 50,
				/obj/item/soap/syndie = 50,
				/obj/item/lighter/zippo/gonzofist = 50,
				/obj/item/clothing/under/costume/psyjump = 50,
				/obj/item/immortality_talisman = 50,
				/obj/item/clothing/mask/holo_cigar = 100,
				/obj/item/storage/box/syndie_kit/chameleon = 50, //costumes!
				/obj/item/storage/backpack/satchel_flat = 50,
				/obj/item/book_of_babel = 50,
				/obj/item/clothing/mask/whistle = 50
				)

/obj/effect/spawner/lootdrop/trade_sol/minerals
	name = "2. minerals"
	loot = list(
				// Common stuff you get from mining which isn't already present on the station
				// Note that plasma and derived hybrid materials are NOT included in this list because plasma is the trader's objective!
				/obj/item/stack/sheet/mineral/silver = 50,
				/obj/item/stack/sheet/mineral/gold = 50,
				/obj/item/stack/sheet/mineral/uranium = 50,
				/obj/item/stack/sheet/mineral/diamond = 50,
				/obj/item/stack/sheet/mineral/titanium = 50,
				/obj/item/stack/sheet/plasteel = 50,

				// Hybrid stuff you could in theory get from mining
				/obj/item/stack/sheet/titaniumglass = 50,

				// Rare stuff you can't get from mining
				/obj/item/stack/sheet/mineral/tranquillite = 50,
				/obj/item/stack/sheet/mineral/bananium = 50,
				/obj/item/stack/sheet/wood = 50,
				/obj/item/stack/sheet/plastic = 50,
				/obj/item/stack/sheet/mineral/sandstone = 50
				)

/obj/effect/spawner/lootdrop/trade_sol/minerals/Initialize(mapload)
	while(lootcount)
		var/lootspawn = pickweight(loot)
		loot -= lootspawn //We do this as the minerals will merge, and if duplicates roll they add one to the stack, instead of doubling.
		var/obj/item/stack/sheet/S = new lootspawn(get_turf(src))
		S.amount = 25
		lootcount--
	. = ..()

/obj/effect/spawner/lootdrop/trade_sol/donksoft
	name = "3. donksoft gear"
	loot = list(
				// Donksoft guns
				/obj/item/gun/projectile/automatic/c20r/toy = 50,
				/obj/item/gun/projectile/automatic/l6_saw/toy = 50,
				/obj/item/gun/projectile/automatic/toy/pistol = 100,
				/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 50,
				/obj/item/gun/projectile/shotgun/toy = 50,
				/obj/item/gun/projectile/shotgun/toy/crossbow = 50,
				/obj/item/gun/projectile/shotgun/toy/tommygun = 50,
				/obj/item/gun/projectile/automatic/sniper_rifle/toy = 50
				)


/obj/effect/spawner/lootdrop/trade_sol/sci
	name = "4. science gear"
	loot = list(
				// Robotics
				/obj/item/assembly/signaler/anomaly/random = 50, // anomaly core
				/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 25, // mecha x-ray laser
				/obj/item/mecha_parts/mecha_equipment/teleporter/precise = 25, // upgraded mecha teleporter
				/obj/item/autosurgeon/organ = 50,
				/obj/item/mod/construction/plating/research = 25,

				// Research / Experimentor
				/obj/item/paper/researchnotes = 125, // papers that give random R&D levels
				/obj/item/storage/box/telescience = 25, // Code green or blue. Probably not antags. People haven't touched it in ages. Let us see what happens.

				// Xenobio
				/obj/item/slimepotion/sentience = 50, // Low-value, but we want to encourage getting more players back in the round.
				/obj/item/slimepotion/transference = 50,

				// Might as well let AI be interested
				/obj/item/surveillance_upgrade = 25
				)

/obj/effect/spawner/lootdrop/trade_sol/med
	name = "5. medical gear"
	loot = list(
				// Medchem
				/obj/item/storage/pill_bottle/random_meds/labelled = 100, // random medical and other chems
				/obj/item/reagent_containers/glass/bottle/reagent/omnizine = 50,

				// Surgery
				/obj/item/organ/internal/heart/gland/ventcrawling = 50,
				/obj/item/organ/internal/heart/gland/heals = 50,

				// Genetics Research (should really be under science, but I was stuck for items to put in medical)
				/obj/item/dnainjector/regenerate = 50, // regeneration
				/obj/item/dnainjector/nobreath = 50,
				/obj/item/dnainjector/telemut = 50,

				// Medical in general
				/obj/item/mod/construction/plating/rescue = 25,
				/obj/item/gun/medbeam = 25, //Antags can see this to remove it if a threat, unlikely to happen with another midround
				/obj/item/bodyanalyzer = 25,
				/obj/item/circuitboard/sleeper/syndicate = 25
				)

/obj/effect/spawner/lootdrop/trade_sol/sec
	name = "6. security gear"
	loot = list(
				// Melee
				/obj/item/kitchen/knife/combat = 50,
				/obj/item/fluff/desolate_baton_kit = 50, // permission granted by Desolate to use their fluff kit in this loot table

				// Utility
				/obj/item/storage/belt/military/assault = 50,
				/obj/item/clothing/mask/gas/sechailer/swat = 50,
				/obj/item/clothing/glasses/thermal = 50, // see heat-source mobs through walls. Less powerful than already-available xray.
				/obj/item/mod/construction/plating/safeguard = 25,
				/obj/item/mod/module/power_kick = 50,
				/obj/item/storage/box/syndie_kit/camera_bug = 25, //Camera viewing on the go, planting cameras with detective work? Could be interesting!

				// Ranged weapons
				/obj/item/storage/box/enforcer_rubber = 50, //Lethal ammo can be printed at an autolathe, so no need for the lethal subtype
				/obj/item/gun/projectile/shotgun/automatic/dual_tube = 100, // cycler shotgun, not normally available to crew
				/obj/item/weaponcrafting/gunkit/universal_gun_kit/sol_gov = 50, //Weapon crafting, lets officers experiment however lets not have it be C class

				)

/obj/effect/spawner/lootdrop/trade_sol/eng
	name = "7. eng gear"
	lootcount = 8 //increased due to this pool being a bit more... niche?
	loot = list(
				/obj/item/storage/belt/utility/chief/full = 25,
				/obj/item/rcd/combat = 25,
				/obj/item/rpd/bluespace = 25,
				/obj/item/tank/internals/emergency_oxygen/double = 25,
				/obj/item/storage/backpack/holding = 25,
				/obj/item/clothing/glasses/meson/night = 25, // NV mesons
				/obj/item/clothing/glasses/material = 25, // shows objects, but not mobs, through walls
				/obj/item/mod/construction/plating/advanced = 25,
				/obj/item/mod/module/jetpack/advanced = 25,
				/obj/item/slimepotion/oil_slick = 25, //Suggested by discord, moderately common but not as common as most rnd things
				/obj/item/holosign_creator/atmos = 25
				)

/obj/effect/spawner/lootdrop/trade_sol/largeitem
	name = "8. largeitem"
	lootcount = 1
	loot = list(
				/obj/machinery/disco = 20,
				/obj/structure/spirit_board = 20,
				/obj/mecha/combat/durand/old = 20,
				/obj/machinery/snow_machine = 20,
				/obj/machinery/cooker/cerealmaker = 20
				)

/obj/effect/spawner/lootdrop/trade_sol/vehicle
	name = "9. vehicle"
	loot = list(
				/obj/vehicle/motorcycle = 50,
				/obj/vehicle/snowmobile = 50,
				/obj/vehicle/snowmobile/blue = 50,
				/obj/vehicle/space/speedbike/red = 50,
				/obj/vehicle/space/speedbike = 50
				)

/obj/effect/spawner/lootdrop/trade_sol/vehicle/Initialize(mapload)
	while(lootcount)
		var/lootspawn = pickweight(loot)
		var/obj/vehicle/V = new lootspawn(get_turf(src))
		if(V.key_type)
			V.inserted_key = new V.key_type(V)
		lootcount--
	. = ..()

/obj/effect/spawner/lootdrop/trade_sol/serv
	name = "10. service gear"
	loot = list(
				// Mining
				/obj/item/pickaxe/drill/jackhammer = 100,
				/obj/item/gun/energy/kinetic_accelerator/experimental = 100,
				/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs = 100,

				// Botanist
				/obj/item/storage/box/botany_labelled_seeds = 100,

				// Clown
				/obj/item/grenade/clusterbuster/honk = 100,
				/obj/item/bikehorn/golden = 100,
				/obj/item/gun/throw/piecannon = 100,

				// Bartender
				/obj/item/storage/box/bartender_rare_ingredients_kit = 100,

				// Chef
				/obj/item/storage/box/chef_rare_ingredients_kit = 100,
				/obj/item/mod/module/dispenser = 50, // Prints burgers. When you want to be space mcdonalds.
				// It would be nice to also have items for other service jobs: Mime, Librarian, Chaplain, etc

				// Chaplain
				/obj/structure/constructshell = 50 //Fuck it we ball what could go wrong
				)



/obj/effect/spawner/lootdrop/three_course_meal
	name = "three course meal spawner"
	lootcount = 3
	lootdoubles = FALSE
	var/soups = list(
			/obj/item/reagent_containers/food/snacks/soup/beetsoup,
			/obj/item/reagent_containers/food/snacks/soup/stew,
			/obj/item/reagent_containers/food/snacks/soup/hotchili,
			/obj/item/reagent_containers/food/snacks/soup/nettlesoup,
			/obj/item/reagent_containers/food/snacks/soup/meatballsoup)
	var/salads = list(
			/obj/item/reagent_containers/food/snacks/salad/herb,
			/obj/item/reagent_containers/food/snacks/salad/valid,
			/obj/item/reagent_containers/food/snacks/salad/aesir)
	var/mains = list(
			/obj/item/reagent_containers/food/snacks/enchiladas,
			/obj/item/reagent_containers/food/snacks/stewedsoymeat,
			/obj/item/reagent_containers/food/snacks/burger/bigbite,
			/obj/item/reagent_containers/food/snacks/burger/superbite)

/obj/effect/spawner/lootdrop/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()
