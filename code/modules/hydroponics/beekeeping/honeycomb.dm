
/obj/item/weapon/reagent_containers/honeycomb
	name = "honeycomb"
	desc = "a hexagonal mesh of honeycomb"
	icon = 'icons/obj/apiary_bees.dmi'
	icon_state = "honeycomb"
	possible_transfer_amounts = list()
	disease_amount = 0
	volume = 10
	amount_per_transfer_from_this = 0
	list_reagents = list("honey" = 5)
	var/honey_color = ""

/obj/item/weapon/reagent_containers/honeycomb/New()
	..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)
	update_icon()


/obj/item/weapon/reagent_containers/honeycomb/update_icon()
	overlays.Cut()
	var/image/honey
	if(honey_color)
		honey = image(icon = 'icons/obj/apiary_bees.dmi', icon_state = "greyscale_honey")
		honey.color = honey_color
	else
		honey = image(icon = 'icons/obj/apiary_bees.dmi', icon_state = "honey")
	overlays += honey


/obj/item/weapon/reagent_containers/honeycomb/proc/set_reagent(reagent)
	var/datum/reagent/R = chemical_reagents_list[reagent]
	if(istype(R))
		name = "honeycomb ([R.name])"
		honey_color = R.color
		reagents.add_reagent(R.id,5)
	else
		honey_color = ""
	update_icon()
