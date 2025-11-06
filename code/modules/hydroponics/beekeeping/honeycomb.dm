
/obj/item/food/honeycomb
	name = "honeycomb"
	desc = "A hexagonal mesh of honeycomb."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	volume = 10
	list_reagents = list("honey" = 5)
	var/honey_color = ""
	scatter_distance = 8

/obj/item/food/honeycomb/Initialize(mapload)
	. = ..()
	scatter_atom()
	update_icon(UPDATE_OVERLAYS)

/obj/item/food/honeycomb/update_overlays()
	. = ..()
	var/image/honey
	if(honey_color)
		honey = image(icon = 'icons/obj/hydroponics/harvest.dmi', icon_state = "greyscale_honey")
		honey.color = honey_color
	else
		honey = image(icon = 'icons/obj/hydroponics/harvest.dmi', icon_state = "honey")
	. += honey


/obj/item/food/honeycomb/proc/set_reagent(reagent)
	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent]
	if(istype(R))
		name = "honeycomb ([R.name])"
		honey_color = R.color
		reagents.add_reagent(R.id,5)
	else
		honey_color = ""
	update_icon(UPDATE_OVERLAYS)
