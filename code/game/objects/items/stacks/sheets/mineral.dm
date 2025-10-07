/*
Mineral Sheets
	Contains:
		- Sandstone
		- Diamond
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Bananium
		- Tranqillite
		- Enriched Uranium
		- Platinum
		- Alien Alloy
		- Adamantine
*/

GLOBAL_LIST_INIT(sandstone_recipes, list (
	new /datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("sandstone airlock assembly", /obj/structure/door_assembly/door_assembly_sandstone, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("sarcophagus", /obj/structure/closet/coffin/sarcophagus, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("Assistant Statue", /obj/structure/statue/sandstone/assistant, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("Breakdown into sand", /obj/item/stack/ore/glass, 1, one_per_turf = FALSE, on_floor = TRUE),
	))

GLOBAL_LIST_INIT(silver_recipes, list (
	new /datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("silver airlock assembly", /obj/structure/door_assembly/door_assembly_silver, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20),
	null,
	new /datum/stack_recipe_list("silver statues", list(
		new /datum/stack_recipe("Janitor Statue", /obj/structure/statue/silver/janitor, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sec Officer Statue", /obj/structure/statue/silver/sec, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Sec Borg Statue", /obj/structure/statue/silver/secborg, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Med Doctor Statue", /obj/structure/statue/silver/md, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Med Borg Statue", /obj/structure/statue/silver/medborg, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Monkey Statue", /obj/structure/statue/silver/monkey, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Corgi Statue", /obj/structure/statue/silver/corgi, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	null,
	new /datum/stack_recipe("Silver Locket", /obj/item/clothing/neck/necklace/locket/silver, 1),
	))

GLOBAL_LIST_INIT(diamond_recipes, list (
	new /datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("diamond airlock assembly", /obj/structure/door_assembly/door_assembly_diamond, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),
	null,
	new /datum/stack_recipe_list("diamond statues", list(
		new /datum/stack_recipe("Captain Statue", /obj/structure/statue/diamond/captain, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("AI Hologram Statue", /obj/structure/statue/diamond/ai1, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("AI Core Statue", /obj/structure/statue/diamond/ai2, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	))

GLOBAL_LIST_INIT(uranium_recipes, list (
	new /datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("uranium airlock assembly", /obj/structure/door_assembly/door_assembly_uranium, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20),
	null,
	new /datum/stack_recipe_list("uranium statues", list(
		new /datum/stack_recipe("Nuke Statue", /obj/structure/statue/uranium/nuke, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("Engineer Statue", /obj/structure/statue/uranium/eng, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	))

GLOBAL_LIST_INIT(gold_recipes, list (
	new /datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("golden airlock assembly", /obj/structure/door_assembly/door_assembly_gold, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20),
	null,
	new /datum/stack_recipe_list("gold statues", list(
		new /datum/stack_recipe("HoS Statue", /obj/structure/statue/gold/hos, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("HoP Statue", /obj/structure/statue/gold/hop, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("CE Statue", /obj/structure/statue/gold/ce, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("RD Statue", /obj/structure/statue/gold/rd, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("CMO Statue", /obj/structure/statue/gold/cmo, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	null,
	new /datum/stack_recipe_list("gold clothing", list(
		new /datum/stack_recipe("Simple Crown", /obj/item/clothing/head/crown, 5),
		null,
		new /datum/stack_recipe("Simple Necklace", /obj/item/clothing/neck/necklace, 1),
		new /datum/stack_recipe("Large Necklace", /obj/item/clothing/neck/necklace/long, 2),
		new /datum/stack_recipe("Gold Locket", /obj/item/clothing/neck/necklace/locket, 1),
		)),
	))

GLOBAL_LIST_INIT(plasma_recipes, list (
	new /datum/stack_recipe/dangerous("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe/dangerous("plasma airlock assembly", /obj/structure/door_assembly/door_assembly_plasma, 4, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe/dangerous("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20),
	null,
	new /datum/stack_recipe_list("plasma statues", list(
		new /datum/stack_recipe/dangerous("Scientist Statue", /obj/structure/statue/plasma/scientist, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe/dangerous("Xenomorph Statue", /obj/structure/statue/plasma/xeno, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	))

GLOBAL_LIST_INIT(bananium_recipes, list (
	new /datum/stack_recipe("bananium airlock assembly", /obj/structure/door_assembly/door_assembly_bananium, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20),
	null,
	new /datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("bananium grenade casing", /obj/item/grenade/bananade/casing, 4, on_floor = TRUE),
	))

GLOBAL_LIST_INIT(tranquillite_recipes, list (
	new /datum/stack_recipe("tranquillite airlock assembly", /obj/structure/door_assembly/door_assembly_tranquillite, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("invisible wall", /obj/structure/barricade/mime, 5, one_per_turf = TRUE, on_floor = TRUE, time = 50),
	null,
	new /datum/stack_recipe("silent tile", /obj/item/stack/tile/mineral/tranquillite, 1, 4, 20),
	null,
	new /datum/stack_recipe("Mime Statue", /obj/structure/statue/tranquillite/mime, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	))

GLOBAL_LIST_INIT(abductor_recipes, list (
	new /datum/stack_recipe("alien bed", /obj/structure/bed/abductor, 2, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 2, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("alien table frame", /obj/structure/table_frame/abductor, 1, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("alien airlock assembly", /obj/structure/door_assembly/door_assembly_abductor, 4, time = 20, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20),
	))

GLOBAL_LIST_INIT(adamantine_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount = 1, res_amount = 1),
	))

GLOBAL_LIST_INIT(snow_recipes, list(
	new /datum/stack_recipe("snowman", /obj/structure/snowman, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("Snowball", /obj/item/snowball, 1)
	))

/obj/item/stack/sheet/mineral
	throw_speed = 3

/obj/item/stack/sheet/mineral/Initialize(mapload, new_amount, merge)
	. = ..()
	scatter_atom()

/obj/item/stack/sheet/mineral/scatter_atom(offset_x, offset_y)
	pixel_x = rand(-4,0) + offset_x
	pixel_y = rand(-4,0) + offset_y

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_range = 5
	sheettype = "sandstone"
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/sandstone/fifty
	amount = 50

/obj/item/stack/sheet/mineral/sandstone/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.sandstone_recipes

/*
 * Sandbags
 */

/obj/item/stack/sheet/mineral/sandbags
	name = "sandbags"
	desc = "Cloth bags full of sand. They can be used to construct robust defensive emplacements that block movement and provide protection from gunfire."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "sandbags"
	singular_name = "sandbag"
	layer = LOW_ITEM_LAYER
	merge_type = /obj/item/stack/sheet/mineral/sandbags

GLOBAL_LIST_INIT(sandbag_recipes, list (
	new /datum/stack_recipe("sandbags", /obj/structure/barricade/sandbags, 1, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	))

/obj/item/stack/sheet/mineral/sandbags/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.sandbag_recipes

/obj/item/emptysandbag
	name = "empty sandbag"
	desc = "A cloth bag to be filled with sand."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "empty-sandbags"
	w_class = WEIGHT_CLASS_TINY

/obj/item/emptysandbag/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/G = I
		to_chat(user, "<span class='notice'>You fill the sandbag.</span>")
		var/obj/item/stack/sheet/mineral/sandbags/S = new /obj/item/stack/sheet/mineral/sandbags(drop_location())
		qdel(src)
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(S)
		G.use(1)
	else
		return ..()

/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	desc = "Sparkles like a twinkling star."
	icon_state = "sheet-diamond"
	singular_name = "diamond"
	origin_tech = "materials=6"
	sheettype = "diamond"
	merge_type = /obj/item/stack/sheet/mineral/diamond
	materials = list(MAT_DIAMOND = MINERAL_MATERIAL_AMOUNT)
	point_value = 25

/obj/item/stack/sheet/mineral/diamond/examine_more(mob/user)
	. = ..()
	. += "Diamond is the hardest known material, made of elemental carbon arranged in a tightly packed cubic crystal structure. \
	It has excellent thermal conductivity, a high refractive index, and is widely seen as very pretty to look at."
	. += ""
	. += "Diamond is highly sought after for both aesthetic uses and as a component of many advanced technologies."

/obj/item/stack/sheet/mineral/diamond/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.diamond_recipes

/obj/item/stack/sheet/mineral/diamond/ten
	amount = 10

/obj/item/stack/sheet/mineral/diamond/fifty
	amount = 50

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	desc = "Don't keep this stuff in your pocket for too long. Hell, don't keep it anywhere near your person for too long."
	icon_state = "sheet-uranium"
	singular_name = "uranium sheet"
	origin_tech = "materials=5"
	sheettype = "uranium"
	merge_type = /obj/item/stack/sheet/mineral/uranium
	materials = list(MAT_URANIUM = MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/uranium/examine_more(mob/user)
	. = ..()
	. += "Uranium is extremely dense, radioactive metal. Without undergoing complex enrichment processes, it consists of roughly 99% uranium-238, and roughly 1% fissile uranium-235."
	. += ""
	. += "It finds uses in a great number of applications, including medicine, nuclear power generation, radiation shielding, cybernetic and robotic components, as well as weapons."

/obj/item/stack/sheet/mineral/uranium/ten
	amount = 10

/obj/item/stack/sheet/mineral/uranium/twenty
	amount = 20

/obj/item/stack/sheet/mineral/uranium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/uranium/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.uranium_recipes

/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	desc = "Beautiful pure purple crystals, ready to ignite if a naked flame touches them..."
	icon_state = "sheet-plasma"
	singular_name = "plasma sheet"
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"
	merge_type = /obj/item/stack/sheet/mineral/plasma
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	max_integrity = 100
	point_value = 20

/obj/item/stack/sheet/mineral/plasma/twenty
	amount = 20

/obj/item/stack/sheet/mineral/plasma/examine_more(mob/user)
	. = ..()
	. += "Plasma, the new oil. A highly sought-after material, and what propelled Nanotrasen from being a small, relatively unknown company to the interstellar megacorporation it is today."
	. += ""
	. += "Plasma is a metastable exotic matter, capable of existing in all 3 basic states of matter across a wide range of tempratures and pressures. It is widely used as starship fuel for both conventional engines and \
	Faster-Than-Light drives. It is also used in the creation of several classes of high-performance supermaterials and other advanced technologies. New uses for this wonder material are constantly being researched."
	. += ""
	. += "Its high flammability makes it very dangerous to handle, and it is also toxic and carcinogenic to most species. Veteran miners often begin to suffer from health problems caused by chronic exposure to plasma dust."
	. += ""
	. += "Despite its flammability, plasma-enhanced materials such as plasteel or plasma glass generally possess extreme fire resistance, ultra-low thermal conductivity, and a high emissivity. \
	This allows, for example, a relatively thin pane of plasma glass to be cool to the touch even when a massive inferno is burning on the other side."

/obj/item/stack/sheet/mineral/plasma/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.plasma_recipes

/obj/item/stack/sheet/mineral/plasma/ten
	amount = 10

/obj/item/stack/sheet/mineral/plasma/fifty
	amount = 50

/obj/item/stack/sheet/mineral/plasma/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		log_and_set_aflame(user, I)
	return TRUE

/obj/item/stack/sheet/mineral/plasma/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	if(I.get_heat())
		log_and_set_aflame(user, I)
	else
		return ..()

/obj/item/stack/sheet/mineral/plasma/proc/log_and_set_aflame(mob/user, obj/item/I)
	var/turf/T = get_turf(src)
	message_admins("Plasma sheets ignited by [key_name_admin(user)]([ADMIN_QUE(user, "?")]) ([ADMIN_FLW(user, "FLW")]) in ([COORD(T)] - [ADMIN_JMP(T)]")
	log_game("Plasma sheets ignited by [key_name(user)] in [COORD(T)]")
	investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]", INVESTIGATE_ATMOS)
	user.create_log(MISC_LOG, "Plasma sheets ignited using [I]", src)
	fire_act()

/obj/item/stack/sheet/mineral/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, amount*10)
	qdel(src)

/obj/item/stack/sheet/mineral/gold
	name = "gold"
	desc = "GOLD!"
	icon_state = "sheet-gold"
	singular_name = "gold bar"
	origin_tech = "materials=4"
	sheettype = "gold"
	merge_type = /obj/item/stack/sheet/mineral/gold
	materials = list(MAT_GOLD = MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/gold/examine_more(mob/user)
	. = ..()
	. += "A dense, soft, yellow precious metal that has been sought after by many species since before they recorded history as a symbol of wealth. \
	It has an exceptionally low reactivity and excellent corrosion resistance, being the most noble of the metallic elements."
	. += ""
	. += "It is widely used in the production of advanced electronics and chemical catalysts, as well as a few specialised medicines. Also used as a relatively safe store of wealth that is not affected by the economics of cash."

/obj/item/stack/sheet/mineral/gold/twenty
	amount = 20

/obj/item/stack/sheet/mineral/gold/fifty
	amount = 50

/obj/item/stack/sheet/mineral/gold/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.gold_recipes

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	desc = "Shiny as a mirror. Allegedly repels werewolves and other mythical creatures."
	icon_state = "sheet-silver"
	singular_name = "silver bar"
	origin_tech = "materials=4"
	sheettype = "silver"
	merge_type = /obj/item/stack/sheet/mineral/silver
	materials = list(MAT_SILVER = MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/silver/twenty
	amount = 20

/obj/item/stack/sheet/mineral/silver/examine_more(mob/user)
	. = ..()
	. += "A shiny grey precious metal that has been sought after by many species since before they recorded history as a symbol of wealth. \
	It has very high thermal and electrical conductivity, and exhibits antimicrobial properties."
	. += ""
	. += "It is widely used in the production of advanced electronics, chemical catalysts, medicines, and some high performance materials."

/obj/item/stack/sheet/mineral/silver/fifty
	amount = 50

/obj/item/stack/sheet/mineral/silver/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.silver_recipes

/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	desc = "It looks, smells, and tastes like real bananas. You'll break your teeth if you try to bite down on it, though."
	icon_state = "sheet-bananium"
	singular_name = "bananium sheet"
	origin_tech = "materials=4"
	sheettype = "bananium"
	merge_type = /obj/item/stack/sheet/mineral/bananium
	materials = list(MAT_BANANIUM = MINERAL_MATERIAL_AMOUNT)
	point_value = 50

/obj/item/stack/sheet/mineral/bananium/examine_more(mob/user)
	. = ..()
	. += "Bananium. An extremely rare crystalline material of unknown origin. Various theories of where it originates have been proposed, usually with no evidence to support them. \
	It makes a squeaking sound when something compresses it."
	. += ""
	. += "It is sought after by clowns all across the known galaxy and is used in the creation of many clownish contraptions."

/obj/item/stack/sheet/mineral/bananium/ten
	amount = 10

/obj/item/stack/sheet/mineral/bananium/thirty
	amount = 30

/obj/item/stack/sheet/mineral/bananium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/bananium/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.bananium_recipes

/obj/item/stack/sheet/mineral/tranquillite
	name = "tranquillite"
	desc = "..."
	icon_state = "sheet-tranquillite"
	singular_name = "beret"
	origin_tech = "materials=4"
	sheettype = "tranquillite"
	merge_type = /obj/item/stack/sheet/mineral/tranquillite
	materials = list(MAT_TRANQUILLITE = MINERAL_MATERIAL_AMOUNT)
	wall_allowed = FALSE	//no tranquilite walls in code
	point_value = 50

/obj/item/stack/sheet/mineral/tranquillite/examine_more(mob/user)
	..()
	. += "Tranquilite. An extremely rare crystalline material of unknown origin. Various theories of where it originates have been proposed, usually with no evidence to support them. \
	Uniquely, it makes no sounds when bent, broken, smashed, or otherwise manipulated in any way, remaining deathly silent at all times. \
	It also dampens sounds around it, and can become completely transparent when properly manipulated."
	. += ""
	. += "It is sought after by mimes all across the known galaxy and is used in the creation of many of their mysterious contraptions. Various other groups also express an interest in its unusual properites."

/obj/item/stack/sheet/mineral/tranquillite/ten
	amount = 10

/obj/item/stack/sheet/mineral/tranquillite/thirty
	amount = 30

/obj/item/stack/sheet/mineral/tranquillite/fifty
	amount = 50

/obj/item/stack/sheet/mineral/tranquillite/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.tranquillite_recipes

/obj/item/stack/sheet/mineral/platinum
	name = "platinum"
	desc = "Shiny and valuable."
	icon_state = "sheet-platinum"
	singular_name = "platinum"
	origin_tech = "materials=5"
	sheettype = "platinum"
	merge_type = /obj/item/stack/sheet/mineral/platinum
	materials = list(MAT_PLATINUM = MINERAL_MATERIAL_AMOUNT)
	point_value = 25

/obj/item/stack/sheet/mineral/palladium
	name = "palladium"
	desc = "A valuable space mineral."
	icon_state = "sheet-palladium"
	singular_name = "palladium"
	origin_tech = "materials=5"
	sheettype = "palladium"
	merge_type = /obj/item/stack/sheet/mineral/palladium
	materials = list(MAT_PALLADIUM = MINERAL_MATERIAL_AMOUNT)
	point_value = 25

/obj/item/stack/sheet/mineral/iridium
	name = "iridium"
	desc = "A dense mineral found in abundance in space and extremely rare on planets."
	icon_state = "sheet-iridium"
	singular_name = "iridium"
	origin_tech = "materials=5"
	sheettype = "iridium"
	merge_type = /obj/item/stack/sheet/mineral/iridium
	materials = list(MAT_IRIDIUM = MINERAL_MATERIAL_AMOUNT)
	point_value = 25

/*
 * Titanium
 */
/obj/item/stack/sheet/mineral/titanium
	name = "titanium"
	desc = "It feels much lighter than it looks."
	icon_state = "sheet-titanium"
	singular_name = "titanium sheet"
	throw_speed = 1
	sheettype = "titanium"
	merge_type = /obj/item/stack/sheet/mineral/titanium
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/titanium/examine_more(mob/user)
	. = ..()
	. += "A strong, lightweight metal. Titanium has a strength similar to most steel alloys despite being about 45% less dense, whilst also exhibiting superior corrosion resistance. \
	It is also very good at reflecting energy weapon attacks. Careful where you fire that laser gun!"
	. += ""
	. += "It is widely used in robotics, aerospace applications, and in starship construction thanks to its excellent strength-to-weight ratio. Notably, it is also extensively used in space station construction by the USSP."

GLOBAL_LIST_INIT(titanium_recipes, list(
	new /datum/stack_recipe("titanium airlock assembly", /obj/structure/door_assembly/door_assembly_titanium, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe("titanium tile", /obj/item/stack/tile/mineral/titanium, 1, 4, 20),
	new /datum/stack_recipe("surgical tray", /obj/item/storage/surgical_tray, 1),
	new /datum/stack_recipe("surgical instrument table", /obj/structure/table/tray, 3, one_per_turf = TRUE, on_floor = TRUE),
	))

/obj/item/stack/sheet/mineral/titanium/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.titanium_recipes

/obj/item/stack/sheet/mineral/titanium/fifty
	amount = 50


/*
 * Plastitanium
 */
/obj/item/stack/sheet/mineral/plastitanium
	name = "plastitanium"
	desc = "Just as light as normal titanium, but you can <i>feel</i> an aura of extra robustness about it."
	icon_state = "sheet-plastitanium"
	singular_name = "plastitanium sheet"
	throw_speed = 1
	sheettype = "plastitanium"
	merge_type = /obj/item/stack/sheet/mineral/plastitanium
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	point_value = 45

/obj/item/stack/sheet/mineral/plastitanium/examine_more(mob/user)
	. = ..()
	. += "A high-performance superalloy of plasma and titanium, plastitanium is exceptionally light and strong, and has excellent thermal and corrosion resistance."
	. += ""
	. += "It is used in the construction of military-grade starship hulls, top-of-the-line personal armour, and melee weaponry."

/obj/item/stack/sheet/mineral/plastitanium/fifty
	amount = 50


GLOBAL_LIST_INIT(plastitanium_recipes, list(
	new /datum/stack_recipe("plas-titanium tile", /obj/item/stack/tile/mineral/plastitanium, 1, 4, 20),
	new /datum/stack_recipe("Kidan Warrior Statue", /obj/structure/statue/plastitanium/kidanstatue, 5, time = 2.5 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("reinforced wheelchair", /obj/structure/chair/wheelchair/plastitanium, 15, time = 7 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	))

/obj/item/stack/sheet/mineral/plastitanium/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.plastitanium_recipes


//Alien Alloy
/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	desc = "The dizzying colours change constantly depending on how the light hits it."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	dynamic_icon_state = FALSE
	singular_name = "alien alloy sheet"
	throw_speed = 1
	origin_tech = "materials=6;abductor=1"
	sheettype = "abductor"
	merge_type = /obj/item/stack/sheet/mineral/abductor
	table_type = /obj/structure/table/abductor

/obj/item/stack/sheet/mineral/abductor/examine_more(mob/user)
	. = ..()
	. += "An out-of-this-world material used in the construction of exceptionally advanced technologies. Known to be associated strongly with abductors."

/obj/item/stack/sheet/mineral/abductor/fifty
	amount = 50

/obj/item/stack/sheet/mineral/abductor/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.abductor_recipes

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	desc = "A strange mineral used in the construction of sentient golems."
	icon_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	origin_tech = "materials=5"
	merge_type = /obj/item/stack/sheet/mineral/adamantine
	wall_allowed = FALSE

/obj/item/stack/sheet/mineral/adamantine/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.adamantine_recipes


/obj/item/stack/sheet/mineral/adamantine/fifty
	amount = 50

/*
 * Snow
 */
/obj/item/stack/sheet/mineral/snow
	name = "snow"
	icon_state = "sheet-snow"
	singular_name = "snow block"
	force = 1
	throwforce = 2
	merge_type = /obj/item/stack/sheet/mineral/snow

/obj/item/stack/sheet/mineral/snow/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.snow_recipes
