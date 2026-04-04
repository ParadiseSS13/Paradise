// From Hispania!
//These are the seeds
/obj/item/seeds/mate
	name = "pack of mate"
	desc = "These seeds will grow into a mate plant, grow it before it's cool."
	icon_state = "mate-seed"
	species = "mate"
	plantname = "Mate Bush"
	product = /obj/item/food/grown/mate
	lifespan = 55
	endurance = 35
	yield = 5
	potency = 30
	maturation = 4
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'

/obj/item/food/grown/mate
	seed = /obj/item/seeds/mate
	name = "mate"
	desc = "Very hipster"
	icon_state = "mate"
	tastes = list("bitter" = 1 , "hipstery" = 1)