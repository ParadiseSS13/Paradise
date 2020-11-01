//Semilla
/obj/item/seeds/ricinus
	name = "pack of ricinu"
	desc = "These seeds will grow into a castor oil plant, used for extracting castor oil... And nothing else."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "ricinus-seeds"
	species = "ricinus"
	plantname = "Ricinus Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/ricinus
	lifespan = 30
	endurance = 25
	yield = 5
	potency = 37
	maturation = 4
	growing_icon = 'icons/hispania/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("sugar" = 0.12)

//Fruta
/obj/item/reagent_containers/food/snacks/grown/ricinus
	seed = /obj/item/seeds/ricinus
	name = "ricinus"
	desc = "Ricinus communis, the castor bean or castor oil plant, is a species of perennial flowering plant"
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "ricinus"
	tastes = list("beans" = 1)
