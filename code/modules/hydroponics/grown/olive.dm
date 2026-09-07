// Olives!
/obj/item/seeds/olive
	name = "pack of olive seeds"
	desc = "These seeds grow into olive trees."
	icon_state = "seed-olive"
	species = "olive"
	plantname = "Olive Tree"
	product = /obj/item/food/grown/olive
	lifespan = 150
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list()
	reagents_add = list("vitamin" = 0.02, "plantmatter" = 0.2, "sodiumchloride" = 0.2)

/obj/item/food/grown/olive
	seed = /obj/item/seeds/olive
	name = "olive"
	desc = "A small cylindrical salty fruit closely related to mangoes. Can be ground into a paste and mixed with water to make quality oil."
	icon_state = "olive"
	tastes = list("olive" = 1)
	wine_power = 0.4
