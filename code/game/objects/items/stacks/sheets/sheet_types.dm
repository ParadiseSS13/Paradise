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
 */

/*
 * Metal
 */
var/global/list/datum/stack_recipe/metal_recipes = list(
	new /datum/stack_recipe("stool", /obj/structure/chair/stool, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("chair", /obj/structure/chair, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("shuttle seat", /obj/structure/chair/comfy/shuttle, 2, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (middle)", /obj/structure/chair/sofa, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (left)", /obj/structure/chair/sofa/left, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (right)", /obj/structure/chair/sofa/right, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("sofa (corner)", /obj/structure/chair/sofa/corner, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("barber chair", /obj/structure/chair/barber, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("wheelchair", /obj/structure/chair/wheelchair, 15, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("bed", /obj/structure/bed, 2, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("psychiatrist bed", /obj/structure/bed/psych, 5, one_per_turf = 1, on_floor = 1),
	null,
	new /datum/stack_recipe_list("office chairs",list(
		new /datum/stack_recipe("dark office chair", /obj/structure/chair/office/dark, 5, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("light office chair", /obj/structure/chair/office/light, 5, one_per_turf = 1, on_floor = 1),
	)),

	new /datum/stack_recipe_list("comfy chairs", list(
		new /datum/stack_recipe("beige comfy chair", /obj/structure/chair/comfy/beige, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("black comfy chair", /obj/structure/chair/comfy/black, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("brown comfy chair", /obj/structure/chair/comfy/brown, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("lime comfy chair", /obj/structure/chair/comfy/lime, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("teal comfy chair", /obj/structure/chair/comfy/teal, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("red comfy chair", /obj/structure/chair/comfy/red, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("blue comfy chair", /obj/structure/chair/comfy/blue, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("purple comfy chair", /obj/structure/chair/comfy/purp, 2, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("green comfy chair", /obj/structure/chair/comfy/green, 2, one_per_turf = 1, on_floor = 1),
	)),

	null,
	new /datum/stack_recipe("rack parts", /obj/item/rack_parts),
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
	new /datum/stack_recipe("reflector frame", /obj/structure/reflector, 5, time = 25, one_per_turf = 1, on_floor = 1),
	null,
	new /datum/stack_recipe_list("airlock assemblies", list(
		new /datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("public airlock assembly", /obj/structure/door_assembly/door_assembly_public, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("external maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_extmai, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 8, time = 50, one_per_turf = 1, on_floor = 1),
	)),
	null,
	new /datum/stack_recipe("mass driver button frame", /obj/item/mounted/frame/driver_button, 1, time = 50, one_per_turf = 0, on_floor = 1),
	new /datum/stack_recipe("light switch frame", /obj/item/mounted/frame/light_switch, 1, time = 50, one_per_turf = 0, on_floor = 1),
	null,
	new /datum/stack_recipe("grenade casing", /obj/item/grenade/chem_grenade),
	new /datum/stack_recipe("light fixture frame", /obj/item/mounted/frame/light_fixture, 2),
	new /datum/stack_recipe("small light fixture frame", /obj/item/mounted/frame/light_fixture/small, 1),
	null,
	new /datum/stack_recipe("apc frame", /obj/item/mounted/frame/apc_frame, 2),
	new /datum/stack_recipe("air alarm frame", /obj/item/mounted/frame/alarm_frame, 2),
	new /datum/stack_recipe("fire alarm frame", /obj/item/mounted/frame/firealarm, 2),
	new /datum/stack_recipe("intercom frame", /obj/item/mounted/frame/intercom, 2),
	new /datum/stack_recipe("extinguisher cabinet frame", /obj/item/mounted/frame/extinguisher, 2),
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
	resistance_flags = FIRE_PROOF
	origin_tech = "materials=1"
	merge_type = /obj/item/stack/sheet/metal
	point_value = 2

/obj/item/stack/sheet/metal/cyborg
	materials = list()

/obj/item/stack/sheet/metal/fifty
	amount = 50

/obj/item/stack/sheet/metal/ratvar_act()
	new /obj/item/stack/tile/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/metal/narsie_act()
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
	new /datum/stack_recipe("bomb assembly", /obj/machinery/syndicatebomb/empty, 3, time = 50),
	new /datum/stack_recipe("Surgery Table", /obj/machinery/optable, 5, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, one_per_turf = 1),
	new /datum/stack_recipe("Mass Driver frame", /obj/machinery/mass_driver_frame, 3, time = 50, one_per_turf = 1),
	null,
	new /datum/stack_recipe_list("airlock assemblies", list(
		new /datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 6, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("vault door assembly", /obj/structure/door_assembly/door_assembly_vault, 8, time = 50, one_per_turf = 1, on_floor = 1),
	)),
)

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	materials = list(MAT_METAL=2000, MAT_PLASMA=2000)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	resistance_flags = FIRE_PROOF
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=2"
	merge_type = /obj/item/stack/sheet/plasteel
	point_value = 23

/obj/item/stack/sheet/plasteel/New(var/loc, var/amount=null)
	recipes = plasteel_recipes
	return ..()

/*
 * Wood
 */
var/global/list/datum/stack_recipe/wood_recipes = list(
	new /datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1),
	new /datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20),
	new /datum/stack_recipe("wood table frame", /obj/structure/table_frame/wood, 2, time = 10), \
	new /datum/stack_recipe("wooden chair", /obj/structure/chair/wood, 3, time = 10, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("bookcase", /obj/structure/bookcase, 5, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("dresser", /obj/structure/dresser, 30, time = 50, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("drying rack", /obj/machinery/smartfridge/drying_rack, 10, time = 15, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("dog bed", /obj/structure/bed/dogbed, 10, time = 10, one_per_turf = 1, on_floor = 1), \
	new /datum/stack_recipe("rifle stock", /obj/item/weaponcrafting/stock, 10, time = 40),
	new /datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = 1, on_floor = 1),
	new /datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("display case chassis", /obj/structure/displaycase_chassis, 5, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("wooden buckler", /obj/item/shield/riot/buckler, 20, time = 40),
	new /datum/stack_recipe("apiary", /obj/structure/beebox, 40, time = 50),
	new /datum/stack_recipe("honey frame", /obj/item/honey_frame, 5, time = 10),
	new /datum/stack_recipe("wooden bucket", /obj/item/reagent_containers/glass/bucket/wooden, 3, time = 10),
	new /datum/stack_recipe("rake", /obj/item/cultivator/rake, 5, time = 10),
	new /datum/stack_recipe("ore box", /obj/structure/ore_box, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("baseball bat", /obj/item/melee/baseball_bat, 5, time = 15),
	new /datum/stack_recipe("loom", /obj/structure/loom, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	new /datum/stack_recipe("fermenting barrel", /obj/structure/fermenting_barrel, 30, time = 50),
	new /datum/stack_recipe("firebrand", /obj/item/match/firebrand, 2, time = 100)
)

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	gender = PLURAL
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"
	resistance_flags = FLAMMABLE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	merge_type = /obj/item/stack/sheet/wood

/obj/item/stack/sheet/wood/New(var/loc, var/amount=null)
	recipes = wood_recipes
	return ..()

/*
 * Cloth
 */
var/global/list/datum/stack_recipe/cloth_recipes = list ( \
	new/datum/stack_recipe("white jumpsuit", /obj/item/clothing/under/color/white, 3), \
	new/datum/stack_recipe("white shoes", /obj/item/clothing/shoes/white, 2), \
	new/datum/stack_recipe("white scarf", /obj/item/clothing/accessory/scarf/white, 1), \
	null, \
	new/datum/stack_recipe("backpack", /obj/item/storage/backpack, 4), \
	new/datum/stack_recipe("dufflebag", /obj/item/storage/backpack/duffel, 6), \
	null, \
	new/datum/stack_recipe("plant bag", /obj/item/storage/bag/plants, 4), \
	new/datum/stack_recipe("book bag", /obj/item/storage/bag/books, 4), \
	new/datum/stack_recipe("mining satchel", /obj/item/storage/bag/ore, 4), \
	new/datum/stack_recipe("chemistry bag", /obj/item/storage/bag/chemistry, 4), \
	new/datum/stack_recipe("bio bag", /obj/item/storage/bag/bio, 4), \
	null, \
	new/datum/stack_recipe("improvised gauze", /obj/item/stack/medical/bruise_pack/improvised, 1, 2, 6), \
	new/datum/stack_recipe("rag", /obj/item/reagent_containers/glass/rag, 1), \
	new/datum/stack_recipe("bedsheet", /obj/item/bedsheet, 3), \
	new/datum/stack_recipe("empty sandbag", /obj/item/emptysandbag, 4), \
	null, \
	new/datum/stack_recipe("fingerless gloves", /obj/item/clothing/gloves/fingerless, 1), \
	new/datum/stack_recipe("white gloves", /obj/item/clothing/gloves/color/white, 3), \
	new/datum/stack_recipe("white softcap", /obj/item/clothing/head/soft/mime, 2), \
	new/datum/stack_recipe("white beanie", /obj/item/clothing/head/beanie, 2), \
	null, \
	new/datum/stack_recipe("blindfold", /obj/item/clothing/glasses/sunglasses/blindfold, 3), \
	)

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
	recipes = cloth_recipes
	..()

/obj/item/stack/sheet/cloth/ten
	amount = 10

GLOBAL_LIST_INIT(durathread_recipes, list ( \
	new/datum/stack_recipe("durathread jumpsuit", /obj/item/clothing/under/misc/durathread, 4, time = 40),
	new/datum/stack_recipe("durathread beret", /obj/item/clothing/head/beret/durathread, 2, time = 40), \
	new/datum/stack_recipe("durathread beanie", /obj/item/clothing/head/beanie/durathread, 2, time = 40), \
	new/datum/stack_recipe("durathread bandana", /obj/item/clothing/mask/bandana/durathread, 1, time = 25), \
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
var/global/list/datum/stack_recipe/cardboard_recipes = list (
	new /datum/stack_recipe("box", /obj/item/storage/box),
	new /datum/stack_recipe("large box", /obj/item/storage/box/large, 4),
	new /datum/stack_recipe("patch pack", /obj/item/storage/pill_bottle/patch_pack, 2),
	new /datum/stack_recipe("light tubes", /obj/item/storage/box/lights/tubes),
	new /datum/stack_recipe("light bulbs", /obj/item/storage/box/lights/bulbs),
	new /datum/stack_recipe("mouse traps", /obj/item/storage/box/mousetraps),
	new /datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3),
	new /datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg),
	new /datum/stack_recipe("pizza box", /obj/item/pizzabox),
	new /datum/stack_recipe("folder", /obj/item/folder),
	new /datum/stack_recipe("cardboard tube", /obj/item/c_tube),
	new /datum/stack_recipe("cardboard box", /obj/structure/closet/cardboard, 4),
	new/datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5),
)

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
	origin_tech = "materials=1"
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/cardboard

/obj/item/stack/sheet/cardboard/New(var/loc, var/amt = null)
	recipes = cardboard_recipes
	return ..()

/*
 * Runed Metal
 */

var/global/list/datum/stack_recipe/cult = list ( \
	new/datum/stack_recipe/cult("runed door", /obj/machinery/door/airlock/cult, 1, time = 50, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe/cult("runed girder", /obj/structure/girder/cult, 1, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/cult("pylon", /obj/structure/cult/functional/pylon, 3, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/cult("forge", /obj/structure/cult/functional/forge, 5, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/cult("archives", /obj/structure/cult/functional/archives, 2, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/cult("altar", /obj/structure/cult/functional/altar, 5, time = 40, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal sheet"
	icon_state = "sheet-runed"
	item_state = "sheet-metal"
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal

/obj/item/stack/sheet/runed_metal/New()
	. = ..()
	icon_state = SSticker.cultdat?.runed_metal_icon_state

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/tile/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='warning'>The energies of this place interfere with the metal shaping!</span>")
		return

	return ..()

/datum/stack_recipe/cult
   one_per_turf = 1
   on_floor = 1

/datum/stack_recipe/cult/post_build(obj/item/stack/S, obj/result)
   if(ishuman(S.loc))
      var/mob/living/carbon/human/H = S.loc
      H.bleed(5)
   ..()

/obj/item/stack/sheet/runed_metal/fifty
	amount = 50

/obj/item/stack/sheet/runed_metal/New(var/loc, var/amount=null)
	recipes = cult
	return ..()

/*
 * Brass
 */
var/global/list/datum/stack_recipe/brass_recipes = list (\
	new/datum/stack_recipe("wall gear", /obj/structure/clockwork/wall_gear, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
	null,
	new/datum/stack_recipe/window("brass windoor", /obj/machinery/door/window/clockwork, 2, time = 30, on_floor = TRUE, window_checks = TRUE), \
	null,
	new/datum/stack_recipe/window("directional brass window", /obj/structure/window/reinforced/clockwork, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe/window("fulltile brass window", /obj/structure/window/reinforced/clockwork/fulltile, 2, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("brass chair", /obj/structure/chair/brass, 1, time = 0, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("brass table frame", /obj/structure/table_frame/brass, 1, time = 5, one_per_turf = TRUE, on_floor = TRUE), \
	)

/obj/item/stack/tile/brass
	name = "brass"
	desc = "Sheets made out of brass."
	singular_name = "brass sheet"
	icon_state = "sheet-brass"
	icon = 'icons/obj/items.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	turf_type = /turf/simulated/floor/clockwork

/obj/item/stack/tile/brass/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/tile/brass/New(loc, amount=null)
	recipes = brass_recipes
	. = ..()
	pixel_x = 0
	pixel_y = 0

/obj/item/stack/tile/brass/fifty
	amount = 50

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

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, one_per_turf = 1, on_floor = 1, time = 40), \
	new /datum/stack_recipe("wet floor sign", /obj/item/caution, 2), \
	new /datum/stack_recipe("water bottle", /obj/item/reagent_containers/glass/beaker/waterbottle/empty), \
	new /datum/stack_recipe("large water bottle", /obj/item/reagent_containers/glass/beaker/waterbottle/large/empty,3), \
	new /datum/stack_recipe("plastic crate", /obj/structure/closet/crate/plastic, 10, one_per_turf = 1, on_floor = 1), \
	new /datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 2, one_per_turf = 1, on_floor = 1), \
	new /datum/stack_recipe("plastic fork", /obj/item/kitchen/utensil/pfork, 1, on_floor = 1), \
	new /datum/stack_recipe("plastic spoon", /obj/item/kitchen/utensil/pspoon, 1, on_floor = 1), \
	new /datum/stack_recipe("plastic spork", /obj/item/kitchen/utensil/pspork, 1, on_floor = 1), \
	new /datum/stack_recipe("plastic knife", /obj/item/kitchen/knife/plastic, 1, on_floor = 1), \
	new /datum/stack_recipe("plastic bag", /obj/item/storage/bag/plasticbag, 3, on_floor = 1), \
	new /datum/stack_recipe("bear mould", /obj/item/kitchen/mould/bear, 1, on_floor = 1), \
	new /datum/stack_recipe("worm mould", /obj/item/kitchen/mould/worm, 1, on_floor = 1), \
	new /datum/stack_recipe("bean mould", /obj/item/kitchen/mould/bean, 1, on_floor = 1), \
	new /datum/stack_recipe("ball mould", /obj/item/kitchen/mould/ball, 1, on_floor = 1), \
	new /datum/stack_recipe("cane mould", /obj/item/kitchen/mould/cane, 1, on_floor = 1), \
	new /datum/stack_recipe("cash mould", /obj/item/kitchen/mould/cash, 1, on_floor = 1), \
	new /datum/stack_recipe("coin mould", /obj/item/kitchen/mould/coin, 1, on_floor = 1), \
	new /datum/stack_recipe("sucker mould", /obj/item/kitchen/mould/loli, 1, on_floor = 1)))

/obj/item/stack/sheet/plastic
	name = "plastic"
	desc = "Compress dinosaur over millions of years, then refine, split and mold, and voila! You have plastic."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
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
