//Semilla
/obj/item/seeds/peach
	name = "pack of peach"
	desc = "These seeds grow into thicc juicy bouncy peaches."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "peach-seed"
	species = "peach"
	plantname = "Peach Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/peach
	lifespan = 20
	endurance = 25
	yield = 9
	potency = 45
	maturation = 4
	weed_chance = 45
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list("vitamin" = 0.06)

//Fruta
/obj/item/reagent_containers/food/snacks/grown/peach
	seed = /obj/item/seeds/peach
	name = "peach"
	desc = "The peach is a round, coloured, juicy fruit, typically eaten in summer."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "peach"
	tastes = list("deliciously sweet" = 1)
