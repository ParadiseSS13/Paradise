//Semillas
/obj/item/seeds/kiwi
	name = "pack of kiwi seeds"
	desc = "These seeds grow into kiwi bushes"
	icon_state = "kiwi-seeds"
	species = "kiwi"
	plantname = "Kiwi Tree"
	product = /obj/item/food/grown/kiwi
	lifespan = 20
	production = 5
	yield = 2
	weed_chance = 15
	maturation = 4
	potency = 30
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	// mutatelist = list(/obj/item/seeds/kiwi/actual_kiwi) do later, converting simple animal to basic mob
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list("sugar" = 0.12)

//Frutas

/obj/item/food/grown/kiwi
	seed = /obj/item/seeds/kiwi
	name = "kiwi"
	desc = "Is a fruit of ovoid shape, of variable size and covered with a brown fuzzy thin skin"
	icon_state = "kiwi"
	tastes = list("sour" = 1, "sweet" = 1)