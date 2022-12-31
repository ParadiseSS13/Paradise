// cucumber
/obj/item/seeds/cucumber
	name = "pack of cucumber seeds"
	desc = "These seeds grow into cucumber plants."
	icon_state = "seed-cucumber"
	species = "cucumber"
	plantname = "cucumber Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/cucumber
	lifespan = 40
	endurance = 70
	potency = 30
	yield = 5
	maturation = 8
	weed_rate = 4
	growthstages = 2
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "cucumber-grow"
	icon_dead = "cucumber-dead"
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("water" = 0.15, "kelotane" = 0.04, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/cucumber
	seed = /obj/item/seeds/cucumber
	name = "cucumber"
	desc = "Сила земли!"
	icon_state = "cucumber"
	splat_type = /obj/effect/decal/cleanable/plant_smudge
	filling_color = "#47FF91"
	tastes = list("cucumber" = 1)
	bitesize_mod = 2
	distill_reagent = "enzyme"
