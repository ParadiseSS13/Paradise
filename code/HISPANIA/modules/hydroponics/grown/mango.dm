//These are the seeds
/obj/item/seeds/mango
	name = "pack of mango"
	desc = "These seeds grow into a miniature mango tree."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "mango-seed"
	species = "mango"
	plantname = "Mango Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/mango
	lifespan = 20
	maturation = 5
	production = 3
	yield = 2
	potency = 30
	weed_chance = 15
	maturation = 7
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("sugar" = 0.12)

/obj/item/reagent_containers/food/snacks/grown/mango
	seed = /obj/item/seeds/mango
	name = "mango"
	desc = "It has an ovoid shape, non-edible rind and variable colour, from of pale yellow to dark red."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "mango"
	tastes = list("sweet" = 1, "juicy"=1)
