/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/champagne
	name = "Champagne flute"
	desc = "A glass on a foot used to serve Champagne. Let's celebrate and suck some..."
	icon = 'hyntatmta/icons/obj/reagent_containers.dmi'
	icon_state = "glass-champagne"
	volume = 20
	materials = list(MAT_GLASS=100)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/champagne/on_reagent_change()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('hyntatmta/icons/obj/reagentfillings.dmi', src, "[icon_state]1")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 25)
				filling.icon_state = "[icon_state]1"
			if(26 to 75)
				filling.icon_state = "[icon_state]5"
			if(76 to INFINITY)
				filling.icon_state = "[icon_state]12"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		name = "Flute of " + reagents.get_master_reagent_name()
	else
		name = "Champagne flute"