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
				/obj/item/weapon/gun/projectile/shotgun/combat = 5,
				/obj/item/weapon/gun/projectile/revolver/mateba,
				/obj/item/weapon/gun/projectile/automatic/deagle
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
				/obj/item/bodybag = 1,
				/obj/item/clothing/glasses/meson = 2,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/clothing/gloves/color/yellow/fake = 1,
				/obj/item/clothing/head/hardhat = 1,
				/obj/item/clothing/head/hardhat/red = 1,
				/obj/item/clothing/head/that{throwforce = 1; throwing = 1} = 1,
				/obj/item/clothing/head/ushanka = 1,
				/obj/item/clothing/head/welding = 1,
				/obj/item/clothing/mask/gas = 10,
				/obj/item/clothing/suit/storage/hazardvest = 1,
				/obj/item/clothing/under/rank/vice = 1,
				/obj/item/device/assembly/prox_sensor = 4,
				/obj/item/device/assembly/timer = 3,
				/obj/random/tool = 4,
				/obj/item/device/flashlight/seclite = 1,
				/obj/item/device/flashlight/pen = 1,
				/obj/item/device/flashlight/flare = 4,
				/obj/item/device/multitool = 2,
				/obj/item/device/radio/off = 2,
				/obj/random/technology_scanner = 4,
				/obj/item/stack/cable_coil = 4,
				/obj/item/stack/cable_coil{amount = 5} = 6,
				/obj/item/stack/medical/advanced/bruise_pack = 1,
				/obj/item/stack/rods{amount = 10} = 9,
				/obj/item/stack/rods{amount = 23} = 1,
				/obj/item/stack/rods{amount = 50} = 1,
				/obj/item/stack/sheet/cardboard = 2,
				/obj/item/stack/sheet/metal{amount = 20} = 1,
				/obj/item/stack/sheet/mineral/plasma{layer = 2.9} = 1,
				/obj/item/stack/sheet/rglass = 1,
				/obj/item/weapon/book/manual/engineering_construction = 1,
				/obj/item/weapon/book/manual/engineering_hacking = 1,
				/obj/item/clothing/head/cone = 1,
				/obj/item/weapon/coin/silver = 1,
				/obj/item/weapon/coin/twoheaded = 1,
				/obj/item/weapon/contraband/poster = 1,
				/obj/item/weapon/crowbar = 1,
				/obj/item/weapon/crowbar/red = 1,
				/obj/item/weapon/extinguisher = 11,
				//obj/item/weapon/gun/projectile/revolver/russian = 1, //disabled until lootdrop is a proper world proc.
				/obj/item/weapon/hand_labeler = 1,
				/obj/item/weapon/paper/crumpled = 1,
				/obj/item/weapon/pen = 1,
				/obj/item/weapon/plantspray/pests = 1,
				/obj/item/weapon/stock_parts/cell = 3,
				/obj/item/weapon/storage/belt/utility = 2,
				/obj/item/weapon/storage/box = 2,
				/obj/item/weapon/storage/box/cups = 1,
				/obj/item/weapon/storage/box/donkpockets = 1,
				/obj/item/weapon/storage/box/lights/mixed = 3,
				/obj/item/weapon/storage/fancy/cigarettes/dromedaryco = 1,
				/obj/item/weapon/storage/toolbox/mechanical = 1,,
				/obj/item/weapon/tank/emergency_oxygen = 2,
				/obj/item/weapon/vending_refill/cola = 1,
//				/obj/item/weapon/relic = 3, //disabled until we add in the E.X.P.E.R.I-MENTOR,
				/obj/effect/decal/cleanable/random = 5,
				/obj/item/toy/random = 5,
				/obj/item/weapon/grenade/chem_grenade/dirt = 1,
				/obj/item/weapon/storage/pill_bottle/happy = 1,
				/obj/item/weapon/storage/pill_bottle/random_drug_bottle = 1,
				/obj/item/device/guitar = 1,
				/obj/item/candle = 3,
				/obj/item/trash/can = 5,
				/obj/item/trash/raisins = 5,
				/obj/item/trash/candy = 5,
				/obj/item/trash/cheesie = 5,
				/obj/item/trash/chips = 5,
				/obj/item/trash/popcorn = 5,
				/obj/item/trash/sosjerky = 5,
				/obj/item/trash/syndi_cakes = 3,
				/obj/item/trash/waffles = 4,
				/obj/item/trash/plate = 4,
				/obj/item/trash/snack_bowl = 4,
				/obj/item/trash/pistachios = 5,
				/obj/item/trash/semki = 5,
				/obj/item/trash/tray = 4,
				/obj/item/trash/candle = 3,
				/obj/item/trash/liquidfood = 3,
				/obj/item/trash/gum = 5,
				/obj/item/ammo_casing/c10mm = 5,
				/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink = 5,
				/obj/item/device/assembly/mousetrap/armed = 3,
				/obj/item/device/assembly/mousetrap = 4,
				/obj/item/clothing/gloves/ring/plastic/random = 2,
				/obj/item/weapon/reagent_containers/pill/methamphetamine = 2,
				/obj/item/weapon/reagent_containers/pill/zoom = 2,
				/obj/item/weapon/reagent_containers/pill/happy = 2,
				/obj/item/clothing/mask/pig = 1,
				/obj/item/clothing/head/hairflower = 1,
				/obj/item/clothing/head/cueball = 1,
				/obj/item/weapon/soap = 3,
				/obj/item/weapon/soap/nanotrasen = 2,
				/obj/item/weapon/soap/deluxe = 1,
				/obj/item/weapon/lipstick/random = 1,
				/obj/crate/fireworks = 1,
				/obj/item/weapon/card/emag_broken = 1,
				/obj/item/toy/balloon = 2,
				"" = 12
				)
