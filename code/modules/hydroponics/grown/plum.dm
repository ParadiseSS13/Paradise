/obj/item/seeds/plum
	name = "pack of plum seeds"
	desc = "These seeds grow into plum trees."
	icon_state = "seed-plum"
	species = "plum"
	plantname = "Plum Tree"
	product = /obj/item/food/grown/plum
	lifespan = 55
	endurance = 35
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "plum-grow"
	icon_dead = "plum-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("nutriment" = 0.1, "vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/food/grown/plum
	seed = /obj/item/seeds/plum
	name = "plum"
	desc = "A poet's favorite fruit. Noice."
	icon_state = "plum"
	filling_color = "#F6CB0B"
	bitesize = 4
	tastes = list("plum" = 1)
