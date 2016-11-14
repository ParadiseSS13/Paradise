/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/wine
	name = "Wine glass"
	desc = "A glass on a foot used to drink and taste wine"
	icon = 'hyntatmta/icons/obj/reagent_containers.dmi'
	icon_state = "glass-wine"
	volume = 30
	materials = list(MAT_GLASS=100)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/wine/on_reagent_change()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('hyntatmta/icons/obj/reagentfillings.dmi', src, "[icon_state]1")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 25)
				filling.icon_state = "[icon_state]1"
			if(26 to 50)
				filling.icon_state = "[icon_state]3"
			if(51 to 75)
				filling.icon_state = "[icon_state]5"
			if(76 to INFINITY)
				filling.icon_state = "[icon_state]12"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		name = "Glass of " + reagents.get_master_reagent_name()
	else
		name = "Wine glass"