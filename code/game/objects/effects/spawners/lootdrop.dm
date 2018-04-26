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
				////////////////CONTRABAND STUFF//////////////////
				/obj/item/grenade/clown_grenade = 3,
				/obj/item/seeds/ambrosia/cruciatus = 3,
				/obj/item/gun/projectile/automatic/pistol/empty = 1,
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
				/obj/item/storage/belt/military = 2,
				/obj/item/storage/box/syndie_kit/space = 2,
				/obj/item/multitool/ai_detect = 2,
				/obj/item/implanter/storage = 1,
				/obj/item/toy/cards/deck/syndicate = 2,
				/obj/item/storage/secure/briefcase/syndie = 2,
				"" = 70
				)

/obj/effect/spawner/lootdrop/crate_spawner // for ruins
	name = "lootcrate spawner"
	lootdoubles = 0

	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80,
				)

/obj/effect/spawner/lootdrop/trade_sol_rare
	name = "trader rare item spawner"
	lootdoubles = 0
	color = "#00FFFF"

	loot = list(
				/obj/item/card/emag_broken = 2,
				/obj/item/defibrillator/compact/loaded = 2,
				/obj/item/gun/energy/laser/retro = 2,
				/obj/item/rcd/combat = 1,
				/obj/item/rcd = 2,
				)

/obj/effect/spawner/lootdrop/trade_sol_common
	name = "trader common item spawner"
	lootdoubles = 0
	color = "#00FFFF"

	loot = list(
				/obj/item/tank/anesthetic = 2,
				/obj/item/weldingtool/hugetank = 2,
				/obj/item/pickaxe/diamond = 1,
				/obj/item/spacepod_equipment/weaponry/mining_laser = 1,
				/obj/item/paicard = 2,
				/obj/item/gun/projectile/automatic/pistol = 2,
				/obj/item/megaphone = 2,
				/obj/item/stock_parts/capacitor = 1,
				/obj/item/stock_parts/cell/high = 1,
				/obj/item/stock_parts/manipulator = 1,
				/obj/item/stock_parts/matter_bin = 1,
				/obj/item/stock_parts/micro_laser = 1,
				/obj/item/stock_parts/scanning_module = 1,
				/obj/item/stack/spacecash/c200 = 1,
				/obj/item/airlock_electronics = 1,
				/obj/item/gun/energy/kinetic_accelerator = 1,
				/obj/item/pizzabox = 3,
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
