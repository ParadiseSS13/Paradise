//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle


/obj/item/reagent_containers/glass/jug
	name = "Jug"
	desc = "A decent sized plastic jug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug"
	item_state = "plastic_jug"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,50)
	container_type = OPENCONTAINER
	volume = 50

/obj/item/reagent_containers/glass/jug/New()
	..()
	add_lid()

/obj/item/reagent_containers/glass/jug/proc/add_lid()
	container_type ^= REFILLABLE | DRAINABLE
	update_icon()

/obj/item/reagent_containers/glass/jug/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/jug/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "plastic_jug10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 10)
				filling.icon_state = "plastic_jug-10"
			if(11 to 29)
				filling.icon_state = "plastic_jug20"
			if(30 to 49)
				filling.icon_state = "plastic_jug40"
			if(50 to 69)
				filling.icon_state = "plastic_jug60"
			if(70 to 89)
				filling.icon_state = "plastic_jug80"
			if(90 to INFINITY)
				filling.icon_state = "plastic_jug100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_jug")
		overlays += lid
