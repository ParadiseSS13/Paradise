/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "No glasses were shot in the making of this glass."
	icon_state = "shotglass"
	amount_per_transfer_from_this = 15
	volume = 15
	materials = list(MAT_GLASS=100)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]1")
		switch(reagents.total_volume)
			if(0 to 4)		filling.icon_state = "[icon_state]1"
			if(5 to 11) 	filling.icon_state = "[icon_state]5"
			if(12 to INFINITY)	filling.icon_state = "[icon_state]12"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		name = "shot glass of " + reagents.get_master_reagent_name() //No matter what, the glass will tell you the reagent's name. Might be too abusable in the future.
	else
		name = "shot glass"
