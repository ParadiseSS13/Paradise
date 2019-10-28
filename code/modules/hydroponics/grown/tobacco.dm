// Tobacco
/obj/item/seeds/tobacco
	name = "pack of tobacco seeds"
	desc = "These seeds grow into tobacco plants."
	icon_state = "seed-tobacco"
	species = "tobacco"
	plantname = "Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco
	lifespan = 20
	maturation = 5
	production = 5
	yield = 10
	growthstages = 3
	icon_dead = "tobacco-dead"
	mutatelist = list(/obj/item/seeds/tobacco/space)
	reagents_add = list("nicotine" = 0.03, "plantmatter" = 0.03)

/obj/item/reagent_containers/food/snacks/grown/tobacco
	seed = /obj/item/seeds/tobacco
	name = "tobacco leaves"
	desc = "Dry them out to make some smokes."
	icon_state = "tobacco_leaves"
	tastes = list("tobacco" = 1)
	filling_color = "#008000"
	distill_reagent = "creme_de_menthe" //Menthol, I guess.

// Space Tobacco
/obj/item/seeds/tobacco/space
	name = "pack of space tobacco seeds"
	desc = "These seeds grow into space tobacco plants."
	icon_state = "seed-stobacco"
	species = "stobacco"
	plantname = "Space Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco/space
	mutatelist = list()
	reagents_add = list("salbutamol" = 0.05, "nicotine" = 0.08, "plantmatter" = 0.03)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tobacco/space
	seed = /obj/item/seeds/tobacco/space
	name = "space tobacco leaves"
	desc = "Dry them out to make some space-smokes."
	icon_state = "stobacco_leaves"
	tastes = list("space tobacco" = 1)
	distill_reagent = null
	wine_power = 0.5