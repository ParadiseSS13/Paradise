/*
Mineral Sheets
	Contains:
		- Sandstone
		- Diamond
		- Uranium
		- Plasma
		- Plastic
		- Gold
		- Silver
		- Bananium
		- Tranqillite
		- Enriched Uranium
		- Platinum
		- Metallic Hydrogen
		- Tritium
		- Osmium
*/

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/portable_atmospherics/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Simple Crown", /obj/item/clothing/head/crown, 5), \
	)

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/plastic_recipes = list ( \
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

var/global/list/datum/stack_recipe/bananium_recipes = list ( \
	new/datum/stack_recipe("bananium computer frame", /obj/structure/computerframe/HONKputer, 50, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bananium grenade casing", /obj/item/weapon/grenade/bananade/casing, 4, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/tranquillite_recipes = list ( \
	new/datum/stack_recipe("silent tile", /obj/item/stack/tile/silent, 1, 4, 20), \
	new/datum/stack_recipe("invisible wall", /obj/structure/barricade/mime, 5, one_per_turf = 1, on_floor = 1, time = 50), \
	)

/obj/item/stack/sheet/mineral
	force = 5.0
	throwforce = 5
	w_class = 3
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/mineral/New()
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 3
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
	origin_tech = "materials=6"
	sheettype = "diamond"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)


/obj/item/stack/sheet/mineral/diamond/New()
	..()
	recipes = diamond_recipes

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	origin_tech = "materials=5"
	sheettype = "uranium"
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/uranium/New()
	..()
	recipes = uranium_recipes

/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
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

/obj/item/stack/sheet/mineral/plastic
	name = "Plastic"
	icon_state = "sheet-plastic"
	origin_tech = "materials=3"

/obj/item/stack/sheet/mineral/plastic/New()
	..()
	recipes = plastic_recipes

/obj/item/stack/sheet/mineral/plastic/cyborg
	name = "plastic sheets"
	icon_state = "sheet-plastic"

/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	origin_tech = "materials=4"
	sheettype = "gold"
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/gold/New()
	..()
	recipes = gold_recipes

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	origin_tech = "materials=3"
	sheettype = "silver"
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/silver/New()
	..()
	recipes = silver_recipes

/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-clown"
	origin_tech = "materials=4"
	sheettype = "bananium"
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/bananium/New(var/loc, var/amount=null)
	..()
	recipes = bananium_recipes

/obj/item/stack/sheet/mineral/tranquillite
	name = "tranquillite"
	singular_name = "beret"
	icon_state = "sheet-mime"
	origin_tech = "materials=4"
	sheettype = "tranquillite"
	materials = list(MAT_TRANQUILLITE=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/tranquillite/New(var/loc, var/amount=null)
	..()
	recipes = tranquillite_recipes

/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	origin_tech = "materials=6"
	materials = list(MAT_URANIUM=3000)

/*
 * Alien Alloy
 */
/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	singular_name = "alien alloy sheet"
	force = 5
	throwforce = 5
	w_class = 3
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=6;abductor=1"
	sheettype = "abductor"

var/global/list/datum/stack_recipe/abductor_recipes = list ( \
	new/datum/stack_recipe("alien bed", /obj/structure/stool/bed/abductor, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien table frame", /obj/structure/abductor_tableframe, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/abductor/New(var/loc, var/amount=null)
	recipes = abductor_recipes
	..()