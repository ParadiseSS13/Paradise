//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle


/obj/item/reagent_containers/glass/jug
	name = "jug"
	desc = "A decent sized plastic jug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug"
	item_state = "plastic_jug"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,20,40,80)
	container_type = OPENCONTAINER
	volume = 80

/obj/item/reagent_containers/glass/jug/Initialize()
	..()
	add_lid()

/obj/item/reagent_containers/glass/jug/proc/add_lid()		//code for when the item is created, exclusively for
	container_type ^= REFILLABLE | DRAINABLE				//jugs so that they start with their lids on.
	update_icon()

/obj/item/reagent_containers/glass/jug/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/jug/update_icon()
	cut_overlays()

	if(reagents != null && reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "plastic_jug10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 10)
				filling.icon_state = "plastic_jug-10"
			if(11 to 29)
				filling.icon_state = "plastic_jug25"
			if(30 to 45)
				filling.icon_state = "plastic_jug40"
			if(46 to 61)
				filling.icon_state = "plastic_jug55"
			if(62 to 77)
				filling.icon_state = "plastic_jug70"
			if(78 to 92)
				filling.icon_state = "plastic_jug85"
			if(93 to INFINITY)
				filling.icon_state = "plastic_jug100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

	if(!is_open_container())
		add_overlay("lid_jug")
