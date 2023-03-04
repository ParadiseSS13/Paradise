// Soybeans
/obj/item/seeds/soya
	name = "pack of soybean seeds"
	desc = "These seeds grow into soybean plants."
	icon_state = "seed-soybean"
	species = "soybean"
	plantname = "Soybean Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/soybeans
	maturation = 4
	production = 4
	potency = 15
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "soybean-grow"
	icon_dead = "soybean-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/soya/koi)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.05, "soybeanoil" = 0.03)

/obj/item/reagent_containers/food/snacks/grown/soybeans
	seed = /obj/item/seeds/soya
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	filling_color = "#F0E68C"
	bitesize_mod = 2
	tastes = list("soy" = 1)
	wine_power = 0.2

// Koibean
/obj/item/seeds/soya/koi
	name = "pack of koibean seeds"
	desc = "These seeds grow into koibean plants."
	icon_state = "seed-koibean"
	species = "koibean"
	plantname = "Koibean Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/koibeans
	potency = 10
	mutatelist = list()
	reagents_add = list("carpotoxin" = 0.1, "vitamin" = 0.04, "plantmatter" = 0.05)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/koibeans
	seed = /obj/item/seeds/soya/koi
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	filling_color = "#F0E68C"
	bitesize_mod = 2
	tastes = list("koi" = 1)
	wine_power = 0.4

// Olives
/obj/item/seeds/soya/olive
	name = "pack of olives seeds"
	desc = "These seeds grow into olive plants."
	icon_state = "seed-olive"
	species = "olives"
	plantname = "Olive Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/olive
	icon_grow = "olives-grow"
	icon_dead = "olives-dead"
	icon_harvest = "olives-harvest"
	mutatelist = list(/obj/item/seeds/soya/olive/charc)

/obj/item/reagent_containers/food/snacks/grown/olive
	seed = /obj/item/seeds/soya/olive
	name = "olives"
	desc = "Hate it or like it..."
	icon_state = "olives"
	filling_color = "#161220"
	tastes = list("olive" = 1)

/obj/item/seeds/soya/olive/charc
	name = "pack of charcolives seeds"
	desc = "These seeds grow into charcolive plants."
	icon_state = "seed-charcolive"
	species = "charcolives"
	plantname = "Charcolive Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/olive/charc
	icon_grow = "charcolives-grow"
	icon_dead = "charcolives-dead"
	icon_harvest = "charcolives-harvest"
	reagents_add = list("charcoal" = 0.4, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/olive/charc
	seed = /obj/item/seeds/soya/olive/charc
	name = "charcolives"
	icon_state = "charcolives"
	filling_color = "#000000"
	tastes = list("charcoal" = 1)
