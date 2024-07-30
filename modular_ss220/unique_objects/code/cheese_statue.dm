// =========== statues ===========

/obj/structure/statue/cheese
	name = "cheese statue"
	desc = "For squeek enjoyer."
	max_integrity = 100
	material_drop_type = /obj/item/stack/sheet/cheese
	icon = 'modular_ss220/unique_objects/icons/statue.dmi'
	icon_state = "cheesus1"

/obj/structure/statue/cheese/cheesus
	name = "statue of cheesus"
	desc = "Cheese expertly crafted into a representation of our mighty lord and saviour."
	icon_state = "cheesus1"

/obj/structure/statue/cheese/cheesus/attackby(obj/item/W, mob/user, params)
	switch(obj_integrity)
		if(0 to 20)
			icon_state = "cheesus4"
		if(20 to 40)
			icon_state = "cheesus3"
		if(40 to 60)
			icon_state = "cheesus2"
		else
			icon_state = "cheesus1"
	update_icon(UPDATE_ICON_STATE)
	return ..()

/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()
	LAZYADD(blend_items, list(/obj/item/stack/sheet/cheese = list("milk" = 20)))

// =========== items ===========

GLOBAL_LIST_INIT(cheese_recipes, list(
	new /datum/stack_recipe("Cheesus statue", /obj/structure/statue/cheese/cheesus, 5, one_per_turf = TRUE, time = 100, on_floor = TRUE),
))

/obj/item/stack/sheet/cheese
	name = "reinforced cheese"
	desc = "A stack of cheese that seems sturdier than regular cheese."
	icon = 'modular_ss220/unique_objects/icons/organic.dmi'
	icon_state = "sheet-cheese"
	item_state = "sheet-cheese"
	singular_name = "reinforced cheese block"
	sheettype = "cheese"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	max_amount = 15
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/cheese

/obj/item/stack/sheet/cheese/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.cheese_recipes

/obj/item/stack/sheet/cheese/fifteen
	amount = 15

//////////////////////////////////////////
//Reinforced cheese
//////////////////////////////////////////
/datum/recipe/oven/reinforcedcheese
	reagents = list("sodiumchloride" = 10)
	items = list(
		/obj/item/food/sliceable/cheesewheel,
		/obj/item/food/sliceable/cheesewheel
	)
	result = /obj/item/stack/sheet/cheese
