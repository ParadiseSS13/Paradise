// From Hispania!
//These are the seeds
/obj/item/seeds/mate
	name = "pack of mate"
	desc = "These seeds will grow into a mate plant, famous for its bitter herbal tea."
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
	reagents_add = list("mate" = 0.2,)

/obj/item/food/grown/mate
	seed = /obj/item/seeds/mate
	name = "mate"
	desc = "It has a very earthy smell."
	icon_state = "mate"
	tastes = list("bitterness" = 1 , "earthiness" = 1)
