/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 *		Plasma Glass Sheets
 *		Reinforced Plasma Glass Sheets (AKA Holy fuck strong windows)

 Todo: Create a unified construct_window(sheet, user, created_window, full_window)

 */

/*
 * Glass sheets
 */

GLOBAL_LIST_INIT(glass_recipes, list ( \
	new/datum/stack_recipe/window("directional window", /obj/structure/window/basic, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe/window("fulltile window", /obj/structure/window/full/basic, 2, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fishbowl", /obj/machinery/fishtank/bowl, 1, time = 0), \
	new/datum/stack_recipe("fish tank", /obj/machinery/fishtank/tank, 3, time = 0, on_floor = TRUE), \
	new/datum/stack_recipe("wall aquariam", /obj/machinery/fishtank/wall, 4, time = 0, on_floor = TRUE) \
))

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "materials=1"
	created_window = /obj/structure/window/basic
	full_window = /obj/structure/window/full/basic
	merge_type = /obj/item/stack/sheet/glass
	point_value = 1

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/cyborg
	materials = list()

/obj/item/stack/sheet/glass/New(loc, amount)
	recipes = GLOB.glass_recipes
	..()

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 5)
			to_chat(user, "<b>There is not enough wire in this coil. You need 5 lengths.</b>")
			return
		CC.use(5)
		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
		new /obj/item/stack/light_w(user.loc)
		src.use(1)
	else if( istype(W, /obj/item/stack/rods) )
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
	else
		return ..()


/*
 * Reinforced glass sheets
 */

GLOBAL_LIST_INIT(reinforced_glass_recipes, list ( \
	new/datum/stack_recipe/window("windoor frame", /obj/structure/windoor_assembly, 5, time = 0, on_floor = TRUE, window_checks = TRUE), \
	null, \
	new/datum/stack_recipe/window("directional reinforced window", /obj/structure/window/reinforced, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe/window("fulltile reinforced window", /obj/structure/window/full/reinforced, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "materials=2"
	created_window = /obj/structure/window/reinforced
	full_window = /obj/structure/window/full/reinforced
	merge_type = /obj/item/stack/sheet/rglass
	point_value = 4

/obj/item/stack/sheet/rglass/cyborg
	materials = list()

/obj/item/stack/sheet/rglass/New(loc, amount)
	recipes = GLOB.reinforced_glass_recipes
	..()

GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe/window("directional window", /obj/structure/window/plasmabasic, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe/window("fulltile window", /obj/structure/window/full/plasmabasic, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	item_state = "sheet-rglass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT*2)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "plasmatech=2;materials=2"
	created_window = /obj/structure/window/plasmabasic
	full_window = /obj/structure/window/full/plasmabasic
	point_value = 19

/obj/item/stack/sheet/plasmaglass/New(loc, amount)
	recipes = GLOB.pglass_recipes
	..()

/obj/item/stack/sheet/plasmaglass/attackby(obj/item/W, mob/user, params)
	..()
	if( istype(W, /obj/item/stack/rods) )
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

/*
 * Reinforced plasma glass sheets
 */

GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe/window("directional reinforced window", /obj/structure/window/plasmareinforced, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe/window("fulltile reinforced window", /obj/structure/window/full/plasmareinforced, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	item_state = "sheet-rglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT*2)
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "plasmatech=2;materials=2"
	created_window = /obj/structure/window/plasmareinforced
	full_window = /obj/structure/window/full/plasmareinforced
	point_value = 23

/obj/item/stack/sheet/plasmarglass/New(loc, amount)
	recipes = GLOB.prglass_recipes
	..()

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new/datum/stack_recipe/window("shuttle window", /obj/structure/window/full/shuttle, 2, time = 0, on_floor = TRUE, window_checks = TRUE)
	))

/obj/item/stack/sheet/titaniumglass
	name = "titanium glass"
	desc = "A glass sheet made out of a titanium-silicate alloy."
	singular_name = "titanium glass sheet"
	icon_state = "sheet-titaniumglass"
	item_state = "sheet-rglass"
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/titaniumglass
	full_window = /obj/structure/window/full/shuttle

/obj/item/stack/sheet/titaniumglass/New(loc, amount)
	recipes = GLOB.titaniumglass_recipes
	..()

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new/datum/stack_recipe/window("plastitanium window", /obj/structure/window/plastitanium, 2, time = 0, on_floor = TRUE, window_checks = TRUE)
	))

/obj/item/stack/sheet/plastitaniumglass
	name = "plastitanium glass"
	desc = "A glass sheet made out of a plasma-titanium-silicate alloy."
	singular_name = "plastitanium glass sheet"
	icon_state = "sheet-plastitaniumglass"
	item_state = "sheet-rglass"
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT, MAT_PLASMA=MINERAL_MATERIAL_AMOUNT, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plastitaniumglass
	full_window = /obj/structure/window/plastitanium

/obj/item/stack/sheet/plastitaniumglass/New(loc, amount)
	recipes = GLOB.plastitaniumglass_recipes
	..()
