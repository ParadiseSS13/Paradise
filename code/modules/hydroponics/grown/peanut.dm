// Peanuts
/obj/item/seeds/peanuts
	name = "pack of peanut seeds"
	desc = "These seeds grow into peanuts."
	icon_state = "seed-potato"
	species = "potato"
	plantname = "Peanut Vines"
	product = /obj/item/reagent_containers/food/snacks/grown/peanuts
	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "potato-grow"
	icon_dead = "potato-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/peanuts
	seed = /obj/item/seeds/peanuts
	name = "patch of peanuts"
	desc = "Best avoided if you have spess allergies."
	icon_state = "peanuts"
	gender = PLURAL