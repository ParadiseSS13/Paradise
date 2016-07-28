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
				/obj/item/weapon/gun/projectile/automatic/pistol = 8,
				/obj/item/weapon/gun/projectile/shotgun/automatic/combat = 5,
				/obj/item/weapon/gun/projectile/revolver/mateba,
				/obj/item/weapon/gun/projectile/automatic/pistol/deagle
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
				/obj/item/clothing/head/that{throwforce = 1; throwing = 1} = 10,
				/obj/item/clothing/head/ushanka = 10,
				/obj/item/clothing/head/welding = 10,
				/obj/item/clothing/mask/gas = 10,
				/obj/item/clothing/suit/storage/hazardvest = 10,
				/obj/item/clothing/under/rank/vice = 10,
				/obj/item/device/assembly/prox_sensor = 40,
				/obj/item/device/assembly/timer = 30,
				/obj/item/device/flashlight = 40,
				/obj/item/device/flashlight/pen = 10,
				/obj/item/device/multitool = 20,
				/obj/item/device/radio/off = 20,
				/obj/item/device/t_scanner = 60,
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
				/obj/item/weapon/book/manual/engineering_construction = 10,
				/obj/item/weapon/book/manual/engineering_hacking = 10,
				/obj/item/clothing/head/cone = 10,
				/obj/item/weapon/coin/silver = 10,
				/obj/item/weapon/coin/twoheaded = 10,
				/obj/item/weapon/contraband/poster = 10,
				/obj/item/weapon/crowbar = 10,
				/obj/item/weapon/crowbar/red = 10,
				/obj/item/weapon/extinguisher = 90,
				//obj/item/weapon/gun/projectile/revolver/russian = 1, //disabled until lootdrop is a proper world proc.
				/obj/item/weapon/hand_labeler = 10,
				/obj/item/weapon/paper/crumpled = 10,
				/obj/item/weapon/pen = 10,
				 /obj/item/weapon/minihoe = 10,
				/obj/item/weapon/plantspray/pests = 10,
				/obj/item/weapon/stock_parts/cell = 30,
				/obj/item/weapon/storage/belt/utility = 20,
				/obj/item/weapon/storage/box = 20,
				/obj/item/weapon/storage/box/cups = 10,
				/obj/item/weapon/storage/box/donkpockets = 10,
				/obj/item/weapon/storage/box/lights/mixed = 30,
				/obj/item/weapon/storage/fancy/cigarettes/dromedaryco = 10,
				/obj/item/weapon/storage/toolbox/mechanical = 10,
				/obj/item/weapon/screwdriver = 30,
				/obj/item/weapon/tank/emergency_oxygen = 20,
				/obj/item/weapon/tank/emergency_oxygen/engi = 10,
				/obj/item/weapon/vending_refill/cola = 10,
				/obj/item/weapon/weldingtool = 30,
				/obj/item/weapon/wirecutters = 10,
				/obj/item/weapon/wrench = 40,
				/obj/item/weapon/relic = 35,
				/obj/item/clothing/shoes/brown = 30,
				/obj/item/seeds/ambrosiadeusseed = 10,
				/obj/item/seeds/ambrosiavulgarisseed = 20,
				/obj/item/clothing/under/color/black = 30,
				/obj/item/stack/tape_roll = 10,
				////////////////CONTRABAND STUFF//////////////////
				/obj/item/weapon/grenade/clown_grenade = 3,
				/obj/item/seeds/ambrosiavulgarisseed/cruciatus = 3,
				/obj/item/weapon/gun/projectile/automatic/pistol/empty = 1,
				/obj/item/ammo_box/magazine/m10mm = 4,
				/obj/item/weapon/soap/syndie = 7,
				/obj/item/weapon/gun/syringe/syndicate = 2,
				/obj/item/weapon/suppressor = 4,
				/obj/item/clothing/under/chameleon = 2,
				/obj/item/weapon/stamp/chameleon = 2,
				/obj/item/clothing/shoes/syndigaloshes = 5,
				/obj/item/clothing/mask/gas/voice = 2,
				/obj/item/weapon/dnascrambler = 1,
				/obj/item/weapon/storage/backpack/satchel_flat = 2,
				/obj/item/weapon/storage/toolbox/syndicate = 2,
				/obj/item/weapon/storage/backpack/duffel/syndie/surgery_fake = 2,
				/obj/item/weapon/storage/belt/military = 2,
				/obj/item/weapon/storage/box/syndie_kit/space = 2,
				/obj/item/device/multitool/ai_detect = 2,
				/obj/item/weapon/implanter/storage = 1,
				/obj/item/toy/cards/deck/syndicate = 2,
				/obj/item/weapon/storage/secure/briefcase/syndie = 2,
				"" = 90
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
				/obj/item/weapon/card/emag_broken = 2,
				/obj/item/weapon/defibrillator/compact/loaded = 2,
				/obj/item/weapon/gun/energy/laser/retro = 2,
				/obj/item/weapon/rcd/combat = 1,
				/obj/item/weapon/rcd = 2,
				)

/obj/effect/spawner/lootdrop/trade_sol_common
	name = "trader common item spawner"
	lootdoubles = 0
	color = "#00FFFF"

	loot = list(
				/obj/item/weapon/tank/anesthetic = 2,
				/obj/item/weapon/weldingtool/hugetank = 2,
				/obj/item/weapon/pickaxe/diamond = 1,
				/obj/item/device/spacepod_equipment/weaponry/mining_laser = 1,
				/obj/item/device/paicard = 2,
				/obj/item/weapon/gun/projectile/automatic/pistol = 2,
				/obj/item/device/megaphone = 2,
				/obj/item/weapon/stock_parts/capacitor = 1,
				/obj/item/weapon/stock_parts/cell/high = 1,
				/obj/item/weapon/stock_parts/manipulator = 1,
				/obj/item/weapon/stock_parts/matter_bin = 1,
				/obj/item/weapon/stock_parts/micro_laser = 1,
				/obj/item/weapon/stock_parts/scanning_module = 1,
				/obj/item/weapon/spacecash/c200 = 1,
				/obj/item/weapon/airlock_electronics = 1,
				/obj/item/weapon/gun/energy/kinetic_accelerator/super = 1,
				/obj/item/pizzabox = 3,
				)
