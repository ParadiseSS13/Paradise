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
*/

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Assistant Statue", /obj/structure/statue/sandstone/assistant, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Breakdown into sand", /obj/item/weapon/ore/glass, 1, one_per_turf = 0, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Janitor Statue", /obj/structure/statue/silver/janitor, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Officer Statue", /obj/structure/statue/silver/sec, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Borg Statue", /obj/structure/statue/silver/secborg, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Doctor Statue", /obj/structure/statue/silver/md, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Borg Statue", /obj/structure/statue/silver/medborg, 5, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	null, \
	new/datum/stack_recipe("Captain Statue", /obj/structure/statue/diamond/captain, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Hologram Statue", /obj/structure/statue/diamond/ai1, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Core Statue", /obj/structure/statue/diamond/ai2, 5, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Nuke Statue", /obj/structure/statue/uranium/nuke, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Engineer Statue", /obj/structure/statue/uranium/eng, 5, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("HoS Statue", /obj/structure/statue/gold/hos, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("HoP Statue", /obj/structure/statue/gold/hop, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CE Statue", /obj/structure/statue/gold/ce, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("RD Statue", /obj/structure/statue/gold/rd, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CMO Statue", /obj/structure/statue/gold/cmo, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Simple Crown", /obj/item/clothing/head/crown, 5), \
	)

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Scientist Statue", /obj/structure/statue/plasma/scientist, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Xenomorph Statue", /obj/structure/statue/plasma/xeno, 5, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/bananium_recipes = list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("bananium computer frame", /obj/structure/computerframe/HONKputer, 50, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bananium grenade casing", /obj/item/weapon/grenade/bananade/casing, 4, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/tranquillite_recipes = list ( \
	new/datum/stack_recipe("invisible wall", /obj/structure/barricade/mime, 5, one_per_turf = 1, on_floor = 1, time = 50), \
	null, \
	new/datum/stack_recipe("silent tile", /obj/item/stack/tile/mineral/tranquillite, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Mime Statue", /obj/structure/statue/tranquillite/mime, 5, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/abductor_recipes = list ( \
	new/datum/stack_recipe("alien bed", /obj/structure/stool/bed/abductor, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien table frame", /obj/structure/abductor_tableframe, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral
	force = 5.0
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3

/obj/item/stack/sheet/mineral/New()
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/sandstone/New()
	..()
	recipes = sandstone_recipes

/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	singular_name = "diamond"
	origin_tech = "materials=6"
	sheettype = "diamond"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/diamond/New()
	..()
	recipes = diamond_recipes

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	singular_name = "uranium sheet"
	origin_tech = "materials=5"
	sheettype = "uranium"
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/uranium/New()
	..()
	recipes = uranium_recipes

/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	singular_name = "plasma sheet"
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)
	burn_state = FLAMMABLE
	burntime = 5

/obj/item/stack/sheet/mineral/plasma/New()
	..()
	recipes = plasma_recipes

/obj/item/stack/sheet/mineral/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma sheets ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma sheets ignited by [key_name(user)] in ([x],[y],[z])")
		fire_act()
	else
		return ..()

/obj/item/stack/sheet/mineral/plasma/fire_act()
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, amount*10)
	qdel(src)

/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	singular_name = "gold bar"
	origin_tech = "materials=4"
	sheettype = "gold"
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/gold/New()
	..()
	recipes = gold_recipes

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	singular_name = "silver bar"
	origin_tech = "materials=4"
	sheettype = "silver"
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/silver/New()
	..()
	recipes = silver_recipes

/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-clown"
	singular_name = "bananium sheet"
	origin_tech = "materials=4"
	sheettype = "bananium"
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/bananium/New(loc, amount=null)
	..()
	recipes = bananium_recipes

/obj/item/stack/sheet/mineral/tranquillite
	name = "tranquillite"
	icon_state = "sheet-mime"
	singular_name = "beret"
	origin_tech = "materials=4"
	sheettype = "tranquillite"
	materials = list(MAT_TRANQUILLITE=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/tranquillite/New(loc, amount=null)
	..()
	recipes = tranquillite_recipes

/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	origin_tech = "materials=6"
	materials = list(MAT_URANIUM=3000)

//Alien Alloy
/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	singular_name = "alien alloy sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	origin_tech = "materials=6;abductor=1"
	sheettype = "abductor"

/obj/item/stack/sheet/mineral/abductor/New(loc, amount=null)
	recipes = abductor_recipes
	..()
