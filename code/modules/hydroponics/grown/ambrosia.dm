// Ambrosia - base type
/obj/item/reagent_containers/food/snacks/grown/ambrosia
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = SLOT_HEAD
	filling_color = "#008000"
	bitesize_mod = 2

// Ambrosia Vulgaris
/obj/item/seeds/ambrosia
	name = "pack of ambrosia vulgaris seeds"
	desc = "These seeds grow into common ambrosia, a plant grown by and from medicine."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	lifespan = 60
	endurance = 25
	yield = 6
	potency = 5
	icon_dead = "ambrosia-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/ambrosia/deus)
	reagents_add = list("space_drugs" = 0.15, "bicaridine" = 0.1, "kelotane" = 0.1, "vitamin" = 0.04, "plantmatter" = 0.05, "toxin" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	origin_tech = "biotech=2"
	wine_power = 0.2

// Ambrosia Deus
/obj/item/seeds/ambrosia/deus
	name = "pack of ambrosia deus seeds"
	desc = "These seeds grow into ambrosia deus. Could it be the food of the gods..?"
	icon_state = "seed-ambrosiadeus"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/deus
	mutatelist = list(/obj/item/seeds/ambrosia/gaia)
	reagents_add = list("weak_omnizine" = 0.15, "synaptizine" = 0.15, "space_drugs" = 0.1, "vitamin" = 0.04, "plantmatter" = 0.05)
	rarity = 40

/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosia/deus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"
	origin_tech = "biotech=4;materials=3"
	wine_power = 0.5

//Ambrosia Gaia
/obj/item/seeds/ambrosia/gaia
	name = "pack of ambrosia gaia seeds"
	desc = "These seeds grow into ambrosia gaia, filled with infinite potential."
	icon_state = "seed-ambrosia_gaia"
	species = "ambrosia_gaia"
	plantname = "Ambrosia Gaia"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia
	mutatelist = list()
	reagents_add = list("earthsblood" = 0.05, "nutriment" = 0.06, "vitamin" = 0.05)
	rarity = 30 //These are some pretty good plants right here
	genes = list()
	weed_rate = 4
	weed_chance = 100

/obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia
	name = "ambrosia gaia branch"
	desc = "Eating this <i>makes</i> you immortal."
	icon_state = "ambrosia_gaia"
	filling_color = rgb(255, 175, 0)
	origin_tech = "biotech=6;materials=5"
	light_range = 3
	seed = /obj/item/seeds/ambrosia/gaia
	wine_power = 0.7
	wine_flavor = "the earthmother's blessing"

// Ambrosia Cruciatus
/obj/item/seeds/ambrosia/cruciatus
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/cruciatus
	potency = 10
	mutatelist = list()
	reagents_add = list("thc" = 0.15, "kelotane" = 0.15, "bicaridine" = 0.1, "bath_salts" = 0.20, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/ambrosia/cruciatus
	seed = /obj/item/seeds/ambrosia/cruciatus
	wine_power = 0.7