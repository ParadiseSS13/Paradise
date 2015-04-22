/datum/seed/tomato/explosive
	name = "explosivetomato"
	seed_name = "seething tomato"
	display_name = "seething tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomatoexplosive)
	packet_icon = "seed-explosivetomato"
	plant_icon = "explosivetomato"
	chems = list("blackpowder" = list(1,10))
	yield = 3

/obj/item/seeds/explosivetomatoseed
	seed_type = "explosivetomato"

/datum/seed/wheat/steel
	name = "steelwheat"
	seed_name = "steel wheat"
	display_name = "steel wheat stalks"
	packet_icon = "seed-steelwheat"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/steelwheat)
	plant_icon = "steelwheat"
	mutants = null
	chems = list("iron" = list(1,25))
	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5

/obj/item/seeds/steelwheatseed
	seed_type = "steelwheat"