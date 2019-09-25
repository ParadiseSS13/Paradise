// Chili
/obj/item/seeds/chili
	name = "pack of chili seeds"
	desc = "These seeds grow into chili plants. HOT! HOT! HOT!"
	icon_state = "seed-chili"
	species = "chili"
	plantname = "Chili Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/chili
	lifespan = 20
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "chili-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "chili-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/chili/ice, /obj/item/seeds/chili/ghost)
	reagents_add = list("capsaicin" = 0.25, "vitamin" = 0.04, "plantmatter" = 0.04)

/obj/item/reagent_containers/food/snacks/grown/chili
	seed = /obj/item/seeds/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"
	bitesize_mod = 2
	tastes = list("chili" = 1)
	wine_power = 0.2

// Ice Chili
/obj/item/seeds/chili/ice
	name = "pack of chilly pepper seeds"
	desc = "These seeds grow into chilly pepper plants."
	icon_state = "seed-icepepper"
	species = "chiliice"
	plantname = "Chilly Pepper Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/icepepper
	lifespan = 25
	maturation = 4
	production = 4
	rarity = 20
	mutatelist = list()
	reagents_add = list("frostoil" = 0.25, "vitamin" = 0.02, "plantmatter" = 0.02)

/obj/item/reagent_containers/food/snacks/grown/icepepper
	seed = /obj/item/seeds/chili/ice
	name = "chilly pepper"
	desc = "It's a mutant strain of chili"
	icon_state = "icepepper"
	filling_color = "#0000CD"
	bitesize_mod = 2
	origin_tech = "biotech=4"
	tastes = list("chilly" = 1)
	wine_power = 0.3

// Ghost Chili
/obj/item/seeds/chili/ghost
	name = "pack of ghost chili seeds"
	desc = "These seeds grow into a chili said to be the hottest in the galaxy."
	icon_state = "seed-chilighost"
	species = "chilighost"
	plantname = "Ghost Chili Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/ghost_chili
	endurance = 10
	maturation = 10
	production = 10
	yield = 3
	rarity = 20
	mutatelist = list()
	reagents_add = list("condensedcapsaicin" = 0.3, "capsaicin" = 0.55, "plantmatter" = 0.04)

/obj/item/reagent_containers/food/snacks/grown/ghost_chili
	seed = /obj/item/seeds/chili/ghost
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	filling_color = "#F8F8FF"
	bitesize_mod = 4
	origin_tech = "biotech=4;magnets=5"
	tastes = list("ghost chili" = 1)
	wine_power = 0.5
