/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pitcher
	name = "Pitcher"
	desc = "A big container for holding a lot of liquid that you then serve to people."
	icon = 'hyntatmta/icons/obj/reagent_containers.dmi'
	icon_state = "pitcher"
	amount_per_transfer_from_this = 15
	volume = 120
	materials = list(MAT_GLASS=300)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pitcher/on_reagent_change()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('hyntatmta/icons/obj/reagentfillings.dmi', src, "[icon_state]1")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 25)
				filling.icon_state = "[icon_state]1"
			if(26 to 79)
				filling.icon_state = "[icon_state]5"
			if(80 to INFINITY)
				filling.icon_state = "[icon_state]12"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		name = "Pitcher of " + reagents.get_master_reagent_name() //No matter what, the glass will tell you the reagent's name. Might be too abusable in the future.
	else
		name = "Pitcher"