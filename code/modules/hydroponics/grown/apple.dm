// Apple
/obj/item/seeds/apple
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/apple/gold)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	filling_color = "#FF4500"
	bitesize = 100 // Always eat the apple in one bite
	tastes = list("apple" = 1)
	distill_reagent = "hcider"

// Posioned Apple
/obj/item/seeds/apple/poisoned
	product = /obj/item/reagent_containers/food/snacks/grown/apple/poisoned
	mutatelist = list()
	reagents_add = list("cyanide" = 0.5, "vitamin" = 0.04, "plantmatter" = 0.1)
	rarity = 50 // Source of cyanide, and hard (almost impossible) to obtain normally.

/obj/item/reagent_containers/food/snacks/grown/apple/poisoned
	seed = /obj/item/seeds/apple/poisoned

// Gold Apple
/obj/item/seeds/apple/gold
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/gold
	maturation = 10
	production = 10
	mutatelist = list()
	reagents_add = list("gold" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.1)
	rarity = 40 // Alchemy!

/obj/item/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/apple/gold
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	filling_color = "#FFD700"
	origin_tech = "biotech=4;materials=5"
	distill_reagent = null
	wine_power = 0.5
