/obj/item/seeds/strawberry
	name = "pack of strawberry seeds"
	desc = "These seeds grow into strawberries."
	icon_state = "seed-strawberry"
	species = "strawberry"
	plantname = "Strawberry Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/strawberry
	potency = 30
	lifespan = 40
	maturation = 5
	production = 3
	yield = 3
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "strawberry-grow"
	icon_dead = "strawberry-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("vitamin" = 0.1, "plantmatter" = 0.1, "water" = 0.04)

/obj/item/reagent_containers/food/snacks/grown/strawberry
	seed = /obj/item/seeds/strawberry
	name = "strawberry"
	desc = "A delicious, little fruit, full of vitamin C!"
	icon_state = "strawberry"
	tastes = list("strawberry" = 3, "sweetness" = 1)
	gender = PLURAL
	bitesize = 2
