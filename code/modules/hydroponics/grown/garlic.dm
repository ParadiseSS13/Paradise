/obj/item/seeds/garlic
	name = "pack of garlic seeds"
	desc = "A packet of extremely pungent seeds."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "garlic-seeds"
	species = "garlic"
	plantname = "Garlic Sprouts"
	product = /obj/item/reagent_containers/food/snacks/grown/garlic
	yield = 6
	potency = 25
	growthstages = 7
	growing_icon = 'icons/hispania/obj/hydroponics/growing_flowers.dmi'
	reagents_add = list("garlicpaste" = 0.14, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/garlic
	seed = /obj/item/seeds/garlic
	name = "garlic"
	desc = "Delicious, but with a potentially overwhelming odor."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "garlic"
	filling_color = "#C0C9A0"
	bitesize_mod = 2
	tastes = list("garlic" = 1)
	wine_power = 0.1
