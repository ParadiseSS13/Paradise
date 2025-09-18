/* CONTENTS:
 *	1. GLASS
 *	2. REINFORCED GLASS
 *	3. PLASMA GLASS
 *	4. REINFORCED PLASMA GLASS
 *	5. TITANIUM GLASS
 *	6. PLASTITANIUM GLASS

 Todo: Create a unified construct_window(sheet, user, created_window, full_window)

 */

//////////////////////////////
// MARK: GLASS
//////////////////////////////
GLOBAL_LIST_INIT(glass_recipes, list (
	new /datum/stack_recipe("glass shard", /obj/item/shard, time = 0 SECONDS),
	new /datum/stack_recipe/window("directional window", /obj/structure/window/basic, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile window", /obj/structure/window/full/basic, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe("fishbowl", /obj/machinery/fishtank/bowl, 1, time = 1 SECONDS),
	new /datum/stack_recipe("fish tank", /obj/machinery/fishtank/tank, 3, time = 2 SECONDS, on_floor = TRUE),
	new /datum/stack_recipe("wall aquarium", /obj/machinery/fishtank/wall, 4, time = 4 SECONDS, on_floor = TRUE),
	new /datum/stack_recipe("glass ashtray", /obj/item/ashtray/glass, 1, time = 1 SECONDS),
	new /datum/stack_recipe("dropper", /obj/item/reagent_containers/dropper, 1, time = 1 SECONDS),
))

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	icon_state = "sheet-glass"
	singular_name = "glass sheet"
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 100)
	resistance_flags = ACID_PROOF
	created_window = /obj/structure/window/basic
	full_window = /obj/structure/window/full/basic
	merge_type = /obj/item/stack/sheet/glass
	point_value = 1
	table_type = /obj/structure/table/glass

/obj/item/stack/sheet/glass/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Using rods on a floor plating will install glass floor. You can make reinforced glass by combining rods and normal glass sheets.</span>"

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/cyborg
	energy_type = /datum/robot_storage/material/glass
	is_cyborg = TRUE
	materials = list()

/obj/item/stack/sheet/glass/cyborg/examine(mob/user)
	. = ..()
	var/mob/living/silicon/robot/robot = user
	if(!istype(robot.module, /obj/item/robot_module/drone))
		. += "<span class='notice'>You can refill your glass by using your <b>magnetic gripper</b> on the Ore Redemption machine, or by picking it up from the ground.</span>"

/obj/item/stack/sheet/glass/cyborg/drone
	energy_type = /datum/robot_storage/energy/glass

/obj/item/stack/sheet/glass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.glass_recipes

/obj/item/stack/sheet/glass/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.get_amount() < 5)
			to_chat(user, "<b>There is not enough wire in this coil. You need 5 lengths.</b>")
			return
		CC.use(5)
		to_chat(user, "<span class='notice'>You attach wire to [src].</span>")
		new /obj/item/stack/light_w(user.loc)
		use(1)
		return

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/rglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if(!G && !RG && replace)
			user.put_in_hands(RG)
		return

	return ..()

//////////////////////////////
// MARK: REINFORCED GLASS
//////////////////////////////
GLOBAL_LIST_INIT(reinforced_glass_recipes, list (
	new /datum/stack_recipe("glass shard", /obj/item/shard, time = 0 SECONDS),
	new /datum/stack_recipe/window("windoor frame", /obj/structure/windoor_assembly, 5, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	null,
	new /datum/stack_recipe/window("directional reinforced window", /obj/structure/window/reinforced, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile reinforced window", /obj/structure/window/full/reinforced, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	null,
	new /datum/stack_recipe/window("directional electrochromic window", /obj/structure/window/reinforced/polarized, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile electrochromic window", /obj/structure/window/full/reinforced/polarized, 4, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE)
))

/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT / 2, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 70, ACID = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "materials=2"
	created_window = /obj/structure/window/reinforced
	full_window = /obj/structure/window/full/reinforced
	merge_type = /obj/item/stack/sheet/rglass
	point_value = 4
	table_type = /obj/structure/table/glass/reinforced

/obj/item/stack/sheet/rglass/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Reinforced glass is much stronger against damage than normal glass, otherwise it functions like normal glass does.</span>"

/obj/item/stack/sheet/rglass/fifty
	amount = 50

/obj/item/stack/sheet/rglass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.reinforced_glass_recipes

GLOBAL_LIST_INIT(pglass_recipes, list (
	new /datum/stack_recipe("plasma shard", /obj/item/shard/plasma, time = 0 SECONDS),
	new /datum/stack_recipe/window("directional window", /obj/structure/window/plasmabasic, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile window", /obj/structure/window/full/plasmabasic, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE)
))

/obj/item/stack/sheet/rglass/cyborg
	energy_type = /datum/robot_storage/material/rglass
	is_cyborg = TRUE
	materials = list()

/obj/item/stack/sheet/rglass/cyborg/examine(mob/user)
	. = ..()
	var/mob/living/silicon/robot/robot = user
	if(!istype(robot.module, /obj/item/robot_module/drone))
		. += "<span class='notice'>You can refill your reinforced glass by picking it up from the ground.</span>"

/obj/item/stack/sheet/rglass/cyborg/drone
	energy_type = /datum/robot_storage/energy/rglass

//////////////////////////////
// MARK: PLASMA GLASS
//////////////////////////////
/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass mixture."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 75, ACID = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "plasmatech=2;materials=2"
	created_window = /obj/structure/window/plasmabasic
	full_window = /obj/structure/window/full/plasmabasic
	point_value = 19
	table_type = /obj/structure/table/glass/plasma

/obj/item/stack/sheet/plasmaglass/examine_more(mob/user)
	. = ..()
	. += "A mixture of silica glass and plasma. The plasma forces the normally amorphous glass to assume a regular crystal structure. The plasma encourges heavy cross-linking, \
	massively improving the strength of the glass whilst also giving it exceptional thermal resistance. The denser molecular structure is also better at blocking radiation."
	. += ""
	. += "Unlike metal alloys incorporating plasma, plasma glass is not common - the secrets of producing it are a closely guarded trade secret of Nanotrasen, \
	very demanding conditions are required to correctly combine plasma and silica, and without this knowledge the process is fraught with great risk of igniting the plasma and (at best) destroying the production equipment."
	. += ""
	. += "Despite plastitanium glass being a structurally more robust material, pure plasma glass has some unique properties that Nanotrasen exploits in some of its experimental energy weapons, such as the immolator laser."

/obj/item/stack/sheet/plasmaglass/fifty
	amount = 50

/obj/item/stack/sheet/plasmaglass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.pglass_recipes

/obj/item/stack/sheet/plasmaglass/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/plasmarglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if(!G && !RG && replace)
			user.put_in_hands(RG)
	else
		return ..()

//////////////////////////////
// MARK: REINFORCED PLASMA GLASS
//////////////////////////////

GLOBAL_LIST_INIT(prglass_recipes, list (
	new /datum/stack_recipe("plasma shard", /obj/item/shard/plasma, time = 0 SECONDS),
	new /datum/stack_recipe/window("directional reinforced window", /obj/structure/window/plasmareinforced, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile reinforced window", /obj/structure/window/full/plasmareinforced, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE)
))

/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT / 2, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "plasmatech=2;materials=2"
	created_window = /obj/structure/window/plasmareinforced
	full_window = /obj/structure/window/full/plasmareinforced
	point_value = 23
	table_type = /obj/structure/table/glass/reinforced/plasma

/obj/item/stack/sheet/plasmarglass/examine_more(mob/user)
	. = ..()
	. += "A mixture of silica glass and plasma. The plasma forces the normally amorphous glass to assume a regular crystal structure. The plasma encourges heavy cross-linking, \
	massively improving the strength of the glass whilst also giving it exceptional thermal resistance. The denser molecular structure is also better at blocking radiation."
	. += ""
	. += "Unlike metal alloys incorporating plasma, plasma glass is not common - the secrets of producing it are a closely guarded trade secret of Nanotrasen, \
	very demanding conditions are required to correctly combine plasma and silica, and without this knowledge the process is fraught with great risk of igniting the plasma and (at best) destroying the production equipment."
	. += ""
	. += "Despite plastitanium glass being a structurally more robust material, pure plasma glass has some unique properties that Nanotrasen exploits in some of its experimental energy weapons, such as the immolator laser."

/obj/item/stack/sheet/plasmarglass/fifty
	amount = 50

/obj/item/stack/sheet/plasmarglass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.prglass_recipes

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new /datum/stack_recipe/window("shuttle window", /obj/structure/window/full/shuttle, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE)
	))

//////////////////////////////
// MARK: TITANIUM GLASS
//////////////////////////////
/obj/item/stack/sheet/titaniumglass
	name = "titanium glass"
	desc = "A glass sheet made out of titanium silicate."
	singular_name = "titanium glass sheet"
	icon_state = "sheet-titaniumglass"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/titaniumglass
	full_window = /obj/structure/window/full/shuttle
	table_type = /obj/structure/table/glass/reinforced/titanium

/obj/item/stack/sheet/titaniumglass/examine_more(mob/user)
	. = ..()
	. += "Titanium-silica mixes are an old but highly effective technology that produce a relatively lightweight, very strong glass that can withstand a good amount of punishment."
	. += ""
	. += "It is extensively used in the production of starship viewports and transparent armour, and is notably used extensively in space station construction by the USSP."

/obj/item/stack/sheet/titaniumglass/fifty
	amount = 50

/obj/item/stack/sheet/titaniumglass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.titaniumglass_recipes

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new /datum/stack_recipe("plastitanium shard", /obj/item/shard/plastitanium, time = 0 SECONDS),
	new /datum/stack_recipe/window("directional plastitanium window", /obj/structure/window/plastitanium, 1, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile plastitanium window", /obj/structure/window/full/plastitanium, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	))

//////////////////////////////
// MARK: PLASTITANIUM GLASS
//////////////////////////////
/obj/item/stack/sheet/plastitaniumglass
	name = "plastitanium glass"
	desc = "A glass sheet made out of a plasma-titanium-silica mixture."
	singular_name = "plastitanium glass sheet"
	icon_state = "sheet-plastitaniumglass"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plastitaniumglass
	created_window = /obj/structure/window/plastitanium
	full_window = /obj/structure/window/full/plastitanium
	table_type = /obj/structure/table/glass/reinforced/plastitanium

/obj/item/stack/sheet/plastitaniumglass/examine_more(mob/user)
	. = ..()
	. += "A mixture of silica glass, and plastitanium. It boasts similar material properties to plastitanium whilst also being optically transparent."
	. += ""
	. += "Unlike regular plasma glass, the production process of plastitanium glass is relatively safer and better known, as the titanium helps to control the plasma's reactivity whilst it is being mixed with the silica. \
	It is extensively employed for military-grade transparent armour and optics."

/obj/item/stack/sheet/plastitaniumglass/fifty
	amount = 50

/obj/item/stack/sheet/plastitaniumglass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.plastitaniumglass_recipes

