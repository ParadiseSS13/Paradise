
/obj/item/reagent_containers/food/snacks/honeycomb
	name = "honeycomb"
	desc = "A hexagonal mesh of honeycomb."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	possible_transfer_amounts = null
	disease_amount = 0
	volume = 10
	amount_per_transfer_from_this = 0
	visible_transfer_rate = FALSE
	list_reagents = list("honey" = 5)
	var/honey_color = ""

/obj/item/reagent_containers/food/snacks/honeycomb/Initialize(mapload)
	. = ..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/food/snacks/honeycomb/update_overlays()
	. = ..()
	var/image/honey
	if(honey_color)
		honey = image(icon = 'icons/obj/hydroponics/harvest.dmi', icon_state = "greyscale_honey")
		honey.color = honey_color
	else
		honey = image(icon = 'icons/obj/hydroponics/harvest.dmi', icon_state = "honey")
	. += honey


/obj/item/reagent_containers/food/snacks/honeycomb/proc/set_reagent(reagent)
	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent]
	if(istype(R))
		name = "honeycomb ([R.name])"
		honey_color = R.color
		reagents.add_reagent(R.id,5)
	else
		honey_color = ""
	update_icon(UPDATE_OVERLAYS)
