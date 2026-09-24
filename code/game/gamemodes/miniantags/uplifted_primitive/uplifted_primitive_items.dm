/obj/item/uplifted
	icon = 'icons/obj/uplifted_primitive.dmi'

/obj/item/uplifted/nest_bundle
	name = "bundle of junk"
	desc = "A loosely put together collection of scrap metal and food items."
	icon_state = "bundle"

	w_class = WEIGHT_CLASS_SMALL

	var/scrap = 0
	var/food = 0

/obj/item/uplifted/nest_bundle/Initialize(mapload, new_scrap, new_food)
	. = ..()
	scrap = new_scrap
	food = new_food

/obj/item/uplifted/nest_bundle/examine(mob/user)
	. = ..()
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/uplifted_primitive))
		. += SPAN_NOTICE("It contains [scrap] units of scrap.")
		. += SPAN_NOTICE("It contains [food] units of food.")
