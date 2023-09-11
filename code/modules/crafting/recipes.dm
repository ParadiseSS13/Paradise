/datum/crafting_recipe
	/// In-game display name.
	var/name = ""
	/// Type paths of items consumed associated with how many are needed.
	var/list/reqs = list()
	/// Type paths of items explicitly not allowed as an ingredient.
	var/list/blacklist = list()
	/// Type paths of item(s) resulting from this craft.
	var/list/result = list()
	/// Tool behaviours of items needed but not consumed.
	var/list/tools = list()
	/// Type paths of items needed but not consumed.
	var/list/pathtools = list()
	/// Crafting time in deciseconds.
	var/time = 30
	/// Type paths of items that will be placed inside the result.
	var/list/parts = list()
	var/list/chem_catalysts = list() //like tools but for reagents
	/// What category it's shown under in the crafting UI.
	var/category = CAT_NONE
	/// What subcategory it's shown under in the crafting UI. (e.g 'Ammo' under 'Weapons')
	var/subcategory = CAT_NONE
	/// Is this recipe always available, or does it need to be learned first.
	var/always_availible = TRUE
	/// Will this recipe send an admin message when it's completed.
	var/alert_admins_on_craft = FALSE

/datum/crafting_recipe/IED
	name = "IED"
	result = list(/obj/item/grenade/iedcasing)
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/reagent_containers/food/drinks/cans = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/cans = 1)
	time = 15
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/molotov
	name = "Molotov"
	result = list(/obj/item/reagent_containers/food/drinks/bottle/molotov)
	reqs = list(/obj/item/reagent_containers/glass/rag = 1,
				/obj/item/reagent_containers/food/drinks/bottle = 1)
	blacklist = list(/obj/item/reagent_containers/food/drinks/bottle/molotov)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = list(/obj/item/melee/baton/cattleprod)
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/assembly/igniter = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bola
	name = "Bola"
	result = list(/obj/item/restraints/legcuffs/bola)
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20//15 faster than crafting them by hand!
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/advancedegun
	name = "Advanced Energy Gun"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/gun/nuclear)
	reqs = list(/obj/item/gun/energy/gun = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/nuclear = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/advancedegun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/gun)

/datum/crafting_recipe/tempgun
	name = "Temperature Gun"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/temperature)
	reqs = list(/obj/item/gun/energy/gun = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/temperature = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/tempgun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/gun)

/datum/crafting_recipe/decloner
	name = "Biological Demolecularisor"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/decloner)
	reqs = list(/obj/item/gun/energy/gun = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/decloner = 1,
				/datum/reagent/mutagen = 40)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/decloner/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/gun)

/datum/crafting_recipe/ioncarbine
	name = "Ion Carbine"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/ionrifle/carbine)
	reqs = list(/obj/item/gun/energy/gun = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/ion = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/ioncarbine/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/gun)

/datum/crafting_recipe/ebow
	name = "Energy Crossbow"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/kinetic_accelerator/crossbow/large)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/ebow = 1,
				/datum/reagent/radium = 15)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/ebow/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/xraylaser
	name = "X-ray Laser Gun"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/xray)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/xray = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/xraylaser/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/immolator
	name = "Immolator Laser Gun"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/immolator)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/immolator = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/immolator/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/plasma
	name = "Plasma Pistol"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/plasma_pistol)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/plasma = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/plasma/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/teslarevolver
	name = "Arc Revolver"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/arc_revolver)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/tesla = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/teslarevolver/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/accelerator
	name = "Accelerator Laser Cannon"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/lasercannon)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/accelerator = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/accelerator/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/lwap
	name = "LWAP Laser Sniper"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/lwap)
	reqs = list(/obj/item/gun/energy/laser = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/lwap = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/lwap/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/silencer
	name = "u-ION Silencer"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/gun/energy/disabler/silencer)
	reqs = list(/obj/item/gun/energy/disabler = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weaponcrafting/gunkit/u_ionsilencer = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/silencer/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/disabler)

/datum/crafting_recipe/ed209
	name = "ED209"
	result = list(/mob/living/simple_animal/bot/ed209)
	reqs = list(/obj/item/robot_parts/robot_suit = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/clothing/suit/armor/vest = 1,
				/obj/item/robot_parts/l_leg = 1,
				/obj/item/robot_parts/r_leg = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/gun/energy/disabler = 1,
				/obj/item/stock_parts/cell = 1,
				/obj/item/assembly/prox_sensor = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/secbot
	name = "Secbot"
	result = list(/mob/living/simple_animal/bot/secbot)
	reqs = list(/obj/item/assembly/signaler = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/melee/baton = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	tools = list(TOOL_WELDER)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/griefsky
	name = "General Griefsky"
	result = list(/mob/living/simple_animal/bot/secbot/griefsky)
	reqs = list(/obj/item/assembly/signaler = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/melee/energy/sword = 4,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 2,
				/obj/item/robot_parts/l_arm = 2)
	tools = list(TOOL_WELDER)
	time = 120
	category = CAT_ROBOT
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/cleanbot
	name = "Cleanbot"
	result = list(/mob/living/simple_animal/bot/cleanbot)
	reqs = list(/obj/item/reagent_containers/glass/bucket = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/honkbot
	name = "Honkbot"
	result = list(/mob/living/simple_animal/bot/honkbot)
	reqs = list(/obj/item/robot_parts/r_arm = 1,
				/obj/item/bikehorn = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/storage/box/clown = 1,
				/obj/item/instrument/trombone  = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/floorbot
	name = "Floorbot"
	result = list(/mob/living/simple_animal/bot/floorbot)
	reqs = list(/obj/item/storage/toolbox = 1,
				/obj/item/stack/tile/plasteel = 10,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/medbot
	name = "Medbot"
	result = list(/mob/living/simple_animal/bot/medbot)
	reqs = list(/obj/item/healthanalyzer = 1,
				/obj/item/storage/firstaid = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result = list(/obj/item/flamethrower)
	reqs = list(/obj/item/weldingtool = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/assembly/igniter = 1,
				/obj/item/weldingtool = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 10
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = list(/obj/item/ammo_casing/shotgun/pulseslug)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 2,
				/obj/item/stock_parts/micro_laser/ultra = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = list(/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/phosphorus = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/frag12
	name = "FRAG-12 Shell"
	result = list(/obj/item/ammo_casing/shotgun/frag12)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/glycerol = 5,
				/datum/reagent/acid = 5,
				/datum/reagent/acid/facid = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = list(/obj/item/ammo_casing/shotgun/ion)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/micro_laser/ultra = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/improvisedslug
	name = "Improvised Shotgun Shell"
	result = list(/obj/item/ammo_casing/shotgun/improvised)
	reqs = list(/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/fuel = 10)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/improvisedslugoverload
	name = "Overload Improvised Shell"
	result = list(/obj/item/ammo_casing/shotgun/improvised/overload)
	reqs = list(/obj/item/ammo_casing/shotgun/improvised = 1,
				/datum/reagent/blackpowder = 10,
				/datum/reagent/plasma_dust = 20)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/lasershot
	name = "Lasershot Shell"
	result = list(/obj/item/ammo_casing/shotgun/lasershot)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 1,
				/obj/item/stock_parts/micro_laser/high = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/confettishot
	name = "Confetti Shot"
	result = list(/obj/item/ammo_casing/shotgun/confetti)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/confetti = 10)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ishotgun
	name = "Improvised Shotgun"
	result = list(/obj/item/gun/projectile/revolver/doublebarrel/improvised)
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/packageWrap = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/chainsaw
	name = "Chainsaw"
	result = list(/obj/item/chainsaw)
	reqs = list(/obj/item/circular_saw = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/plasteel = 1)
	tools = list(TOOL_WELDER)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/spear
	name = "Spear"
	result = list(/obj/item/spear)
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/shard = 1,
				/obj/item/stack/rods = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/spooky_camera
	name = "Camera Obscura"
	result = list(/obj/item/camera/spooky)
	time = 15
	reqs = list(/obj/item/camera = 1,
				/datum/reagent/holywater = 10)
	parts = list(/obj/item/camera = 1)
	category = CAT_MISC

/datum/crafting_recipe/papersack
	name = "Paper Sack"
	result = list(/obj/item/storage/box/papersack)
	time = 10
	reqs = list(/obj/item/paper = 5)
	category = CAT_MISC

/datum/crafting_recipe/donk_box
	name = "Donk Pocket Box"
	result = list(/obj/item/storage/box/donkpockets/empty)
	time = 10
	reqs = list(/obj/item/storage/box = 1,
				/obj/item/stack/sheet/plastic = 1,
				/obj/item/stack/sheet/metal = 1)
	category = CAT_MISC

/datum/crafting_recipe/flashlight_eyes
	name = "Flashlight Eyes"
	result = list(/obj/item/organ/internal/eyes/cybernetic/flashlight)
	time = 10
	reqs = list(/obj/item/flashlight = 2,
				/obj/item/restraints/handcuffs/cable = 1)
	category = CAT_MISC

/datum/crafting_recipe/sushimat
	name = "Sushi Mat"
	result = list(/obj/item/kitchen/sushimat)
	time = 10
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/stack/cable_coil = 2)
	category = CAT_MISC

/datum/crafting_recipe/notreallysoap
	name = "Homemade Soap"
	result = list(/obj/item/soap/ducttape)
	time = 50
	reqs = list(/obj/item/stack/tape_roll = 1,
				/datum/reagent/liquidgibs = 10)
	category = CAT_MISC

/datum/crafting_recipe/garrote
	name = "Makeshift Garrote"
	result = list(/obj/item/garrote/improvised)
	time = 15
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/stack/cable_coil = 5)
	pathtools = list(/obj/item/kitchen/knife) // Gotta carve the wood into handles
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/makeshift_bolt
	name = "Makeshift Bolt"
	result = list(/obj/item/arrow/rod)
	time = 5
	reqs = list(/obj/item/stack/rods = 1)
	tools = list(TOOL_WELDER)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/crossbow
	name = "Powered Crossbow"
	result = list(/obj/item/gun/throw/crossbow)
	time = 150
	reqs = list(/obj/item/stack/rods = 3,
				/obj/item/stack/cable_coil = 10,
				/obj/item/stack/sheet/plastic = 3,
				/obj/item/stack/sheet/wood = 5)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/glove_balloon
	name = "Latex Glove Balloon"
	result = list(/obj/item/latexballon)
	time = 15
	reqs = list(/obj/item/clothing/gloves/color/latex = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_MISC

/datum/crafting_recipe/gold_horn
	name = "Golden bike horn"
	result = list(/obj/item/bikehorn/golden)
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/bananium = 5,
				/obj/item/bikehorn = 1)
	category = CAT_MISC

/datum/crafting_recipe/sad_trombone
	name = "Sad trombone"
	result = list(/obj/item/instrument/trombone/sad)
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/bananium = 5)
	category = CAT_MISC

/datum/crafting_recipe/blackcarpet
	name = "Black Carpet"
	result = list(/obj/item/stack/tile/carpet/black)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/black)
	category = CAT_MISC

/datum/crafting_recipe/bluecarpet
	name = "Blue Carpet"
	result = list(/obj/item/stack/tile/carpet/blue)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/blue)
	category = CAT_MISC

/datum/crafting_recipe/cyancarpet
	name = "Cyan Carpet"
	result = list(/obj/item/stack/tile/carpet/cyan)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/blue, /obj/item/toy/crayon/green)
	category = CAT_MISC

/datum/crafting_recipe/greencarpet
	name = "Green Carpet"
	result = list(/obj/item/stack/tile/carpet/green)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/green)
	category = CAT_MISC

/datum/crafting_recipe/orangecarpet
	name = "Orange Carpet"
	result = list(/obj/item/stack/tile/carpet/orange)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/orange)
	category = CAT_MISC

/datum/crafting_recipe/purplecarpet
	name = "Purple Carpet"
	result = list(/obj/item/stack/tile/carpet/purple)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/purple)
	category = CAT_MISC

/datum/crafting_recipe/redcarpet
	name = "Red Carpet"
	result = list(/obj/item/stack/tile/carpet/red)
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_MISC

/datum/crafting_recipe/royalblackcarpet
	name = "Royal Black Carpet"
	result = list(/obj/item/stack/tile/carpet/royalblack/ten)
	time = 20
	reqs = list(/obj/item/stack/tile/carpet/black = 10,
				/obj/item/stack/sheet/mineral/gold = 1)
	category = CAT_MISC

/datum/crafting_recipe/royalbluecarpet
	name = "Royal Blue Carpet"
	result = list(/obj/item/stack/tile/carpet/royalblue/ten)
	time = 20
	reqs = list(/obj/item/stack/tile/carpet/blue = 10,
				/obj/item/stack/sheet/mineral/gold = 1)
	category = CAT_MISC

/datum/crafting_recipe/showercurtain
	name = "Shower Curtains"
	result = list(/obj/structure/curtain)
	time = 20
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/plastic = 2,
				/obj/item/stack/rods = 1)
	category = CAT_MISC

/datum/crafting_recipe/chemical_payload
	name = "Chemical Payload (C4)"
	result = list(/obj/item/bombcore/chemical)
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 30
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/chemical_payload2
	name = "Chemical Payload (gibtonite)"
	result = list(/obj/item/bombcore/chemical)
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/gibtonite = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/toxins_payload
	name = "Toxins Payload Casing"
	result = list(/obj/item/bombcore/toxins)
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/stack/sheet/metal = 2
	)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bonearmor
	name = "Bone Armor"
	result = list(/obj/item/clothing/suit/armor/bone)
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 6)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonetalisman
	name = "Bone Talisman"
	result = list(/obj/item/clothing/accessory/necklace/talisman)
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonecodpiece
	name = "Skull Codpiece"
	result = list(/obj/item/clothing/accessory/necklace/skullcodpiece)
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bracers
	name = "Bone Bracers"
	result = list(/obj/item/clothing/gloves/bracer)
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/skullhelm
	name = "Skull Helmet"
	result = list(/obj/item/clothing/head/helmet/skull)
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliathcloak
	name = "Goliath Cloak"
	result = list(/obj/item/clothing/suit/hooded/goliath)
	time = 50
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/drakecloak
	name = "Ash Drake Armour"
	result = list(/obj/item/clothing/suit/hooded/drake)
	time = 60
	reqs = list(/obj/item/stack/sheet/bone = 10,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/ashdrake = 5)
	category = CAT_PRIMAL

/datum/crafting_recipe/firebrand
	name = "Firebrand"
	result = list(/obj/item/match/firebrand)
	time = 100 //Long construction time. Making fire is hard work.
	reqs = list(/obj/item/stack/sheet/wood = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/tribal_splint
	name = "Tribal Splint"
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 1)
	result = list(/obj/item/stack/medical/splint/tribal)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonedagger
	name = "Bone Dagger"
	result = list(/obj/item/kitchen/knife/combat/survival/bone)
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonespear
	name = "Bone Spear"
	result = list(/obj/item/spear/bonespear)
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4,
				/obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonepickaxe
	name = "Bone Pickaxe"
	result = list(/obj/item/pickaxe/bone)
	time = 40
	reqs = list(/obj/item/stack/sheet/bone = 4,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonescythe
	name = "Bone Scythe"
	result = list(/obj/item/scythe/bone)
	time = 40
	reqs = list(/obj/item/stack/sheet/bone = 5,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/boneaxe
	name = "Bone Axe"
	result = list(/obj/item/fireaxe/boneaxe)
	time = 50
	reqs = list(/obj/item/stack/sheet/bone = 6,
				/obj/item/stack/sheet/sinew = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonfire
	name = "Bonfire"
	time = 60
	reqs = list(/obj/item/grown/log = 5)
	result = list(/obj/structure/bonfire)
	category = CAT_PRIMAL
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/rake //Category resorting incoming
	name = "Rake"
	time = 30
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = list(/obj/item/cultivator/rake)
	category = CAT_PRIMAL

/datum/crafting_recipe/woodbucket
	name = "Wooden Bucket"
	time = 30
	reqs = list(/obj/item/stack/sheet/wood = 3)
	result = list(/obj/item/reagent_containers/glass/bucket/wooden)
	category = CAT_PRIMAL

/datum/crafting_recipe/guillotine
	name = "Guillotine"
	result = list(/obj/structure/guillotine)
	time = 150 // Building a functioning guillotine takes time
	reqs = list(/obj/item/stack/sheet/plasteel = 3,
				/obj/item/stack/sheet/wood = 20,
				/obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_MISC

/datum/crafting_recipe/ghettojetpack
	name = "Improvised Jetpack"
	result = list(/obj/item/tank/jetpack/improvised)
	time = 30
	reqs = list(/obj/item/tank/internals/oxygen = 2, /obj/item/extinguisher = 1, /obj/item/pipe = 3, /obj/item/stack/cable_coil = MAXCOIL)
	category = CAT_MISC
	tools = list(TOOL_WRENCH, TOOL_WELDER, TOOL_WIRECUTTER)

/datum/crafting_recipe/drill
	name = "Thermal Drill"
	result = list(/obj/item/thermal_drill)
	time = 60
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/mecha_parts/mecha_equipment/drill = 1,
				/obj/item/stock_parts/cell = 1,
				/obj/item/stack/rods = 2,
				/obj/item/assembly/timer = 1)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

/datum/crafting_recipe/d_drill
	name = "Diamond Tipped Thermal Drill"
	result = list(/obj/item/thermal_drill/diamond_drill)
	time = 60
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 1,
				/obj/item/stock_parts/cell = 1,
				/obj/item/stack/rods = 2,
				/obj/item/assembly/prox_sensor = 1) // Not a timer because the system sees a diamond drill as a drill too, letting you make both otherwise.
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

/datum/crafting_recipe/faketoolbox
	name = "Black and Red toolbox"
	result = list(/obj/item/storage/toolbox/fakesyndi)
	time = 40
	reqs = list(/datum/reagent/paint/red = 10,
				/datum/reagent/paint/black = 30,
				/obj/item/storage/toolbox = 1) //Paint in reagents so it doesnt take the container up, yet still take it from the beaker
	pathtools = list(/obj/item/reagent_containers/glass/rag = 1) //need something to paint with it
	category = CAT_MISC

/datum/crafting_recipe/snowman
	name = "Snowman"
	result = list(/obj/structure/snowman/built)
	reqs = list(/obj/item/snowball = 10,
				/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
				/obj/item/grown/log = 2)
	time = 50
	category = CAT_MISC
	always_availible = FALSE

/datum/crafting_recipe/paper_craft
	name = "Paper Heart"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/heart)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 1)
	tools = list(TOOL_WIRECUTTER) //cutters act as makeshift scissors. I doubt the barber wants to have their scissors stolen when somone wants to decorate
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/single_eye
	name = "Paper Eye"
	result = list(/obj/item/decorations/sticky_decorations/flammable/singleeye)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen, /obj/item/toy/crayon/blue)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/googlyeyes
	name = "Paper Googly Eye"
	result = list(/obj/item/decorations/sticky_decorations/flammable/googlyeyes)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/clock
	name = "Paper Clock"
	result = list(/obj/item/decorations/sticky_decorations/flammable/paperclock)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/jack_o_lantern
	name = "Paper Jack o'Lantern"
	result = list(/obj/item/decorations/sticky_decorations/flammable/jack_o_lantern)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/orange,
					/obj/item/toy/crayon/green)//pen ink is black
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/ghost
	name = "Paper Ghost"
	result = list(/obj/item/decorations/sticky_decorations/flammable/ghost)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)//it's white paper why need a white crayon?
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/spider
	name = "Paper Spider"
	result = list(/obj/item/decorations/sticky_decorations/flammable/spider)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/spiderweb
	name = "Paper Spiderweb"
	result = list(/obj/item/decorations/sticky_decorations/flammable/spiderweb)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list()
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/skull
	name = "Paper Skull"
	result = list(/obj/item/decorations/sticky_decorations/flammable/skull)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/skeleton
	name = "Paper Skeleton"
	result = list(/obj/item/decorations/sticky_decorations/flammable/skeleton)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/cauldron
	name = "Paper Cauldron"
	result = list(/obj/item/decorations/sticky_decorations/flammable/cauldron)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/snowman
	name = "Paper Snowman"
	result = list(/obj/item/decorations/sticky_decorations/flammable/snowman)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/christmas_stocking
	name = "Paper Christmas Stocking"
	result = list(/obj/item/decorations/sticky_decorations/flammable/christmas_stocking)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/christmas_tree
	name = "Paper Christmas Tree"
	result = list(/obj/item/decorations/sticky_decorations/flammable/christmas_tree)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red,
					/obj/item/toy/crayon/yellow,
					/obj/item/toy/crayon/blue,
					/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/snowflake
	name = "Paper Snowflake"
	result = list(/obj/item/decorations/sticky_decorations/flammable/snowflake)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list()
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/candy_cane
	name = "Paper Candy Cane"
	result = list(/obj/item/decorations/sticky_decorations/flammable/candy_cane)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/mistletoe
	name = "Paper Mistletoe"
	result = list(/obj/item/decorations/sticky_decorations/flammable/mistletoe)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red,
					/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/holly
	name = "Paper Holly"
	result = list(/obj/item/decorations/sticky_decorations/flammable/holly)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red,
					/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_white
	name = "Paper Tinsel White"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list()
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_red
	name = "Red Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/red)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_blue
	name = "Blue Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/blue)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/blue)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_yellow
	name = "Yellow Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/yellow)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/yellow)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_purple
	name = "Purple Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/purple)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_green
	name = "Green Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/green)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_orange
	name = "Orange Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/orange)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_black
	name = "Black Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/black)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_halloween
	name = "Halloween style Paper Tinsel"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/tinsel/halloween)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/arrowed_heart
	name = "Paper Arrowed Heart"
	result = list(/obj/item/decorations/sticky_decorations/flammable/arrowed_heart)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/heart_chain
	name = "Paper Heart Chain"
	result = list(/obj/item/decorations/sticky_decorations/flammable/heart_chain)
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2,
				/obj/item/stack/cable_coil = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/four_leaf_clover
	name = "Paper Four Leaf Clover"
	result = list(/obj/item/decorations/sticky_decorations/flammable/four_leaf_clover)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/pot_of_gold
	name = "Paper Pot of Gold"
	result = list(/obj/item/decorations/sticky_decorations/flammable/pot_of_gold)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/red,
				/obj/item/toy/crayon/yellow,
				/obj/item/toy/crayon/orange,
				/obj/item/toy/crayon/green,
				/obj/item/toy/crayon/blue,
				/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/leprechaun_hat
	name = "Paper Leprechaun Hat"
	time = 10
	result = list(/obj/item/decorations/sticky_decorations/flammable/leprechaun_hat)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/yellow,
				/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_bunny
	name = "Paper Easter Bunny"
	result = list(/obj/item/decorations/sticky_decorations/flammable/easter_bunny)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/blue,
				/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_blue
	name = "Blue Paper Easter Egg"
	result = list(/obj/item/decorations/sticky_decorations/flammable/easter_egg)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/blue)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_yellow
	name = "Yellow Paper Easter Egg"
	result = list(/obj/item/decorations/sticky_decorations/flammable/easter_egg/yellow)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/yellow)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_red
	name = "Red Paper Easter Egg"
	result = list(/obj/item/decorations/sticky_decorations/flammable/easter_egg/red)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_purple
	name = "Purple Paper Easter Egg"
	result = list(/obj/item/decorations/sticky_decorations/flammable/easter_egg/purple)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_orange
	name = "Orange Paper Easter Egg"
	result = list(/obj/item/decorations/sticky_decorations/flammable/easter_egg/orange)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/metal_angel_statue
	name = "Metal angel statue"
	time = 50
	result = list(/obj/structure/decorative_structures/metal/statue/metal_angel)
	reqs = list(/obj/item/stack/sheet/metal = 10,
				/obj/item/stack/sheet/mineral/gold = 6)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/golden_disk_statue
	name = "Golden disk statue"
	time = 50
	result = list(/obj/structure/decorative_structures/metal/statue/golden_disk)
	reqs = list(/obj/item/stack/sheet/metal = 10,
				/obj/item/stack/sheet/mineral/plasma = 3,
				/obj/item/stack/sheet/mineral/gold = 8)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/sun_statue
	name = "Sun statue"
	time = 40
	result = list(/obj/structure/decorative_structures/metal/statue/sun)
	reqs = list(/obj/item/stack/sheet/metal = 6,
				/obj/item/stack/sheet/mineral/gold = 4)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/moon_statue
	name = "Moon statue"
	time = 50
	result = list(/obj/structure/decorative_structures/metal/statue/moon)
	reqs = list(/obj/item/stack/sheet/metal = 6,
				/obj/item/stack/sheet/mineral/silver = 6,
				/obj/item/stack/sheet/mineral/gold = 4)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/tesla_statue
	name = "Tesla statue"
	time = 40
	result = list(/obj/structure/decorative_structures/metal/statue/tesla)
	reqs = list(/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/sheet/glass = 8)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/tesla_monument
	name = "Tesla monument"
	time = 50
	result = list(/obj/structure/decorative_structures/metal/statue/tesla_monument)
	reqs = list(/obj/item/stack/sheet/metal = 8,
				/obj/item/stock_parts/cell = 3,
				/obj/item/stack/cable_coil = 4)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/grandfather_clock
	name = "Grandfather clock"
	time = 50
	result = list(/obj/structure/decorative_structures/flammable/grandfather_clock)
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/sheet/mineral/gold = 1,
				/obj/item/stack/sheet/glass = 2)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/lava_land_display
	name = "Lava land display"
	time = 50
	result = list(/obj/structure/decorative_structures/flammable/lava_land_display)
	reqs = list(/obj/item/paper = 4,
				/obj/item/stack/sheet/wood = 4,
				/obj/item/stack/rods = 4,
				/obj/item/stock_parts/cell = 1,
				/obj/item/stack/cable_coil = 4)//thing is a wireframe construct with an electro magnetic hover field
	tools = list(TOOL_WIRECUTTER,
				TOOL_WELDER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS
