/* Different misc types of sheets
 * Contains:
 * Metal
 * Plasteel
 * Wood
 * Cloth
 * Plastic
 * Cardboard
 * Runed Metal (cult)
 * Brass (clockwork cult)
 * Bamboo
 */

/*
 * Metal
 */

GLOBAL_LIST_INIT(metal_recipes, list(
	new /datum/stack_recipe("Stool", /obj/structure/chair/stool, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Barstool", /obj/structure/chair/stool/bar, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Chair", /obj/structure/chair, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Barber chair", /obj/structure/chair/barber, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Wheelchair", /obj/structure/chair/wheelchair, 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Bed", /obj/structure/bed, 2, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Psychiatrist bed", /obj/structure/bed/psych, 5, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("Sofas", list(
		new /datum/stack_recipe("Sofa (middle)", /obj/structure/chair/sofa, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sofa (left)", /obj/structure/chair/sofa/left, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sofa (right)", /obj/structure/chair/sofa/right, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sofa (corner)", /obj/structure/chair/sofa/corner, one_per_turf = TRUE, on_floor = TRUE)
		)),
	new /datum/stack_recipe_list("Corporate sofas", list(
		new /datum/stack_recipe("Sofa (middle)", /obj/structure/chair/sofa/corp, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sofa (left)", /obj/structure/chair/sofa/corp/left, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sofa (right)", /obj/structure/chair/sofa/corp/right, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sofa (corner)", /obj/structure/chair/sofa/corp/corner, one_per_turf = TRUE, on_floor = TRUE),
	)),
	new /datum/stack_recipe_list("Shuttle seats",list(
		new /datum/stack_recipe("White shuttle seat", /obj/structure/chair/comfy/shuttle, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Black shuttle seat", /obj/structure/chair/comfy/shuttle/dark, 2, one_per_turf = TRUE, on_floor = TRUE),
	)),
	new /datum/stack_recipe_list("Office chairs",list(
		new /datum/stack_recipe("Dark office chair", /obj/structure/chair/office/dark, 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Light office chair", /obj/structure/chair/office/light, 5, one_per_turf = TRUE, on_floor = TRUE),
	)),
	new /datum/stack_recipe_list("Comfy chairs", list(
		new /datum/stack_recipe("Beige comfy chair", /obj/structure/chair/comfy/beige, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Black comfy chair", /obj/structure/chair/comfy/black, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Blue comfy chair", /obj/structure/chair/comfy/blue, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Brown comfy chair", /obj/structure/chair/comfy/brown, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Green comfy chair", /obj/structure/chair/comfy/green, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Lime comfy chair", /obj/structure/chair/comfy/lime, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Purple comfy chair", /obj/structure/chair/comfy/purp, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Red comfy chair", /obj/structure/chair/comfy/red, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Teal comfy chair", /obj/structure/chair/comfy/teal, 2, one_per_turf = TRUE, on_floor = TRUE),
	)),
	null,
	new /datum/stack_recipe("Rack parts", /obj/item/rack_parts),
	new /datum/stack_recipe("Gun rack parts", /obj/item/gunrack_parts),
	new /datum/stack_recipe("Grenade casing", /obj/item/grenade/chem_grenade),
	new /datum/stack_recipe("Canister", /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Closet", /obj/structure/closet, 2, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("Floor tile", /obj/item/stack/tile/plasteel, TRUE, 4, 20),
	new /datum/stack_recipe/rods("Metal rod", /obj/item/stack/rods, TRUE, 2, 50),
	null,
	new /datum/stack_recipe("Computer frame", /obj/structure/computerframe, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Firelock frame", /obj/structure/firelock_frame, 3, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Machine frame", /obj/machinery/constructable_frame/machine_frame, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Meatspike frame", /obj/structure/kitchenspike_frame, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Reflector frame", /obj/structure/reflector, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Turret frame", /obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Wall girders", /obj/structure/girder, 2, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("Airlock assemblies", list(
		new /datum/stack_recipe("Airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("External airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("External maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_extmai, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		new /datum/stack_recipe("Freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 8, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Public airlock assembly", /obj/structure/door_assembly/door_assembly_public, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Standard airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	)),
	null,
	new /datum/stack_recipe("Mass driver button frame", /obj/item/mounted/frame/driver_button, time = 50, on_floor = TRUE),
	new /datum/stack_recipe("Light switch frame", /obj/item/mounted/frame/light_switch, time = 50, on_floor = TRUE),
	new /datum/stack_recipe("Light fixture frame", /obj/item/mounted/frame/light_fixture, 2),
	new /datum/stack_recipe("Small light fixture frame", /obj/item/mounted/frame/light_fixture/small, TRUE),
	null,
	new /datum/stack_recipe("APC frame", /obj/item/mounted/frame/apc_frame, 2),
	new /datum/stack_recipe("Air alarm frame", /obj/item/mounted/frame/alarm_frame, 2),
	new /datum/stack_recipe("Extinguisher cabinet frame", /obj/item/mounted/frame/extinguisher, 2),
	new /datum/stack_recipe("Fire alarm frame", /obj/item/mounted/frame/firealarm, 2),
	new /datum/stack_recipe("Intercom frame", /obj/item/mounted/frame/intercom, 2),
	new /datum/stack_recipe("Shower", /obj/item/mounted/shower, 5, time = 7, on_floor = TRUE),
))

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
	throwforce = 10.0
	flags = CONDUCT
	resistance_flags = FIRE_PROOF
	origin_tech = "materials=1"
	merge_type = /obj/item/stack/sheet/metal
	point_value = 2

/obj/item/stack/sheet/metal/cyborg
	materials = list()
	is_cyborg = 1

/obj/item/stack/sheet/metal/fifty
	amount = 50

/obj/item/stack/sheet/metal/ratvar_act()
	new /obj/item/stack/sheet/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/metal/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/metal/New(loc, amount=null)
	recipes = GLOB.metal_recipes
	return ..()

/*
 * Plasteel
 */

GLOBAL_LIST_INIT(plasteel_recipes, list(
	new /datum/stack_recipe_list("Airlock assemblies", list(
		new /datum/stack_recipe("High security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 6, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Vault door assembly", /obj/structure/door_assembly/door_assembly_vault, 8, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	)),
	null,
	new /datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = TRUE),
	new /datum/stack_recipe("Bomb assembly", /obj/machinery/syndicatebomb/empty, 3, time = 50),
	new /datum/stack_recipe("Mass Driver frame", /obj/machinery/mass_driver_frame, 3, time = 50, one_per_turf = TRUE),
	new /datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, one_per_turf = TRUE),
	new /datum/stack_recipe("Surgery Table", /obj/machinery/optable, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE),
))

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-plasteel"
	materials = list(MAT_METAL=2000, MAT_PLASMA=2000)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	resistance_flags = FIRE_PROOF
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=2"
	merge_type = /obj/item/stack/sheet/plasteel
	point_value = 23

/obj/item/stack/sheet/plasteel/lowplasma
	desc = "This sheet is an alloy of iron and plasma. There are an special barcode 'Low Plasma Level'"
	materials = list(MAT_METAL=2000, MAT_PLASMA=400)

/obj/item/stack/sheet/plasteel/New(loc, amount=null)
	recipes = GLOB.plasteel_recipes
	return ..()

/*
 * Wood
 */

GLOBAL_LIST_INIT(wood_recipes, list(
	new /datum/stack_recipe("Apiary", /obj/structure/beebox, 40, time = 50),
	new /datum/stack_recipe("Baseball bat", /obj/item/melee/baseball_bat, 5, time = 15),
	new /datum/stack_recipe("Bookcase", /obj/structure/bookcase, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Display case chassis", /obj/structure/displaycase_chassis, 5, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Dog bed", /obj/structure/bed/dogbed, 10, time = 10, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Dresser", /obj/structure/dresser, 30, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Drying rack", /obj/machinery/smartfridge/drying_rack, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Fermenting barrel", /obj/structure/fermenting_barrel, 30, time = 50),
	new /datum/stack_recipe("Firebrand", /obj/item/match/firebrand, 2, time = 100),
	new /datum/stack_recipe("Honey frame", /obj/item/honey_frame, 5, time = 10),
	new /datum/stack_recipe("Loom", /obj/structure/loom, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Ore box", /obj/structure/ore_box, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Rake", /obj/item/cultivator/rake, 5, time = 10),
	new /datum/stack_recipe("Rifle stock", /obj/item/weaponcrafting/stock, 10, time = 40),
	new /datum/stack_recipe("Wooden bucket", /obj/item/reagent_containers/glass/bucket/wooden, 3, time = 10),
	new /datum/stack_recipe("Wooden buckler", /obj/item/shield/riot/buckler, 20, time = 40),
	new /datum/stack_recipe("Wooden sandals", /obj/item/clothing/shoes/sandal),
	null,
	new /datum/stack_recipe_list("Pews", list(
		new /datum/stack_recipe("Pew (middle)", /obj/structure/chair/sofa/pew, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Pew (left)", /obj/structure/chair/sofa/pew/left, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Pew (right)", /obj/structure/chair/sofa/pew/right, one_per_turf = TRUE, on_floor = TRUE),
	)),
	new /datum/stack_recipe_list("Wooden floor tiles", list(
		new /datum/stack_recipe("Wood floor tile", /obj/item/stack/tile/wood, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Oak floor tile", /obj/item/stack/tile/wood/oak, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Birch floor tile", /obj/item/stack/tile/wood/birch, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Cherry floor tile", /obj/item/stack/tile/wood/cherry, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Fancy oak floor tile", /obj/item/stack/tile/wood/fancy/oak, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Fancy light oak floor tile", /obj/item/stack/tile/wood/fancy/light, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Fancy birch floor tile", /obj/item/stack/tile/wood/fancy/birch, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("Fancy cherry floor tile", /obj/item/stack/tile/wood/fancy/cherry, res_amount = 4, max_res_amount = 20)
	)),
	new /datum/stack_recipe("Wood table frame", /obj/structure/table_frame/wood, 2, time = 10),
	new /datum/stack_recipe("Wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Wooden chair", /obj/structure/chair/wood, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
))

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	gender = PLURAL
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	item_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"
	resistance_flags = FLAMMABLE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	merge_type = /obj/item/stack/sheet/wood

/obj/item/stack/sheet/wood/cyborg
	is_cyborg = 1

/obj/item/stack/sheet/wood/New(loc, amount=null)
	recipes = GLOB.wood_recipes
	return ..()

/*
 * Cloth
 */

GLOBAL_LIST_INIT(cloth_recipes, list(
	new /datum/stack_recipe("White beanie", /obj/item/clothing/head/beanie, 2),
	new /datum/stack_recipe("White gloves", /obj/item/clothing/gloves/color/white, 3),
	new /datum/stack_recipe("White jumpsuit", /obj/item/clothing/under/color/white, 3),
	new /datum/stack_recipe("White scarf", /obj/item/clothing/accessory/scarf/white),
	new /datum/stack_recipe("White shoes", /obj/item/clothing/shoes/white, 2),
	new /datum/stack_recipe("White softcap", /obj/item/clothing/head/soft/mime, 2),
	null,
	new /datum/stack_recipe("Backpack", /obj/item/storage/backpack, 4),
	new /datum/stack_recipe("Dufflebag", /obj/item/storage/backpack/duffel, 6),
	new /datum/stack_recipe_list("Job specific bags", list(
		new /datum/stack_recipe("Bio bag", /obj/item/storage/bag/bio, 4),
		new /datum/stack_recipe("Book bag", /obj/item/storage/bag/books, 4),
		new /datum/stack_recipe("Chemistry bag", /obj/item/storage/bag/chemistry, 4),
		new /datum/stack_recipe("Fish bag", /obj/item/storage/bag/fish, 4),
		new /datum/stack_recipe("Mining satchel", /obj/item/storage/bag/ore, 4),
		new /datum/stack_recipe("Plant bag", /obj/item/storage/bag/plants, 4),
	)),
	null,
	new /datum/stack_recipe("Bedsheet", /obj/item/bedsheet, 3),
	new /datum/stack_recipe("Blindfold", /obj/item/clothing/glasses/sunglasses/blindfold, 3),
	new /datum/stack_recipe("Fingerless gloves", /obj/item/clothing/gloves/fingerless),
	new /datum/stack_recipe("Empty sandbag", /obj/item/emptysandbag, 4),
	new /datum/stack_recipe("Improvised gauze", /obj/item/stack/medical/bruise_pack/improvised, res_amount = 2, max_res_amount = 6),
	new /datum/stack_recipe("Rag", /obj/item/reagent_containers/glass/rag),
))
/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "Is it cotton? Linen? Denim? Burlap? Canvas? You can't tell."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cloth

/obj/item/stack/sheet/cloth/New(loc, amount=null)
	recipes = GLOB.cloth_recipes
	..()

/obj/item/stack/sheet/cloth/ten
	amount = 10

/*
 * Durathread
 */

GLOBAL_LIST_INIT(durathread_recipes, list(
	new/datum/stack_recipe("Durathread bandana", /obj/item/clothing/mask/bandana/durathread, time = 25),
	new/datum/stack_recipe("Durathread beanie", /obj/item/clothing/head/beanie/durathread, 2, time = 40),
	new/datum/stack_recipe("Durathread beret", /obj/item/clothing/head/beret/durathread, 2, time = 40),
	new/datum/stack_recipe("Durathread duffelbag", /obj/item/storage/backpack/duffel/durathread, 6, time = 40),
	new/datum/stack_recipe("Durathread jumpsuit", /obj/item/clothing/under/misc/durathread, 4, time = 40),
))

/obj/item/stack/sheet/durathread
	name = "durathread"
	desc = "A fabric sown from incredibly durable threads, known for its usefulness in armor production."
	singular_name = "durathread roll"
	icon_state = "sheet-durathread"
	item_state = "sheet-cloth"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/durathread

/obj/item/stack/sheet/durathread/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.durathread_recipes
	return ..()

/obj/item/stack/sheet/cotton
	name = "raw cotton bundle"
	desc = "A bundle of raw cotton ready to be spun on the loom."
	singular_name = "raw cotton ball"
	icon_state = "sheet-cotton"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cotton
	var/pull_effort = 30
	var/loom_result = /obj/item/stack/sheet/cloth

/obj/item/stack/sheet/cotton/durathread
	name = "raw durathread bundle"
	desc = "A bundle of raw durathread ready to be spun on the loom."
	singular_name = "raw durathread ball"
	icon_state = "sheet-durathreadraw"
	merge_type = /obj/item/stack/sheet/cotton/durathread
	pull_effort = 70
	loom_result = /obj/item/stack/sheet/durathread

/*
 * Cardboard
 */

GLOBAL_LIST_INIT(cardboard_recipes, list(
	new /datum/stack_recipe_list("Small boxes", list(
		new /datum/stack_recipe("box", /obj/item/storage/box),
		new /datum/stack_recipe("light tubes", /obj/item/storage/box/lights/tubes),
		new /datum/stack_recipe("light bulbs", /obj/item/storage/box/lights/bulbs),
		new /datum/stack_recipe("mouse traps", /obj/item/storage/box/mousetraps),
		//вообще, стоит наверное убрать эти рецепты и заменить их возможностью перекрасить коробку,
		//как это сделано для paperbag в boxes.dm
	)),
	new /datum/stack_recipe("large box", /obj/item/storage/box/large, 4),
	new /datum/stack_recipe("cardboard box", /obj/structure/closet/cardboard, 4),
	null,
	new /datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5),
	new /datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg),
	new /datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3),
	new /datum/stack_recipe("folder", /obj/item/folder),
	new /datum/stack_recipe("patch pack", /obj/item/storage/pill_bottle/patch_pack, 2),
	null,
	new /datum/stack_recipe("cardboard tube", /obj/item/c_tube),
	new /datum/stack_recipe("donut box", /obj/item/storage/fancy/donut_box/empty),
	new /datum/stack_recipe("pizza box", /obj/item/pizzabox),
))

/obj/item/stack/sheet/cardboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stamp/clown) && !istype(loc, /obj/item/storage))
		var/atom/droploc = drop_location()
		if(use(1))
			playsound(I, 'sound/items/bikehorn.ogg', 50, 1, -1)
			to_chat(user, "<span class='notice'>You stamp the cardboard! It's a clown box! Honk!</span>")
			new/obj/item/storage/box/clown(droploc) //bugfix
	else
		. = ..()

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	item_state = "sheet-card"
	origin_tech = "materials=1"
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/cardboard

/obj/item/stack/sheet/cardboard/New(loc, amt = null)
	recipes = GLOB.cardboard_recipes
	return ..()

/*
 * Runed Metal
 */

GLOBAL_LIST_INIT(cult_recipes, list(
	new /datum/stack_recipe/cult("Runed door (stuns non-cultists)", /obj/machinery/door/airlock/cult, time = 50, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("Runed girder (used to make cult walls)", /obj/structure/girder/cult, time = 10, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("Pylon (heals nearby cultists)", /obj/structure/cult/functional/pylon, 4, time = 40, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("Forge (crafts shielded robes, flagellant's robes, and mirror shields)", /obj/structure/cult/functional/forge, 3, time = 40, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("Archives (crafts zealot's blindfolds, shuttle curse orbs, and veil shifters)", /obj/structure/cult/functional/archives, 3, time = 40, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("Altar (crafts eldritch whetstones, construct shells, and flasks of unholy water)", /obj/structure/cult/functional/altar, 3, time = 40, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
))

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal sheet"
	icon_state = "sheet-runed"
	item_state = "sheet-runed"
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	recipe_width = 700

/obj/item/stack/sheet/runed_metal/New()
	. = ..()
	icon_state = SSticker.cultdat?.runed_metal_icon_state

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/sheet/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(isclocker(user))
		user.visible_message("<span class='warning'>[user] drops [src] with burning wounds appearing!</span>", \
		"<span class='cultlarge'>\"Go ahead. Try again.\"</span>")
		user.drop_item()
		user.adjustFireLoss(20)
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='warning'>The energies of this place interfere with the metal shaping!</span>")
		return

	return ..()

/datum/stack_recipe/cult
   one_per_turf = TRUE
   on_floor = TRUE

/datum/stack_recipe/cult/post_build(obj/item/stack/S, obj/result)
   if(ishuman(S.loc))
      var/mob/living/carbon/human/H = S.loc
      H.bleed(5)
   ..()

/obj/item/stack/sheet/runed_metal/ten
	amount = 10

/obj/item/stack/sheet/runed_metal/fifty
	amount = 50

/obj/item/stack/sheet/runed_metal/New(loc, amount=null)
	recipes = GLOB.cult_recipes
	return ..()

/*
 * Brass
 */

GLOBAL_LIST_INIT(brass_recipes, list(
	new /datum/stack_recipe("Altar of credence", /obj/structure/clockwork/functional/altar, 4, time = 40, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe("Eternal workshop", /obj/structure/clockwork/functional/workshop, 4, time = 40, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe("Herald's beacon", /obj/structure/clockwork/functional/beacon, 6, time = 80, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe("Wall gear", /obj/structure/clockwork/wall_gear, time = 10, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	null,
	new /datum/stack_recipe_list("Windows and furniture", list(
		new /datum/stack_recipe("Brass chair", /obj/structure/chair/brass, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Brass table frame", /obj/structure/table_frame/brass, time = 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Bronze ashtray", /obj/item/storage/ashtray/bronze, 2, one_per_turf = TRUE, on_floor = TRUE),
		null,
		new /datum/stack_recipe/window("Brass windoor", /obj/machinery/door/window/clockwork, 2, time = 30, on_floor = TRUE, window_checks = TRUE),
		new /datum/stack_recipe/window("Directional brass window", /obj/structure/window/reinforced/clockwork, on_floor = TRUE, window_checks = TRUE),
		new /datum/stack_recipe/window("Fulltile brass window", /obj/structure/window/reinforced/clockwork/fulltile, 2, on_floor = TRUE, window_checks = TRUE),
	)),
))

/obj/item/stack/sheet/brass
	name = "brass"
	desc = "Specially hand-crafted sheets of brass."
	singular_name = "brass sheet"
	icon_state = "sheet-brass"
	item_state = "sheet-brass"
	icon = 'icons/obj/items.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	merge_type = /obj/item/stack/sheet/brass

/obj/item/stack/sheet/brass/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/brass/attack_self(mob/living/user)
	if(iscultist(user))
		user.visible_message("<span class='warning'>[user] drops [src] with burning wounds appearing!</span>", \
		"<span class='clocklarge'>\"How dare you even to hold this piece of my art?\"</span>")
		user.drop_item()
		user.adjustFireLoss(20)
		return
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='warning'>The energies of this place interfere with the metal shaping!</span>")
		return

	return ..()

/obj/item/stack/sheet/brass/New(loc, amount=null)
	recipes = GLOB.brass_recipes
	. = ..()

/obj/item/stack/sheet/brass/ten
	amount = 10

/obj/item/stack/sheet/brass/fifty
	amount = 50

/obj/item/stack/sheet/brass/cyborg
	materials = list()
	is_cyborg = 1


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

/*
 * Plastic
 */

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("Plastic ashtray", /obj/item/storage/ashtray/, 2, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Plastic bag", /obj/item/storage/bag/plasticbag, 3, on_floor = TRUE),
	new /datum/stack_recipe("Plastic crate", /obj/structure/closet/crate/plastic, 10, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Plastic flaps", /obj/structure/plasticflaps, 5, time = 40, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("Moulds", list(
		new /datum/stack_recipe("Ball mould", /obj/item/kitchen/mould/ball, on_floor = TRUE),
		new /datum/stack_recipe("Bean mould", /obj/item/kitchen/mould/bean, on_floor = TRUE),
		new /datum/stack_recipe("Bear mould", /obj/item/kitchen/mould/bear, on_floor = TRUE),
		new /datum/stack_recipe("Cane mould", /obj/item/kitchen/mould/cane, on_floor = TRUE),
		new /datum/stack_recipe("Cash mould", /obj/item/kitchen/mould/cash, on_floor = TRUE),
		new /datum/stack_recipe("Coin mould", /obj/item/kitchen/mould/coin, on_floor = TRUE),
		new /datum/stack_recipe("Sucker mould", /obj/item/kitchen/mould/loli, on_floor = TRUE),
		new /datum/stack_recipe("Worm mould", /obj/item/kitchen/mould/worm, on_floor = TRUE),
	)),
	new /datum/stack_recipe_list("Signs", list(
		new /datum/stack_recipe("Barber shop", /obj/structure/sign/barber, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Biohazard", /obj/structure/sign/biohazard, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Botany", /obj/structure/sign/botany, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Cargo", /obj/structure/sign/cargo, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Cargo department", /obj/structure/sign/directions/cargo, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Chemistry", /obj/structure/sign/chemistry, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Chinese restaurant", /obj/structure/sign/chinese, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Custodian", /obj/structure/sign/custodian, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Dangerous alien life", /obj/structure/sign/xeno_warning_mining, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Deathsposal", /obj/structure/sign/deathsposal, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Drop pods", /obj/structure/sign/drop, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Engineering department", /obj/structure/sign/directions/engineering, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Engineering", /obj/structure/sign/engineering, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Escape arm", /obj/structure/sign/directions/evac, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Evacuation", /obj/structure/sign/evac, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Exam room", /obj/structure/sign/examroom, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Explosives", /obj/structure/sign/explosives, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Explosives alt", /obj/structure/sign/explosives/alt, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("External airlock", /obj/structure/sign/vacuum/external, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Fire", /obj/structure/sign/fire, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Green cross", /obj/structure/sign/greencross, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Hazardous radiation", /obj/structure/sign/radiation, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("High voltage", /obj/structure/sign/electricshock, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Holy", /obj/structure/sign/holy, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Medical bay", /obj/structure/sign/directions/medical, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("No smoking", /obj/structure/sign/nosmoking_1, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("No smoking alt", /obj/structure/sign/nosmoking_2, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Pods", /obj/structure/sign/pods, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Radioactive area", /obj/structure/sign/radiation/rad_area, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Red cross", /obj/structure/sign/redcross, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Research division", /obj/structure/sign/directions/science, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE), //да, они немного багнуты и я это знаю
		new /datum/stack_recipe("Restroom", /obj/structure/sign/restroom, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Science", /obj/structure/sign/science, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Secure area", /obj/structure/sign/securearea, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Security", /obj/structure/sign/security, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Security department", /obj/structure/sign/directions/security, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Vacuum", /obj/structure/sign/vacuum, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Xenobio", /obj/structure/sign/xenobio, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
	)),
	new /datum/stack_recipe_list("Utensil", list(
		new /datum/stack_recipe("Plastic fork", /obj/item/kitchen/utensil/pfork, on_floor = TRUE),
		new /datum/stack_recipe("Plastic knife", /obj/item/kitchen/knife/plastic, on_floor = TRUE),
		new /datum/stack_recipe("Plastic spoon", /obj/item/kitchen/utensil/pspoon, on_floor = TRUE),
		new /datum/stack_recipe("Plastic spork", /obj/item/kitchen/utensil/pspork, on_floor = TRUE),
	)),
	null,
	new /datum/stack_recipe("Warning cone", /obj/item/clothing/head/cone, 5, on_floor = TRUE),
	new /datum/stack_recipe("Wet floor sign", /obj/item/caution, 2),
	null,
	new /datum/stack_recipe("Water bottle", /obj/item/reagent_containers/glass/beaker/waterbottle/empty, on_floor = TRUE),
	new /datum/stack_recipe("Large water bottle", /obj/item/reagent_containers/glass/beaker/waterbottle/large/empty, 3, on_floor = TRUE),
))

/obj/item/stack/sheet/plastic
	name = "plastic"
	desc = "Compress dinosaur over millions of years, then refine, split and mold, and voila! You have plastic."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	item_state = "sheet-plastic"
	throwforce = 7
	origin_tech = "materials=1;biotech=1"
	materials = list(MAT_PLASTIC = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/plastic

/obj/item/stack/sheet/plastic/New()
	recipes = GLOB.plastic_recipes
	. = ..()

/obj/item/stack/sheet/plastic/fifty
	amount = 50

/obj/item/stack/sheet/plastic/five
	amount = 5

/*
 * Bamboo
 */

GLOBAL_LIST_INIT(bamboo_recipes, list(
	new /datum/stack_recipe("Bamboo spear", /obj/item/twohanded/bamboospear, 25, time = 90),
	new /datum/stack_recipe("Blow gun", /obj/item/gun/syringe/blowgun, 10, time = 70),
	new /datum/stack_recipe("Punji sticks trap", /obj/structure/punji_sticks, 5, time = 30, one_per_turf = TRUE, on_floor = TRUE),
))

/obj/item/stack/sheet/bamboo
	name = "bamboo cuttings"
	desc = "Finely cut bamboo sticks."
	singular_name = "cut bamboo"
	icon_state = "sheet-bamboo"
	item_state = "sheet-bamboo"
	icon = 'icons/obj/items.dmi'
	sheettype = "bamboo"
	force = 10
	throwforce = 10
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/bamboo

/obj/item/stack/sheet/bamboo/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bamboo_recipes
	return ..()
