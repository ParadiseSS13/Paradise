/datum/crafting_recipe
	var/name = "" //in-game display name
	var/reqs[] = list() //type paths of items consumed associated with how many are needed
	var/result //type path of item resulting from this craft
	var/tools[] = list() //type paths of items needed but not consumed
	var/time = 30 //time in deciseconds
	var/parts[] = list() //type paths of items that will be placed in the result
	var/chem_catalists[] = list() //like tools but for reagents
	var/fruit[] = list()	//grown products required by the recipe
	var/category = CAT_MISC // Recipe category

/datum/crafting_recipe/proc/AdjustChems(var/obj/resultobj as obj)
	//This proc is to replace the make_food proc of recipes from microwaves and such that are being converted to table crafting recipes.
	//Use it to handle the removal of reagents after the food has been created (like removing toxins from a salad made with ambrosia)
	//If a recipe does not require it's chems adjusted, don't bother declaring this for the recipe, as it will call this placeholder
	return

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/weapon/grenade/iedcasing/filled
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/device/assembly/igniter = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans = 1)
	parts = list(/obj/item/weapon/reagent_containers/food/drinks/cans = 1)
	time = 15
	category = CAT_WEAPON

/datum/crafting_recipe/lance
	name = "explosive lance (grenade)"
	result = /obj/item/weapon/twohanded/spear
	reqs = list(/obj/item/weapon/twohanded/spear = 1,
				/obj/item/weapon/grenade = 1)
	parts = list(/obj/item/weapon/grenade = 1)
	time = 15
	category = CAT_WEAPON

/datum/crafting_recipe/molotov
	name = "Molotov"
	result = /obj/item/weapon/reagent_containers/food/drinks/bottle/molotov
	reqs = list(/obj/item/weapon/reagent_containers/glass/rag = 1,
				/obj/item/weapon/reagent_containers/food/drinks/bottle = 1)
	parts = list(/obj/item/weapon/reagent_containers/food/drinks/bottle = 1)
	time = 40
	category = CAT_WEAPON

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/weapon/melee/baton/cattleprod
	reqs = list(/obj/item/weapon/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/weapon/wirecutters = 1,
				/obj/item/weapon/stock_parts/cell = 1)
	time = 40
	parts = list(/obj/item/weapon/stock_parts/cell = 1)
	category = CAT_WEAPON

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/weapon/restraints/legcuffs/bola
	reqs = list(/obj/item/weapon/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20//15 faster than crafting them by hand!
	category= CAT_WEAPON

/datum/crafting_recipe/ed209
	name = "ED209"
	result = /mob/living/simple_animal/bot/ed209
	reqs = list(/obj/item/robot_parts/robot_suit = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/clothing/suit/armor/vest = 1,
				/obj/item/robot_parts/l_leg = 1,
				/obj/item/robot_parts/r_leg = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/weapon/gun/energy/gun/advtaser = 1,
				/obj/item/weapon/stock_parts/cell = 1,
				/obj/item/device/assembly/prox_sensor = 1)
	tools = list(/obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/secbot
	name = "Secbot"
	result = /mob/living/simple_animal/bot/secbot
	reqs = list(/obj/item/device/assembly/signaler = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/weapon/melee/baton = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/cleanbot
	name = "Cleanbot"
	result = /mob/living/simple_animal/bot/cleanbot
	reqs = list(/obj/item/weapon/reagent_containers/glass/bucket = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/floorbot
	name = "Floorbot"
	result = /mob/living/simple_animal/bot/floorbot
	reqs = list(/obj/item/weapon/storage/toolbox/mechanical = 1,
				/obj/item/stack/tile/plasteel = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/medbot
	name = "Medbot"
	result = /mob/living/simple_animal/bot/medbot
	reqs = list(/obj/item/device/healthanalyzer = 1,
				/obj/item/weapon/storage/firstaid = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result = /obj/item/weapon/flamethrower
	reqs = list(/obj/item/weapon/weldingtool = 1,
				/obj/item/device/assembly/igniter = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/device/assembly/igniter = 1,
				/obj/item/weapon/weldingtool = 1)
	tools = list(/obj/item/weapon/screwdriver)
	time = 10
	category = CAT_WEAPON

/datum/crafting_recipe/meteorshot
	name = "Meteorshot Shell"
	result = /obj/item/ammo_casing/shotgun/meteorshot
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/weapon/rcd_ammo = 1,
				/obj/item/weapon/stock_parts/manipulator = 2)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/weapon/stock_parts/capacitor/adv = 2,
				/obj/item/weapon/stock_parts/micro_laser/ultra = 1)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/phosphorus = 5,)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/frag12
	name = "FRAG-12 Shell"
	result = /obj/item/ammo_casing/shotgun/frag12
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/glycerol = 5,
				/datum/reagent/sacid = 5,
				/datum/reagent/facid = 5,)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = /obj/item/ammo_casing/shotgun/ion
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/weapon/stock_parts/micro_laser/ultra = 1,
				/obj/item/weapon/stock_parts/subspace/crystal = 1)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/improvisedslug
	name = "Improvised Shotgun Shell"
	result = /obj/item/ammo_casing/shotgun/improvised
	reqs = list(/obj/item/weapon/grenade/chem_grenade = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/fuel = 10)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/improvisedslugoverload
	name = "Overload Improvised Shell"
	result = /obj/item/ammo_casing/shotgun/improvised/overload
	reqs = list(/obj/item/ammo_casing/shotgun/improvised = 1,
				/datum/reagent/blackpowder = 10,
				/datum/reagent/plasma_dust = 20)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/laserslug
	name = "Laser Slug Shell"
	result = /obj/item/ammo_casing/shotgun/laserslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/weapon/stock_parts/capacitor/adv = 1,
				/obj/item/weapon/stock_parts/micro_laser/high = 1)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5
	category = CAT_AMMO

/datum/crafting_recipe/ishotgun
	name = "Improvised Shotgun"
	result = /obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/packageWrap = 5,)
	tools = list(/obj/item/weapon/screwdriver)
	time = 100
	category = CAT_WEAPON

/datum/crafting_recipe/chainsaw
	name = "Chainsaw"
	result = /obj/item/weapon/twohanded/required/chainsaw
	reqs = list(/obj/item/weapon/circular_saw = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/plasteel = 1)
	tools = list(/obj/item/weapon/weldingtool)
	time = 50
	category = CAT_WEAPON

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/weapon/twohanded/spear
	reqs = list(/obj/item/weapon/restraints/handcuffs/cable = 1,
				/obj/item/weapon/shard = 1,
				/obj/item/stack/rods = 1)
	time = 40
	category = CAT_WEAPON

/datum/crafting_recipe/spooky_camera
	name = "Camera Obscura"
	result = /obj/item/device/camera/spooky
	time = 15
	reqs = list(/obj/item/device/camera = 1,
				/datum/reagent/holywater = 10)
	parts = list(/obj/item/device/camera = 1)

/datum/crafting_recipe/papersack
	name = "Paper Sack"
	result = /obj/item/weapon/storage/box/papersack
	time = 10
	reqs = list(/obj/item/weapon/paper = 5)
	category = CAT_MISC

/datum/crafting_recipe/notreallysoap
	name = "Homemade Soap"
	result = /obj/item/weapon/soap/ducttape
	time = 50
	reqs = list(/obj/item/stack/tape_roll = 1,
				/datum/reagent/liquidgibs = 10)

/datum/crafting_recipe/garrote
	name = "Makeshift Garrote"
	result = /obj/item/weapon/twohanded/garrote/improvised
	time = 15
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/stack/cable_coil = 5)
	tools = list(/obj/item/weapon/kitchen/knife) // Gotta carve the wood into handles
	category = CAT_WEAPON

/datum/crafting_recipe/makeshift_bolt
	name = "Makeshift Bolt"
	result = /obj/item/weapon/arrow/rod
	time = 5
	reqs = list(/obj/item/stack/rods = 1)
	tools = list(/obj/item/weapon/weldingtool)
	category = CAT_AMMO

/datum/crafting_recipe/crossbow
	name = "Powered Crossbow"
	result = /obj/item/weapon/gun/throw/crossbow
	time = 150
	reqs = list(/obj/item/stack/rods = 3,
				/obj/item/stack/cable_coil = 10,
				/obj/item/stack/sheet/mineral/plastic = 3,
				/obj/item/stack/sheet/wood = 5)
	tools = list(/obj/item/weapon/weldingtool,
				/obj/item/weapon/screwdriver)
	category = CAT_WEAPON

/datum/crafting_recipe/glove_balloon
	name = "Latex Glove Balloon"
	result = /obj/item/latexballon
	time = 15
	reqs = list(/obj/item/clothing/gloves/color/latex = 1,
				/obj/item/stack/cable_coil = 5)

/datum/crafting_recipe/gold_horn
	name = "Golden bike horn"
	result = /obj/item/weapon/bikehorn/golden
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/bananium = 5,
				/obj/item/weapon/bikehorn)
	category = CAT_MISC