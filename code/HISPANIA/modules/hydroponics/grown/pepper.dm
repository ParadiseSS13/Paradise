//Semilla
/obj/item/seeds/bell_pepper
	name = "pack of bell pepper"
	desc = "These seeds grow into bell peppers."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "bellpepper-seeds"
	species = "bellp"
	plantname = "Bell Pepper Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/bell_pepper
	lifespan = 25
	endurance = 20
	yield = 4
	potency = 3
	maturation = 3
	weed_chance = 35
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list("nutriment" = 0.14, "sugar" = 0.12)

//Fruta
/obj/item/reagent_containers/food/snacks/grown/bell_pepper
	seed = /obj/item/seeds/bell_pepper
	name = "bell pepper"
	desc = "The bell pepper is the fruit of plants in the Grossum cultivar group of the species Capsicum annuum."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "bellpepper"
	tastes = list("fruity" = 1)
