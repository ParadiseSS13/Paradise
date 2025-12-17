// cassava root
/obj/item/seeds/cassava
	name = "pack of cassava seeds"
	desc = "These seeds grow into Cassava."
	icon_state = "seed-cassava"
	species = "cassava"
	plantname = "Cassava"
	product = /obj/item/food/grown/cassava
	lifespan = 50
	endurance = 35
	yield = 5
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "cassava-grow"
	icon_dead = "cassava-dead"
	mutatelist = list(/obj/item/seeds/cassava/iron)
	reagents_add = list("tapioca" = 0.4, "nutriment" = 0.1)

/obj/item/food/grown/cassava
	seed = /obj/item/seeds/cassava
	name = "cassava root"
	desc = "The root of the cassava plant. Nice."
	icon_state = "cassava"
	filling_color = "#d1d1bcff"
	bitesize = 5
	tastes = list("dirt" = 0.75, "starch" = 0.25)

// Cast-ava root (cast iron, i really was trying to think of puns for this but :shrug:)
/obj/item/seeds/cassava/iron
	name = "pack of cast-ava seeds."
	desc = "These grow into cassava that are made of softened cast-iron steel."
	species = "ironcassava"
	plantname = "Cast-ava"
	product = /obj/item/food/grown/cassava/iron
	mutatelist = list()
	reagents_add = list("nutriment" = 0.4, "tapioca" = 0.1)

/obj/item/food/grown/cassava/iron
	seed = /obj/item/seeds/cassava/iron
	name = "cast-ava root"
	desc = "A cassava root that looks like it was forged out of cast-iron."
	icon_state = "ironcassava"
	filling_color = "#333333ff"
	distill_reagent = null
