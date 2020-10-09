/obj/item/seeds/chanter/champignon
	name = "pack of champignon"
	desc = "A pack of delicious champignons, perfect for pizza."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "champignon-seed"
	species = "champ"
	plantname = "Champignon Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/chanter/champignon
	mutatelist = list()
	lifespan = 55
	endurance = 35
	yield = 5
	potency = 30
	maturation = 5
	growing_icon = 'icons/hispania/obj/hydroponics/growing_mushrooms.dmi'

/obj/item/reagent_containers/food/snacks/grown/chanter/champignon
	seed = /obj/item/seeds/chanter/champignon
	name = "champignon"
	desc = "An edible mushroom, especially the much cultivated species Agaricus bisporus."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "champignon"
	tastes = list("chewy" = 1)
