/* Different misc types of sheets
 * Contains:
 * Metal
 * Plasteel
 * Wood
 * Bamboo
 * Cloth
 * Durathread
 * Cardboard
 * Soil
 * Runed Metal (cult)
 * Brass (clockwork cult)
 * Bones
 * Plastic
 * Saltpetre Crystal
 */

//////////////////////////////
// MARK: METAL
//////////////////////////////
GLOBAL_LIST_INIT(metal_recipes, list(
	new /datum/stack_recipe("stool", /obj/structure/chair/stool, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("barstool", /obj/structure/chair/stool/bar, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("chair (dark)", /obj/structure/chair, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("chair (light)", /obj/structure/chair/light, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("shuttle seat", /obj/structure/chair/comfy/shuttle, 2, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe_list("sofas", list(
		new /datum/stack_recipe("sofa (middle)", /obj/structure/chair/sofa, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("sofa (left)", /obj/structure/chair/sofa/left, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("sofa (right)", /obj/structure/chair/sofa/right, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("sofa (corner)", /obj/structure/chair/sofa/corner, 1, one_per_turf = TRUE, on_floor = TRUE)
		)),
	new /datum/stack_recipe_list("corporate sofas", list(
		new /datum/stack_recipe("sofa (middle)", /obj/structure/chair/sofa/corp, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("sofa (left)", /obj/structure/chair/sofa/corp/left, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("sofa (right)", /obj/structure/chair/sofa/corp/right, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("sofa (corner)", /obj/structure/chair/sofa/corp/corner, 1, one_per_turf = TRUE, on_floor = TRUE),
		)),
	new /datum/stack_recipe_list("benches", list(
		new /datum/stack_recipe("bench (middle)", /obj/structure/chair/sofa/bench, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bench (left)", /obj/structure/chair/sofa/bench/left, 1, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bench (right)", /obj/structure/chair/sofa/bench/right, 1, one_per_turf = TRUE, on_floor = TRUE),
		)),
	new /datum/stack_recipe("barber chair", /obj/structure/chair/barber, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("wheelchair", /obj/structure/chair/wheelchair, 15, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("bed", /obj/structure/bed, 2, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("psychiatrist bed", /obj/structure/bed/psych, 5, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("bronze ashtray", /obj/item/ashtray/bronze, 1, time = 1 SECONDS),
	null,
	new /datum/stack_recipe_list("office chairs",list(
		new /datum/stack_recipe("dark office chair", /obj/structure/chair/office/dark, 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("light office chair", /obj/structure/chair/office, 5, one_per_turf = TRUE, on_floor = TRUE),
	)),

	new /datum/stack_recipe_list("comfy chairs", list(
		new /datum/stack_recipe("corporate comfy chair", /obj/structure/chair/comfy/corp, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("red comfy chair", /obj/structure/chair/comfy/red, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("orange comfy chair", /obj/structure/chair/comfy/orange, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("yellow comfy chair", /obj/structure/chair/comfy/yellow, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("green comfy chair", /obj/structure/chair/comfy/green, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("teal comfy chair", /obj/structure/chair/comfy/teal, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("lime comfy chair", /obj/structure/chair/comfy/lime, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("blue comfy chair", /obj/structure/chair/comfy/blue, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("purple comfy chair", /obj/structure/chair/comfy/purp, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("brown comfy chair", /obj/structure/chair/comfy/brown, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("black comfy chair", /obj/structure/chair/comfy/black, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("beige comfy chair", /obj/structure/chair/comfy/beige, 2, one_per_turf = TRUE, on_floor = TRUE),
	)),

	null,
	new /datum/stack_recipe("rack parts", /obj/item/rack_parts),
	new /datum/stack_recipe("closet", /obj/structure/closet, 2, time = 1.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("canister", /obj/machinery/atmospherics/portable/canister, 10, time = 1.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20),
	new /datum/stack_recipe/rods("metal rod", /obj/item/stack/rods, 1, 2, 50),
	null,
	new /datum/stack_recipe("computer frame", /obj/structure/computerframe, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("machine frame", /obj/structure/machine_frame, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("firelock frame", /obj/structure/firelock_frame, 3, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("meatspike frame", /obj/structure/kitchenspike_frame, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("reflector frame", /obj/structure/reflector, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("storage shelf", /obj/structure/shelf, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("metal bookcase", /obj/structure/bookcase/metal, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("gun rack", /obj/structure/gunrack, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("airlock assemblies", list(
		new /datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("public airlock assembly", /obj/structure/door_assembly/door_assembly_public, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("virology airlock assembly", /obj/structure/door_assembly/door_assembly_viro, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("external maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_extmai, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 8, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	)),
	null,
	new /datum/stack_recipe("mass driver button frame", /obj/item/mounted/frame/driver_button, 1, time = 5 SECONDS, one_per_turf = FALSE, on_floor = TRUE),
	new /datum/stack_recipe("light switch frame", /obj/item/mounted/frame/light_switch, 1, time = 5 SECONDS, one_per_turf = FALSE, on_floor = TRUE),
	new /datum/stack_recipe("window tint control button frame", /obj/item/mounted/frame/light_switch/windowtint, 1, time = 5 SECONDS, one_per_turf = FALSE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("grenade casing", /obj/item/grenade/chem_grenade),
	new /datum/stack_recipe("light fixture frame", /obj/item/mounted/frame/light_fixture, 2),
	new /datum/stack_recipe("small light fixture frame", /obj/item/mounted/frame/light_fixture/small, 1),
	new /datum/stack_recipe("floor light fixture frame", /obj/item/mounted/frame/light_fixture/floor, 3),
	null,
	new /datum/stack_recipe("apc frame", /obj/item/mounted/frame/apc_frame, 2),
	new /datum/stack_recipe("air alarm frame", /obj/item/mounted/frame/alarm_frame, 2),
	new /datum/stack_recipe("fire alarm frame", /obj/item/mounted/frame/firealarm, 2),
	new /datum/stack_recipe("intercom frame", /obj/item/mounted/frame/intercom, 2),
	new /datum/stack_recipe/barsign_frame("bar sign frame", /obj/machinery/barsign, 4),
	new /datum/stack_recipe("extinguisher cabinet frame", /obj/item/mounted/frame/extinguisher, 2),
	null,
	new /datum/stack_recipe_list("gym equipment", list(
		new /datum/stack_recipe("bench press", /obj/structure/weightmachine/weightlifter, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("chest press", /obj/structure/weightmachine/stacklifter, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	)),
))

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of steel."
	icon_state = "sheet-metal"
	singular_name = "metal sheet"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT)
	throwforce = 10.0
	flags = CONDUCT
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/metal
	point_value = 2
	table_type = /obj/structure/table

/obj/item/stack/sheet/metal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Metal is used in various different construction sequences.</span>"

/obj/item/stack/sheet/metal/examine_more(mob/user)
	. = ..()
	. += "At its core, steel is an alloy of iron and carbon. The addition of a wide range of other elements and the use of various metallurgical processes allows control over nearly every property of the resulting alloy, \
	from hardness and ductility to corrosion resistance."
	. += ""
	. += "Its use is ubiquitous across all post-industrial civilisations and is extensively used within all areas of construction, as well as the manufacture of almost any device that one can care to imagine."

/obj/item/stack/sheet/metal/cyborg
	energy_type = /datum/robot_storage/material/metal
	is_cyborg = TRUE
	materials = list()

/obj/item/stack/sheet/metal/cyborg/examine(mob/user)
	. = ..()
	var/mob/living/silicon/robot/robot = user
	if(!istype(robot.module, /obj/item/robot_module/drone))
		. += "<span class='notice'>You can refill your metal by using your <b>magnetic gripper</b> on the Ore Redemption Machine, or by picking it up from the ground.</span>"

/obj/item/stack/sheet/metal/cyborg/drone
	energy_type = /datum/robot_storage/energy/metal

/obj/item/stack/sheet/metal/ten
	amount = 10

/obj/item/stack/sheet/metal/fifty
	amount = 50

/obj/item/stack/sheet/metal/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/metal/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.metal_recipes

//////////////////////////////
// MARK: PLASTEEL
//////////////////////////////
GLOBAL_LIST_INIT(plasteel_recipes, list(
	new /datum/stack_recipe("AI core", /obj/structure/ai_core, 4, time = 5 SECONDS, one_per_turf = TRUE),
	new /datum/stack_recipe("bomb assembly", /obj/machinery/syndicatebomb/empty, 3, time = 5 SECONDS),
	new /datum/stack_recipe("Surgery Table", /obj/machinery/optable, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 5 SECONDS, one_per_turf = TRUE),
	new /datum/stack_recipe("military bookcase", /obj/structure/bookcase/military, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Mass Driver frame", /obj/machinery/mass_driver_frame, 3, time = 5 SECONDS, one_per_turf = TRUE),
	new /datum/stack_recipe("hardened wheelchair", /obj/structure/chair/wheelchair/plasteel, 15, time = 6 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("airlock assemblies", list(
		new /datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 6, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("vault door assembly", /obj/structure/door_assembly/door_assembly_vault, 8, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	)),
))

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	singular_name = "plasteel sheet"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 80)
	resistance_flags = FIRE_PROOF
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=2"
	merge_type = /obj/item/stack/sheet/plasteel
	point_value = 23
	table_type = /obj/structure/table/reinforced

/obj/item/stack/sheet/plasteel/examine_more(mob/user)
	. = ..()
	. += "A high-performance steel superalloy that incorporates a significant quantity of plasma. The plasma forms cross-links with the other constituants of the metal, \
	pulling them in and bonding with them extremely strongly. It is exceptionally tough, heat-resistant, corrosion-resistant, and about 2.5 times as dense as regular steel."
	. += ""
	. += "It is used in the constuction of top-grade building and vehicle armour and some specialised tools and weapons. It is too heavy to make starships out of, \
	although it is sometimes incorporated into the armour of critical areas. Its high density also makes it an excellent material for radiation shielding."

/obj/item/stack/sheet/plasteel/five
	amount = 5

/obj/item/stack/sheet/plasteel/fifteen
	amount = 15

/obj/item/stack/sheet/plasteel/fifty
	amount = 50

/obj/item/stack/sheet/plasteel/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.plasteel_recipes

//////////////////////////////
// MARK: WOOD
//////////////////////////////
GLOBAL_LIST_INIT(wood_recipes, list(
	new /datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1),
	new /datum/stack_recipe("baseball bat", /obj/item/melee/baseball_bat, 5, time = 1.5 SECONDS),
	new /datum/stack_recipe("wooden buckler", /obj/item/shield/riot/buckler, 20, time = 4 SECONDS),
	new /datum/stack_recipe("rake", /obj/item/cultivator/rake, 5, time = 1 SECONDS),
	new /datum/stack_recipe("wooden bucket", /obj/item/reagent_containers/glass/bucket/wooden, 3, time = 1 SECONDS),
	new /datum/stack_recipe("firebrand", /obj/item/match/firebrand, 2, time = 10 SECONDS),
	new /datum/stack_recipe("mug", /obj/item/reagent_containers/drinks/mug/wood, 1, time = 0.5 SECONDS),
	new /datum/stack_recipe("notice board", /obj/item/mounted/noticeboard, 5, time = 5 SECONDS),
	null,
	new /datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20),
	new /datum/stack_recipe_list("wood structures", list(
		new /datum/stack_recipe("wood table frame", /obj/structure/table_frame/wood, 2, time = 1 SECONDS),
		new /datum/stack_recipe("wooden chair", /obj/structure/chair/wood, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("wooden stool", /obj/structure/chair/stool/wood, 2, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bookcase", /obj/structure/bookcase, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("dresser", /obj/structure/dresser, 30, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("wooden marker", /obj/structure/signpost/wood, 2, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("spear rack", /obj/structure/spear_rack, 2, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("dog bed", /obj/structure/bed/dogbed, 10, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("slab bed", /obj/structure/bed/wood, 5, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("wooden airlock assembly", /obj/structure/door_assembly/door_assembly_wood, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 1.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("torch sconce", /obj/structure/lightable/torch, 5, time = 3 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("wooden storage shelf", /obj/structure/shelf/wood, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	new /datum/stack_recipe_list("pews", list(
		new /datum/stack_recipe("pew (middle)", /obj/structure/chair/sofa/pew, 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("pew (left)", /obj/structure/chair/sofa/pew/left, 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("pew (right)", /obj/structure/chair/sofa/pew/right, 5, one_per_turf = TRUE, on_floor = TRUE),
		)),
	null,
	new /datum/stack_recipe("drying rack", /obj/machinery/smartfridge/drying_rack, 10, time = 1.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("rifle stock", /obj/item/weaponcrafting/stock, 10, time = 4 SECONDS),
	new /datum/stack_recipe("display case chassis", /obj/structure/displaycase_chassis, 5, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("apiary", /obj/structure/beebox, 40, time = 5 SECONDS),
	new /datum/stack_recipe("honey frame", /obj/item/honey_frame, 5, time = 1 SECONDS),
	new /datum/stack_recipe("ore box", /obj/structure/ore_box, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("loom", /obj/structure/loom, 10, time = 1.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("fermenting barrel", /obj/structure/fermenting_barrel, 30, time = 5 SECONDS),
	new /datum/stack_recipe("compost bin", /obj/machinery/compost_bin, 10, time = 1.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("roulette", /obj/structure/roulette, 10, time = 3 SECONDS, one_per_turf = TRUE, on_floor = TRUE)
))

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-wood"
	gender = PLURAL
	singular_name = "wood plank"
	origin_tech = "materials=1;biotech=1"
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 0)
	merge_type = /obj/item/stack/sheet/wood
	sheettype = "wood"
	table_type = /obj/structure/table/wood

/obj/item/stack/sheet/wood/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.wood_recipes

/obj/item/stack/sheet/wood/fifty
	amount = 50

/obj/item/stack/sheet/wood/cyborg
	energy_type = /datum/robot_storage/energy/wood
	is_cyborg = TRUE

//////////////////////////////
// MARK: BAMBOO
//////////////////////////////
GLOBAL_LIST_INIT(bamboo_recipes, list(
	new /datum/stack_recipe("punji sticks trap", /obj/structure/punji_sticks, req_amount = 5, time = 3 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("bamboo spear", /obj/item/spear/bamboo, req_amount = 25, time = 9 SECONDS),
	new /datum/stack_recipe("blow gun", /obj/item/gun/syringe/blowgun, req_amount = 10, time = 7 SECONDS),
	new /datum/stack_recipe("rice hat", /obj/item/clothing/head/rice_hat, req_amount = 10, time = 7 SECONDS),
	null,
	new /datum/stack_recipe("bamboo mat piece", /obj/item/stack/tile/bamboo, req_amount = 1, res_amount = 4, max_res_amount = 20),
	new /datum/stack_recipe_list("tatami mats", list(
		new /datum/stack_recipe("green tatami", /obj/item/stack/tile/bamboo/tatami, req_amount = 1, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("purple tatami", /obj/item/stack/tile/bamboo/tatami/purple, req_amount = 1, res_amount = 4, max_res_amount = 20),
		new /datum/stack_recipe("black tatami", /obj/item/stack/tile/bamboo/tatami/black, req_amount = 1, res_amount = 4, max_res_amount = 20),
		)),
	null,
	new /datum/stack_recipe("bamboo stool", /obj/structure/chair/stool/bamboo, req_amount = 2, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe_list("bamboo benches", list(
		new /datum/stack_recipe("bamboo bench (middle)", /obj/structure/chair/sofa/bamboo, req_amount = 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bamboo bench (left)", /obj/structure/chair/sofa/bamboo/left, req_amount = 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bamboo bench (right)", /obj/structure/chair/sofa/bamboo/right, req_amount = 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE)
		)),
	))

/obj/item/stack/sheet/bamboo
	name = "bamboo cuttings"
	desc = "Finely cut bamboo sticks."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-bamboo"
	singular_name = "cut bamboo stick"
	resistance_flags = FLAMMABLE
	sheettype = "bamboo"
	merge_type = /obj/item/stack/sheet/bamboo

/obj/item/stack/sheet/bamboo/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.bamboo_recipes

/obj/item/stack/sheet/bamboo/fifty
	amount = 50

//////////////////////////////
// MARK: CLOTH
//////////////////////////////
GLOBAL_LIST_INIT(cloth_recipes, list (
	new /datum/stack_recipe_list("cloth clothings", list(
		new /datum/stack_recipe("white jumpsuit", /obj/item/clothing/under/color/white, 3),
		new /datum/stack_recipe("white scarf", /obj/item/clothing/neck/scarf/white, 1),
		new /datum/stack_recipe("white shoes", /obj/item/clothing/shoes/white, 2),
		new /datum/stack_recipe("cloth footwraps", /obj/item/clothing/shoes/footwraps, 2),
		null,
		new /datum/stack_recipe("cloth handwraps", /obj/item/clothing/gloves/handwraps, 2),
		new /datum/stack_recipe("fingerless gloves", /obj/item/clothing/gloves/fingerless, 1),
		new /datum/stack_recipe("white gloves", /obj/item/clothing/gloves/color/white, 3),
		new /datum/stack_recipe("white softcap", /obj/item/clothing/head/soft/white, 2),
		new /datum/stack_recipe("white beanie", /obj/item/clothing/head/beanie, 2),
	)),
	null,
	new /datum/stack_recipe_list("cloth bags", list(
		new /datum/stack_recipe("backpack", /obj/item/storage/backpack, 4),
		new /datum/stack_recipe("satchel", /obj/item/storage/backpack/satchel_norm, 4),
		new /datum/stack_recipe("dufflebag", /obj/item/storage/backpack/duffel, 6),
		null,
		new /datum/stack_recipe("plant bag", /obj/item/storage/bag/plants, 4),
		new /datum/stack_recipe("book bag", /obj/item/storage/bag/books, 4),
		new /datum/stack_recipe("mining satchel", /obj/item/storage/bag/ore, 4),
		new /datum/stack_recipe("chemistry bag", /obj/item/storage/bag/chemistry, 4),
		new /datum/stack_recipe("bio bag", /obj/item/storage/bag/bio, 4),
		new /datum/stack_recipe("fish bag", /obj/item/storage/bag/fish, 4),
		new /datum/stack_recipe("mail bag", /obj/item/storage/bag/mail, 4),
		new /datum/stack_recipe("construction bag", /obj/item/storage/bag/construction, 4),
		new /datum/stack_recipe("money bag", /obj/item/storage/bag/money, 3),
	)),
	null,
	new /datum/stack_recipe("improvised gauze", /obj/item/stack/medical/bruise_pack/improvised, 1, 2, 6),
	new /datum/stack_recipe("imrovised drapes", /obj/item/surgical_drapes/improvised, 1),
	new /datum/stack_recipe("rag", /obj/item/reagent_containers/glass/rag, 1),
	new /datum/stack_recipe("bedsheet", /obj/item/bedsheet, 3),
	new /datum/stack_recipe("empty sandbag", /obj/item/emptysandbag, 4),
	new /datum/stack_recipe("punching bag", /obj/structure/punching_bag, 10, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("blindfold", /obj/item/clothing/glasses/sunglasses/blindfold, 3),
	new /datum/stack_recipe("tattered blindfold", /obj/item/clothing/glasses/sunglasses/blindfold/fake, 2),
))

/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "Is it cotton? Linen? Denim? Burlap? Canvas? You can't tell."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-cloth"
	singular_name = "cloth roll"
	origin_tech = "materials=2"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cloth
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stack/sheet/cloth/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.cloth_recipes

/obj/item/stack/sheet/cloth/ten
	amount = 10

/obj/item/stack/sheet/cloth/fifty
	amount = 50

//////////////////////////////
// MARK: DURATHREAD
//////////////////////////////

GLOBAL_LIST_INIT(durathread_recipes, list (
	new /datum/stack_recipe("durathread jumpsuit", /obj/item/clothing/under/misc/durathread, 4, time = 4 SECONDS),
	new /datum/stack_recipe("durathread beret", /obj/item/clothing/head/beret/durathread, 2, time = 4 SECONDS),
	new /datum/stack_recipe("durathread beanie", /obj/item/clothing/head/beanie/durathread, 2, time = 4 SECONDS),
	new /datum/stack_recipe("durathread bandana", /obj/item/clothing/mask/bandana/durathread, 1, time = 2.5 SECONDS),
	new /datum/stack_recipe("surgical drapes", /obj/item/surgical_drapes, 1, time = 3 SECONDS)
	))

/obj/item/stack/sheet/durathread
	name = "durathread"
	desc = "A fabric sown from incredibly durable threads, known for its usefulness in armor production."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-durathread"
	singular_name = "durathread roll"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/durathread
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stack/sheet/durathread/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.durathread_recipes
	return ..()

/obj/item/stack/sheet/durathread/fifty
	amount = 50

/obj/item/stack/sheet/cotton
	name = "raw cotton bundle"
	desc = "A bundle of raw cotton ready to be spun on the loom."
	singular_name = "raw cotton ball"
	icon_state = "sheet-cotton"
	icon = 'icons/obj/stacks/organic.dmi'
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

//////////////////////////////
// MARK: CARDBOARD
//////////////////////////////
GLOBAL_LIST_INIT(cardboard_recipes, list (
	new /datum/stack_recipe("box", /obj/item/storage/box),
	new /datum/stack_recipe("large box", /obj/item/storage/box/large, 4),
	new /datum/stack_recipe("patch pack", /obj/item/storage/pill_bottle/patch_pack, 2),
	new /datum/stack_recipe("light tubes", /obj/item/storage/box/lights/tubes),
	new /datum/stack_recipe("light bulbs", /obj/item/storage/box/lights/bulbs),
	new /datum/stack_recipe("mouse traps", /obj/item/storage/box/mousetraps),
	new /datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3),
	new /datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg),
	new /datum/stack_recipe("pizza box", /obj/item/pizzabox),
	new /datum/stack_recipe("donut box", /obj/item/storage/fancy/donut_box/empty, 1),
	new /datum/stack_recipe("folder", /obj/item/folder),
	new /datum/stack_recipe("cardboard tube", /obj/item/c_tube),
	new /datum/stack_recipe("cardboard box", /obj/structure/closet/cardboard, 4),
	new /datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5),
	null,
	new /datum/stack_recipe_list("chess pieces", list(
		new /datum/stack_recipe("black pawn", /obj/item/chesspiece/bpawn, 1),
		new /datum/stack_recipe("black rook", /obj/item/chesspiece/brook, 1),
		new /datum/stack_recipe("black knight", /obj/item/chesspiece/bknight, 1),
		new /datum/stack_recipe("black bishop", /obj/item/chesspiece/bbishop, 1),
		new /datum/stack_recipe("black queen", /obj/item/chesspiece/bqueen, 1),
		new /datum/stack_recipe("black king", /obj/item/chesspiece/bking, 1),
		new /datum/stack_recipe("white pawn", /obj/item/chesspiece/wpawn, 1),
		new /datum/stack_recipe("white rook", /obj/item/chesspiece/wrook, 1),
		new /datum/stack_recipe("white knight", /obj/item/chesspiece/wknight, 1),
		new /datum/stack_recipe("white bishop", /obj/item/chesspiece/wbishop, 1),
		new /datum/stack_recipe("white queen", /obj/item/chesspiece/wqueen, 1),
		new /datum/stack_recipe("white king", /obj/item/chesspiece/wking, 1),
		)),
))

/obj/item/stack/sheet/cardboard/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stamp/clown) && !isstorage(loc))
		var/atom/droploc = drop_location()
		if(use(1))
			playsound(I, 'sound/items/bikehorn.ogg', 50, TRUE, -1)
			to_chat(user, "<span class='notice'>You stamp the cardboard! It's a clown box! Honk!</span>")
			new/obj/item/storage/box/clown(droploc) //bugfix
	else
		. = ..()

/// BubbleWrap
/obj/item/stack/sheet/cardboard
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "sheet-card"
	singular_name = "cardboard sheet"
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/cardboard

/obj/item/stack/sheet/cardboard/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.cardboard_recipes

/obj/item/stack/sheet/cardboard/fifty
	amount = 50

//////////////////////////////
// MARK: SOIL
//////////////////////////////
GLOBAL_LIST_INIT(soil_recipes, list (
	new /datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE)
))

/obj/item/stack/sheet/soil
	name = "soil"
	singular_name = "soil clump"
	desc = "A clump of fertile soil which can be used to make a plot."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-soil"
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/soil

/obj/item/stack/sheet/soil/Initialize(mapload, loc, amt)
	recipes = GLOB.soil_recipes
	return ..()

//////////////////////////////
// MARK: RUNED METAL
//////////////////////////////

GLOBAL_LIST_INIT(cult_recipes, list (
	new /datum/stack_recipe_list("furniture ", list(
		new /datum/stack_recipe("runed metal chair", /obj/structure/chair/comfy/cult, 2, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe/cult("runed metal table frame", /obj/structure/table_frame/cult, 1, time = 0.5 SECONDS, one_per_turf = TRUE, cult_structure = TRUE),
	)),
	new /datum/stack_recipe/cult("runed door (stuns non-cultists)", /obj/machinery/door/airlock/cult, 3, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("runed girder (used to make cult walls)", /obj/structure/girder/cult, 1, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("pylon (heals nearby cultists)", /obj/structure/cult/functional/pylon, 4, time = 4 SECONDS, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("forge (crafts shielded robes, flagellant's robes, and mirror shields)", /obj/structure/cult/functional/forge, 3, time = 4 SECONDS, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("archives (crafts zealot's blindfolds, shuttle curse orbs, veil shifters, reality sunderers, and blank tarot cards)", /obj/structure/cult/functional/archives, 3, time = 4 SECONDS, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	new /datum/stack_recipe/cult("altar (crafts eldritch whetstones, construct shells, and flasks of unholy water)", /obj/structure/cult/functional/altar, 3, time = 4 SECONDS, one_per_turf = TRUE, on_floor = TRUE, cult_structure = TRUE),
	))

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	icon_state = "sheet-runed"
	singular_name = "runed metal sheet"
	sheettype = "runed"
	table_type = /obj/structure/table/reinforced/cult
	merge_type = /obj/item/stack/sheet/runed_metal

/obj/item/stack/sheet/runed_metal/examine_more(mob/user)
	. = ..()
	. += "There are things lurking in the darkness beyond our comprehension, sealed away by terrible writs. They scheme and plot amongst themselves and with the fools and unwilling converts that serve them in our world."
	. += ""
	. += "Mundane matter turned extraordinary by the dark blessings of those things that lie in wait - such as this - is the canvas used to build the works that shall one day tear asunder the veil that shields our world."

/obj/item/stack/sheet/runed_metal/Initialize(mapload, new_amount, merge)
	. = ..()
	icon_state = GET_CULT_DATA(runed_metal_icon_state, initial(icon_state))
	recipes = GLOB.cult_recipes

/obj/item/stack/sheet/runed_metal/attack_self__legacy__attackchain(mob/living/user)
	if(!IS_CULTIST(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	if(usr.holy_check())
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

//////////////////////////////
// MARK: BRASS
//////////////////////////////
GLOBAL_LIST_INIT(brass_recipes, list (
	new /datum/stack_recipe("wall gear", /obj/structure/clockwork/wall_gear, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe/window("brass windoor", /obj/machinery/door/window/clockwork, 2, time = 3 SECONDS, on_floor = TRUE, window_checks = TRUE),
	null,
	new /datum/stack_recipe/window("directional brass window", /obj/structure/window/reinforced/clockwork, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe/window("fulltile brass window", /obj/structure/window/reinforced/clockwork/fulltile, 2, time = 0 SECONDS, on_floor = TRUE, window_checks = TRUE),
	new /datum/stack_recipe("brass chair", /obj/structure/chair/brass, 1, time = 0 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe_list("pews", list(
		new /datum/stack_recipe("brass pew (middle)", /obj/structure/chair/sofa/pew/clockwork, 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("brass pew (left)", /obj/structure/chair/sofa/pew/clockwork/left, 5, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("brass pew (right)", /obj/structure/chair/sofa/pew/clockwork/right, 5, one_per_turf = TRUE, on_floor = TRUE)
		)),
	new /datum/stack_recipe("pinion airlock assembly", /obj/structure/door_assembly/door_assembly_clockwork, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("brass table frame", /obj/structure/table_frame/brass, 1, time = 0.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("brass storage shelf", /obj/structure/shelf/clockwork, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("brass gun rack", /obj/structure/gunrack/clockwork, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("brass light fixture frame", /obj/item/mounted/frame/light_fixture/clockwork, 2, time = 0 SECONDS, one_per_turf = FALSE, on_floor = FALSE),
	new /datum/stack_recipe("small brass light fixture frame", /obj/item/mounted/frame/light_fixture/clockwork/small, 1, time = 0 SECONDS, one_per_turf = FALSE, on_floor = FALSE),
	new /datum/stack_recipe("brass floor light fixture frame", /obj/item/mounted/frame/light_fixture/clockwork/floor, 3, time = 0 SECONDS, one_per_turf = FALSE, on_floor = FALSE),
	))

/obj/item/stack/tile/brass
	name = "brass"
	desc = "Sheets made out of brass."
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "sheet-brass"
	singular_name = "brass sheet"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	turf_type = /turf/simulated/floor/clockwork
	table_type = /obj/structure/table/reinforced/brass
	dynamic_icon_state = TRUE
	materials = list(MAT_BRASS = 2000)

/obj/item/stack/tile/brass/examine_more(mob/user)
	. = ..()
	. += "Brass describes a class of alloys made primarily from copper and zinc, with colours ranging from yellowish-white, gold, brown, and reddish. \
	It is a highly workable material with good electrical and thermal conductivity, and corrosion resistance."
	. += ""
	. += "It is used for ornamental and fashion applications (sometimes as a cheap substitute for gold), musical instruments, some specialised electronics, and spark-free tooling."
	. += ""
	. += "Brass is also associated with the Cult of the Clockwork Justiciar - Ratvar. His followers use it extensively in their works and creations, although it has been a long time since anyone has seen them..."

/obj/item/stack/tile/brass/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/tile/brass/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.brass_recipes
	pixel_x = 0
	pixel_y = 0

/obj/item/stack/tile/brass/fifty
	amount = 50

//////////////////////////////
// MARK: BONES
//////////////////////////////
/obj/item/stack/sheet/bone
	name = "bones"
	desc = "Someone's been drinking their milk."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "bone"
	singular_name = "bone"
	force = 7
	origin_tech = "materials=2;biotech=2"

//////////////////////////////
// MARK: PLASTIC
//////////////////////////////

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS),
	new /datum/stack_recipe("wet floor sign", /obj/item/caution, 2),
	new /datum/stack_recipe("water bottle", /obj/item/reagent_containers/glass/beaker/waterbottle/empty),
	new /datum/stack_recipe("large water bottle", /obj/item/reagent_containers/glass/beaker/waterbottle/large/empty,3),
	new /datum/stack_recipe("spray bottle", /obj/item/reagent_containers/spray/empty, 6),
	null,
	new /datum/stack_recipe_list("first-aid kits", list(
		new /datum/stack_recipe("first-aid kit", /obj/item/storage/firstaid/regular, 4),
		new /datum/stack_recipe("brute trauma treatment kit", /obj/item/storage/firstaid/brute, 4),
		new /datum/stack_recipe("fire first-aid kit", /obj/item/storage/firstaid/fire, 4),
		new /datum/stack_recipe("toxin first aid kit", /obj/item/storage/firstaid/toxin, 4),
		new /datum/stack_recipe("oxygen deprivation first aid kit", /obj/item/storage/firstaid/o2, 4),
		new /datum/stack_recipe("advanced first-aid kit", /obj/item/storage/firstaid/adv, 4),
		new /datum/stack_recipe("machine repair kit", /obj/item/storage/firstaid/machine, 4),
		new /datum/stack_recipe("aquatic starter kit", /obj/item/storage/firstaid/aquatic_kit, 4),
		)),
	new /datum/stack_recipe("pill bottle", /obj/item/storage/pill_bottle),
	new /datum/stack_recipe("IV bag", /obj/item/reagent_containers/iv_bag, 2),
	new /datum/stack_recipe("biomesh", /obj/item/biomesh, 1),
	new /datum/stack_recipe("plastic crate", /obj/structure/closet/crate/plastic, 10, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 1, time = 1 SECONDS),
	new /datum/stack_recipe("plastic bag", /obj/item/storage/bag/plasticbag, 3, on_floor = TRUE),
	new /datum/stack_recipe("warning cone", /obj/item/clothing/head/cone, 5, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("plastic utensils", list(
		new /datum/stack_recipe("plastic fork", /obj/item/kitchen/utensil/pfork, 1, on_floor = TRUE),
		new /datum/stack_recipe("plastic spoon", /obj/item/kitchen/utensil/pspoon, 1, on_floor = TRUE),
		new /datum/stack_recipe("plastic spork", /obj/item/kitchen/utensil/pspork, 1, on_floor = TRUE),
		new /datum/stack_recipe("plastic knife", /obj/item/kitchen/knife/plastic, 1, on_floor = TRUE),
		)),
	new /datum/stack_recipe_list("plastic moulds", list(
		new /datum/stack_recipe("bear mould", /obj/item/reagent_containers/cooking/mould/bear, 1, on_floor = TRUE),
		new /datum/stack_recipe("worm mould", /obj/item/reagent_containers/cooking/mould/worm, 1, on_floor = TRUE),
		new /datum/stack_recipe("bean mould", /obj/item/reagent_containers/cooking/mould/bean, 1, on_floor = TRUE),
		new /datum/stack_recipe("ball mould", /obj/item/reagent_containers/cooking/mould/ball, 1, on_floor = TRUE),
		new /datum/stack_recipe("cane mould", /obj/item/reagent_containers/cooking/mould/cane, 1, on_floor = TRUE),
		new /datum/stack_recipe("cash mould", /obj/item/reagent_containers/cooking/mould/cash, 1, on_floor = TRUE),
		new /datum/stack_recipe("coin mould", /obj/item/reagent_containers/cooking/mould/coin, 1, on_floor = TRUE),
		new /datum/stack_recipe("sucker mould", /obj/item/reagent_containers/cooking/mould/loli, 1, on_floor = TRUE),
		)),
	))

/obj/item/stack/sheet/plastic
	name = "plastic"
	desc = "Compress dinosaur over millions of years, then refine, split and mold, and voila! You have plastic."
	icon_state = "sheet-plastic"
	singular_name = "plastic sheet"
	throwforce = 7
	origin_tech = "materials=1;biotech=1"
	materials = list(MAT_PLASTIC = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/plastic

/obj/item/stack/sheet/plastic/examine_more(mob/user)
	. = ..()
	. += "Plastics are a large and diverse range of materials consisting of long-chain polymers, typically based on hydrocarbons, \
	but other chemical groups can be attached to the molecular backbone to achieve specific properties. \
	They are generally characterised as very lightweight, easily mouldable, and versatile. Most plastics either cannot be recycled, or are cost-prohibitive to recycle."
	. += ""
	. += "Despite the extensive uses of plastics, they are not as ubiquitous as other materials (especially steel). This is due to a combination of environmental regulations, \
	established market patterns, and the operational requirements for many space-based installations to employ easily recycled materials to conserve limited supplies."

/obj/item/stack/sheet/plastic/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.plastic_recipes

/obj/item/stack/sheet/plastic/fifty
	amount = 50

/obj/item/stack/sheet/plastic/five
	amount = 5

/*
 * Saltpetre crystal
 */

/obj/item/stack/sheet/saltpetre_crystal
	name = "saltpetre crystal"
	desc = "A bunch of saltpetre crystals. Can be ground to get liquid saltpetre that can be used to dope hydroponics trays and soil plots."
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-saltpetre"
	singular_name = "saltpetre crystal"
	origin_tech = "materials=1;biotech=1"
