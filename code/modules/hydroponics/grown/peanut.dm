// Peanuuts
/obj/item/seeds/peanuts
	name = "pack of peanut seeds"
	desc = "These seeds grow into peanuts."
	icon_state = "seed-peanut"
	species = "potato"
	plantname = "Peanut Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/peanuts
	maturation = 6
	production = 6
	yield = 6
	potency = 10
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "potato-grow"
	icon_dead = "potato-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("plantmatter" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/peanuts
	seed = /obj/item/seeds/peanuts
	name = "patch of peanuts"
	desc = "Best avoided if you have spess allergies."
	icon_state = "peanuts"
	gender = PLURAL