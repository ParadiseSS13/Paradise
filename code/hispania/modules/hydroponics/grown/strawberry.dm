//These are the seeds
/obj/item/seeds/strawberry
	name = "pack of strawberry"
	desc = "These seeds grow into strawberries."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "strawberry-seeds"
	species = "straw"
	plantname = "Strawberry Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/strawberry
	lifespan = 20
	endurance = 25
	yield = 5
	potency = 46
	maturation = 5
	weed_chance = 25
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)

/obj/item/reagent_containers/food/snacks/grown/strawberry
	seed = /obj/item/seeds/strawberry
	name = "strawberry"
	desc = " The fruit of passion is widely appreciated for its characteristic aroma, bright red color, juicy texture, and sweetness."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "strawberry"
	tastes = list("acid" = 1, "sweet" = 1)
