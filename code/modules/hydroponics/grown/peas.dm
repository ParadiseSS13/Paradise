// Finally, peas. Base plant.
/obj/item/seeds/peas
	name = "pack of pea pods"
	desc = "These seeds grows into vitamin rich peas!"
	icon_state = "seed-peas"
	species = "peas"
	plantname = "Pea Vines"
	product = /obj/item/reagent_containers/food/snacks/grown/peas
	maturation = 3
	potency = 25
	weed_rate = 3
	weed_chance = 10
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "peas-grow"
	icon_dead = "peas-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/peas/laugh)
	reagents_add = list ("vitamin" = 0.1, "nutriment" = 0.05, "water" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/peas
	seed = /obj/item/seeds/peas
	name = "peapod"
	desc = "Finally... peas."
	icon_state = "peas"
	tastes = list ("peas" = 1, "chalky saltiness" = 1)
	wine_power = 50
	wine_flavor = "what is, distressingly, fermented peas."

// Laughin' Peas
/obj/item/seeds/peas/laugh
	name = "pack of laughin' peas"
	desc = "These seeds give off a very soft purple glow.. they should grow into Laughin' Peas."
	icon_state = "seed-laughpeas"
	species = "laughpeas"
	plantname = "Laughin' Peas"
	product = /obj/item/reagent_containers/food/snacks/grown/peaslaugh
	maturation = 7
	potency = 10
	yield = 7
	production = 5
	growthstages = 3
	weed_chance = 15
	icon_grow = "laughpeas-grow"
	icon_dead = "laughpeas-dead"
	genes = list (/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/purple, /datum/plant_gene/trait/plant_laughter)
	mutatelist = list (/obj/item/seeds/peas/laugh/peace)
	reagents_add = list ("laughter" = 0.05, "sugar" = 0.05, "nutriment" = 0.07)
	rarity = 25 //It actually might make Central Command Officials loosen up a smidge, eh?

/obj/item/reagent_containers/food/snacks/grown/peaslaugh
	seed = /obj/item/seeds/peas/laugh
	name = "pod of laughin' peas"
	desc = "Ridens Cicer, guaranteed to improve your mood dramatically upon consumption!"
	icon_state = "laughpeas"
	tastes = list ("a prancing rabbit" = 1) //Vib Ribbon sends her regards.. wherever she is.
	wine_power = 90
	wine_flavor = "a vector-graphic rabbit dancing on your tongue"

// World Peas - Peace at last, peace at last...
/obj/item/seeds/peas/laugh/peace
	name = "pack of world peas"
	desc = "These rather large seeds give off a soothing blue glow..."
	icon_state = "seed-worldpeas"
	species = "worldpeas"
	plantname = "World Peas"
	product = /obj/item/reagent_containers/food/snacks/grown/peaspeace
	maturation = 15
	potency = 75
	yield = 1
	production = 10
	weed_chance = 25
	growthstages = 3
	icon_grow = "worldpeas-grow"
	icon_dead = "worldpeas-dead"
	genes = list (/datum/plant_gene/trait/glow/blue)
	reagents_add = list ("fomepizole" = 0.1, "love" = 0.1, "nutriment" = 0.15)
	rarity = 50 // This absolutely will make even the most hardened Syndicate Operators relax.
	mutatelist = null

/obj/item/reagent_containers/food/snacks/grown/peaspeace
	seed = /obj/item/seeds/peas/laugh/peace
	name = "cluster of world peas"
	desc = "A plant discovered through extensive genetic engineering, and iterative graft work. It's rumored to bring peace to any who consume it. In the wider AgSci community, it's attained the nickname of 'Pax Mundi'." //at last... world peas. I'm not sorry.
	icon_state = "worldpeas"
	bitesize = 100
	tastes = list ("numbing tranquility" = 2, "warmth" = 1)
	wine_power = 100
	wine_flavor = "mind-numbing peace and warmth"
