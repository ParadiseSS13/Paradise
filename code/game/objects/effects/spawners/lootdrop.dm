/obj/effect/spawner/lootdrop
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = 1		//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)

/obj/effect/spawner/lootdrop/New()
	if(loot && loot.len)
		for(var/i = lootcount, i > 0, i--)
			if(!loot.len) break
			var/lootspawn = pickweight(loot)
			if(!lootdoubles)
				loot.Remove(lootspawn)

			if(lootspawn)
				new lootspawn(get_turf(src))
	qdel(src)

/obj/effect/spawner/lootdrop/armory_contraband
	name = "armory contraband gun spawner"
	lootdoubles = 0

	loot = list(
				/obj/item/gun/projectile/automatic/pistol = 8,
				/obj/item/gun/projectile/shotgun/automatic/combat = 5,
				/obj/item/gun/projectile/revolver/mateba,
				/obj/item/gun/projectile/automatic/pistol/deagle
				)

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"

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
				/obj/item/clothing/under/rank/vice = 10,
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
				/obj/item/stack/rods{amount = 10} = 80,
				/obj/item/stack/rods{amount = 23} = 20,
				/obj/item/stack/rods{amount = 50} = 10,
				/obj/item/stack/sheet/cardboard = 20,
				/obj/item/stack/sheet/metal{amount = 20} = 10,
				/obj/item/stack/sheet/mineral/plasma{layer = 2.9} = 10,
				/obj/item/stack/sheet/rglass = 10,
				/obj/item/book/manual/engineering_construction = 10,
				/obj/item/book/manual/engineering_hacking = 10,
				/obj/item/clothing/head/cone = 10,
				/obj/item/coin/silver = 10,
				/obj/item/coin/twoheaded = 10,
				/obj/item/poster/random_contraband = 10,
				/obj/item/crowbar = 10,
				/obj/item/crowbar/red = 10,
				/obj/item/extinguisher = 90,
				//obj/item/gun/projectile/revolver/russian = 1, //disabled until lootdrop is a proper world proc.
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
				/obj/item/tank/emergency_oxygen = 20,
				/obj/item/tank/emergency_oxygen/engi = 10,
				/obj/item/vending_refill/cola = 10,
				/obj/item/weldingtool = 30,
				/obj/item/wirecutters = 10,
				/obj/item/wrench = 40,
				/obj/item/relic = 35,
				/obj/item/weaponcrafting/receiver = 2,
				/obj/item/clothing/shoes/brown = 30,
				/obj/item/seeds/ambrosia/deus = 10,
				/obj/item/seeds/ambrosia = 20,
				/obj/item/clothing/under/color/black = 30,
				/obj/item/stack/tape_roll = 10,
				/obj/item/storage/bag/plasticbag = 20,
				/obj/item/caution = 10,
				////////////////CONTRABAND STUFF//////////////////
				/obj/item/grenade/clown_grenade = 3,
				/obj/item/seeds/ambrosia/cruciatus = 3,
				/obj/item/gun/projectile/automatic/pistol = 1,
				/obj/item/ammo_box/magazine/m10mm = 4,
				/obj/item/soap/syndie = 7,
				/obj/item/gun/syringe/syndicate = 2,
				/obj/item/suppressor = 4,
				/obj/item/clothing/under/chameleon = 2,
				/obj/item/stamp/chameleon = 2,
				/obj/item/clothing/shoes/syndigaloshes = 5,
				/obj/item/clothing/mask/gas/voice = 2,
				/obj/item/dnascrambler = 1,
				/obj/item/storage/backpack/satchel_flat = 2,
				/obj/item/storage/toolbox/syndicate = 2,
				/obj/item/storage/backpack/duffel/syndie/surgery_fake = 2,
				/obj/item/storage/belt/military/traitor = 2,
				/obj/item/storage/box/syndie_kit/space = 2,
				/obj/item/multitool/ai_detect = 2,
				/obj/item/implanter/storage = 1,
				/obj/item/toy/cards/deck/syndicate = 2,
				/obj/item/storage/secure/briefcase/syndie = 2,
				/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 2,
				"" = 70
				)

/obj/effect/spawner/lootdrop/crate_spawner // for ruins
	name = "lootcrate spawner"
	lootdoubles = 0

	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80,
				)

/obj/effect/spawner/lootdrop/trade_sol/
	name = "trader item spawner"
	lootcount = 6
	lootdoubles = 1
	color = "#00FFFF"

/obj/effect/spawner/lootdrop/trade_sol/civ
	loot = list(
				// Donksoft guns
				/obj/item/gun/projectile/automatic/c20r/toy = 50,
				/obj/item/gun/projectile/automatic/l6_saw/toy = 50,
				/obj/item/gun/projectile/automatic/toy/pistol = 100,
				/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 50,
				/obj/item/gun/projectile/shotgun/toy = 50,
				/obj/item/gun/projectile/shotgun/toy/crossbow = 50,
				/obj/item/gun/projectile/shotgun/toy/tommygun = 50,

				// General utility gear
				/obj/item/storage/belt/utility/full/multitool = 150,
				/obj/item/clothing/gloves/color/yellow = 100,
				/obj/item/clothing/glasses/welding = 50,
				/obj/item/reagent_containers/spray/cleaner = 100,
				/obj/item/clothing/shoes/magboots = 50,
				)

/obj/effect/spawner/lootdrop/trade_sol/serv
	loot = list(
				// Mining
				/obj/item/mining_voucher = 100,
				/obj/item/pickaxe/drill/jackhammer = 100,

				// Bartender


				// Chef


				// Botanist


				// Librarian


				// Chaplain


				// Clown
				/obj/item/bikehorn/golden = 100,


				// Mime


				)

/obj/effect/spawner/lootdrop/trade_sol/minerals
	lootdoubles = 1
	loot = list(
				// Common stuff you get from mining which isn't already present on the station
				/obj/item/stack/sheet/mineral/silver = 50,
				/obj/item/stack/sheet/mineral/gold = 50,
				/obj/item/stack/sheet/mineral/plasma = 50,
				/obj/item/stack/sheet/mineral/uranium = 50,
				/obj/item/stack/sheet/mineral/diamond = 50,
				/obj/item/stack/sheet/mineral/titanium = 50,
				/obj/item/stack/sheet/plasteel = 50,

				// Hybrid stuff you could in theory get from mining
				/obj/item/stack/sheet/plasmaglass = 50,
				/obj/item/stack/sheet/plasmarglass = 50,
				/obj/item/stack/sheet/titaniumglass = 50,

				// Rare stuff you can't get from mining
				/obj/item/stack/sheet/mineral/tranquillite = 50,
				/obj/item/stack/sheet/mineral/bananium = 50,
				/obj/item/stack/sheet/wood = 50,
				/obj/item/stack/sheet/plastic = 50,
				/obj/item/stack/sheet/mineral/sandstone = 50,

				)

/obj/effect/spawner/lootdrop/trade_sol/minerals/New()
	if(loot && loot.len)
		for(var/i = lootcount, i > 0, i--)
			if(!loot.len)
				break
			var/lootspawn = pickweight(loot)
			if(!lootdoubles)
				loot.Remove(lootspawn)
			if(lootspawn)
				var/obj/item/stack/sheet/S = new lootspawn(get_turf(src))
				S.amount = 25
	qdel(src)

/obj/effect/spawner/lootdrop/trade_sol/sec
	loot = list(
				// Melee
				/obj/item/kitchen/knife/combat = 50,

				// Utility
				/obj/item/storage/belt/military/assault = 50,
				/obj/item/clothing/mask/gas/sechailer/swat = 50,

				// Ranged weapons
				/obj/item/gun/projectile/shotgun/automatic/combat = 50, // combat shotgun, between riot and bulldog in robustness. Not illegal, can be obtained from cargo.

				// Armor: need ideas for armor

				)

/obj/effect/spawner/lootdrop/trade_sol/sci
	loot = list(

				// Robotics
				/obj/item/mmi/robotic_brain = 50, // Low-value, but we want to encourage getting more players back in the round.
				/obj/item/assembly/signaler/anomaly = 50, // anomaly core
				/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 50, // mecha x-ray laser
				/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy = 50, // mecha heavy missile

				// Research / Experimentor
				/obj/item/relic = 150, // strange object
				/obj/item/paper/researchnotes = 150, // papers that give random R&D levels

				// Genetics Research
				/obj/item/dnainjector/xraymut = 50, // xray
				/obj/item/dnainjector/regenerate = 50, // regeneration
				/obj/item/dnainjector/nobreath = 50,
				/obj/item/dnainjector/remoteview = 50,
				/obj/item/dnainjector/midgit = 50,
				/obj/item/dnainjector/telemut = 50,

				// Xenobio
				/obj/item/slime_extract/rainbow = 50,
				/obj/item/slimepotion/sentience = 50, // Low-value, but we want to encourage getting more players back in the round.
				/obj/item/slimepotion/transference = 50,
				/obj/item/slimepotion/speed = 50,
				/obj/item/slimepotion/fireproof = 50,

				// Scichem
				//xenomicrobes - xeno transformation


				)

/obj/effect/spawner/lootdrop/trade_sol/med
	loot = list(
				// General medical tools
				///obj/item/defibrillator/compact/loaded = 50, // Theft objective.
				/obj/item/reagent_containers/hypospray/safety/ert = 50, // Contains omnizine, like CMO hypospray, but does not count for theft objective

				/obj/item/storage/pill_bottle/random_meds/labelled = 150, // random medical and other chems

				// Standard medicines
				/obj/item/reagent_containers/glass/bottle/reagent/omnizine = 50,
				/obj/item/reagent_containers/glass/bottle/reagent/strange_reagent = 50,

				// Virus cultures (basic heal,

				)


/obj/effect/spawner/lootdrop/trade_sol/eng
	loot = list(
				/obj/item/storage/belt/utility/chief/full = 25,
				/obj/item/rcd/combat = 25,
				/obj/item/rcd = 25
				)

/obj/effect/spawner/lootdrop/trade_sol/mech
	lootcount = 1
	loot = list(
				/obj/mecha/working/ripley = 20,
				/obj/mecha/working/ripley/firefighter = 20,
				/obj/mecha/medical/odysseus = 20
				)

/obj/effect/spawner/lootdrop/trade_sol/pets
	lootcount = 1
	loot = list(
				/obj/structure/closet/critter/corgi = 20,
				/obj/structure/closet/critter/goat = 20,
				/obj/structure/closet/critter/cat = 20,
				/obj/structure/closet/critter/fox = 20,
				/obj/structure/closet/critter/butterfly = 20
				)


/obj/effect/spawner/lootdrop/three_course_meal
	name = "three course meal spawner"
	lootcount = 3
	lootdoubles = FALSE
	var/soups = list(
			/obj/item/reagent_containers/food/snacks/beetsoup,
			/obj/item/reagent_containers/food/snacks/stew,
			/obj/item/reagent_containers/food/snacks/hotchili,
			/obj/item/reagent_containers/food/snacks/nettlesoup,
			/obj/item/reagent_containers/food/snacks/meatballsoup)
	var/salads = list(
			/obj/item/reagent_containers/food/snacks/herbsalad,
			/obj/item/reagent_containers/food/snacks/validsalad,
			/obj/item/reagent_containers/food/snacks/aesirsalad)
	var/mains = list(
			/obj/item/reagent_containers/food/snacks/enchiladas,
			/obj/item/reagent_containers/food/snacks/stewedsoymeat,
			/obj/item/reagent_containers/food/snacks/bigbiteburger,
			/obj/item/reagent_containers/food/snacks/superbiteburger)

/obj/effect/spawner/lootdrop/three_course_meal/New()
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()
