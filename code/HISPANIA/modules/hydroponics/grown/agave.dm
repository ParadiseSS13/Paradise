//Semilla
/obj/item/seeds/agave
	name = "pack of agave"
	desc = "These seeds grow into agave, used to create tequila."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "agave-seed"
	species = "agave"
	plantname = "Agave Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/agave
	lifespan = 30
	endurance = 40
	yield = 5
	potency = 30
	maturation = 5
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'

//Fruta
/obj/item/reagent_containers/food/snacks/grown/agave
	seed = /obj/item/seeds/agave
	name = "agave"
	desc = "Used to create tequila."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "agave"
	wine_power = 0.5
	tastes = list("bland" = 1)
