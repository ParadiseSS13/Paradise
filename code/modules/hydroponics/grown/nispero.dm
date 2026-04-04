// From Hispania!
//These are the seeds
/obj/item/seeds/nispero
	name = "pack of nispero"
	desc = "These seeds will grow into a small n�spero tree, a small sour-sweet fruit that can also be used to make an alcoholic beverage"
	icon_state = "nispero-seed"
	species = "nispero"
	plantname = "Nispero Tree"
	product = /obj/item/food/grown/nispero
	lifespan = 20
	endurance = 25
	yield = 9
	potency = 25
	maturation = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("vitamin" = 0.06)

/obj/item/food/grown/nispero
	seed = /obj/item/seeds/nispero
	name = "nispero"
	desc = "A small sour-sweet fruit that can also be used to make an alcoholic beverage"
	icon_state = "nispero"
	tastes = list("sour" = 1, "sweet" = 1)