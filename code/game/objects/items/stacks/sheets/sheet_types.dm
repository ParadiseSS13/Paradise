/* Diffrent misc types of sheets
 * Contains:
 *		Metal
 *		Plasteel
 *		Wood
 *		Cloth
 *		Plastic
 *		Cardboard
 *		Runed Metal (cult)
 */

/*
 * Metal
 */
var/global/list/datum/stack_recipe/metal_recipes = list(
	new /datum/stack_recipe("stool", /obj/structure/stool, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("chair", /obj/structure/stool/bed/chair, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (middle)", /obj/structure/stool/bed/chair/sofa, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (left)", /obj/structure/stool/bed/chair/sofa/left, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (right)", /obj/structure/stool/bed/chair/sofa/right, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (corner)", /obj/structure/stool/bed/chair/sofa/corner, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("barber chair", /obj/structure/stool/bed/chair/barber, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("wheelchair", /obj/structure/stool/bed/chair/wheelchair, 15, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("bed", /obj/structure/stool/bed, 2, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("psychiatrist bed", /obj/structure/stool/psychbed, 5, one_per_turf = 1, on_floor = 1),
	null,
	new /datum/stack_recipe_list("office chairs",list(
		new /datum/stack_recipe("dark office chair", /obj/structure/stool/bed/chair/office/dark, 5, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("light office chair", /obj/structure/stool/bed/chair/office/light, 5, one_per_turf = 1, on_floor = 1),
	), 5),

	new /datum/stack_recipe_list("comfy chairs", list(
		new /datum/stack_recipe("beige comfy chair", /obj/structure/stool/bed/chair/comfy/beige, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("black comfy chair", /obj/structure/stool/bed/chair/comfy/black, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("brown comfy chair", /obj/structure/stool/bed/chair/comfy/brown, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("lime comfy chair", /obj/structure/stool/bed/chair/comfy/lime, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("teal comfy chair", /obj/structure/stool/bed/chair/comfy/teal, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("red comfy chair", /obj/structure/stool/bed/chair/comfy/red, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("blue comfy chair", /obj/structure/stool/bed/chair/comfy/blue, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("purple comfy chair", /obj/structure/stool/bed/chair/comfy/purp, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("green comfy chair", /obj/structure/stool/bed/chair/comfy/green, 2, one_per_turf = 1, on_floor = 1),
	), 2),

	null,
	new /datum/stack_recipe("table parts", /obj/item/weapon/table_parts, 2),
	new /datum/stack_recipe("glass table frame parts", /obj/item/weapon/table_parts/glass, 2),
	new /datum/stack_recipe("rack parts", /obj/item/weapon/rack_parts),
	new /datum/stack_recipe("closet", /obj/structure/closet, 2, time = 15, one_per_turf = 1, on_floor = 1),
	null,
	new /datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = 1, on_floor = 1),
	null,
	new /datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20),
	new /datum/stack_recipe/rods("metal rod", /obj/item/stack/rods, 1, 2, 50),
	null,
	new /datum/stack_recipe("computer frame", /obj/structure/computerframe, 5, time = 25, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("modular console", /obj/machinery/modular_computer/console/buildable/, 10, time = 25, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("machine frame", /obj/machinery/constructable_frame/machine_frame, 5, time = 25, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("firelock frame", /obj/structure/firelock_frame, 3, time = 50, one_per_turf = 1, on_floor = 1), \
	new /datum/stack_recipe("meatspike frame", /obj/structure/kitchenspike_frame, 5, time = 25, one_per_turf = 1, on_floor = 1),
	null,
	new /datum/stack_recipe_list("airlock assemblies", list(
		new /datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 4, time = 50, one_per_turf = 1, on_floor = 1),
	), 4),
	null,
	new /datum/stack_recipe("mass driver button frame", /obj/item/mounted/frame/driver_button, 1, time = 50, one_per_turf = 0, on_floor = 1),
	new /datum/stack_recipe("light switch frame", /obj/item/mounted/frame/light_switch, 1, time = 50, one_per_turf = 0, on_floor = 1),
	null,
	new /datum/stack_recipe("grenade casing", /obj/item/weapon/grenade/chem_grenade),
	new /datum/stack_recipe("light fixture frame", /obj/item/mounted/frame/light_fixture, 2),
	new /datum/stack_recipe("small light fixture frame", /obj/item/mounted/frame/light_fixture/small, 1),
	null,
	new /datum/stack_recipe("apc frame", /obj/item/mounted/frame/apc_frame, 2),
	new /datum/stack_recipe("air alarm frame", /obj/item/mounted/frame/alarm_frame, 2),
	new /datum/stack_recipe("fire alarm frame", /obj/item/mounted/frame/firealarm, 2),
	new /datum/stack_recipe("intercom frame", /obj/item/mounted/frame/intercom, 2),
	null
)

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=1"
	merge_type = /obj/item/stack/sheet/metal

/obj/item/stack/sheet/metal/cyborg
	materials = list()

/obj/item/stack/sheet/metal/fifty
	amount = 50

/obj/item/stack/sheet/metal/narsie_act()
	if(prob(20))
		new /obj/item/stack/sheet/runed_metal(loc, amount)
		qdel(src)

/obj/item/stack/sheet/metal/New(var/loc, var/amount=null)
	recipes = metal_recipes
	return ..()

/*
 * Plasteel
 */
var/global/list/datum/stack_recipe/plasteel_recipes = list(
	new /datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = 1),
	new /datum/stack_recipe("bomb assembly", /obj/machinery/syndicatebomb/empty, 10, time = 50),
	new /datum/stack_recipe("Surgery Table", /obj/machinery/optable, 5, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, one_per_turf = 1),
	new /datum/stack_recipe("Mass Driver frame", /obj/machinery/mass_driver_frame, 3, time = 50, one_per_turf = 1)
)

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	materials = list(MAT_METAL=6000, MAT_PLASMA=6000)
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=2"
	merge_type = /obj/item/stack/sheet/plasteel

/obj/item/stack/sheet/plasteel/New(var/loc, var/amount=null)
	recipes = plasteel_recipes
	return ..()

/*
 * Wood
 */
var/global/list/datum/stack_recipe/wood_recipes = list(
	new /datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1),
	new /datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20),
	new /datum/stack_recipe("table parts", /obj/item/weapon/table_parts/wood, 2),
	new /datum/stack_recipe("wooden chair", /obj/structure/stool/bed/chair/wood/normal, 3, time = 10, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("bookcase", /obj/structure/bookcase, 5, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("dresser", /obj/structure/dresser, 30, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("drying rack", /obj/machinery/smartfridge/drying_rack, 10, time = 15, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("dog bed", /obj/structure/stool/bed/dogbed, 10, time = 10, one_per_turf = 1, on_floor = 1), \
	new /datum/stack_recipe("rifle stock", /obj/item/weaponcrafting/stock, 10, time = 40),
	new /datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("easel", /obj/structure/easel, 3, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("wooden buckler", /obj/item/weapon/shield/riot/buckler, 20, time = 40),
	new /datum/stack_recipe("apiary", /obj/structure/beebox, 40, time = 50),
	new /datum/stack_recipe("honey frame", /obj/item/honey_frame, 5, time = 10),
	new /datum/stack_recipe("baseball bat", /obj/item/weapon/melee/baseball_bat, 5, time = 15)
)

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	gender = PLURAL
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"
	burn_state = FLAMMABLE
	merge_type = /obj/item/stack/sheet/wood

/obj/item/stack/sheet/wood/New(var/loc, var/amount=null)
	recipes = wood_recipes
	return ..()

/*
 * Cloth
 */
var/global/list/datum/stack_recipe/cloth_recipes = list ( \
	new/datum/stack_recipe("grey jumpsuit", /obj/item/clothing/under/color/grey, 3), \
	new/datum/stack_recipe("black shoes", /obj/item/clothing/shoes/black, 2), \
	null, \
	new/datum/stack_recipe("backpack", /obj/item/weapon/storage/backpack, 4), \
	new/datum/stack_recipe("dufflebag", /obj/item/weapon/storage/backpack/duffel, 6), \
	null, \
	new/datum/stack_recipe("plant bag", /obj/item/weapon/storage/bag/plants, 4), \
	new/datum/stack_recipe("book bag", /obj/item/weapon/storage/bag/books, 4), \
	new/datum/stack_recipe("mining satchel", /obj/item/weapon/storage/bag/ore, 4), \
	new/datum/stack_recipe("chemistry bag", /obj/item/weapon/storage/bag/chemistry, 4), \
	new/datum/stack_recipe("bio bag", /obj/item/weapon/storage/bag/bio, 4), \
	null, \
	new/datum/stack_recipe("rag", /obj/item/weapon/reagent_containers/glass/rag, 1), \
	new/datum/stack_recipe("bedsheet", /obj/item/weapon/bedsheet, 3), \
	null, \
	new/datum/stack_recipe("fingerless gloves", /obj/item/clothing/gloves/fingerless, 1), \
	new/datum/stack_recipe("black gloves", /obj/item/clothing/gloves/color/black, 3), \
	)

/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "Is it cotton? Linen? Denim? Burlap? Canvas? You can't tell."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"
	burn_state = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cloth

/obj/item/stack/sheet/cloth/New(loc, amount=null)
	recipes = cloth_recipes
	..()

/obj/item/stack/sheet/cloth/ten
	amount = 10

/*
 * Cardboard
 */
var/global/list/datum/stack_recipe/cardboard_recipes = list (
	new /datum/stack_recipe("box", /obj/item/weapon/storage/box),
	new /datum/stack_recipe("large box", /obj/item/weapon/storage/box/large, 4),
	new /datum/stack_recipe("light tubes", /obj/item/weapon/storage/box/lights/tubes),
	new /datum/stack_recipe("light bulbs", /obj/item/weapon/storage/box/lights/bulbs),
	new /datum/stack_recipe("mouse traps", /obj/item/weapon/storage/box/mousetraps),
	new /datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3),
	new /datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg),
	new /datum/stack_recipe("pizza box", /obj/item/pizzabox),
	new /datum/stack_recipe("folder", /obj/item/weapon/folder),
	new /datum/stack_recipe("cardboard tube", /obj/item/weapon/c_tube),
	new /datum/stack_recipe("cardboard box", /obj/structure/closet/cardboard, 4),
	new/datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5),
)

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	origin_tech = "materials=1"
	burn_state = FLAMMABLE
	merge_type = /obj/item/stack/sheet/cardboard

/obj/item/stack/sheet/cardboard/New(var/loc, var/amt = null)
	recipes = cardboard_recipes
	return ..()

/*
 * Runed Metal
 */

var/global/list/datum/stack_recipe/runed_metal_recipes = list ( \
	new/datum/stack_recipe("runed door", /obj/machinery/door/airlock/cult, 1, time = 50, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("runed girder", /obj/structure/girder/cult, 1, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("pylon", /obj/structure/cult/functional/pylon, 3, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("forge", /obj/structure/cult/functional/forge, 5, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("archives", /obj/structure/cult/functional/tome, 2, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("altar", /obj/structure/cult/functional/talisman, 5, time = 40, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal"
	icon_state = "sheet-runed"
	icon = 'icons/obj/items.dmi'
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	return ..()

/obj/item/stack/sheet/runed_metal/fifty
	amount = 50

/obj/item/stack/sheet/runed_metal/New(var/loc, var/amount=null)
	recipes = runed_metal_recipes
	return ..()

/*
 * Bones
 */
/obj/item/stack/sheet/bone
	name = "bones"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone"
	singular_name = "bone"
	desc = "Someone's been drinking their milk."
	force = 7
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=2;biotech=2"

var/global/list/datum/stack_recipe/plastic_recipes = list ( \
	new/datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, one_per_turf = 1, on_floor = 1, time = 40), \
	new/datum/stack_recipe("plastic crate", /obj/structure/closet/crate/plastic, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic fork", /obj/item/weapon/kitchen/utensil/pfork, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spoon", /obj/item/weapon/kitchen/utensil/pspoon, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic knife", /obj/item/weapon/kitchen/knife/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic bag", /obj/item/weapon/storage/bag/plasticbag, 3, on_floor = 1), \
	new/datum/stack_recipe("bear mould", /obj/item/weapon/kitchen/mould/bear, 1, on_floor = 1), \
	new/datum/stack_recipe("worm mould", /obj/item/weapon/kitchen/mould/worm, 1, on_floor = 1), \
	new/datum/stack_recipe("bean mould", /obj/item/weapon/kitchen/mould/bean, 1, on_floor = 1), \
	new/datum/stack_recipe("ball mould", /obj/item/weapon/kitchen/mould/ball, 1, on_floor = 1), \
	new/datum/stack_recipe("cane mould", /obj/item/weapon/kitchen/mould/cane, 1, on_floor = 1), \
	new/datum/stack_recipe("cash mould", /obj/item/weapon/kitchen/mould/cash, 1, on_floor = 1), \
	new/datum/stack_recipe("coin mould", /obj/item/weapon/kitchen/mould/coin, 1, on_floor = 1), \
	new/datum/stack_recipe("sucker mould", /obj/item/weapon/kitchen/mould/loli, 1, on_floor = 1), \
	)

/obj/item/stack/sheet/plastic
	name = "plastic"
	desc = "Compress dinosaur over millions of years, then refine, split and mold, and voila! You have plastic."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	throwforce = 7
	origin_tech = "materials=1;biotech=1"
	merge_type = /obj/item/stack/sheet/plastic

/obj/item/stack/sheet/plastic/New()
	recipes = plastic_recipes
	. = ..()

/obj/item/stack/sheet/plastic/fifty
	amount = 50

/obj/item/stack/sheet/plastic/five
	amount = 5
